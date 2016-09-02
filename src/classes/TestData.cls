/*
 * Test data to help unit testing in test classes
 */
@isTest
public class TestData { 

    //create records for Job_Description__c with tolal records required
    public static list<Job_Description__c> listJobDescription(integer total) {
        list<Job_Description__c> listJobDescription = new list<Job_Description__c>();
        
        for(integer i = 0; i<total; i++){
        	Job_Description__c obj = new Job_Description__c(Name = 'Job Description '+i);
        	listJobDescription.add(obj);
        }        
        return listJobDescription;
    }
    
    //create records for Contact with total records required
    public static list<Contact> listContact(list<Account> listAccount){
    	list<Contact> listContact = new list<Contact>();
    	
    	integer i = 0;    	
    	for(Account objAcc:listAccount){
    		Contact objCon = new Contact(LastName ='Contact '+i, FirstName = 'First Contact'+i, 
    		                             Email = 'Test@email.com', AccountId = objAcc.id);
    		listContact.add(objCon);
    		i++;
    	}    	
    	return listContact;
    }
    
    //create records for Account with total records required
    public static list<Account> listAccount(integer total, string recordType, id parentAccId){
    	list<Account> listAccount = new list<Account>();
    	
    	Id recTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(recordType).getRecordTypeId();
    	//system.debug('recordTypeId = '+recTypeId);
    	
    	for(integer i = 0; i<total; i++){
    		Account acc = new Account(Name ='Account '+i,recordTypeId = recTypeId, ParentId = parentAccId);    		
    		listAccount.add(acc);
    	}    	
    	return listAccount;
    }
    
    //create records for Parent Account with total records required
    public static list<Account> listParentAccount(integer total){
    	list<Account> listAccount = new list<Account>();    	
    	
    	for(integer i = 0; i<total; i++){
    		Account acc = new Account(Name ='Parent Account '+i, Affiliate_Status__c = 'Open');    		
    		listAccount.add(acc);
    	}    	
    	return listAccount;
    }
    
    //create records for Account with total records required
    public static list<Requisition__c> listRequisition(integer total, id conId, id accId, id jobDesId){
    	list<Requisition__c> listRequisition = new list<Requisition__c>();
    	
    	for(integer i = 0; i<total; i++){
    		Requisition__c req = new Requisition__c(Name ='Requisition '+i, Employee_Type__c='Community Volunteer', 
    		                                        Stage__c='New/Submitted', live_in_position__c = 'Yes - Required');
    		req.Affiliate__c = accId;
    		req.Hiring_Manager__c = conId;
    		req.Job_Description__c = jobDesId;
    		listRequisition.add(req);
    	}    	
    	return listRequisition;
    }
    
    //create records for Benefits Package with total records required
    public static list<Benefits_Package__c> listBenefitsPackage(integer total){
    	list<Benefits_Package__c> listBenefitsPackage = new list<Benefits_Package__c>();    	
    	
    	for(integer i = 0; i<total; i++){
    		Benefits_Package__c objBenefitsPack = new Benefits_Package__c(Name ='Benefit Pacakage '+i);    		
    		listBenefitsPackage.add(objBenefitsPack);
    	}    	
    	return listBenefitsPackage;
    }
}