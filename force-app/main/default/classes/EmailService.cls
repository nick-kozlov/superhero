public with sharing class EmailService {

    public static void sendEmailsToGuildHeroes(List<Superhero_Mission__c> newGuildMissions) {
        Set<Id> guildIds = new Set<Id>();
        String emailBody = 'New missions: ';
        List<String> missionSubjects = new List<String>();

        for (Superhero_Mission__c mission : newGuildMissions) {
            guildIds.add(mission.Guild__c);
            missionSubjects.add(mission.Subject__c);
        }

        emailBody = emailBody + String.join(missionSubjects, ', ');

        List<Hero__c> guildHeroes = [
            SELECT
                Id,
                Contact__r.Email
            FROM Hero__c
            WHERE Guild__c IN: guildIds
        ];

        Map<String,Id> emailToUserIdMap = getEmailToUserIdMap(guildHeroes);
        List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();

        for (Hero__c hero : guildHeroes) {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

            if (emailToUserIdMap.get(hero.Contact__r.Email) != null) {
                email.setTargetObjectId(emailToUserIdMap.get(hero.Contact__r.Email));
                email.setSaveAsActivity(false);
            }
            email.setSubject('New Missions!');
            email.setPlainTextBody(emailBody);
            email.setToAddresses(new List<String>{hero.Contact__r.Email});

            emailMessages.add(email);
        }

        Messaging.sendEmail(emailMessages);
    }

    public static void sendEmailsToAllHeroes(List<Superhero_Mission__c> newPublicMissions) {
        String emailBody = 'New missions: ';
        List<String> missionSubjects = new List<String>();

        for (Superhero_Mission__c mission : newPublicMissions) {
            missionSubjects.add(mission.Subject__c);
        }

        emailBody = emailBody + String.join(missionSubjects, ', ');

        Database.executeBatch(new SendEmailsToAllHeroesBatch(emailBody), 1);
    }

    public static Map<String,Id> getEmailToUserIdMap(List<Hero__c> heroes) {
        Set<Id> contactIds = new Set<Id>();
        Map<String,Id> emailToUserIdMap = new Map<String,Id>();

        for (Hero__c hero : heroes) {
            contactIds.add(hero.Contact__c);
        }

        List<User> users = [
            SELECT
                Id,
                Email
            FROM User
            WHERE ContactId IN: contactIds
        ];

        for(User user : users) {
            emailToUserIdMap.put(user.Email, user.Id);
        }

        return emailToUserIdMap;
    }
}