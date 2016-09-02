@isTest
private class CandidateResumeUploadControllerTest {

	@testSetup static void setup() {
		list<Job_Description__c> listJobDescription = TestData.listJobDescription(10);
		insert listJobDescription;

		listJobDescription = [Select id, Name From Job_Description__c];

		list<Account> listParentAccount = TestData.listParentAccount(3);
		insert listParentAccount;

		listParentAccount = [Select id, Name From Account];

		list<Account> listAccount = TestData.listAccount(5,'Affiliate',listParentAccount[0].id);
		insert listAccount;

		listAccount = [Select id, Name From Account Where ParentId =:listParentAccount[0].id];

		list<Contact> listContact = TestData.listContact(listAccount);
		insert listContact;

		listContact = [Select id, LastName, FirstName, Email, AccountId From Contact];

		list<Requisition__c> listRequisition = new list<Requisition__c>();
		for(Job_Description__c objJobDes:listJobDescription){
			listRequisition.addAll(TestData.listRequisition(10,listContact[0].id,
			listContact[0].AccountId,objJobDes.id));
		}

		for(integer i=0; i<50; i++){
			listRequisition[i].Stage__c = 'Open';
			listRequisition[i].Subcategory__c ='Active - Posting, advertising, accepting resumes';
		}

		insert listRequisition;
	}

	//test validate() on select yes
	static testMethod void testValidateOnYes() {

		list<Contact> listContact = [Select id, LastName, FirstName, Email, AccountId From Contact];
		list<Requisition__c> listRequisition = [Select id, Stage__c, Subcategory__c
		From   Requisition__c
		Where  Stage__c = 'Open' And
		Subcategory__c ='Active - Posting, advertising, accepting resumes'];
		Blob objBlob = Blob.valueOf('Test Data');
		Attachment objAttachment = new Attachment();
		objAttachment.Name = 'Resume';
		objAttachment.ParentID = listContact[0].id;
		objAttachment.Body = objBlob;
		insert objAttachment;

		PageReference pageRef = Page.CandidateResumeUpload;
		pageRef.getParameters().put('selectPositionRec',listRequisition[0].id);
		Test.setCurrentPage(pageRef);

		CandidateResumeUploadController objCandidate = new CandidateResumeUploadController();
		objCandidate.firstName = 'First Contact0';
		objCandidate.lastName = 'Contact 0';
		objCandidate.email = 'Test@email.com';

		Test.startTest();
		objCandidate.validate();
		objCandidate.getOptions();
		objCandidate.selectedVal = 'Yes - Apply existing resume';
		objCandidate.checkSelection();
		Test.stoptest();
	}



	//test validate() on select yes
	static testMethod void testValidateOnNo() {

		list<Contact> listContact = [Select id, LastName, FirstName, Email, AccountId From Contact];
		list<Requisition__c> listRequisition = [Select id, Stage__c, Subcategory__c
		From   Requisition__c
		Where  Stage__c = 'Open' And
		Subcategory__c
		='Active - Posting, advertising, accepting resumes'];
		Blob objBlob = Blob.valueOf('Test Data');
		Attachment objAttachment = new Attachment();
		objAttachment.Name = 'Resume';
		objAttachment.ParentID = listContact[0].id;
		objAttachment.Body = objBlob;
		insert objAttachment;

		PageReference pageRef = Page.CandidateResumeUpload;
		pageRef.getParameters().put('selectPositionRec',listRequisition[0].id);
		Test.setCurrentPage(pageRef);

		CandidateResumeUploadController objCandidate = new CandidateResumeUploadController();
		objCandidate.firstName = 'First Contact0';
		objCandidate.lastName = 'Contact 0';
		objCandidate.email = 'Test@email.com';
		Test.startTest();
		objCandidate.validate();
		objCandidate.getOptions();
		objCandidate.selectedVal = 'No - Upload a new version';
		objCandidate.checkSelection();
		objCandidate.getNextPageURL();
		Test.stoptest();
	}

