@isTest(SeeAllData=true)
public class GiftTrigger_Test {

	// class TestFactory {
	//
    //     Integer recordCount { get; set; }
    //     List<String> affiliateNameList { get; set; }
    //     List<causeview__Gift__c> testGiftList { get; set; }
    //     Map<String, String> emailAddressByAffiliateMap { get; set; }
    //     Map<String, Id> userIdByAffiliateMap { get; set; }
	//
    //     TestFactory(Integer count) {
    //         recordCount = count;
    //         setAffiliateNameList();
    //         setTestGiftList();
    //     }
	//
    //     public Map<Id, causeview__Gift__c> getTestGiftMap() {
    //         insert testGiftList;
    //         return new Map<Id, causeview__Gift__c>(testGiftList);
    //     }
	//
    //     public List<causeview__Gift__c> getTestGiftList() {
    //         return testGiftList;
    //     }
	//
    //     public List<String> getAffiliateList() {
    //         return affiliateNameList;
    //     }
	//
        // public void setAffiliateNameList() {
        //     emailAddressByAffiliateMap = new Map<String, String>();
        //     userIdByAffiliateMap = new Map<String, Id>();
        //     affiliateNameList = new List<String>();
        //     Integer count = 1;
		// 	List<User> userList = [SELECT Id FROM User WHERE IsActive = true AND Profile.Name = 'System Administrator' LIMIT :recordCount];
		// 	recordCount = userList.size();
		// 	List<Affiliate__c> testAffiliateList = (List<Affiliate__c>)SmartFactory.createSObjectList('Affiliate__c', true, recordCount);
		// 	for(Integer i=0; i<recordCount; i++) {
        //         testAffiliateList[i].Email_Address__c = 'testAffiliate' + String.valueOf(count) + '@test.com';
        //         testAffiliateList[i].User__c = userList[i].Id;
        //         emailAddressByAffiliateMap.put(testAffiliateList[i].Affiliate_Name__c, testAffiliateList[i].Email_Address__c);
        //         affiliateNameList.add(testAffiliateList[i].Affiliate_Name__c);
        //         count++;
        //     }
        //     insert testAffiliateList;
        //     for(Integer i=0; i<userList.size(); i++) {
        //         if(!userIdByAffiliateMap.containsKey(testAffiliateList[i].Affiliate_Name__c)) {
        //             userIdByAffiliateMap.put(testAffiliateList[i].Affiliate_Name__c, userList[i].Id);
        //         }
        //     }
        // }
	//
    //     public void setTestGiftList() {
	// 		testGiftList = (List<causeview__Gift__c>)SmartFactory.createSObjectList('causeview__Gift__c', true, recordCount);
	// 		for(Integer i=0; i<testGiftList.size(); i++) {
    //             testGiftList[i].Affiliate__c = affiliateNameList[i];
	// 			testGiftList[i].causeview__Organization__c = null;
	// 			testGiftList[i].causeview__Expected_Amount__c = 500.00;
    //         }
    //         testGiftList.add(testGiftList[0].clone());
    //     }
    // }

	@isTest
    static void testInsertCreateEventRegistrationFromBatchGift() {
        Test.startTest();
		Contact testContact = (Contact)SmartFactory.createSObject('Contact');
		insert testContact;
        Campaign testEvent = (Campaign)SmartFactory.createSObject('Campaign', false);
        insert testEvent;
        causeview__Gift_Batch__c testBatch = (causeview__Gift_Batch__c)SmartFactory.createSObject('causeview__Gift_Batch__c');
		insert testBatch;
        List<causeview__Gift__c> testGiftList = (List<causeview__Gift__c>)SmartFactory.createSObjectList('causeview__Gift__c', false, 10);
        for(causeview__Gift__c testGift : testGiftList) {
			testGift.causeview__GiftBatch__c = testBatch.Id;
			testGift.causeview__Constituent__c = testContact.Id;
            testGift.causeview__Gift_Type__c = 'Event Registration';
            testGift.causeview__Gift_Date__c = Date.today();
            testGift.causeview__Event_Id__c = String.valueOf(testEvent.Id);
        }
        insert testGiftList;
        System.assertEquals(testGiftList.size(), [SELECT count() FROM causeview__Event_Registration__c WHERE causeview__Transaction__c IN :testGiftList]);
        Test.stopTest();
    }

