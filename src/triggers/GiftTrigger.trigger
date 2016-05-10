trigger GiftTrigger on causeview__Gift__c (before insert, before update, after insert, after update) {

	GiftTriggerHandler handler = new GiftTriggerHandler();

	if(Trigger.isBefore) {
		if(Trigger.isInsert) {
			handler.onBeforeInsert(Trigger.new);
		} else if(Trigger.isUpdate) {
			handler.onBeforeUpdate(Trigger.new, Trigger.oldMap);
		}
	} else if (Trigger.isAfter) {
		if(Trigger.isInsert) {
			handler.onAfterInsert(Trigger.new);
		} else if(Trigger.isUpdate) {
			handler.onAfterUpdate(Trigger.new, Trigger.oldMap);
		}
	}
}