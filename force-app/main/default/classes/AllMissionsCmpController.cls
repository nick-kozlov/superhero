public without sharing class AllMissionsCmpController {

    @AuraEnabled
    public static List<Superhero_Mission__c> getAllMissions() {

        Id userId = UserInfo.getUserId();

        User user = [
            SELECT
                Id,
                ContactId
            FROM User
            WHERE Id =: userId
            LIMIT 1
        ];

        Id guildId = [
            SELECT
                Id,
                Guild__c
            FROM Hero__c
            WHERE Contact__c =: user.ContactId
            LIMIT 1
        ].Guild__c;

        return [
            SELECT
                Id,
                Complexity_Rank__c,
                Deadline__c,
                Details__c,
                Guild__r.Name,
                Reward__c,
                Status__c,
                Subject__c,
                Is_Public__c
            FROM Superhero_Mission__c
            WHERE Is_Public__c = true
                OR Guild__c =: guildId
            ORDER BY CreatedDate DESC
        ];
    }
}