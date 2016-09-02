@isTest
private class BHGH_UploadResumeTest {
    
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
            listRequisition.addAll(TestData.listRequisition(10,listContact[0].id,listContact[0].AccountId,objJobDes.id)); 
        }       
        
        for(integer i=0; i<50; i++){
            listRequisition[i].Stage__c = 'Open';
            listRequisition[i].Subcategory__c ='Active - Posting, advertising, accepting resumes';
        }       
        insert listRequisition;
        listRequisition = [Select id, Stage__c, Subcategory__c From Requisition__c];
        
    }
    
    
    static testMethod void coverLetterNotMandatorySubmittedAttachments() {
        list<Contact> listContact = [Select id, LastName, FirstName, Email, AccountId From Contact];
        
        list<Requisition__c> listRequisition = [Select id, Stage__c, Subcategory__c From Requisition__c];
        listRequisition[1].Require_Cover_Letter__c = false;
        
        update listRequisition;
        
        Blob objBlob = Blob.valueOf('Test Data');
        Attachment objAttachment = new Attachment();
        objAttachment.Name = 'Resume';      
        objAttachment.Body = objBlob;
        
        PageReference pageRef = Page.BHGH_UploadResume;
        pageRef.getParameters().put('popupContactId',listContact[1].id);
        pageRef.getParameters().put('selectPositionRec',listRequisition[1].id);
        pageRef.getParameters().put('selectionOption', 'No - Upload a new version');
        Test.setCurrentPage(pageRef);
        
        BHGH_UploadResume objUploadResume = new BHGH_UploadResume();        
        objUploadResume.objAttachment = objAttachment;
        
        Test.startTest();
            objUploadResume.addCoverLetter();
        Test.stopTest();
        
    }
    static testMethod void coverLetterNotMandatorySubmittedAttachments1() {
        list<Contact> listContact = [Select id, LastName, FirstName, Email, AccountId From Contact];
        
        list<Requisition__c> listRequisition = [Select id, Stage__c, Subcategory__c From Requisition__c];
        listRequisition[1].Require_Cover_Letter__c = false;
        update listRequisition;
        
        Blob objBlob = Blob.valueOf('Test Data');
        Attachment objAttachment = new Attachment();
        objAttachment.Name = 'Test';      
        objAttachment.Body = objBlob;
        
        PageReference pageRef = Page.BHGH_UploadResume;
        pageRef.getParameters().put('popupContactId',listContact[1].id);
        pageRef.getParameters().put('selectPositionRec',listRequisition[1].id);
        pageRef.getParameters().put('selectionOption', 'No - Upload a new version');
        Test.setCurrentPage(pageRef);
        
        BHGH_UploadResume objUploadResume = new BHGH_UploadResume();        
        objUploadResume.objAttachment = objAttachment;
        
        Test.startTest();
            objUploadResume.addCoverLetter();
        Test.stopTest();
        
        system.assertEquals('TestResume.',objAttachment.Name);
    }
    
    //test addCoverLetter() when Require_Cover_Letter__c is set to false and cover letter not submitted
    static testMethod void coverLetterIsNotMandatoryAndNotSubmittedTest() {
        
        list<Contact> listContact = [Select id, LastName, FirstName, Email, AccountId From Contact];        
        
        list<Requisition__c> listRequisition = [Select id, Stage__c, Subcategory__c From Requisition__c];
        listRequisition[1].Require_Cover_Letter__c = false;
        update listRequisition;
        
        Blob objBlob = Blob.valueOf('Test Data');
        Attachment objAttachment = new Attachment();
        objAttachment.Name = 'Resume';      
        objAttachment.Body = objBlob;
        
        PageReference pageRef = Page.BHGH_UploadResume;
        pageRef.getParameters().put('popupContactId',listContact[1].id);
        pageRef.getParameters().put('selectPositionRec',listRequisition[1].id);
        pageRef.getParameters().put('selectionOption', 'No - Upload a new version');
        pageRef.getParameters().put('strHearAboutUs', 'Email');
        Test.setCurrentPage(pageRef);
        
        BHGH_UploadResume objUploadResume = new BHGH_UploadResume();        
       
        objUploadResume.objAttachment = objAttachment;        
        
        Test.startTest();
            objUploadResume.addCoverLetter();
        Test.stopTest();
        
        list<Candidate__c> listCandidate = [Select id From Candidate__c];          
        system.assertEquals(1,listCandidate.size());        
    }
    
    //test addCoverLetter() when Require_Cover_Letter__c is set to false and cover letter submitted
    static testMethod void coverLetterIsNotMandatoryAndSubmittedTest() {
        
        list<Contact> listContact = [Select id, LastName, FirstName, Email, AccountId From Contact];        
        
        list<Requisition__c> listRequisition = [Select id, Stage__c, Subcategory__c From Requisition__c];
        listRequisition[1].Require_Cover_Letter__c = false;
        update listRequisition;
        
        Blob objBlob = Blob.valueOf('Test Data');
        Attachment objAttachment = new Attachment();
        objAttachment.Name = 'Resume';      
        objAttachment.Body = objBlob;       
        
        Attachment objAttachmentForReq = new Attachment();
        objAttachmentForReq.Name = 'Cover Letter';      
        objAttachmentForReq.Body = objBlob;
        
        PageReference pageRef = Page.BHGH_UploadResume;
        pageRef.getParameters().put('popupContactId',listContact[1].id);
        pageRef.getParameters().put('selectPositionRec',listRequisition[1].id);
        pageRef.getParameters().put('selectionOption', 'No - Upload a new version');
        pageRef.getParameters().put('strHearAboutUs', 'Email');
        Test.setCurrentPage(pageRef);
        
        BHGH_UploadResume objUploadResume = new BHGH_UploadResume();     
              
        objUploadResume.objAttachment = objAttachment;
        objUploadResume.objAttachmentForReq = objAttachmentForReq;
        
        Test.startTest();        
        objUploadResume.addCoverLetter();
        Test.stopTest();
        
        list<Candidate__c> listCandidate = [Select id From Candidate__c];          
        system.assertEquals(1,listCandidate.size());             
    }
    
    //test addCoverLetter() when Require_Cover_Letter__c is set to false and resume not submitted
    static testMethod void resumeNotSubmittedTest() {
        
        list<Contact> listContact = [Select id, LastName, FirstName, Email, AccountId From Contact];        
        
        list<Requisition__c> listRequisition = [Select id, Stage__c, Subcategory__c From Requisition__c];
        listRequisition[1].Require_Cover_Letter__c = false;
        update listRequisition;
        
        Blob objBlob = Blob.valueOf('Test Data');
        Attachment objAttachment = new Attachment();
        objAttachment.Name = 'Resume';      
        objAttachment.Body = objBlob;       
        
        Attachment objAttachmentForReq = new Attachment();
        objAttachmentForReq.Name = 'Cover Letter';      
        objAttachmentForReq.Body = objBlob;
        
        PageReference pageRef = Page.BHGH_UploadResume;
        pageRef.getParameters().put('popupContactId',listContact[1].id);
        pageRef.getParameters().put('selectPositionRec',listRequisition[1].id);
        pageRef.getParameters().put('selectionOption', 'No - Upload a new version');
        pageRef.getParameters().put('strHearAboutUs', 'Email');
        Test.setCurrentPage(pageRef);
        
        BHGH_UploadResume objUploadResume = new BHGH_UploadResume();
        
        Test.startTest();         
        objUploadResume.addCoverLetter(); 
        Test.stopTest();
        
        list<Candidate__c> listCandidate = [Select id From Candidate__c];          
        system.assertEquals(1,listCandidate.size()); 
    }
    
    //test addCoverLetter() when Require_Cover_Letter__c is set to true and cover letter submitted
    static testMethod void coverLetterIsMandatoryAndSubmittedTest() {
        
        list<Contact> listContact = [Select id, LastName, FirstName, Email, AccountId From Contact];        
        
        list<Requisition__c> listRequisition = [Select id, Stage__c, Subcategory__c From Requisition__c];
        listRequisition[1].Require_Cover_Letter__c = true;
        update listRequisition;
        
        Blob objBlob = Blob.valueOf('Test Data');
        Attachment objAttachment = new Attachment();
        objAttachment.Name = 'Resume';      
        objAttachment.Body = objBlob;       
        
        Attachment objAttachmentForReq = new Attachment();
        objAttachmentForReq.Name = 'Cover Letter';      
        objAttachmentForReq.Body = objBlob;
        
        PageReference pageRef = Page.BHGH_UploadResume;
        pageRef.getParameters().put('popupContactId',listContact[1].id);
        pageRef.getParameters().put('selectPositionRec',listRequisition[1].id);
        pageRef.getParameters().put('selectionOption', 'No - Upload a new version');
        pageRef.getParameters().put('strHearAboutUs', 'Email');
        Test.setCurrentPage(pageRef);
        
        BHGH_UploadResume objUploadResume = new BHGH_UploadResume();        
        
        objUploadResume.idFromPopup = listRequisition[1].id;
        objUploadResume.idConFromPopup = listContact[1].id;       
        objUploadResume.objAttachment = objAttachment;
        objUploadResume.objAttachmentForReq = objAttachmentForReq;
        
        list<Candidate__c> listCandidate1 = [Select id From Candidate__c]; 
        
        Test.startTest();        
        objUploadResume.addCoverLetter();
        Test.stopTest(); 
        
        list<Candidate__c> listCandidate = [Select id From Candidate__c];  
        system.assertEquals(1,listCandidate.size()); 
    }
    
    static testMethod void coverLetterIsMandatoryAndSubmittedTest1() {
        
        list<Contact> listContact = [Select id, LastName, FirstName, Email, AccountId From Contact];        
        
        list<Requisition__c> listRequisition = [Select id, Stage__c, Subcategory__c From Requisition__c];
        listRequisition[1].Require_Cover_Letter__c = true;
        update listRequisition;
        
        Blob objBlob = Blob.valueOf('Test Data');
        Attachment objAttachmentForReq = new Attachment();
        objAttachmentForReq.Name = 'Cover Letter';      
        objAttachmentForReq.Body = objBlob;
        
        PageReference pageRef = Page.BHGH_UploadResume;
        pageRef.getParameters().put('popupContactId',listContact[1].id);
        pageRef.getParameters().put('selectPositionRec',listRequisition[1].id);
        pageRef.getParameters().put('selectionOption', 'Yes - Apply existing resume');
        pageRef.getParameters().put('strHearAboutUs', 'Email');
        Test.setCurrentPage(pageRef);
        
        BHGH_UploadResume objUploadResume = new BHGH_UploadResume();        
        
        objUploadResume.idFromPopup = listRequisition[1].id;
        objUploadResume.idConFromPopup = listContact[1].id;       
        //objUploadResume.objAttachment = objAttachment;
        objUploadResume.objAttachmentForReq = objAttachmentForReq;
        
        list<Candidate__c> listCandidate1 = [Select id From Candidate__c]; 
        
        Test.startTest();        
        objUploadResume.addCoverLetter();
        Test.stopTest(); 
        
        list<Candidate__c> listCandidate = [Select id From Candidate__c];  
        system.assertEquals(1,listCandidate.size()); 
    }
    //test addCoverLetter() when Require_Cover_Letter__c is set to true and cover letter not submitted 
    static testMethod void coverLetterIsMandatoryAndNotSubmittedTest() {
        
        list<Contact> listContact = [Select id, LastName, FirstName, Email, AccountId From Contact];        
        
        list<Requisition__c> listRequisition = [Select id, Stage__c, Subcategory__c From Requisition__c];
        listRequisition[1].Require_Cover_Letter__c = true;
        update listRequisition;
        
        Blob objBlob = Blob.valueOf('Test Data');
        Attachment objAttachment = new Attachment();
        objAttachment.Name = 'test';      
        objAttachment.Body = objBlob;
        
        PageReference pageRef = Page.BHGH_UploadResume;
        pageRef.getParameters().put('popupContactId',listContact[1].id);
        pageRef.getParameters().put('selectPositionRec',listRequisition[1].id);
        pageRef.getParameters().put('selectionOption', 'No - Upload a new version');
        pageRef.getParameters().put('strHearAboutUs', 'Email');
        Test.setCurrentPage(pageRef);
        
        BHGH_UploadResume objUploadResume = new BHGH_UploadResume();        
        
        objUploadResume.objAttachment = objAttachment;
        
        Test.startTest();        
        objUploadResume.addCoverLetter();
        Test.stopTest(); 
        
        list<Candidate__c> listCandidate = [Select id From Candidate__c];          
        system.assertEquals(0,listCandidate.size());  
    }
    
    //test cancel()
    static testMethod void cancelTest() {
        
        list<Contact> listContact = [Select id, LastName, FirstName, Email, AccountId From Contact];        
        
        list<Requisition__c> listRequisition = [Select id, Stage__c, Subcategory__c From Requisition__c];
        listRequisition[1].Require_Cover_Letter__c = true;
        update listRequisition;
        
        Blob objBlob = Blob.valueOf('Test Data');
        Attachment objAttachment = new Attachment();
        objAttachment.Name = 'Resume';      
        objAttachment.Body = objBlob;       
        
        Attachment objAttachmentForReq = new Attachment();
        objAttachmentForReq.Name = 'Cover Letter';      
        objAttachmentForReq.Body = objBlob;
        
        PageReference pageRef = Page.BHGH_UploadResume;
        pageRef.getParameters().put('popupContactId',listContact[1].id);
        pageRef.getParameters().put('selectPositionRec',listRequisition[1].id);
        pageRef.getParameters().put('selectionOption', 'No - Upload a new version');
        pageRef.getParameters().put('strHearAboutUs', 'Email');
        Test.setCurrentPage(pageRef);
        
        BHGH_UploadResume objUploadResume = new BHGH_UploadResume();        
        
        objUploadResume.idFromPopup = listRequisition[1].id;
        objUploadResume.idConFromPopup = listContact[1].id;        
        objUploadResume.objAttachment = objAttachment; 
        
        Test.startTest();       
        objUploadResume.cancel();
        Test.stopTest();  
    }
    
    //test through CandidateResumeUploadController
    static testMethod void cancelThroughCandidateResumeUploadControllerTest() {
        
        list<Contact> listContact = [Select id, LastName, FirstName, Email, AccountId From Contact];        
        
        list<Requisition__c> listRequisition = [Select id, Stage__c, Subcategory__c From Requisition__c];
        listRequisition[1].Require_Cover_Letter__c = true;
        update listRequisition;
        
        Blob objBlob = Blob.valueOf('Test Data');
        Attachment objAttachment = new Attachment();
        objAttachment.Name = 'Resume';      
        objAttachment.Body = objBlob;       
        
        Attachment objAttachmentForReq = new Attachment();
        objAttachmentForReq.Name = 'Cover Letter';      
        objAttachmentForReq.Body = objBlob;
        
        PageReference pageRef = Page.BHGH_UploadResume;
        pageRef.getParameters().put('popupContactId',listContact[1].id);
        pageRef.getParameters().put('selectPositionRec',listRequisition[1].id);
        pageRef.getParameters().put('selectionOption', 'No - Upload a new version');
        pageRef.getParameters().put('strHearAboutUs', 'Email');
        Test.setCurrentPage(pageRef);
        
        BHGH_UploadResume objUploadResume = new BHGH_UploadResume(new CandidateResumeUploadController());
        objUploadResume.idFromPopup = listRequisition[1].id;
        objUploadResume.idConFromPopup = listContact[1].id;        
        objUploadResume.objAttachment = objAttachment;
        
        Test.startTest();
        objUploadResume.cancel();
        Test.stopTest();
        system.assertEquals('/apex/jobsearchpage',objUploadResume.returnToJobSearch().getUrl());
    }
    
    //test getRequireCoverLetterStatus() when Require_Cover_Letter__c is set to true and cover letter submitted
    static testMethod void getRequireCoverLetterStatusTest() {
        
        list<Contact> listContact = [Select id, LastName, FirstName, Email, AccountId From Contact];        
        
        list<Requisition__c> listRequisition = [Select id, Stage__c, Subcategory__c From Requisition__c];
        listRequisition[1].Require_Cover_Letter__c = true;
        update listRequisition;
        
        Blob objBlob = Blob.valueOf('Test Data');
        Attachment objAttachment = new Attachment();
        objAttachment.Name = 'Resume';      
        objAttachment.Body = objBlob;       
        
        Attachment objAttachmentForReq = new Attachment();
        objAttachmentForReq.Name = 'Cover Letter';      
        objAttachmentForReq.Body = objBlob;
        
        PageReference pageRef = Page.BHGH_UploadResume;
        pageRef.getParameters().put('popupContactId',listContact[1].id);
        pageRef.getParameters().put('selectPositionRec',listRequisition[1].id);
        pageRef.getParameters().put('selectionOption', 'No - Upload a new version');
        pageRef.getParameters().put('strHearAboutUs', 'Email');
        Test.setCurrentPage(pageRef);
        
        BHGH_UploadResume objUploadResume = new BHGH_UploadResume();        
        
        objUploadResume.idFromPopup = listRequisition[1].id;
        objUploadResume.idConFromPopup = listContact[1].id;        
        objUploadResume.objAttachment = objAttachment;
        objUploadResume.objAttachmentForReq = objAttachmentForReq;
        
        Test.startTest();       
        objUploadResume.addCoverLetter();
        objUploadResume.getRequireCoverLetterStatus();
        Test.stopTest(); 
        list<Candidate__c> listCandidate = [Select id From Candidate__c];          
        system.assertEquals(1,listCandidate.size()); 
    }
    
    //test addCoverLetter() when Require_Cover_Letter__c is set to false and resume submitted doesn't has body
    static testMethod void resumeWithNoBodyTest() {
        
        list<Contact> listContact = [Select id, LastName, FirstName, Email, AccountId From Contact];        
        
        list<Requisition__c> listRequisition = [Select id, Stage__c, Subcategory__c From Requisition__c];
        listRequisition[1].Require_Cover_Letter__c = false;
        update listRequisition;
        
        Blob objBlob = Blob.valueOf('Test Data');
        Attachment objAttachment = new Attachment();
        objAttachment.Name = 'Resume';      
        
        PageReference pageRef = Page.BHGH_UploadResume;
        pageRef.getParameters().put('popupContactId',listContact[1].id);
        pageRef.getParameters().put('selectPositionRec',listRequisition[1].id);
        pageRef.getParameters().put('selectionOption', 'No - Upload a new version');
        pageRef.getParameters().put('strHearAboutUs', 'Email');
        Test.setCurrentPage(pageRef);
        
        BHGH_UploadResume objUploadResume = new BHGH_UploadResume();        
        
        objUploadResume.idFromPopup = listRequisition[1].id;           
        objUploadResume.objAttachment = objAttachment; 
        
        Test.startTest();            
        objUploadResume.addCoverLetter();
        Test.stopTest();  
        
        list<Candidate__c> listCandidate = [Select id From Candidate__c];          
        system.assertEquals(1,listCandidate.size());      
    }  
    
    static testMethod void returnToJobSearchPage() {
        BHGH_UploadResume controller = new BHGH_UploadResume(); 
        PageReference jobsearchPage = page.JobSearchPage;
        //jobsearchPage.getParameters().put('Affiliate',);
        PageReference testReference = Controller.returnToJobSearch();
        Test.setCurrentPage(testReference);
        system.assertEquals('/apex/jobsearchpage',Controller.returnToJobSearch().getUrl());
    }
    static testMethod void attachmentNotHavingKeywordResume() {
        list<Contact> listContact = [Select id, LastName, FirstName, Email, AccountId From Contact];        
        
        list<Requisition__c> listRequisition = [Select id, Stage__c, Subcategory__c From Requisition__c];
        listRequisition[1].Require_Cover_Letter__c = true;
        update listRequisition;
        
        Blob objBlob = Blob.valueOf('Test Data');
        Attachment objAttachment = new Attachment();
        objAttachment.Name = 'Test';      
        objAttachment.Body = objBlob;  
        
        Attachment objAttachmentForReq = new Attachment();
        objAttachmentForReq.Name = 'Cover Letter';      
        objAttachmentForReq.Body = objBlob;
        
        PageReference pageRef = Page.BHGH_UploadResume;
        pageRef.getParameters().put('popupContactId',listContact[1].id);
        pageRef.getParameters().put('selectPositionRec',listRequisition[1].id);
        pageRef.getParameters().put('selectionOption', 'No - Upload a new version');
        pageRef.getParameters().put('strHearAboutUs', 'Email');
        Test.setCurrentPage(pageRef);
        
        BHGH_UploadResume objUploadResume = new BHGH_UploadResume();        
        
        objUploadResume.idFromPopup = listRequisition[1].id;
        objUploadResume.idConFromPopup = listContact[1].id;       
        objUploadResume.objAttachment = objAttachment;
        objUploadResume.objAttachmentForReq = objAttachmentForReq;
        
        Test.startTest();        
        objUploadResume.addCoverLetter();
        Test.stopTest(); 
        
        list<Candidate__c> listCandidate = [Select id From Candidate__c];  
        system.assertEquals(1,listCandidate.size()); 
    }
    
}