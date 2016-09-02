/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class SelectCandidateControllerTest {

    static testMethod void selectCandidateTest() {
        
       Account objParentAccount = new Account();
       objParentAccount.Name = 'Test Parent Account';
       objParentAccount.Affiliate_Status__c = 'Open';
       insert objParentAccount;
       
       Account objAccount = new Account();
       objAccount.Name = 'Test Account';
       objAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Affiliate')
                                                           .getRecordTypeId();
       objAccount.ParentId = objParentAccount.id;
       insert objAccount;
       
       Id recTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('General').getRecordTypeId();
       Contact objContact = new Contact();
       objContact.LastName = 'Test LastName';
       objContact.AccountId = objAccount.id;
       objContact.RecordTypeId = recTypeId;
       insert objContact;
       
       Job_Description__c objDescription = new Job_Description__c();
       objDescription.Name = 'Test Name';
       insert objDescription;
       
       Requisition__c objReq = new Requisition__c();
       objReq.Name = 'Test Requisition';
       objReq.Employee_Type__c = 'Community Volunteer';
       objReq.live_in_position__c = 'Optional';
       objReq.Stage__c = 'New/Submitted';
       objReq.Affiliate__c = objAccount.id;
       objReq.Hiring_Manager__c = objContact.id;
       objReq.Job_Description__c = objDescription.id;
       insert objReq;
       
       Requisition__c objRequisition = new Requisition__c();
       objRequisition.Name = 'Test Requisition Name';
       objRequisition.Employee_Type__c = 'Contract';
       objRequisition.live_in_position__c = 'Yes - Required';
       objRequisition.Stage__c = 'Open';
       objRequisition.Affiliate__c = objAccount.id;
       objRequisition.Hiring_Manager__c = objContact.id;
       objRequisition.Job_Description__c = objDescription.id;
       insert objRequisition;
       
       list<Candidate__c> lstCandidate = new list<Candidate__c>();
       Candidate__c objCandidate = new Candidate__c();
       objCandidate.Requisition__c = objReq.id;
       objCandidate.Contact__c = objContact.id; 
       lstCandidate.add(objCandidate);
       
       Candidate__c objCan = new Candidate__c();
       objCan.Requisition__c = objRequisition.id;
       objCan.Contact__c = objContact.id; 
       lstCandidate.add(objCan);
       insert lstCandidate;
       
       Attachment objAttach = new Attachment();
       objAttach.Name = 'Test Attach';
       objAttach.Body = Blob.valueOf('Test Body');
       objAttach.ParentId = objCandidate.id;
       insert objAttach;
       
       ApexPages.currentPage().getParameters().put('id',objReq.id);
       SelectCandidateController objSelectCandidate = new SelectCandidateController();
       SelectCandidateController.SelectedCandidateWrapper wrapperClass = 
                                            new SelectCandidateController.SelectedCandidateWrapper(objCandidate,true);
       objSelectCandidate.lstCandidateWrp = new List<SelectCandidateController.SelectedCandidateWrapper>();
       objSelectCandidate.lstCandidateWrp.add(wrapperClass);
       objSelectCandidate.getSelectedCandidateIds();
       objSelectCandidate.getFields();
       System.assertEquals(true, objSelectCandidate.setOfCandidateIds.contains(lstCandidate.get(0).id));
    }
}