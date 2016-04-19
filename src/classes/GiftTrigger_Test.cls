@isTest(SeeAllData = true)
public class GiftTrigger_Test {

	@isTest
	static void testUpdateOwnerByAffiliate() {
		Test.startTest();
		Set<String> affliliateNameSet = new Set<String>();
		Map<String, Id> userIdByAffiliateMap = new Map<String, Id>();
		for(User u : [SELECT Id, CompanyName FROM User WHERE CompanyName != '' AND IsActive = true LIMIT 200]) {
			if(!userIdByAffiliateMap.containsKey(u.CompanyName)) {
				userIdByAffiliateMap.put(u.CompanyName, u.Id);
			}
		}
		List<String> affliliateNameList = new List<String>(userIdByAffiliateMap.keySet());
		Account testAccount = (Account)SmartFactory.createSObject('Account', false);
		testAccount.Name = 'GiftTrigger_Test testUpdateOwnerByAffiliate';
		insert testAccount;
		Contact testContact = (Contact)SmartFactory.createSObject('Contact', false);
		testContact.AccountId = testAccount.Id;
		insert testContact;
		List<causeview__Gift__c> testGiftList = (List<causeview__Gift__c>)SmartFactory.createSObjectList('causeview__Gift__c', false, affliliateNameList.size());
		for(Integer i=0; i<affliliateNameList.size(); i++) {
			testGiftList[i].Affiliate__c = affliliateNameList[i];
			testGiftList[i].causeview__Constituent__c = testContact.Id;
			testGiftList[i].causeview__Expected_Amount__c = 500.00;
		}
		testGiftList.add(testGiftList[0].clone());
		insert testGiftList;
		testGiftList = [SELECT Id, OwnerId, Affiliate__c FROM causeview__Gift__c WHERE Id IN :new Map<Id, causeview__Gift__c>(testGiftList).keySet()];
		for(causeview__Gift__c testGift : testGiftList) {
			System.assertEquals(userIdByAffiliateMap.get(testGift.Affiliate__c), testGift.OwnerId);
		}
		Test.stopTest();
	}
}
