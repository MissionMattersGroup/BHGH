@isTest
public with sharing class ResumeUploadTest {

	class TestFactory {

		public Requisition__c testReq { get; set; }
		public PageReference testPr { get; set; }

		public PageReference getTestPr(Boolean reqLetter) {
			testPr = Page.ResumeUpload;
			testPr.getParameters().put('affiliateId', getTestAffiliate().Id);
			testPr.getParameters().put('contactId', getTestContact().Id);
			testPr.getParameters().put('selectedVal', 'abc');
			testPr.getParameters().put('hearAboutUs', 'def');
			testPr.getParameters().put('hearAboutUsText', 'ghi');
			testPr.getParameters().put('requisitionId', getTestReq(reqLetter).Id);
			return testPr;
		}

		private Account getTestAffiliate() {
			Account testAffiliate = (Account)SmartFactory.createSobject('Account');
			insert testAffiliate;
			return testAffiliate;
		}

		public Contact getTestContact() {
			Contact testContact = (Contact)SmartFactory.createSobject('Contact');
			insert testContact;
			return testContact;
		}

		public Requisition__c getTestReq(Boolean reqLetter) {
			Requisition__c testReq = (Requisition__c)SmartFactory.createSobject('Requisition__c');
			testReq.Require_Cover_Letter__c = reqLetter;
			insert testReq;
			return testReq;
		}
	}

	static testmethod void testSave() {
		Test.startTest();
		TestFactory factory = new TestFactory();
		Test.setCurrentPage(factory.getTestPr(false));
		ResumeUploadController testController = new ResumeUploadController();
		testController.resume = (Attachment)SmartFactory.createSobject('Attachment');
		testController.checkIfProcessing();
		Test.stopTest();
	}
}