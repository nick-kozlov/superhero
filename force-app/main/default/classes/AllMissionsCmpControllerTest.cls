@isTest
private with sharing class AllMissionsCmpControllerTest {

    @TestSetup
    private static void makeData(){
        Account acc = TestDataFactory.createAccount();
        User user = TestDataFactory.createCommunityUser(acc.Id);
        List<Guild__c> guilds = TestDataFactory.createGuilds(2);
        TestDataFactory.createHero(user.ContactId, guilds[0].Id, true);

        Superhero_Mission__c sm1 = TestDataFactory.createSuperHeroMission(false, guilds[0].Id, false);
        Superhero_Mission__c sm2 = TestDataFactory.createSuperHeroMission(true, guilds[1].Id, false);

        insert new List<Superhero_Mission__c> {sm1, sm2};
    }

    @isTest
    private static void getAllMissionsTest(){
        List<Superhero_Mission__c> missions = new List<Superhero_Mission__c>();
        User communityUser = [
            SELECT Id
            FROM User
            WHERE LastName = 'TestLast'
        ];

        TestDataFactory.assignPermissionSet(communityUser.Id, 'Hero_User');

        System.runAs(communityUser) {
            missions = AllMissionsCmpController.getAllMissions();
        }

        Assert.areEqual(2, missions.size(), 'Expected 2 missions');
    }
}