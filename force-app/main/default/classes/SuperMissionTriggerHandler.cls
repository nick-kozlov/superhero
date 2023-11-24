public with sharing class SuperMissionTriggerHandler {

    public static void notifyHeroesAboutNewMissions(List<Superhero_Mission__c> newMissions) {

        List<Superhero_Mission__c> publicMissions = new List<Superhero_Mission__c>();
        List<Superhero_Mission__c> guildMissions = new List<Superhero_Mission__c>();

        for (Superhero_Mission__c mission : newMissions) {
            if (mission.Is_Public__c == true) {
                publicMissions.add(mission);
            } else {
                guildMissions.add(mission);
            }
        }

        if (!guildMissions.isEmpty()) {
            EmailService.sendEmailsToGuildHeroes(guildMissions);
        }

        if (!publicMissions.isEmpty()) {
            EmailService.sendEmailsToAllHeroes(publicMissions);
        }

    }
}