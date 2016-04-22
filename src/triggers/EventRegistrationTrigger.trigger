trigger EventRegistrationTrigger on causeview__Event_Registration__c (before insert, before update) {

	EventRegistrationTriggerHandler handler = new EventRegistrationTriggerHandler();

	if(Trigger.isBefore) {
		if(Trigger.isInsert) {
			handler.onBeforeInsert(Trigger.New);
		} else if(Trigger.isUpdate) {
			handler.onBeforeUpdate(Trigger.New, Trigger.OldMap);
		}
	}
}
