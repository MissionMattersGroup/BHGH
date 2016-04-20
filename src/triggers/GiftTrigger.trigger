trigger GiftTrigger on causeview__Gift__c (before insert, before update) {

	GiftTriggerHandler handler = new GiftTriggerHandler();

	if(Trigger.isBefore) {
		if(Trigger.isInsert) {
			handler.onBeforeInsert(Trigger.new);
		}
		if(Trigger.isUpdate) {
			handler.onBeforeUpdate(Trigger.new, Trigger.oldMap);
		}
	}
}
