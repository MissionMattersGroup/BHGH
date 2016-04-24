public without sharing class GiftTriggerHandler {

	public void onBeforeInsert(List<causeview__Gift__c> newGiftList) {
		updateOwnerIdByAffliate(newGiftList);
		updateAffiliteaffiliateEmail(newGiftList);
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
			updateAffiliteaffiliateEmail(giftAffiliateChangeList);
		}
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
		for(Affiliate__c a : [SELECT Affiliate_Name__c, User__c FROM Affiliate__c WHERE Affiliate_Name__c IN :giftListByAffiliateMap.keySet()]) {
			if(!ownerIdByAffiliateNameMap.containsKey(a.Affiliate_Name__c)) {
				ownerIdByAffiliateNameMap.put(a.Affiliate_Name__c, a.User__c);
				affiliateCount++;
			}
			if(affiliateCount >= giftListByAffiliateMap.size()) break;
		}
		for(causeview__Gift__c gift : newGiftList) {
			gift.OwnerId = ownerIdByAffiliateNameMap.containsKey(gift.Affiliate__c) ? ownerIdByAffiliateNameMap.get(gift.Affiliate__c) : gift.OwnerId;
		}
	}

	private void updateAffiliteaffiliateEmail(List<causeview__Gift__c> newGiftList) {
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
