public class ResumeUploadController {

	public String attachmentName { get; set; }
	public Account affiliate { get; set; }
	public Boolean showUpperPanel { get; set; }
	public Id contactId { get; set; }
	public Id affiliateId { get; set; }
	public String selectedOption { get; set; }
	public String hearAboutUs { get; set; }
	public String hearAboutUsText { get; set; }
	public Requisition__c requisition { get; set; }
	public String errorMessage { get; set; }
	public Boolean displayErrorMessage { get; set; }
	public static Blob resumeBody { get; set; }
	public String resumeName { get; set; }
	public Blob coverletterBody { get; set; }
	public String coverletterName { get; set; }
	public Attachment resume { get; set; }
	public Attachment coverletter { get; set; }
	public Boolean isProcessingString { get; set; }

	public ResumeUploadController() {
		errorMessage = '';
		isProcessingString = false;
		resume = new Attachment();
		coverletter = new Attachment();
		affiliateId = ApexPages.currentPage().getParameters().get('affiliateId');
		contactId = ApexPages.currentPage().getParameters().get('contactId');
		selectedOption = ApexPages.currentPage().getParameters().get('selectedVal');
		hearAboutUs = ApexPages.currentPage().getParameters().get('hearAboutUs');
		hearAboutUsText = ApexPages.currentPage().getParameters().get('hearAboutUsText');
		displayErrorMessage = false;
		showUpperPanel = true;
		if(String.isNotBlank(affiliateId)) {
			affiliate = [SELECT Id, Name FROM Account WHERE Id = :affiliateId];
		}
		if(String.isNotBlank(ApexPages.currentPage().getParameters().get('requisitionId'))) {
			requisition = [SELECT Id, Name, Affiliate_Name__c, Require_Cover_Letter__c FROM Requisition__c WHERE Id = :ApexPages.currentPage().getParameters().get('requisitionId')];
		}
	}

	public void checkIfProcessing() {
		showUpperPanel = false;
		if(!isProcessingString) {
			isProcessingString = true;
			save();
		}
	}

	public PageReference save() {
		List<Attachment> attachmentList = new List<Attachment>();
		displayErrorMessage = (String.isNotBlank(selectedOption) && selectedOption.EqualsIgnoreCase(System.Label.BHGH_Upload_New_Version_Resume)) ? !validateAttachments() : false;
		if(displayErrorMessage) return null;
		if(requisition.Require_Cover_Letter__c) {
			coverletter.ParentId = contactId;
			attachmentList.add(coverletter);
		}
		resume.ParentId = contactId;
		resume.IsPrivate = false;
		attachmentList.add(resume);
		Candidate__c candidate = new Candidate__c(Contact__c = contactId, Requisition__c = requisition.Id, How_did_you_hear_about_us__c = hearAboutUs, Source_Hear_About_Us__c = hearAboutUsText);
		candidate.RecordTypeId = Schema.SObjectType.Candidate__c.getRecordTypeInfosByName().get('1. Resume Only').getRecordTypeId();
		try {
			insert attachmentList;
			insert candidate;
		} catch(DmlException e) {
			showUpperPanel = true;
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
			return null;
		}
		PageReference pageReg = Page.JobSearchPage;
		pageReg.getParameters().put('affiliateId', affiliateId);
		pageReg.setRedirect(true);
		return pageReg;
	}

	public PageReference cancel() {
		return Page.JobSearchPage;
	}

	public Boolean validateAttachments() {
		if(resume == null) {
			errorMessage = 'Please include a resume file.';
			return false;
		}
		if(requisition.Require_Cover_Letter__c && (coverletter == null)) {
			errorMessage = 'The selected position requires a cover letter.';
			return false;
		}
		return true;
	}
}