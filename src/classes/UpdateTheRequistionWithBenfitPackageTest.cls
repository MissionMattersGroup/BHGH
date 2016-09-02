/*
 * Description : This Page to upload resume for particular contact
 *
 * Version               Author            Date (DD-MM-YYYY)           Change Log
 * 1.1                   Geeta Kushwaha       18/01/2016               Initial Draft
 * 1.2                   Geeta Kushwaha       21/01/2016               Created test data and added two methods 
 *                                                                     testRequisitionRecordForFirstCriteria()
 *                                                                     and testRequisitionRecordForSecondCriteria()
 *                                                                     to test the below two scenarios.
 *
 * Class to test controller for process builder to assign Requisition with Benefits Package for following criteria:
 * 1. When Benefits Package's Affiliate equals Requisition's associated Affiliate's parent Account
 *    and Employee_Type__c on Benefits Package includes Internal_Value_Employee_Type__c of Requisition.
 * 2. When Benefits Package does not have an Affiliate 
 *    but Employee_Type__c on Benefits Package includes Internal_Value_Employee_Type__c of Requisition.
 */
@isTest
public with sharing class UpdateTheRequistionWithBenfitPackageTest{
     //setup test data to be used later in the methods to be tested
     @testSetup
     static void setup() {
        //create parent account record from test data class
        list<Account> listParentAccount = TestData.listParentAccount(1);
        insert listParentAccount;
        //create Affiliate(Account) records from test data class
        list<Account> listAccount = TestData.listAccount(2,'Affiliate',listParentAccount[0].Id);
        insert listAccount;
        //create Benefits Package records from test data class
        list<Benefits_Package__c> listBenefitsPackage = TestData.listBenefitsPackage(2);
        listBenefitsPackage[0].Affiliate__c = listParentAccount[0].Id;
        listBenefitsPackage[0].Employee_Type__c = 'Community Volunteer'; 
        listBenefitsPackage[1].Affiliate__c = null;
        listBenefitsPackage[1].Employee_Type__c = 'Contract';
        insert listBenefitsPackage;
        //list to hold Requisition to be inserted 
        list<Requisition__c> lstRequisition = new list<Requisition__c>();
        //add Requisitions to the list
        lstRequisition.add(new Requisition__c(Name = 'Test req 1',
                                                   Internal_Value_Employee_Type__c = 'Community Volunteer',
                                                   Affiliate__c = listAccount[0].Id));
        lstRequisition.add(new Requisition__c(Name = 'Test req 2',
                                                   Internal_Value_Employee_Type__c = 'Contract',
                                                   Affiliate__c = listAccount[1].Id));
        insert lstRequisition;
     }
     /*method to check if requisition record is linked to  benefits package record when Affiliate id on benefits package 
      *equals Affiliate's parent id on requisition
      */
     static testMethod void testRequisitionRecordForFirstCriteria() {
        //get requisition where Affiliate__c is not blank
        Requisition__c objReq = [Select Id 
                                 From   Requisition__c 
                                 Where  Affiliate__c <> null 
                                 Limit  1];
        //get Benefits_Package__c where Employee_Type__c is 'Contract'
        Benefits_Package__c objBenePack = [Select Id 
                                           From   Benefits_Package__c 
                                           Where  Affiliate__c <> null 
                                           Limit  1];          
        //list to hold requisition id
        List<Id> lstOfReqId = new List<Id>();
        //add requisition id to list of id's
        lstOfReqId.add(objReq.Id);
                   
        Test.startTest();
             //pass the list of id's to the method to be tested
             UpdateTheRequistionWithBenfitPackage.updateReqWithBenefitPackage(lstOfReqId);
        Test.stopTest();
        //get the requisition after being updated
        list<Requisition__c> lstRequisition = [Select Id, Benefits_Package__c From Requisition__c Where Id =:objReq.Id];
        //assert if requisition contains refrence to Benefits_Package__c
        system.assertEquals(objBenePack.Id,lstRequisition[0].Benefits_Package__c);
    }
    /*method to check if requisition record is linked to  benefits package record when Affiliate id on benefits package 
     *is blank
     */
    static testMethod void testRequisitionRecordForSecondCriteria() {
        //get requisition where Internal_Value_Employee_Type__c is 'Contract'
        Requisition__c objReq = [Select Id 
                                 From   Requisition__c 
                                 Where  Internal_Value_Employee_Type__c = 'Contract' 
                                 Limit  1];
        //get Benefits_Package__c where Employee_Type__c is 'Contract'
        Benefits_Package__c objBenePack = [Select Id 
                                           From   Benefits_Package__c 
                                           Where  Employee_Type__c Includes ('Contract') 
                                           Limit  1];   
        //list to hold requisition id
        List<Id> lstOfReqId = new List<Id>();
        //add requisition id to list of id's
        lstOfReqId.add(objReq.Id);
                   
        Test.startTest();
            //pass the list of id's to the method to be tested
            UpdateTheRequistionWithBenfitPackage.updateReqWithBenefitPackage(lstOfReqId);
        Test.stopTest();
        //get the requisition after being updated
        list<Requisition__c> lstRequisition = [Select Id, Benefits_Package__c 
                                               From   Requisition__c 
                                               Where  Id =:objReq.Id];
        //assert if requisition contains refrence to Benefits_Package__c
        system.assertEquals(objBenePack.Id,lstRequisition[0].Benefits_Package__c);
    }
}