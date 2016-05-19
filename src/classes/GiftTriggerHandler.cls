public without sharing class GiftTriggerHandler {

	public void onBeforeInsert(List<causeview__Gift__c> newGiftList) {
		updateOwnerIdByAffliate(newGiftList);
<<<<<<< HEAD
		updateAffiliteReplyToEmail(newGiftList);
=======
		updateAffiliteaffiliateEmail(newGiftList);
>>>>>>> master
	}

	public void onBeforeUpdate(List<causeview__Gift__c> newGiftList, Map<Id, causeview__Gift__c> oldGiftMap) {
		List<causeview__Gift__c> giftAffiliateChangeList = new List<causeview__Gift__c>();
		for(causeview__Gift__c gift : newGiftList) {
			if(gift.Affiliate__c != oldGiftMap.get(gift.Id).Affiliate__c) {
				giftAffiliateChangeList.add(gift);
			}
		}
		if(!giftAffiliateChangeList.isEmpty()) {
			updateOwnerIdByAffliate(giftAffiliateChangeList);
<<<<<<< HEAD
			updateAffiliteReplyToEmail(giftAffiliateChangeList);
=======
			updateAffiliteaffiliateEmail(giftAffiliateChangeList);
>>>>>>> master
		}
	}

	public void onAfterInsert(List<causeview__Gift__c> newGiftList) {
		List<causeview__Gift__c> eventRegGiftList = new List<causeview__Gift__c>();
		for(causeview__Gift__c gift : newGiftList) {
			if(String.isNotBlank(gift.causeview__GiftBatch__c) && gift.causeview__Gift_Type__c == 'Event Registration') {
				eventRegGiftList.add(gift);
			}
		}
		if(!eventRegGiftList.isEmpty()) {
			createEventRegistrationFromBatch(eventRegGiftList);
		}
	}

	public void onAfterUpdate(List<causeview__Gift__c> newGiftList, Map<Id, causeview__Gift__c> oldGiftMap) {
		List<causeview__Gift__c> eventRegGiftList = new List<causeview__Gift__c>();
		for(causeview__Gift__c gift : newGiftList) {
<<<<<<< HEAD
			if((String.isNotBlank(gift.causeview__GiftBatch__c) && gift.causeview__GiftBatch__c != oldGiftMap.get(gift.Id).causeview__GiftBatch__c ) || (gift.causeview__Gift_Type__c == 'Event Registration' && gift.causeview__Gift_Type__c != oldGiftMap.get(gift.Id).causeview__Gift_Type__c)) {
=======
			if((String.isNotBlank(gift.causeview__GiftBatch__c) && gift.causeview__GiftBatch__c != oldGiftMap.get(gift.Id).causeview__GiftBatch__c) || (gift.causeview__Gift_Type__c == 'Event Registration' && gift.causeview__Gift_Type__c != oldGiftMap.get(gift.Id).causeview__Gift_Type__c)) {
>>>>>>> master
				eventRegGiftList.add(gift);
			}
		}
		if(!eventRegGiftList.isEmpty()) {
			createEventRegistrationFromBatch(eventRegGiftList);
		}
	}

	private void createEventRegistrationFromBatch(List<causeview__Gift__c> newGiftList) {
		List<causeview__Event_Registration__c> eventRegList = new List<causeview__Event_Registration__c>();
<<<<<<< HEAD
		for(causeview__Gift__c gift : newGiftList) {
			eventRegList.add(new causeview__Event_Registration__c(causeview__Status__c = 'Registered', causeview__Primary_Registrant__c = true, causeview__Registration_Date__c = gift.causeview__Gift_Date__c, causeview__Transaction__c = gift.Id, causeview__Individual__c = gift.causeview__Constituent__c, causeview__Event__c = gift.causeview__Event_Id__c));
		}
		Database.insert(eventRegList, false);
=======
		Set<Id> eventIdSet = new Set<Id>();
		for(causeview__Gift__c gift : newGiftList) {
			eventIdSet.add(gift.causeview__Event_Id__c);
		}
		Map<Id, Campaign> eventMap = new Map<Id, Campaign>([SELECT Id FROM Campaign WHERE Id IN :eventIdSet]);
		for(causeview__Gift__c gift : newGiftList) {
			eventRegList.add(new causeview__Event_Registration__c(causeview__Status__c = 'Registered', causeview__Primary_Registrant__c = true, causeview__Registration_Date__c = gift.causeview__Gift_Date__c, causeview__Transaction__c = gift.Id, causeview__Individual__c = gift.causeview__Constituent__c, causeview__Event__c = (Id)gift.causeview__Event_Id__c));
		}
		Database.insert(eventRegList, true);
>>>>>>> master
	}

	private void updateOwnerIdByAffliate(List<causeview__Gift__c> newGiftList) {
		Set<String> affliliateNameSet = new Set<String>();
		Map<String, List<causeview__Gift__c>> giftListByAffiliateMap = new Map<String, List<causeview__Gift__c>>();
		for(causeview__Gift__c gift : newGiftList) {
			affliliateNameSet.add(gift.Affiliate__c);
			if(giftListByAffiliateMap.containsKey(gift.Affiliate__c)) {
				List<causeview__Gift__c> giftList = giftListByAffiliateMap.get(gift.Affiliate__c);
				giftList.add(gift);
				giftListByAffiliateMap.put(gift.Affiliate__c, giftList);
			} else {
				giftListByAffiliateMap.put(gift.Affiliate__c, new List<causeview__Gift__c>{gift});
			}
		}
		Map<String, Id> ownerIdByAffiliateNameMap = new Map<String, Id>();
		Integer affiliateCount = 0;
<<<<<<< HEAD
		List<Affiliate__c> affiliateWithInactiveUserList = new List<Affiliate__c>();
		Set<String> companyNameSet = new Set<String>();
		for(Affiliate__c a : [SELECT Affiliate_Name__c, User__c, User__r.IsActive FROM Affiliate__c WHERE Affiliate_Name__c IN :giftListByAffiliateMap.keySet()]) {
			if(!a.User__r.IsActive) {
				affiliateWithInactiveUserList.add(a);
				companyNameSet.add(a.Affiliate_Name__c);
			} else {
				if(!ownerIdByAffiliateNameMap.containsKey(a.Affiliate_Name__c)) {
					ownerIdByAffiliateNameMap.put(a.Affiliate_Name__c, a.User__c);
					affiliateCount++;
				}
				if(affiliateCount >= giftListByAffiliateMap.size()) break;
			}
		}
		if(!affiliateWithInactiveUserList.isEmpty()) {
			Map<String, Id> activeUserIdByCompanyNameMap = getActiveUserIdByCompanyNameMap(companyNameSet);
			for(String companyName : activeUserIdByCompanyNameMap.keySet()) {
				ownerIdByAffiliateNameMap.put(companyName, activeUserIdByCompanyNameMap.get(companyName));
=======
		for(Affiliate__c a : [SELECT Affiliate_Name__c, User__c FROM Affiliate__c WHERE Affiliate_Name__c IN :giftListByAffiliateMap.keySet()]) {
			if(!ownerIdByAffiliateNameMap.containsKey(a.Affiliate_Name__c)) {
				ownerIdByAffiliateNameMap.put(a.Affiliate_Name__c, a.User__c);
				affiliateCount++;
>>>>>>> master
			}
		}
		for(causeview__Gift__c gift : newGiftList) {
			gift.OwnerId = ownerIdByAffiliateNameMap.containsKey(gift.Affiliate__c) ? ownerIdByAffiliateNameMap.get(gift.Affiliate__c) : gift.OwnerId;
		}
	}

<<<<<<< HEAD
	private Map<String, Id> getActiveUserIdByCompanyNameMap(Set<String> companyNameSet) {
		Integer affiliateCount = 0;
		Map<String, Id> activeUserIdByCompanyNameMap = new Map<String, Id>();
		for(User u : [SELECT Id, CompanyName FROM User WHERE IsActive = true AND CompanyName IN :companyNameSet]) {
			if(!activeUserIdByCompanyNameMap.containsKey(u.CompanyName)) {
				activeUserIdByCompanyNameMap.put(u.CompanyName, u.Id);
				affiliateCount++;
			}
			if(affiliateCount >= companyNameSet.size()) break;
		}
		return activeUserIdByCompanyNameMap;
	}

	private void updateAffiliteReplyToEmail(List<causeview__Gift__c> newGiftList) {
=======
	private void updateAffiliteaffiliateEmail(List<causeview__Gift__c> newGiftList) {
>>>>>>> master
		Set<String> affliliateNameSet = new Set<String>();
		Map<String, List<causeview__Gift__c>> giftListByAffiliateMap = new Map<String, List<causeview__Gift__c>>();
		for(causeview__Gift__c gift : newGiftList) {
			affliliateNameSet.add(gift.Affiliate__c);
			if(giftListByAffiliateMap.containsKey(gift.Affiliate__c)) {
				List<causeview__Gift__c> giftList = giftListByAffiliateMap.get(gift.Affiliate__c);
				giftList.add(gift);
				giftListByAffiliateMap.put(gift.Affiliate__c, giftList);
			} else {
				giftListByAffiliateMap.put(gift.Affiliate__c, new List<causeview__Gift__c>{gift});
			}
		}
		Map<String, String> emailByAffiliateNameMap = new Map<String, String>();
		for(Affiliate__c affiliate : [SELECT Affiliate_Name__c, Email_Address__c FROM Affiliate__c WHERE Affiliate_Name__c IN :affliliateNameSet]) {
			if(!emailByAffiliateNameMap.containsKey(affiliate.Affiliate_Name__c)) {
				emailByAffiliateNameMap.put(affiliate.Affiliate_Name__c, affiliate.Email_Address__c);
			}
		}
		for(causeview__Gift__c gift : newGiftList) {
			gift.Affiliate_Reply_To_Email__c = emailByAffiliateNameMap.containsKey(gift.Affiliate__c) ? emailByAffiliateNameMap.get(gift.Affiliate__c) : '';
		}
	}
}
