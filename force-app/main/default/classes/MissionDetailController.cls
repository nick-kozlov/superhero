public without sharing class MissionDetailController {

    @AuraEnabled
    public static String getHeroMissionAssignments(){
        try {
            Id userId = UserInfo.getUserId();

            User user = [
                SELECT
                    Id,
                    ContactId
                FROM User
                WHERE Id =: userId
                LIMIT 1
            ];

            Hero__c hero = [
                SELECT
                    Id,
                    Name,
                    Contact__c,
                    Guild__c,
                    Rank__c
                FROM Hero__c
                WHERE Contact__c =: user.ContactId
                LIMIT 1
            ];

            List<Mission_Assignment__c> missionAssignments = [
                SELECT
                    Id,
                    Hero__c,
                    Mission__c,
                    Mission__r.Complexity_Rank__c,
                    Mission__r.Status__c,
                    Mission__r.Is_Public__c,
                    Status__c
                FROM Mission_Assignment__c
                WHERE Hero__c =: hero.Id
            ];

            return JSON.serialize(new HeroWrapper(hero, missionAssignments));

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void createMissionAssignment(String heroId, String missionId){
        try {
            insert new Mission_Assignment__c(
                Hero__c = heroId,
                Mission__c = missionId
            );
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void completeMission(String missionAssignmentId){
        try {
            Mission_Assignment__c missionAssignment = [
                SELECT
                    Id,
                    Status__c,
                    Mission__c
                FROM Mission_Assignment__c
                WHERE Id =: missionAssignmentId
                LIMIT 1
            ];

            missionAssignment.Status__c = Constants.STATUS_COMPLETED;

            update missionAssignment;

            updateMissionStatusToCompleted(missionAssignment.Mission__c);
            updateOtherMAStatusesToFailed(missionAssignment.Id, missionAssignment.Mission__c);

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static void updateMissionStatusToCompleted(Id missionId) {

        String emailTextBody = 'Mission completed: ';

        Superhero_Mission__c mission = [
            SELECT
                Id,
                CreatedById,
                CreatedBy.Email,
                Status__c,
                Subject__c
            FROM Superhero_Mission__c
            WHERE Id =: missionId
        ];

        if (mission.Status__c == Constants.STATUS_AVAILABLE) {
            mission.Status__c = Constants.STATUS_COMPLETED;
            emailTextBody += mission.Subject__c;
        }

        update mission;

        sendEmailToMissionOwner(mission.CreatedBy.Email, mission.CreatedById, emailTextBody);
    }

    public static void sendEmailToMissionOwner(String ownerEmail, String ownerId, String emailTextBody) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

        email.setTargetObjectId(ownerId);
        email.setSaveAsActivity(false);
        email.setSubject('Mission completed!');
        email.setPlainTextBody(emailTextBody);
        email.setToAddresses(new List<String>{ownerEmail});

        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});
    }

    public static void updateOtherMAStatusesToFailed(String maId, String missionId) {

        List<Mission_Assignment__c> missionAssignmentsToUpdate = new List<Mission_Assignment__c>();

        List<Mission_Assignment__c> mas = [
            SELECT
                Id,
                Mission__c,
                Status__c
            FROM Mission_Assignment__c
            WHERE Id !=: maId
                AND Mission__c =: missionId
        ];

        for (Mission_Assignment__c ma : mas) {
            if (ma.Status__c == Constants.STATUS_IN_PROGRESS) {
                ma.Status__c = Constants.STATUS_FAILED;
                missionAssignmentsToUpdate.add(ma);
            }
        }

        update missionAssignmentsToUpdate;
    }

    public class HeroWrapper {
        public String heroId    { get; set; }
        public String name      { get; set; }
        public String rank      { get; set; }
        public String contactId { get; set; }
        public String guildId   { get; set; }
        public List<Mission_Assignment__c> missionAssignments { get; set; }
        public Integer numberOfActiveMissions { get; set; }

        public HeroWrapper(Hero__c hero, List<Mission_Assignment__c> missionAssignments) {
            this.heroId = hero.Id;
            this.name = hero.Name;
            this.rank = hero.Rank__c;
            this.contactId = hero.Contact__c;
            this.guildId = hero.Guild__c;
            this.missionAssignments = missionAssignments;

            List<Mission_Assignment__c> activeMissionAssignments = new List<Mission_Assignment__c>();

            for(Mission_Assignment__c ma : missionAssignments) {
                if (ma.Status__c == Constants.STATUS_IN_PROGRESS) {
                    activeMissionAssignments.add(ma);
                }
            }
            this.numberOfActiveMissions = activeMissionAssignments.size();
        }
    }
}