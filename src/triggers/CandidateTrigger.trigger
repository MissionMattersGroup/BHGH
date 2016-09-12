trigger CandidateTrigger on Candidate__c (after insert, after update, before update) {

	CandidateTriggerHandler handler = new CandidateTriggerHandler();

	if(Trigger.isBefore) {
		if(Trigger.isUpdate) {
			handler.onBeforeUpdate(Trigger.new, Trigger.oldMap);
		}
	} else if(Trigger.isAfter) {
		if(Trigger.isInsert) {
			CandidateTriggerHandler.onAfterInsert(Trigger.newMap);
		} else if(Trigger.isUpdate) {
			if(RecursiveTriggerCheck.runOnce()) {
				CandidateTriggerHandler.onAfterUpdate(Trigger.newMap, Trigger.oldMap);
			}
		}
	}
}
