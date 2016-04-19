public without sharing class GiftTriggerHandler {

	public void onBeforeInsert(List<causeview__Gift__c> newGiftList) {
		updateOwnerIdByAffliate(newGiftList);
	}

	private void updateOwnerIdByAffliate(List<causeview__Gift__c> newGiftList) {
		System.debug('mlh line 8');
		Set<String> affliliateNameSet = new Set<String>();
		Map<String, List<causeview__Gift__c>> giftListByAffiliateMap = new Map<String, List<causeview__Gift__c>>();
		for(causeview__Gift__c gift : newGiftList) {
			System.debug('mlh line 12');
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
		for(User u : [SELECT Id, CompanyName FROM User WHERE CompanyName IN :giftListByAffiliateMap.keySet() AND IsActive = true]) {
			System.debug('mlh line 25');
			if(!ownerIdByAffiliateNameMap.containsKey(u.CompanyName)) {
				System.debug('mlh line 27');
				ownerIdByAffiliateNameMap.put(u.CompanyName, u.Id);
				affiliateCount++;
			}
			if(affiliateCount >= giftListByAffiliateMap.size()) break;
		}
		for(causeview__Gift__c gift : newGiftList) {
			System.debug('mlh line 34. gift.Affiliate_Name__c = ' + gift.Affiliate__c + '.  ownerIdByAffiliateNameMap.get(gift.Affiliate_Name__c) = ' + ownerIdByAffiliateNameMap.get(gift.Affiliate__c));
			gift.OwnerId = ownerIdByAffiliateNameMap.containsKey(gift.Affiliate__c) ? ownerIdByAffiliateNameMap.get(gift.Affiliate__c) : gift.OwnerId;
			System.debug('mlh line 36. gift.OwnerId = ' + String.valueOf(gift.OwnerId));
		}
	}
}
