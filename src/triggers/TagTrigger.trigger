trigger TagTrigger on Tag__c (after insert, before delete) {
    Set<Id> contactIdSet = new Set<Id>();
    Set<Id> tagValueIdSet = new Set<Id>();
    if(Trigger.isBefore && Trigger.isDelete) {
        for(Tag__c t : Trigger.old) {
            if(String.isNotBlank(String.valueOf(t.Individual__c))) {
                contactIdSet.add(t.Individual__c);
                tagValueIdSet.add(t.Tag_Name__c);
            }
        }
    }
    if(Trigger.isAfter && Trigger.isInsert) {
        for(Tag__c t : Trigger.new) {
            if(String.isNotBlank(String.valueOf(t.Individual__c))) {
                contactIdSet.add(t.Individual__c);
                tagValueIdSet.add(t.Tag_Name__c);
            }
        }
    }
    Map<Id, Tag_Value__c> tagValueMap = new Map<Id, Tag_Value__c>([SELECT Id, Name FROM Tag_Value__c WHERE Id IN :tagValueIdSet AND Name LIKE 'Boys Hope Girls Hope%']);
    Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Id, Affiliates__c FROM Contact WHERE Id IN :contactIdSet]);
    Map<Id, String> affiliatesByContactIdMap = new Map<Id, String>();
    if(Trigger.isAfter && Trigger.isInsert) {
        for(Tag__c t : Trigger.new) {
            if(String.isNotBlank(String.valueOf(t.Individual__c)) && tagValueMap.containsKey(t.Tag_Name__c)) {
                Contact c = contactMap.get(t.Individual__c);
                Set<String> tagSet = String.isNotBlank(c.Affiliates__c) ? new Set<String>(c.Affiliates__c.split(';')) : new Set<String>();
                tagSet.remove(null);
                if(!affiliatesByContactIdMap.containsKey(c.Id)) affiliatesByContactIdMap.put(c.Id, c.Affiliates__c);
                if(!tagSet.contains(tagValueMap.get(t.Tag_Name__c).Name)) {
                    String affiliateString = String.isNotBlank(affiliatesByContactIdMap.get(c.Id)) ? affiliatesByContactIdMap.get(c.Id) : '';
                    affiliatesByContactIdMap.put(c.Id, affiliateString + ';' + tagValueMap.get(t.Tag_Name__c).Name);
                }
            }
        }
    } else if(Trigger.isBefore && Trigger.isDelete) {
        for(Tag__c t : Trigger.old) {
            if(String.isNotBlank(String.valueOf(t.Individual__c)) && tagValueMap.containsKey(t.Tag_Name__c)) {
                Contact c = contactMap.get(t.Individual__c);
                Set<String> tagSet = String.isNotBlank(c.Affiliates__c) ? new Set<String>(c.Affiliates__c.split(';')) : new Set<String>();
                tagSet.remove(null);
                if(!affiliatesByContactIdMap.containsKey(c.Id)) affiliatesByContactIdMap.put(c.Id, c.Affiliates__c);
                if(tagSet.contains(tagValueMap.get(t.Tag_Name__c).Name)) {
                    tagSet.remove(tagValueMap.get(t.Tag_Name__c).Name);
                    affiliatesByContactIdMap.put(c.Id, String.join(new List<String>(tagSet), ';'));
                }
            }
        }
    }
    List<Contact> contactUpdateList = new List<Contact>();
    for(Id cId : affiliatesByContactIdMap.keySet()) {
        Contact c = contactMap.get(cId);
        c.Affiliates__c = affiliatesByContactIdMap.get(cId);
        contactUpdateList.add(c);
    }
    if(!contactUpdateList.isEmpty()) {
        update contactUpdateList;
    }
}
