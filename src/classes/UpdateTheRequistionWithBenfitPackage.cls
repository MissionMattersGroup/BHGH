/*
 * Description : This controller is to fetch the Benfit Package which contains the Employee Type in Requistion with 
 *               the benfit package.
 *
 * Version               Author            Date (DD-MM-YYYY)             Change Log
 * 1.1                   Twinkle P          19/01/2016                   Initial Draft 
 *
 * Detailed description:
 * Class to test controller for process builder to assign Requisition with Benefits Package for following criteria:
 * 1. When Benefits Package's Affiliate equals Requisition's associated Affiliate's parent Account
 *    and Employee_Type__c on Benefits Package includes Internal_Value_Employee_Type__c of Requisition.
 * 2. When Benefits Package does not have an Affiliate 
 *    but Employee_Type__c on Benefits Package includes Internal_Value_Employee_Type__c of Requisition.
 */       
public with sharing class UpdateTheRequistionWithBenfitPackage {
     //This method is to fetch the Benefit Package which matches the account id and update the requisition 
    @InvocableMethod
    public static void updateReqWithBenefitPackage(List<Id> lstReqId) {
    Requisition__c objRequisition = new Requisition__c();
    objRequisition = [SELECT Id, Internal_Value_Employee_Type__c, Affiliate__c,Affiliate__r.Name 
                             , Affiliate__r.Parent.Name
                      FROM Requisition__c
                      WHERE Id =: lstReqId[0]
                      LIMIT 1];
                      
    List<Benefits_Package__c> lstBenefitPackkage = new List<Benefits_Package__c>();
    lstBenefitPackkage = [SELECT Id,Affiliate__c,Employee_Type__c,Affiliate__r.Name
                          FROM Benefits_Package__c
                          WHERE Affiliate__r.Name =: objRequisition.Affiliate__r.Parent.Name 
                          AND  Employee_Type__c includes (:objRequisition.Internal_Value_Employee_Type__c)
                          LIMIT 1];
    if(lstBenefitPackkage.size() > 0){
        objRequisition.Benefits_Package__c = lstBenefitPackkage[0].Id;
    }
    else{
        List<Benefits_Package__c> lstBenefitPckg = new List<Benefits_Package__c>();
        lstBenefitPckg = [SELECT Id,Affiliate__c,Employee_Type__c,Affiliate__r.Name
                          FROM Benefits_Package__c
                          WHERE Affiliate__c = null
                          AND  Employee_Type__c includes (:objRequisition.Internal_Value_Employee_Type__c)
                          LIMIT 1];
        if(lstBenefitPckg.size() > 0){
            objRequisition.Benefits_Package__c = lstBenefitPckg[0].Id;
        }
    }
    update objRequisition;
    }
}