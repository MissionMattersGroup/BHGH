public with sharing class CandidateResumeUploadController{

	private static final String STR_EMAIL_REGEX = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
	public String firstName { get; set; }
	public String lastName { get; set; }
	public String email { get; set; }
	public String confirmEmail { get; set; }
	public String mailingStreet { get; set; }
	public String mailingCity { get; set; }
	public String mailingState { get; set; }
	public String mailingZip { get; set; }
	public String hearAboutUsText { get; set; }
	public String selectedVal { get; set; }
	public String requisitionId { get; set; }
	public String affiliateId { get; set; }
	public String hearAboutUs { get; set; }
	public Boolean displayPopup { get; set; }
	public Boolean displayPopupForCoverLetter { get; set; }
	public Boolean isPopupShown { get; set; }
	public List<SelectOption> optionsType { get; set; }
	private List<Attachment> attachmentList;
	public Contact objCon { get; set; }
	public String candidateContactId { get; set; }

	public CandidateResumeUploadController() {
		affiliateId = ApexPages.currentPage().getParameters().get('affiliateID');
		requisitionId = ApexPages.currentPage().getParameters().get('selectPositionRec');
		displayPopup = false;
		isPopupShown = true;
		objCon = new Contact();
		attachmentList = new List<Attachment>();
		displayPopupForCoverLetter = false;
		hearAboutUs = '';
		Schema.sObjectType sobjectType = Candidate__c.getSObjectType();
		Schema.DescribeSObjectResult sobjectDescribe = sobjectType.getDescribe();
		Map<String, Schema.SObjectField> mapOfFields = sobjectDescribe.fields.getMap();
		List<Schema.PicklistEntry> pickListValues = mapOfFields.get(System.Label.HowDidYouHearAboutUs).getDescribe().getPickListValues();
		optionsType = new List<SelectOption>();
		for(Schema.PicklistEntry pickListObj : pickListValues) {
			optionsType.add(new SelectOption(pickListObj.getLabel(), pickListObj.getValue()));
			hearAboutUs = pickListObj.isDefaultValue() ? pickListObj.getValue() : hearAboutUs;
		}
		hearAboutUs = (String.isBlank(hearAboutUs) && !optionsType.isEmpty()) ? optionsType.get(0).getValue() : hearAboutUs;
	}

	public PageReference getNextPageURL() {
		PageReference searchPg = Page.ResumeUpload;
		searchPg.getParameters().put('affiliateId', affiliateId);
		searchPg.getParameters().put('requisitionId', requisitionId);
		searchPg.getParameters().put('selectionOption', selectedVal);
		searchPg.getParameters().put('hearAboutUs', hearAboutUs);
		searchPg.getParameters().put('hearAboutUsText', hearAboutUsText);
		searchPg.setRedirect(true);
		return searchPg;
	}

	public PageReference validate() {
		if(String.isNotBlank(firstName) && String.isNotBlank(lastName) && String.isNotBlank(email) && String.isNotBlank(mailingStreet) && String.isNotBlank(mailingCity) && String.isNotBlank(mailingState) && String.isNotBlank(mailingZip) && String.isNotBlank(hearAboutUs)) {
			if(String.isBlank(hearAboutUsText) && System.Label.CandidateResumeUpload_FilterTextArea.containsIgnoreCase(hearAboutUs)) {
				ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.CandidateResumeUpload_ErrorIfAdverFriendTextBlank));
			} else if(!confirmEmail.equalsIgnoreCase(email)) {
				ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ErrorMessageForEmailOnCandidateUpload));
			} else if(validateEmail(email)) {
				List<Contact> contactList = [SELECT Id, FirstName, LastName, Name, Email, MailingStreet, MailingCity, MailingState, MailingPostalCode FROM Contact WHERE Email = :email];
				if(!contactList.isEmpty()) {
					objCon = contactList[0];
					objCon.MailingStreet = mailingStreet;
					objCon.MailingCity = mailingCity;
					objCon.MailingState = mailingState;
					objCon.MailingPostalCode = mailingZip;
					try {
						update objCon;
					} catch(DmlException e) {
						ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
						return null;
					}
					return redirectToResumeUpload();
				} else {
					try {
						objCon = new Contact(RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'General' AND SObjectType = 'Contact' LIMIT 1].Id, FirstName = firstName, LastName = lastName, Email = email, MailingStreet = mailingStreet, MailingCity = mailingCity, MailingState = mailingState, MailingPostalCode = mailingZip);
						insert objCon;
					} catch(DmlException e) {
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
						return null;
					}
					selectedVal = System.Label.BHGH_Upload_New_Version_Resume;
					return redirectToResumeUpload();
				}
			} else {
				ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.Warning, Label.CandidateResumeUpload_AppropriateEmailAddress));
			}
		} else {
			ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.Warning, Label.CandidateResumeUpload_FillDetails));
		}
		return null;
	}

	private static Boolean validateEmail(String email) {
		Pattern MyPattern = Pattern.compile(STR_EMAIL_REGEX);
		Matcher MyMatcher = MyPattern.matcher(email);
		return MyMatcher.matches();
	}

	public List<SelectOption> getOptions() {
		List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption(System.Label.BHGH_Upload_Existing_Resume, System.Label.BHGH_Upload_Existing_Resume));
		options.add(new SelectOption(System.Label.BHGH_Upload_New_Version_Resume, System.Label.BHGH_Upload_New_Version_Resume));
		return options;
	}

	public PageReference checkSelection() {
		closePopup();
		if(selectedVal.equalsIgnoreCase(System.Label.BHGH_Upload_Existing_Resume)) {
			if(UtilityGeneral.getRequireCoverLetterStatus(requisitionId)) {
				displayPopupForCoverLetter = true;
			} else {
				UtilityGeneral.createCandidate(objCon.Id, requisitionId, hearAboutUs,hearAboutUsText );
				if(!displayPopupForCoverLetter) ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM, Label.Successful_Application_For_Job));
			}
		} else {
			return redirectToResumeUpload();
		}
		return null;
	}

	public void closePopup() {
		isPopupShown = false;
		displayPopup = false;
	}

	public PageReference redirectToResumeUpload() {
		PageReference pageRef = Page.ResumeUpload;
		pageRef.getParameters().put('contactId', objCon.Id);
		pageRef.getParameters().put('affiliateId', affiliateId);
		pageRef.getParameters().put('requisitionId', requisitionId);
		pageRef.getParameters().put('selectedVal', selectedVal);
		pageRef.getParameters().put('hearAboutUs', hearAboutUs);
		pageRef.getParameters().put('hearAboutUsText', hearAboutUsText);
		pageRef.setRedirect(true);
		return pageRef;
	}
}
