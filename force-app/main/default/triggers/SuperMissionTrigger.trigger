trigger SuperMissionTrigger on Superhero_Mission__c (after insert) {
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            SuperMissionTriggerHandler.notifyHeroesAboutNewMissions(Trigger.new);
        }
    }
}