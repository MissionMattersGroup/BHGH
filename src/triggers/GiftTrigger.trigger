trigger GiftTrigger on causeview__Gift__c (before insert) {

	GiftTriggerHandler handler = new GiftTriggerHandler();

	if(Trigger.isBefore) {
		if(Trigger.isInsert) {
			handler.onBeforeInsert(Trigger.new);
		}
	}
}
