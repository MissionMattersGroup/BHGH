public class CandidateTriggerHandler {

    public static void onAfterInsert(Map<Id, Candidate__c> newMap) {
        Map<Id, String> signatureUrlByCandidateIdMap = generateSignatureFromBase64(newMap);
    }

    public static void onAfterUpdate(Map<Id, Candidate__c> newMap, Map<Id, Candidate__c> oldMap) {
        Map<Id, String> signatureUrlByCandidateIdMap = generateSignatureFromBase64(newMap);
    }

    public void onBeforeUpdate(List<Candidate__c> newList, Map<Id, Candidate__c> oldMap) {
		Map<String, Candidate__c> candidateByRecordNameMap = new Map<String, Candidate__c>();
		for(Candidate__c c : newList) {
			if(c.Signature_URL_Long__c != oldMap.get(c.Id).Signature_URL_Long__c) candidateByRecordNameMap.put(c.Name, c);
		}
		if(!candidateByRecordNameMap.isEmpty()) updateSignatureUrl(candidateByRecordNameMap, newList);
    }

    private void updateSignatureUrl(Map<String, Candidate__c> candidateByRecordNameMap, List<Candidate__c> newList) {
		Map<String, Document> documentByCandidateRecordNameMap = new Map<String, Document>();
		for(Document d : [SELECT Id, Name FROM Document WHERE Name IN :candidateByRecordNameMap.keySet()]) documentByCandidateRecordNameMap.put(d.Name, d);
        for(String cName : candidateByRecordNameMap.keySet()) {
			Candidate__c c = candidateByRecordNameMap.get(cName);
            c.Signature_URL__c = documentByCandidateRecordNameMap.get(cName).Id;
        }
    }

    private static Map<Id, String> generateSignatureFromBase64(Map<Id, Candidate__c> newMap) {
		Map<String, Candidate__c> candidateByRecordNameMap = new Map<String, Candidate__c>();
		Id signatureFolderId = [SELECT Id FROM Folder WHERE Name = 'Applicant Signatures' LIMIT 1].Id;
		for(Candidate__c c : newMap.values()) {
			candidateByRecordNameMap.put(c.Name, c);
		}
        Map<String, Document> signatureDocumentByCandidateRecordNameMap = new Map<String, Document>();
        for(Document d : [SELECT Id, Name, Body FROM Document WHERE Name IN :candidateByRecordNameMap.keySet() AND FolderId = :signatureFolderId]) {
            signatureDocumentByCandidateRecordNameMap.put(d.Name, d);
        }
        List<Document> documentList = new List<Document>();
        for(Candidate__c c : newMap.values()) {
            if(String.isNotBlank(c.Signature_URL_Long__c) && !signatureDocumentByCandidateRecordNameMap.containsKey(c.Name)) {
                Document signatureDocument = new Document();
                signatureDocument.ContentType = 'image/png';
                signatureDocument.Name = c.Name;
				signatureDocument.IsPublic = true;
                signatureDocument.FolderId = signatureFolderId;
                signatureDocument.Body = EncodingUtil.base64Decode(c.Signature_URL_Long__c.startsWith('data:image/png;base64,') ? c.Signature_URL_Long__c.replace('data:image/png;base64,', '') : c.Signature_URL_Long__c);
                documentList.add(signatureDocument);
            }
        }
		Map<Id, String> signatureUrlByCandidateIdMap = new Map<Id, String>();
        if(!documentList.isEmpty()) {
            insert documentList;
			Id orgId = [SELECT Id FROM Organization LIMIT 1].Id;
			for(Document d : documentList) {
				signatureUrlByCandidateIdMap.put(candidateByRecordNameMap.get(d.Name).Id, URL.getSalesforceBaseUrl().toExternalForm() + '/servlet/servlet.ImageServer?id=' + d.Id + '&oid=' + orgId);
			}
        }
		return signatureUrlByCandidateIdMap;
    }
}
