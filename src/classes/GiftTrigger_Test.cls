@isTest(SeeAllData = true)
public class GiftTrigger_Test {

    class TestFactory {

        Integer recordCount { get; set; }
        List<String> affiliateNameList { get; set; }
        List<causeview__Gift__c> testGiftList { get; set; }
        Map<String, String> emailAddressByAffiliateMap { get; set; }
        Map<String, Id> userIdByAffiliateMap { get; set; }

        TestFactory(Integer count) {
            recordCount = count;
            setAffiliateNameList();
            setTestGiftList();
        }

        public Map<Id, causeview__Gift__c> getTestGiftMap() {
            insert testGiftList;
            return new Map<Id, causeview__Gift__c>(testGiftList);
        }

        public List<causeview__Gift__c> getTestGiftList() {
            return testGiftList;
        }

        public List<String> getAffiliateList() {
            return affiliateNameList;
        }

        public void setAffiliateNameList() {
            emailAddressByAffiliateMap = new Map<String, String>();
            userIdByAffiliateMap = new Map<String, Id>();
            affiliateNameList = new List<String>();
            Integer count = 1;
            List<User> userList = [SELECT Id FROM User WHERE IsActive = true AND ProfileId IN (SELECT Id FROM Profile WHERE UserLicense.Name = 'Salesforce') LIMIT :recordCount];
            List<Affiliate__c> testAffiliateList = (List<Affiliate__c>)SmartFactory.createSObjectList('Affiliate__c', false, recordCount);
            for(Integer i=0; i<recordCount; i++) {
                testAffiliateList[i].Affiliate_Name__c = 'test affiliate ' + String.valueOf(count);
                testAffiliateList[i].Email_Address__c = 'testAffiliate' + String.valueOf(count) + '@test.com';
                testAffiliateList[i].User__c = userList[i].Id;
                emailAddressByAffiliateMap.put(testAffiliateList[i].Affiliate_Name__c, testAffiliateList[i].Email_Address__c);
                affiliateNameList.add(testAffiliateList[i].Affiliate_Name__c);
                count++;
            }
            insert testAffiliateList;
            for(Integer i=0; i<userList.size(); i++) {
                if(!userIdByAffiliateMap.containsKey(testAffiliateList[i].Affiliate_Name__c)) {
                    userIdByAffiliateMap.put(testAffiliateList[i].Affiliate_Name__c, userList[i].Id);
                }
            }
        }

        public void setTestGiftList() {
            Account testAccount = (Account)SmartFactory.createSObject('Account', false);
            testAccount.Name = 'GiftTrigger_Test testUpdateOwnerByAffiliate';
            insert testAccount;
            Contact testContact = (Contact)SmartFactory.createSObject('Contact', false);
            testContact.AccountId = testAccount.Id;
            insert testContact;
            testGiftList = (List<causeview__Gift__c>)SmartFactory.createSObjectList('causeview__Gift__c', false, recordCount);
            for(Integer i=0; i<testGiftList.size(); i++) {
                testGiftList[i].Affiliate__c = affiliateNameList[i];
                testGiftList[i].causeview__Constituent__c = testContact.Id;
                testGiftList[i].causeview__Expected_Amount__c = 500.00;
            }
            testGiftList.add(testGiftList[0].clone());
        }
    }

    @isTest
    static void testInsertCreateEventRegistrationFromBatchGift() {
        Test.startTest();
        TestFactory factory = new TestFactory(10);
        Campaign testEvent = (Campaign)SmartFactory.createSObject('Campaign', false);
        insert testEvent;
        causeview__Batch_Template__c testTemplate = (causeview__Batch_Template__c)SmartFactory.createSObject('causeview__Batch_Template__c', false);
        insert testTemplate;
        causeview__Gift_Batch__c testBatch = (causeview__Gift_Batch__c)SmartFactory.createSObject('causeview__Gift_Batch__c', false);
        testBatch.causeview__Template_Name__c = testTemplate.Id;
        insert testBatch;
        List<causeview__Gift__c> testGiftList = factory.getTestGiftList();
        for(causeview__Gift__c testGift : testGiftList) {
            testGift.causeview__GiftBatch__c = testBatch.Id;
            testGift.causeview__Gift_Type__c = 'Event Registration';
            testGift.causeview__Gift_Date__c = Date.today();
            testGift.causeview__Event_Id__c = String.valueOf(testEvent.Id);
        }
        insert testGiftList;
        Map<Id, causeview__Gift__c> testGiftMap = new Map<Id, causeview__Gift__c>(testGiftList);
        System.assertEquals(testGiftList.size(), [SELECT count() FROM causeview__Event_Registration__c WHERE causeview__Transaction__c IN :testGiftMap.keySet()]);
        Test.stopTest();
    }