	//test validate() when contact exists and no resume present for that contact
	static testMethod void testValidateWithNoResume() {

		Contact objCon = [Select id, LastName, FirstName, Email, AccountId
		From   Contact
		Where  FirstName = 'First Contact0' And
		LastName = 'Contact 0' And
		Email = 'Test@email.com'];
		list<Requisition__c> listRequisition = [Select id, Stage__c, Subcategory__c
		From   Requisition__c
		Where  Stage__c = 'Open' And
		Subcategory__c ='Active - Posting, advertising, accepting resumes'];

		list<Account> listParentAccount = [Select Id , (Select Id
		From Requisitions__r
		Where Id =:listRequisition[0].id ) From Account];

		PageReference pageRef = Page.CandidateResumeUpload;
		pageRef.getParameters().put('selectPositionRec',listRequisition[0].id);
		pageRef.getParameters().put('affiliateID',listParentAccount[0].id);
		pageRef.getParameters().put('selectionOption',objCon.id);
		//pageRef.getParameters().put('strHearAboutUs','Email');
		Test.setCurrentPage(pageRef);

		CandidateResumeUploadController objCandidate = new CandidateResumeUploadController();
		objCandidate.firstName = 'First Contact1';
		objCandidate.lastName = 'Contact1';
		objCandidate.email = 'Test1@email.com';
		objCandidate.hearAboutUs = 'Advertisement';
		objCandidate.hearAboutUsText = 'TestAdvertisement';
		Test.startTest();
		objCandidate.validate();
		PageReference pageRefs = objCandidate.getNextPageURL();
		string strURL ='/apex/resumeupload?affiliateID='+listParentAccount[0].Id
		+'&selectPositionRec='+listRequisition[0].Id
		+'&strHearAboutUs='+objCandidate.hearAboutUs +
		+'&hearAboutUsText='+objCandidate.hearAboutUsText;
		PageReference pageRef1 = new PageReference(strURL);
		Test.stoptest();
		system.assert(pageRefs.geturl().containsIgnoreCase('resumeupload'));
	}

	//test validate() when hear about us is Friend or Adveristment , text area is required
	static testMethod void testValidateWithTextRequired() {

		Contact objCon = [Select id, LastName, FirstName, Email, AccountId
		From   Contact
		Where  FirstName = 'First Contact0' And
		LastName = 'Contact 0' And
		Email = 'Test@email.com'];
		list<Requisition__c> listRequisition = [Select id, Stage__c, Subcategory__c
		From   Requisition__c
		Where  Stage__c = 'Open' And
		Subcategory__c ='Active - Posting, advertising, accepting resumes'];

		list<Account> listParentAccount = [Select Id , (Select Id
		From Requisitions__r
		Where Id =:listRequisition[0].id ) From Account];

		PageReference pageRef = Page.CandidateResumeUpload;
		pageRef.getParameters().put('selectPositionRec',listRequisition[0].id);
		pageRef.getParameters().put('affiliateID',listParentAccount[0].id);
		pageRef.getParameters().put('selectionOption',objCon.id);
		//pageRef.getParameters().put('strHearAboutUs','Email');
		Test.setCurrentPage(pageRef);

		CandidateResumeUploadController objCandidate = new CandidateResumeUploadController();
		objCandidate.firstName = 'First Contact1';
		objCandidate.lastName = 'Contact1';
		objCandidate.email = 'Test1@email.com';
		objCandidate.hearAboutUs = 'Friend';
		objCandidate.hearAboutUsText = '';
		Test.startTest();
		objCandidate.validate();
		PageReference pageRefs = objCandidate.getNextPageURL();
		string strURL ='/apex/resumeupload?affiliateID='+listParentAccount[0].Id
		+'&selectPositionRec='+listRequisition[0].Id
		+'&strHearAboutUs='+objCandidate.hearAboutUs +
		+'&hearAboutUsText='+objCandidate.hearAboutUsText;
		PageReference pageRef1 = new PageReference(strURL);
		Test.stoptest();
		system.assert(pageRefs.geturl().containsIgnoreCase('resumeupload'));
	}

