@isTest
public class JobSearchControllerTest {

    @testSetup static void setup() {
    	list<Job_Description__c> listJobDescription = TestData.listJobDescription(10);
    	insert listJobDescription;

    	listJobDescription = [Select id, Name From Job_Description__c];

    	list<Account> listParentAccount = TestData.listParentAccount(3);
        insert listParentAccount;

        listParentAccount = [Select id, Name From Account];

    	list<Account> listAccount = new list<Account>();
    	for(Account objAcc:listParentAccount){
    		listAccount.addAll(TestData.listAccount(5,'Affiliate',objAcc.id));
    	}
    	insert listAccount;

    	listAccount = [Select id, Name From Account Where ParentId =:listParentAccount[0].id];

    	list<Contact> listContact = TestData.listContact(listAccount);
    	insert listContact;

    	listContact = [Select id, AccountId From Contact];

    	list<Requisition__c> listRequisition = new list<Requisition__c>();
    	for(Job_Description__c objJobDes:listJobDescription){
    		listRequisition.addAll(TestData.listRequisition(10,listContact[0].id,
    		                                                      listContact[0].AccountId,objJobDes.id));
    	}

    	for(integer i=0; i<50; i++){
    		listRequisition[i].Stage__c       = 'Open';
    		listRequisition[i].Subcategory__c ='Active - Posting, advertising, accepting resumes';
    	}

    	insert listRequisition;
    	listRequisition = [Select id, Stage__c, Subcategory__c From Requisition__c];
    }

    //test getSearchResultList() with no input provided
    static testMethod void getSearchResultListWithNoInputTest() {

       PageReference pageRef = Page.JobSearchPage;
	   Test.setCurrentPage(pageRef);

	   JobSearchController controller = new JobSearchController();

	   controller.selectedDepPicklistVal = '----ANY-----';
	   controller.selectedEmpType        = '----ANY-----';
	   controller.selectedLiveInOut      = '----ANY-----';

	   Test.startTest();
	   controller.getSearchResultList();
	   Test.stopTest();
	   system.assertEquals(10,controller.requisitionList.size());
    }

    //test getOptions() with no input being provided
    static testMethod void getOptionsTest() {

       PageReference pageRef = Page.JobSearchPage;
	   Test.setCurrentPage(pageRef);

	   JobSearchController controller = new JobSearchController();
	   system.assertEquals(2,controller.getOptions().size());
    }

    //test getOptionsForEmployeeType() with no input provided
    static testMethod void getOptionsForEmployeeTypeTest() {

       PageReference pageRef = Page.JobSearchPage;
	   Test.setCurrentPage(pageRef);

	   JobSearchController controller = new JobSearchController();
	   system.assertEquals(8,controller.getOptionsForEmployeeType().size());
    }

    //test getOptionsForLiveInOut() with no input provided
    static testMethod void getOptionsForLiveInOutTest() {

       PageReference pageRef = Page.JobSearchPage;
	   Test.setCurrentPage(pageRef);

	   JobSearchController controller = new JobSearchController();
	   system.assertEquals(5,controller.getOptionsForLiveInOut ().size());
    }

    //test class to search records for 'Affiliate'
    static testMethod void getSearchResultListWithAllInputValuesTest() {

       PageReference pageRef = Page.JobSearchPage;
	   Test.setCurrentPage(pageRef);

	   JobSearchController controller = new JobSearchController();

	   controller.getOptions();
	   controller.selectedDepPicklistVal = 'Parent Account 0';
	   controller.selectedEmpType        = 'Community Volunteer';
	   controller.selectedLiveInOut      = 'Yes - Required';

	   controller.getSearchResultList();
	   system.assertEquals(5,controller.getOptionsForLiveInOut ().size());
	   system.assertEquals(0,controller.requisitionList.size());
    }

    //test class for next()
    static testMethod void nextTest() {

       PageReference pageRef = Page.JobSearchPage;
	   Test.setCurrentPage(pageRef);

	   JobSearchController controller = new JobSearchController();

	   controller.selectedDepPicklistVal = '----ANY-----';
	   controller.selectedEmpType        = '----ANY-----';
	   controller.selectedLiveInOut      = '----ANY-----';

	   Test.startTest();
	   controller.getSearchResultList();
	   Test.stopTest();
	   controller.getNext();
	   controller.next();
	   system.assertEquals(10,controller.requisitionList.size());
    }

    //test class for previous()
    static testMethod void previousTest() {

       PageReference pageRef = Page.JobSearchPage;
	   Test.setCurrentPage(pageRef);

	   JobSearchController controller = new JobSearchController();

	   controller.selectedDepPicklistVal = '----ANY-----';
	   controller.selectedEmpType        = '----ANY-----';
	   controller.selectedLiveInOut      = '----ANY-----';

	   Test.startTest();
	   controller.getSearchResultList();
	   Test.stopTest();
	   controller.getNext();
	   controller.next();
	   controller.getprev();
	   controller.previous();
	   system.assertEquals(10,controller.requisitionList.size());
    }

