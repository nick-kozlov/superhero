public class SendEmailsToAllHeroesBatch implements Database.Batchable<sObject>{

    public final String emailBody;
    private String query = 'SELECT Id, Contact__r.Email FROM Hero__c';

    public SendEmailsToAllHeroesBatch(String message) {
        emailBody = message;
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Hero__c> heroes){
        List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
        Map<String,Id> emailToUserIdMap = EmailService.getEmailToUserIdMap(heroes);

        for (Hero__c hero : heroes) {
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

    public void finish(Database.BatchableContext BC){}
}