	//test normal flow on page
	static testMethod void testValidate() {

		list<Requisition__c> listRequisition = [Select id, Stage__c, Subcategory__c
		From   Requisition__c
		Where  Stage__c = 'Open' And
		Subcategory__c ='Active - Posting, advertising, accepting resumes'];

		PageReference pageRef = Page.CandidateResumeUpload;
		pageRef.getParameters().put('id',listRequisition[0].id);
		Test.setCurrentPage(pageRef);

		CandidateResumeUploadController objCand = new CandidateResumeUploadController();
		objCand.firstName = 'First Contact';
		objCand.lastName  = 'Contact';
		objCand.email     = 'Test@email.com';
		objCand.confirmEmail = 'Test@email.com';
		objCand.mailingStreet = 'AAA';
		objCand.mailingCity = 'Pune';
		objCand.mailingState = 'MH';
		objCand.mailingZip = '000001';
		objCand.hearAboutUs = 'Email';
		Test.startTest();
		objCand.validate();
		Test.stoptest();

		list<Contact> listContact = [Select id, LastName, FirstName, Email, AccountId
		From   Contact
		Where  FirstName = 'First Contact' And
		LastName = 'Contact' And
		Email = 'Test@email.com'];
		system.assertEquals('First Contact',listContact[0].FirstName);
	}

	//test with inappropriate email
	static testMethod void testValidateEmailNull() {

		list<Requisition__c> listRequisition = [Select id, Stage__c, Subcategory__c
		From   Requisition__c
		Where  Stage__c = 'Open' And
		Subcategory__c ='Active - Posting, advertising, accepting resumes'];

		PageReference pageRef = Page.CandidateResumeUpload;
		pageRef.getParameters().put('id',listRequisition[0].id);
		Test.setCurrentPage(pageRef);

		CandidateResumeUploadController objCand = new CandidateResumeUploadController();
		objCand.firstName  = 'First Contact';
		objCand.lastName   = 'Contact';
		objCand.email      = 'Testemail.com';
		Test.startTest();
		objCand.validate();
		Test.stoptest();
	}

	//test with no first and last name
	static testMethod void testValidateContactNull() {

		list<Requisition__c> listRequisition = [Select id, Stage__c, Subcategory__c
		From   Requisition__c
		Where  Stage__c = 'Open' And
		Subcategory__c ='Active - Posting, advertising, accepting resumes'];

		PageReference pageRef = Page.CandidateResumeUpload;
		pageRef.getParameters().put('id',listRequisition[0].id);
		Test.setCurrentPage(pageRef);

		CandidateResumeUploadController objCand = new CandidateResumeUploadController();
		objCand.firstName = '';
		objCand.lastName  = '';
		objCand.email     = 'Testemail.com';

		Test.startTest();
		objCand.validate();
		Test.stoptest();
		List<Apexpages.Message> msgs = ApexPages.getMessages();
		System.assertEquals(msgs.size(),1);
	}
	// Test for different Email address
	static testMethod void differentEmailAddress() {
		list<Requisition__c> listRequisition = [Select id, Stage__c, Subcategory__c
		From   Requisition__c
		Where  Stage__c = 'Open' And
		Subcategory__c ='Active - Posting, advertising, accepting resumes'];

		PageReference pageRef = Page.CandidateResumeUpload;
		pageRef.getParameters().put('id',listRequisition[0].id);
		Test.setCurrentPage(pageRef);

		CandidateResumeUploadController objCand = new CandidateResumeUploadController();
		objCand.firstName = '';
		objCand.lastName  = '';
		objCand.email     = 'Test@gmail.com';
		Test.startTest();
		objCand.validate();
		Test.stoptest();
		List<Apexpages.Message> msgs = ApexPages.getMessages();
		System.assertEquals(msgs.size(),1);
	}
	//Test normal flow on page when Contact already exist
	static testMethod void testValidateForExistingContact() {

		list<Requisition__c> listRequisition = [Select id, Stage__c, Subcategory__c
		From   Requisition__c
		Where  Stage__c = 'Open' And
		Subcategory__c ='Active - Posting, advertising, accepting resumes'];

		PageReference pageRef = Page.CandidateResumeUpload;
		pageRef.getParameters().put('id',listRequisition[0].id);
		Test.setCurrentPage(pageRef);

		Contact conObj = new Contact(LastName ='Contact0 ', FirstName = 'First Contact0',
		Email = 'Test@email.com', MailingStreet = 'AAA', MailingCity = 'BBB',
		MailingState = 'CCC', MailingPostalCode = '1111');
		insert conObj;

		// Insert one Contact
		CandidateResumeUploadController objCand = new CandidateResumeUploadController();
		objCand.firstName = 'First Contact0';
		objCand.lastName  = 'Contact0';
		objCand.email     = 'Test@email.com';
		objCand.confirmEmail = 'Test@email.com';
		objCand.mailingStreet = 'AAA1';
		objCand.mailingCity = 'BBB1';
		objCand.mailingState = 'CCC1';
		objCand.mailingZip = '11110';
		objCand.hearAboutUs = 'Email';

		Test.startTest();
		objCand.validate();
		Test.stoptest();

		list<Contact> listContact = [Select id, LastName, FirstName, Email, AccountId
		From   Contact
		Where  FirstName = 'First Contact0' And
		LastName = 'Contact0' And
		Email = 'Test@email.com'];
		system.assertEquals('First Contact0',listContact[0].FirstName);
	}
	//Test normal flow on page when Contact already exist and attachment is added
	static testMethod void testValidateForExistingContactHavingAttachment() {

		list<Requisition__c> listRequisition = [Select id, Stage__c, Subcategory__c
		From   Requisition__c
		Where  Stage__c = 'Open' And
		Subcategory__c ='Active - Posting, advertising, accepting resumes'];

		PageReference pageRef = Page.CandidateResumeUpload;
		pageRef.getParameters().put('id',listRequisition[0].id);
		Test.setCurrentPage(pageRef);




		Contact conObj = new Contact(LastName ='Contact0 ', FirstName = 'First Contact0',
		Email = 'Test@email.com', MailingStreet = 'AAA', MailingCity = 'BBB',
		MailingState = 'CCC', MailingPostalCode = '1111');

		insert conObj;

		Blob objBlob = Blob.valueOf('Test Data');
		Attachment objAttachment = new Attachment();
		objAttachment.Name = 'Resume';
		objAttachment.Body = objBlob;
		objAttachment.ParentID=conObj.id;
		insert(objAttachment);
		// Insert one Contact
		CandidateResumeUploadController objCand = new CandidateResumeUploadController();
		objCand.firstName = 'First Contact0';
		objCand.lastName  = 'Contact0';
		objCand.email     = 'Test@email.com';
		objCand.confirmEmail = 'Test@email.com';
		objCand.mailingStreet = 'AAA1';
		objCand.mailingCity = 'BBB1';
		objCand.mailingState = 'CCC1';
		objCand.mailingZip = '11110';
		objCand.hearAboutUs = 'Email';
		//objCand.objAttachment = objAttachment;

		Test.startTest();
		objCand.validate();
		Test.stoptest();

		list<Contact> listContact = [Select id, LastName, FirstName, Email, AccountId
		From   Contact
		Where  FirstName = 'First Contact0' And
		LastName = 'Contact0' And
		Email = 'Test@email.com'];
		system.assertEquals('First Contact0',listContact[0].FirstName);
	}

