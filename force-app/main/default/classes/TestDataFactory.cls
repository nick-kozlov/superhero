public with sharing class TestDataFactory {

    public static Account createAccount() {

        Account acc = new Account(Name = 'TestAcc');

        insert acc;

        return acc;
    }

    public static User createCommunityUser(Id accId) {
        Contact contact = new Contact(LastName = 'Test', Email = 'testemail@test.com', AccountID = accId);

        insert contact;

        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Customer Community user' LIMIT 1];

        User user = new User(
            UserName = 'test_' + math.random() + '@test.com',
            FirstName = 'TestFirst',
            LastName = 'TestLast',
            Alias = 'test',
            Email = 'testemail@test.com',
            CommunityNickName = string.valueOf(math.random()).substring(0,6),
            ProfileID = profile.id,
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ContactID = contact.Id
        );

        insert user;

        return user;
    }

    public static List<Guild__c> createGuilds(Integer numberOfGuilds) {
        List<Guild__c> guilds = new List<Guild__c>();

        for (Integer i = 0; i < numberOfGuilds; i++) {
            guilds.add(new Guild__c(Name = 'TestGuild' + i));
        }

        insert guilds;

        return guilds;
    }

    public static Superhero_Mission__c createSuperHeroMission(Boolean isPublic, Id guildId, Boolean doInsert) {
        Superhero_Mission__c superMission = new Superhero_Mission__c(
            Complexity_Rank__c = 'B',
            Deadline__c = Date.today().addDays(10),
            Details__c = 'Test',
            Guild__c = guildId,
            Is_Public__c = isPublic,
            Reward__c = 100,
            Subject__c = 'TestMission1'
        );

        if (doInsert == true) {
            insert superMission;
        }

        return superMission;
    }

    public static void createHero(Id contactId, Id guildId, Boolean doInsert) {
        Hero__c hero = new Hero__c(
            Name = 'TestHero',
            Rank__c = 'B',
            Contact__c = contactId,
            Guild__c = guildId
        );

        if (doInsert == true) {
            insert hero;
        }
    }

    public static void assignPermissionSet(Id userId, String psName) {
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name =: psName];

        insert new PermissionSetAssignment(
            PermissionSetId = ps.Id,
            AssigneeId = userId
        );
    }
}