    @isTest
     static void testUpdateCreateEventRegistrationFromBatchGift() {
        Test.startTest();
		Contact testContact = (Contact)SmartFactory.createSObject('Contact');
		insert testContact;
        Campaign testEvent = (Campaign)SmartFactory.createSObject('Campaign', false);
        insert testEvent;
        causeview__Gift_Batch__c testBatch = (causeview__Gift_Batch__c)SmartFactory.createSObject('causeview__Gift_Batch__c');
		insert testBatch;
        List<causeview__Gift__c> testGiftList = (List<causeview__Gift__c>)SmartFactory.createSObjectList('causeview__Gift__c', false, 10);
		for(causeview__Gift__c testGift : testGiftList) {
			testGift.causeview__GiftBatch__c = testBatch.Id;
			testGift.causeview__Constituent__c = testContact.Id;
            testGift.causeview__Gift_Type__c = 'Event Registration';
            testGift.causeview__Gift_Date__c = Date.today();
            testGift.causeview__Event_Id__c = String.valueOf(testEvent.Id);
        }
        insert testGiftList;
        for(causeview__Gift__c testGift : testGiftList) {
            testGift.causeview__Gift_Type__c = 'Event Registration';
        }
        update testGiftList;
        System.assertEquals(testGiftList.size(), [SELECT count() FROM causeview__Event_Registration__c WHERE causeview__Transaction__c IN :new Map<Id, causeview__Gift__c>(testGiftList).keySet()]);
        Test.stopTest();
    }

    @isTest
    static void testUpdateAffiliateEmailInsert() {
        Test.startTest();
		Contact testContact = (Contact)SmartFactory.createSObject('Contact');
		insert testContact;
		Map<String, String> emailAddressByAffiliateMap = new Map<String, String>();
		Map<String, Id> userIdByAffiliateMap = new Map<String, Id>();
		List<String> affiliateNameList = new List<String>();
		List<Affiliate__c> testAffiliateList = (List<Affiliate__c>)SmartFactory.createSObjectList('Affiliate__c', true, 10);
		for(Integer i=0; i<10; i++) {
			testAffiliateList[i].Email_Address__c = 'testAffiliate' + String.valueOf(i) + '@test.com';
			emailAddressByAffiliateMap.put(testAffiliateList[i].Affiliate_Name__c, testAffiliateList[i].Email_Address__c);
			affiliateNameList.add(testAffiliateList[i].Affiliate_Name__c);
		}
		insert testAffiliateList;
		for(Integer i=0; i<testAffiliateList.size(); i++) {
			if(!userIdByAffiliateMap.containsKey(testAffiliateList[i].Affiliate_Name__c)) {
				userIdByAffiliateMap.put(testAffiliateList[i].Affiliate_Name__c, testAffiliateList[i].User__c);
			}
		}
		List<causeview__Gift__c> testGiftList = (List<causeview__Gift__c>)SmartFactory.createSObjectList('causeview__Gift__c', false, 10);
		for(Integer i=0; i<testGiftList.size(); i++) {
			testGiftList[i].Affiliate__c = testAffiliateList[i].Id;
		}
		for(causeview__Gift__c testGift : testGiftList) {
			testGift.causeview__Constituent__c = testContact.Id;
		}
		insert testGiftList;
        // for(causeview__Gift__c testGift : [SELECT Id, OwnerId, Affiliate__c, Affiliate_Reply_To_Email__c FROM causeview__Gift__c WHERE Id IN :testGiftList]) {
        //     System.assert(emailAddressByAffiliateMap.get(testGift.Affiliate__c).equalsIgnoreCase(testGift.Affiliate_Reply_To_Email__c));
        // }
        Test.stopTest();
    }

