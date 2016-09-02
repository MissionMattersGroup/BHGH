@isTest
public with sharing class EventRegistrationTrigger_Test {

	class TestFactory {

		Integer recordCount { get; set; }
		List<String> affiliateList { get; set; }
		List<causeview__Event_Registration__c> testRegistrationList;
		Map<String, String> emailAddressByAffiliateMap;

		TestFactory(Integer count) {
			recordCount = count;
			setAffiliateList();
			setTestRegistrationList();
		}

		public Map<Id, causeview__Event_Registration__c> getTestRegistrationMap() {
			insert testRegistrationList;
			return new Map<Id, causeview__Event_Registration__c>(testRegistrationList);
		}

		public List<causeview__Event_Registration__c> getTestRegistrationList() {
			return testRegistrationList;
		}

		public List<String> getAffiliateList() {
			return affiliateList;
		}

		public void setAffiliateList() {
			emailAddressByAffiliateMap = new Map<String, String>();
			List<Affiliate__c> testaffiliateList = (List<Affiliate__c>)SmartFactory.createSObjectList('Affiliate__c', false, recordCount);
			Integer count = 1;
			for(Affiliate__c affiliate : testaffiliateList) {
				affiliate.Affiliate_Name__c = 'test affiliate ' + String.valueOf(count);
				affiliate.Email_Address__c = 'testAffiliate' + String.valueOf(count) + '@test.com';
				count++;
			}
			insert testaffiliateList;
			for(Affiliate__c affiliate : testaffiliateList) {
				emailAddressByAffiliateMap.put(affiliate.Affiliate_Name__c, affiliate.Email_Address__c);
			}
			affiliateList = new List<String>(emailAddressByAffiliateMap.keySet());
		}

		public void setTestRegistrationList() {
			Contact testContact = (Contact)SmartFactory.createSObject('Contact');
			insert testContact;
			Campaign testEvent = (Campaign)SmartFactory.createSObject('Campaign');
			insert testEvent;
			testRegistrationList = (List<causeview__Event_Registration__c>)SmartFactory.createSObjectList('causeview__Event_Registration__c', false, affiliateList.size());
			for(Integer i=0; i<affiliateList.size(); i++) {
				testRegistrationList[i].Affiliate__c = affiliateList[i];
				testRegistrationList[i].causeview__Individual__c = testContact.Id;
				testRegistrationList[i].causeview__Event__c = testEvent.Id;
			}
		}
	}

	@isTest
	static void testUpdateaffiliateAfterInsert() {
		Test.startTest();
		TestFactory factory = new TestFactory(10);
		Map<Id, causeview__Event_Registration__c> testRegMap = factory.getTestRegistrationMap();
		for(causeview__Event_Registration__c testReg : [SELECT Id, Affiliate__c, Reply_to_Email__c FROM causeview__Event_Registration__c WHERE Id IN :testRegMap.keySet()]) {
			System.assert(factory.emailAddressByAffiliateMap.get(testReg.Affiliate__c).equalsIgnoreCase(testReg.Reply_to_Email__c));
		}
		Test.stopTest();
	}

	@isTest
	static void testUpdateaffiliateAfterUpdate() {
		Test.startTest();
		TestFactory factory = new TestFactory(10);
		List<causeview__Event_Registration__c> testRegList = factory.getTestRegistrationMap().values();
		for(Integer i=0; i<testRegList.size(); i++) {
			testRegList[i].Affiliate__c = i < testRegList.size() - 1 ? factory.affiliateList[i+1] : factory.affiliateList[0];
		}
		update testRegList;
		for(causeview__Event_Registration__c testReg : [SELECT Id, Affiliate__c, Reply_to_Email__c FROM causeview__Event_Registration__c WHERE Id IN :new Map<Id, causeview__Event_Registration__c>(testRegList).keySet()]) {
			System.assert(factory.emailAddressByAffiliateMap.get(testReg.Affiliate__c).equalsIgnoreCase(testReg.Reply_to_Email__c));
		}
		Test.stopTest();
	}
}