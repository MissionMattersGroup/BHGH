public with sharing class EventRegistrationTriggerHandler {

	public void onBeforeInsert(List<causeview__Event_Registration__c> newList) {
		updateReplyToEmailAddress(newList);
	}

	public void onBeforeUpdate(List<causeview__Event_Registration__c> newList, Map<Id, causeview__Event_Registration__c> oldMap) {
		List<causeview__Event_Registration__c> replyToUpdateList = new List<causeview__Event_Registration__c>();
		for(causeview__Event_Registration__c eventReg : newList) {
			if(eventReg.Affiliate__c != oldMap.get(eventReg.Id).Affiliate__c) {
				replyToUpdateList.add(eventReg);
			}
		}
		if(!replyToUpdateList.isEmpty()) {
			updateReplyToEmailAddress(replyToUpdateList);
		}
	}

	private void updateReplyToEmailAddress(List<causeview__Event_Registration__c> newList) {
		Map<String, String> replyEmailByAffiliateMap = new Map<String, String>();
		for(causeview__Event_Registration__c eventReg : newList){
			replyEmailByAffiliateMap.put(eventReg.Affiliate__c, '');
		}
		for(Reply_To__c replyTo : [SELECT Affiliate_Name__c, Email_Address__c FROM Reply_To__c WHERE Affiliate_Name__c IN :replyEmailByAffiliateMap.keySet()]) {
			replyEmailByAffiliateMap.put(replyTo.Affiliate_Name__c, replyTo.Email_Address__c);
		}
		for(causeview__Event_Registration__c eventReg : newList) {
			eventReg.Reply_to_Email__c = replyEmailByAffiliateMap.get(eventReg.Affiliate__c);
		}
	}
}