    @isTest
    static void testUpdateOwnerByAffiliateOnInsert() {
        Test.startTest();
		Contact testContact = (Contact)SmartFactory.createSObject('Contact');
		insert testContact;
		List<causeview__Gift__c> testGiftList = (List<causeview__Gift__c>)SmartFactory.createSObjectList('causeview__Gift__c', false, 10);
		for(causeview__Gift__c testGift : testGiftList) {
			testGift.causeview__Constituent__c = testContact.Id;
        }
		testGiftList = [SELECT Id, OwnerId, Affiliate__c FROM causeview__Gift__c WHERE Id IN :testGiftList];
		Map<String, String> emailAddressByAffiliateMap = new Map<String, String>();
		List<String> affiliateNameList = new List<String>();
		List<Affiliate__c> testAffiliateList = (List<Affiliate__c>)SmartFactory.createSObjectList('Affiliate__c', true, 10);
		for(Integer i=0; i<10; i++) {
			testAffiliateList[i].Email_Address__c = 'testAffiliate' + String.valueOf(i) + '@test.com';
			emailAddressByAffiliateMap.put(testAffiliateList[i].Affiliate_Name__c, testAffiliateList[i].Email_Address__c);
			affiliateNameList.add(testAffiliateList[i].Affiliate_Name__c);
		}
		Map<String, Id> userIdByAffiliateMap = new Map<String, Id>();
		for(Integer i=0; i<testAffiliateList.size(); i++) {
			if(!userIdByAffiliateMap.containsKey(testAffiliateList[i].Affiliate_Name__c)) {
				userIdByAffiliateMap.put(testAffiliateList[i].Affiliate_Name__c, testAffiliateList[i].User__c);
			}
		}
        for(causeview__Gift__c testGift : testGiftList) {
            System.assertEquals(userIdByAffiliateMap.get(testGift.Affiliate__c), testGift.OwnerId);
        }
        Test.stopTest();
    }

    @isTest
    static void testUpdateOwnerByAffiliateOnUpdate() {
        Test.startTest();
		Contact testContact = (Contact)SmartFactory.createSObject('Contact');
		insert testContact;
		List<causeview__Gift__c> testGiftList = (List<causeview__Gift__c>)SmartFactory.createSObjectList('causeview__Gift__c', false, 10);
		for(causeview__Gift__c testGift : testGiftList) {
			testGift.causeview__Constituent__c = testContact.Id;
        }
		insert testGiftList;
		Map<String, String> emailAddressByAffiliateMap = new Map<String, String>();
		List<String> affiliateNameList = new List<String>();
		List<Affiliate__c> testAffiliateList = (List<Affiliate__c>)SmartFactory.createSObjectList('Affiliate__c', true, 10);
		for(Integer i=0; i<10; i++) {
			testAffiliateList[i].Email_Address__c = 'testAffiliate' + String.valueOf(i) + '@test.com';
			emailAddressByAffiliateMap.put(testAffiliateList[i].Affiliate_Name__c, testAffiliateList[i].Email_Address__c);
			affiliateNameList.add(testAffiliateList[i].Affiliate_Name__c);
		}
		Map<String, Id> userIdByAffiliateMap = new Map<String, Id>();
		for(Integer i=0; i<testAffiliateList.size(); i++) {
			if(!userIdByAffiliateMap.containsKey(testAffiliateList[i].Affiliate_Name__c)) {
				userIdByAffiliateMap.put(testAffiliateList[i].Affiliate_Name__c, testAffiliateList[i].User__c);
			}
		}
        Integer counter = affiliateNameList.size()-1;
        for(causeview__Gift__c testGift : testGiftList) {
            testGift.Affiliate__c = affiliateNameList[counter];
            counter = counter > 0 ? counter - 1 : 0;
        }
        update testGiftList;
        testGiftList = [SELECT Id, OwnerId, Affiliate__c FROM causeview__Gift__c WHERE Id IN :testGiftList];
        for(causeview__Gift__c testGift : testGiftList) {
            // System.assertEquals(userIdByAffiliateMap.get(testGift.Affiliate__c), testGift.OwnerId);
        }
        Test.stopTest();
    }
}