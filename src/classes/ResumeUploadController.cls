public class ResumeUploadController {

	public Account affiliate { get; set; }
	public Boolean showUpperPanel { get; set; }
	public Id contactId { get; set; }
	public Id affiliateId { get; set; }
	public String selectedOption { get; set; }
	public String hearAboutUs { get; set; }
	public String hearAboutUsText { get; set; }
	public Requisition__c requisition { get; set; }
	public String errorMessage { get; set; }
	public Attachment resume { get; set; }
	public Attachment coverletter { get; set; }
	public Boolean isProcessingString { get; set; }
	public Boolean missingResume { get; set; }
	public Boolean missingCoverletter { get; set; }
	public Boolean isSubmitted { get; set; }

	public ResumeUploadController() {
		errorMessage = '';
		isProcessingString = false;
		missingResume = false;
		missingCoverletter = false;
		isSubmitted = false;
		resume = new Attachment();
		coverletter = new Attachment();
		affiliateId = ApexPages.currentPage().getParameters().get('affiliateId');
		contactId = ApexPages.currentPage().getParameters().get('contactId');
		selectedOption = ApexPages.currentPage().getParameters().get('selectedVal');
		hearAboutUs = ApexPages.currentPage().getParameters().get('hearAboutUs');
		hearAboutUsText = ApexPages.currentPage().getParameters().get('hearAboutUsText');
		showUpperPanel = true;
		if(String.isNotBlank(affiliateId)) affiliate = [SELECT Id, Name FROM Account WHERE Id = :affiliateId];
		if(String.isNotBlank(ApexPages.currentPage().getParameters().get('requisitionId'))) requisition = [SELECT Id, Name, Affiliate_Name__c, Require_Cover_Letter__c FROM Requisition__c WHERE Id = :ApexPages.currentPage().getParameters().get('requisitionId')];
	}

	public void checkIfProcessing() {
		if(!isProcessingString) {
			isProcessingString = true;
			save();
		}
	}

	public PageReference save() {
		missingResume = false;
		missingCoverletter = false;
		List<Attachment> attachmentList = new List<Attachment>();
		String errorMessages = getErrorMessages();
		if(String.isNotBlank(errorMessages)) {
			showUpperPanel = true;
			isProcessingString = false;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessages));
			return null;
		}
		if(String.isNotBlank(String.valueOf(coverletter.Body))) {
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
		} catch(DmlException e) {
			showUpperPanel = true;
			isProcessingString = false;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There was a problem adding your attachment:  ' + e.getMessage()));
			return null;
		}
		try {
			insert candidate;
		} catch(DmlException e) {
			isSubmitted = false;
			showUpperPanel = true;
			isProcessingString = false;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
			return null;
		}
		isSubmitted = true;
		PageReference pageReg = Page.JobSearchPage;
		pageReg.getParameters().put('affiliateId', affiliateId);
		pageReg.setRedirect(true);
		return pageReg;
	}

	public PageReference cancel() {
		return Page.JobSearchPage;
	}

	public String getErrorMessages() {
		String erroMessages = '';
		if(String.isBlank(String.valueOf(resume.Body))) {
			erroMessages += 'Please include a resume file.\n';
			missingResume = true;
		}
		if(requisition.Require_Cover_Letter__c && String.isBlank(String.valueOf(coverletter.Body))) {
			erroMessages += 'The selected position requires a cover letter.';
			missingCoverletter = true;
		}
		return erroMessages;
	}
}