	//test validate() when the Hear About Friend Or Advertisment and Description is blank.
	static testMethod void testValidateOnYesForAttachement() {

		list<Contact> listContact = [Select id, LastName, FirstName, Email, AccountId From Contact];
		list<Requisition__c> listRequisition = [Select id, Stage__c, Subcategory__c
		From   Requisition__c
		Where  Stage__c = 'Open' And
		Subcategory__c ='Active - Posting, advertising, accepting resumes'];
		Blob objBlob = Blob.valueOf('Test Data');
		Attachment objAttachment = new Attachment();
		objAttachment.Name = 'Cover_Letter';
		objAttachment.ParentID = listContact[0].id;
		objAttachment.Body = objBlob;
		insert objAttachment;
		PageReference pageRef = Page.CandidateResumeUpload;
		pageRef.getParameters().put('selectPositionRec',listRequisition[0].id);
		Test.setCurrentPage(pageRef);

		CandidateResumeUploadController objCandidate = new CandidateResumeUploadController();
		objCandidate.firstName = 'First Contact0';
		objCandidate.lastName = 'Contact 0';
		objCandidate.email = 'Test@email.com';
		objCandidate.mailingStreet = 'AAA1';
		objCandidate.mailingCity = 'BBB1';
		objCandidate.mailingState = 'CCC1';
		objCandidate.mailingZip = '11110';
		objCandidate.hearAboutUs = 'Friend';
		objCandidate.hearAboutUsText = '';

		Test.startTest();
		objCandidate.validate();
		objCandidate.getOptions();
		objCandidate.selectedVal = 'Yes - Apply existing resume';
		objCandidate.checkSelection();
		Test.stoptest();
	}
}