    @isTest
    static void testUpdateCreateEventRegistrationFromBatchGift() {
        Test.startTest();
        TestFactory factory = new TestFactory(10);
        Campaign testEvent = (Campaign)SmartFactory.createSObject('Campaign', false);
        insert testEvent;
        causeview__Batch_Template__c testTemplate = (causeview__Batch_Template__c)SmartFactory.createSObject('causeview__Batch_Template__c', false);
        insert testTemplate;
        causeview__Gift_Batch__c testBatch = (causeview__Gift_Batch__c)SmartFactory.createSObject('causeview__Gift_Batch__c', false);
        testBatch.causeview__Template_Name__c = testTemplate.Id;
        insert testBatch;
        List<causeview__Gift__c> testGiftList = factory.getTestGiftList();
        for(causeview__Gift__c testGift : testGiftList) {
            testGift.causeview__GiftBatch__c = testBatch.Id;
            testGift.causeview__Gift_Date__c = Date.today();
            testGift.causeview__Event_Id__c = String.valueOf(testEvent.Id);
        }
        insert testGiftList;
        Map<Id, causeview__Gift__c> testGiftMap = new Map<Id, causeview__Gift__c>(testGiftList);
        System.assertEquals(0, [SELECT count() FROM causeview__Event_Registration__c WHERE causeview__Transaction__c IN :testGiftMap.keySet()]);
		testGiftList = testGiftMap.values();
		for(causeview__Gift__c testGift : testGiftList) {
            testGift.causeview__Gift_Type__c = 'Event Registration';
        }
        update testGiftList;
        System.assertEquals(testGiftList.size(), [SELECT count() FROM causeview__Event_Registration__c WHERE causeview__Transaction__c IN :new Map<Id, causeview__Gift__c>(testGiftList).keySet()]);
        Test.stopTest();
    }

    @isTest
    static void testUpdateaffiliateEmailInsert() {
        Test.startTest();
        TestFactory factory = new TestFactory(10);
        Map<Id, causeview__Gift__c> testGiftMap = factory.getTestGiftMap();
        for(causeview__Gift__c testGift : [SELECT Id, OwnerId, Affiliate__c, Affiliate_Reply_To_Email__c FROM causeview__Gift__c WHERE Id IN :testGiftMap.keySet()]) {
            System.assert(factory.emailAddressByAffiliateMap.get(testGift.Affiliate__c).equalsIgnoreCase(testGift.Affiliate_Reply_To_Email__c));
        }
        Test.stopTest();
    }

    @isTest
    static void testUpdateOwnerByAffiliateOnInsert() {
        Test.startTest();
        TestFactory factory = new TestFactory(10);
        Map<Id, causeview__Gift__c> testGiftMap = factory.getTestGiftMap();
        List<causeview__Gift__c> testGiftList = [SELECT Id, OwnerId, Affiliate__c FROM causeview__Gift__c WHERE Id IN :testGiftMap.keySet()];
        for(causeview__Gift__c testGift : testGiftList) {
            System.assertEquals(factory.userIdByAffiliateMap.get(testGift.Affiliate__c), testGift.OwnerId);
        }
        Test.stopTest();
    }

    @isTest
    static void testUpdateOwnerByAffiliateOnUpdate() {
        Test.startTest();
        TestFactory factory = new TestFactory(10);
        Map<Id, causeview__Gift__c> testGiftMap = factory.getTestGiftMap();
        Integer counter = factory.affiliateNameList.size()-1;
        for(causeview__Gift__c testGift : testGiftMap.values()) {
            testGift.Affiliate__c = factory.affiliateNameList[counter];
            counter = counter > 0 ? counter - 1 : 0;
        }
        update testGiftMap.values();
        List<causeview__Gift__c> testGiftList = [SELECT Id, OwnerId, Affiliate__c FROM causeview__Gift__c WHERE Id IN :testGiftMap.keySet()];
        for(causeview__Gift__c testGift : testGiftList) {
            System.assertEquals(factory.userIdByAffiliateMap.get(testGift.Affiliate__c), testGift.OwnerId);
        }
        Test.stopTest();
    }
}
