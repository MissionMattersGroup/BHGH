public with sharing class EventRegistrationTriggerHandler {

	public void onBeforeInsert(List<causeview__Event_Registration__c> newList) {
		updateaffiliateEmailAddress(newList);
	}

	public void onBeforeUpdate(List<causeview__Event_Registration__c> newList, Map<Id, causeview__Event_Registration__c> oldMap) {
		List<causeview__Event_Registration__c> affiliateUpdateList = new List<causeview__Event_Registration__c>();
		for(causeview__Event_Registration__c eventReg : newList) {
			if(eventReg.Affiliate__c != oldMap.get(eventReg.Id).Affiliate__c) {
				affiliateUpdateList.add(eventReg);
			}
		}
		if(!affiliateUpdateList.isEmpty()) {
			updateaffiliateEmailAddress(affiliateUpdateList);
		}
	}

	private void updateaffiliateEmailAddress(List<causeview__Event_Registration__c> newList) {
		Map<String, String> replyEmailByAffiliateMap = new Map<String, String>();
		for(causeview__Event_Registration__c eventReg : newList){
			replyEmailByAffiliateMap.put(eventReg.Affiliate__c, '');
		}
		for(Affiliate__c affiliate : [SELECT Affiliate_Name__c, Email_Address__c FROM Affiliate__c WHERE Affiliate_Name__c IN :replyEmailByAffiliateMap.keySet()]) {
			replyEmailByAffiliateMap.put(affiliate.Affiliate_Name__c, affiliate.Email_Address__c);
		}
		for(causeview__Event_Registration__c eventReg : newList) {
			eventReg.Reply_to_Email__c = replyEmailByAffiliateMap.get(eventReg.Affiliate__c);
		}
	}
}