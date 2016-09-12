public class AttachmentUtility {

    public String candidateRecordName;

	public String getCandidateRecordName() {
		return candidateRecordName;
	}

	public void setCandidateRecordName(String s) {
		candidateRecordName = s;
		List<Document> signautureDocList = [SELECT Id FROM Document WHERE Name = :candidateRecordName LIMIT 1];
		if(!signautureDocList.isEmpty()) {
			fileUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/servlet/servlet.ImageServer?id=' + signautureDocList[0].Id + '&oid=' + [SELECT Id FROM Organization LIMIT 1].Id;
		}
	}

    public String fileUrl;

	public String getFileUrl() {
		return fileUrl;
	}

	public void setFileUrl(String s) {
		List<Document> signautureDocList = [SELECT Id FROM Document WHERE Name = :candidateRecordName LIMIT 1];
		if(!signautureDocList.isEmpty()) {
			fileUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/servlet/servlet.FileDownload?file=' + signautureDocList[0].Id + '&oid=' + [SELECT Id FROM Organization LIMIT 1].Id;
		}
	}
}