    //test class for FirstPage()
    static testMethod void firstPageTest() {

       PageReference pageRef = Page.JobSearchPage;
	   Test.setCurrentPage(pageRef);

	   JobSearchController controller = new JobSearchController();

	   controller.selectedDepPicklistVal = '----ANY-----';
	   controller.selectedEmpType        = '----ANY-----';
	   controller.selectedLiveInOut      = '----ANY-----';

	   Test.startTest();
	   controller.getSearchResultList();
	   controller.getNext();
	   controller.next();
	   controller.getprev();
	   controller.FirstPage();
	   controller.getprev();
	   Test.stopTest();

	   system.assertEquals(10,controller.requisitionList.size());
    }

    //test class for LastPage()
    static testMethod void lastPageTest() {

       PageReference pageRef = Page.JobSearchPage;
	   Test.setCurrentPage(pageRef);

	   JobSearchController controller = new JobSearchController();

	   controller.selectedDepPicklistVal = '----ANY-----';
	   controller.selectedEmpType        = '----ANY-----';
	   controller.selectedLiveInOut      = '----ANY-----';

	   Test.startTest();
	   controller.getSearchResultList();
	   controller.getNext();
	   controller.LastPage();
	   controller.getNext();
	   Test.stopTest();

	   system.assertEquals(10,controller.requisitionList.size());
    }

    //test class for showJobDescription()
    static testMethod void showJobDescriptionTest() {

       PageReference pageRef = Page.JobSearchPage;
	   Test.setCurrentPage(pageRef);

	   JobSearchController controller = new JobSearchController();

	   controller.selectedDepPicklistVal = '----ANY-----';
	   controller.selectedEmpType        = '----ANY-----';
	   controller.selectedLiveInOut      = '----ANY-----';

	   Test.startTest();
	   controller.getSearchResultList();
	   Test.stopTest();
	   controller.getNext();
	   controller.LastPage();
	   controller.jobDescriptionId  = controller.requisitionList[0].id;
	   controller.showJobDescription();
    }

    //test class for showBenfitPackage()
    static testMethod void showBenefitPackageTest() {

       PageReference pageRef = Page.JobSearchPage;
	   Test.setCurrentPage(pageRef);

	   JobSearchController controller = new JobSearchController();

	   controller.selectedDepPicklistVal = '----ANY-----';
	   controller.selectedEmpType        = '----ANY-----';
	   controller.selectedLiveInOut      = '----ANY-----';

	   Test.startTest();
	   controller.getSearchResultList();
	   Test.stopTest();
	   controller.getNext();
	   controller.LastPage();
	   controller.benefitPackageId  = controller.requisitionList[0].id;
	   controller.showBenefitPackage();
    }

    //test class for closePopup()
    static testMethod void closePopupTest() {

       PageReference pageRef = Page.JobSearchPage;
	   Test.setCurrentPage(pageRef);

	   JobSearchController controller = new JobSearchController();

	   controller.selectedDepPicklistVal = '----ANY-----';
	   controller.selectedEmpType        = '----ANY-----';
	   controller.selectedLiveInOut      = '----ANY-----';

	   Test.startTest();
	   controller.getSearchResultList();
	   Test.stopTest();
	   controller.benefitPackageId  = controller.requisitionList[0].id;
	   controller.showBenefitPackage();
	   controller.closePopup();
    }

    //test class for redirectCandidateResumePage()
    static testMethod void redirectCandidateResumePageTest() {

       PageReference pageRef = Page.JobSearchPage;
	   Test.setCurrentPage(pageRef);

	   JobSearchController controller = new JobSearchController();

	   controller.selectedDepPicklistVal = '----ANY-----';
	   controller.selectedEmpType        = '----ANY-----';
	   controller.selectedLiveInOut      = '----ANY-----';

	   Test.startTest();
	   controller.getSearchResultList();
	   controller.selectPositionRec  = controller.requisitionList[0].id;
	   controller.redirectCandidateResumePage();
	   Test.stopTest();
    }

    //test class for redirectCandidateResumePage() when no record is selected
    static testMethod void negativeRedirectCandidateResumePageTest() {

       PageReference pageRef = Page.JobSearchPage;
	   Test.setCurrentPage(pageRef);

	   JobSearchController controller = new JobSearchController();

	   controller.selectedDepPicklistVal = '----ANY-----';
	   controller.selectedEmpType        = '----ANY-----';
	   controller.selectedLiveInOut      = '----ANY-----';

	   Test.startTest();
	   controller.getSearchResultList();
	   controller.redirectCandidateResumePage();
	   Test.stopTest();
    }

    //test class for getSearchResultList() with text input only
    static testMethod void getSearchResultListWithTextInputOnlyTest() {

       PageReference pageRef = Page.JobSearchPage;
	   Test.setCurrentPage(pageRef);

	   JobSearchController controller = new JobSearchController();

	   controller.selectedDepPicklistVal = '----ANY-----';
	   controller.selectedEmpType        = '----ANY-----';
	   controller.selectedLiveInOut      = '----ANY-----';
	   controller.inputText           = 'Requisition';
	   Test.startTest();
	   controller.getSearchResultList();
	   Test.stopTest();

	   system.assertEquals(10,controller.requisitionList.size());
	   system.assertEquals('Requisition 0',controller.requisitionList[0].Name);
    }
}