public without sharing class JobSearchController {

    public String inputText { get; set; }
    public Set<Id> requistionIdSet { get; set; }
    public List<Requisition__c> requisitionList { get; set; }
    public HeaderFooter__c instanceHeadImg { get; set; }
    public Boolean displayPopup { get; set; }
    public Id jobDescriptionId { get; set; }
    public Id benefitPackageId { get; set; }
    public List<Job_Description__c> jobDescriptionList { get; set; }
    public List<Benefits_Package__c> benefitPackageList { get; set; }
    public String selectedDepPicklistVal { get; set; }
    public String selectedEmpType { get; set; }
    public String selectedLiveInOut { get; set; }
    public Integer offsetSize { get; set; }
    public Integer limitSize { get; set; }
    public Integer totalRecs { get; set; }
    public String affiliateId { get; set; }
    public String checkDefaultButton { get; set; }
    public Id selectPositionRec {get; set;}

    public JobSearchController(){
        affiliateId = ApexPages.currentPage().getParameters().get('affiliateId');
        checkDefaultButton = 'JobDescription';
        init();
    }

    private void init() {
        requistionIdSet = new Set<Id>();
        requisitionList = new List<Requisition__c>();
        jobDescriptionList = new List<Job_Description__c>();
        benefitPackageList = new List<Benefits_Package__c>();
        Map<String,HeaderFooter__c> mapPageHeaderFooter = HeaderFooter__c.getall();
        if (mapPageHeaderFooter != null && mapPageHeaderFooter.size() > 0){
            instanceHeadImg = mapPageHeaderFooter.values().get(0);
        }
        offsetSize = 0;
        limitSize = 10;
        totalRecs = 0;
        selectedDepPicklistVal = selectedEmpType = selectedLiveInOut = '----ANY-----';
        getSearchResultList();
    }

    public void searchingRecord() {
        getSearchResultList();
    }

    private List<Requisition__c> getSearchResultListInReq(String strSearchVal){
        selectPositionRec = null;
        offsetSize = limitSize > totalRecs ? 0 : offsetSize;
        String strCountQuery = 'SELECT count() ';
		List<String> fieldList = new List<String>();
		List<Schema.FieldSetMember> fsmList = new List<Schema.FieldSetMember>(SObjectType.Requisition__c.FieldSets.FieldsForJobSearchPage.getFields());
		fsmList.addAll(SObjectType.Requisition__c.FieldSets.HiddenFieldsForJobSearchPage.getFields());
        for(Schema.FieldSetMember f : fsmList) {
            fieldList.add(f.getFieldPath());
        }
		String strQuery = 'SELECT Id, ' + String.join(fieldList, ', ');
        strCountQuery += getQuery(strSearchVal);
        totalRecs = Database.countQuery(strCountQuery);
        strQuery += getQuery(strSearchVal) + ' LIMIT  ' + limitSize + ' OFFSET ' + offsetSize;
        return Database.query(strQuery);
    }

    private String getQuery(String strSearchVal){
        String strTempQuery = '';
        if ( String.isNotBlank(affiliateId)) {
            strTempQuery+= ' FROM Requisition__c WHERE Stage__c = \'Open\' AND Subcategory__c = \'Active - Posting, advertising, accepting resumes\' AND Affiliate__r.ParentId = \''+affiliateId+'\'';
        } else {
            strTempQuery+= ' FROM Requisition__c WHERE Stage__c = \'Open\' AND Subcategory__c = \'Active - Posting, advertising, accepting resumes\'';
        }
        strTempQuery+= getQueryString(selectedDepPicklistVal, selectedEmpType, selectedLiveInOut, strSearchVal);
        return strTempQuery;
    }

    public String getQueryString(String strAccName, String strEmpType, String strLiveInStatus, String strPosition){
		String strQuery = !strAccName.equalsIgnoreCase('----ANY-----') ? ' AND Affiliate__r.Parent.Name LIKE \'%'+strAccName+'%\'' : '';
        strQuery = !strEmpType.equalsIgnoreCase('----ANY-----') ? strQuery + ' AND Employee_Type__c LIKE \'%'+strEmpType+'%\'' : strQuery;
        strQuery = !strLiveInStatus.equalsIgnoreCase('----ANY-----') ? strQuery + ' AND Live_in_Live_Out__c LIKE \'%'+strLiveInStatus+'%\'' : strQuery;
        strQuery = String.isNotBlank(strPosition) ? strQuery + ' AND Name LIKE \'%'+strPosition+'%\'' : strQuery;
        return strQuery;
    }

    public void getSearchResultList(){
        requisitionList = getSearchResultListInReq(inputText);
        if(requisitionList.size() <= 0 || requisitionList.isEmpty()){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Info,Label.NoRecordsFound));
            requisitionList.clear();
        }
    }

    public List<SelectOption> getOptions() {
        List<SelectOption> optionsList = new List<SelectOption>{new SelectOption('----ANY-----', '----ANY-----')};
        Set<String> affiliateParentNameSet = new Set<String>();
		for(Requisition__c objReq : [SELECT Id, Affiliate__r.Name , Affiliate__r.Parent.Name FROM Requisition__c WHERE Affiliate__r.ParentID != null ORDER BY  Affiliate__r.Parent.Name ASC]) {
            affiliateParentNameSet.add(objReq.Affiliate__r.Parent.Name);
        }
		for(String affiliateParentName : affiliateParentNameSet) {
			optionsList.add(new SelectOption(affiliateParentName, affiliateParentName));
		}
        return optionsList;
    }

    public List<SelectOption> getOptionsForEmployeeType(){
        List<SelectOption> optionsList = new List<SelectOption>();
    	optionsList.add(new SelectOption('----ANY-----', '----ANY-----'));
        Schema.DescribeFieldResult fieldResult = Requisition__c.Employee_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple) {
            optionsList.add(new SelectOption(f.getLabel(), f.getValue()));
        }
        return optionsList;
    }

    public List<SelectOption> getOptionsForLiveInOut(){
        List<SelectOption> optionsList = new List<SelectOption>();
        optionsList.add(new SelectOption('----ANY-----', '----ANY-----'));
        Schema.DescribeFieldResult fieldResult = Requisition__c.Live_in_Live_Out__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry schemaPick : ple) {
            optionsList.add(new SelectOption(schemaPick.getLabel(), schemaPick.getValue()));
        }
     	return optionsList;
    }

    public PageReference closePopup() {
        displayPopup = false;
        return null;
    }

    public PageReference showJobDescription() {
       benefitPackageList.clear();
       displayPopup = true;
       checkDefaultButton = 'JobDescription';
       jobDescriptionList = String.isNotBlank(jobDescriptionId) ? [SELECT Id, Description__c FROM Job_Description__c WHERE Id = :jobDescriptionId] : new List<Job_Description__c>();
       return null;
    }

    public PageReference showBenefitPackage(){
       jobDescriptionList.clear();
       displayPopup = true;
       checkDefaultButton = 'BenefitDescription';
       benefitPackageList = String.isNotBlank(benefitPackageId) ? [SELECT Id, Benefits_Description__c FROM Benefits_Package__c WHERE Id =: benefitPackageId] : new List<Benefits_Package__c>();
       return null;
    }

    public PageReference redirectCandidateResumePage() {
        if(String.isNotBlank(selectPositionRec)) {
            PageReference searchPg = Page.candidateresumeupload;
            searchPg.getParameters().put('affiliateId', affiliateId);
            searchPg.getParameters().put('selectPositionRec', selectPositionRec);
            searchPg.setRedirect(true);
            return searchPg;
        } else {
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.Warning, Label.Error_While_Applying));
            return null;
        }
    }

    public void firstPage() {
        offsetSize = 0;
        getSearchResultList();
    }

    public void previous() {
        selectedDepPicklistVal = selectedEmpType = selectedLiveInOut = '----ANY-----';
        inputText = '';
        offsetSize = offsetSize - limitSize;
        getSearchResultList();
    }

    public void next() {
        selectedDepPicklistVal = selectedEmpType = selectedLiveInOut = '----ANY-----';
        inputText = '';
        offsetSize = offsetSize + limitSize;
        getSearchResultList();
    }

    public void lastPage() {
        offsetSize = math.mod(totalRecs,limitSize) == 0 ? totalrecs - limitSize : totalrecs - math.mod(totalRecs,limitSize);
        getSearchResultList();
    }

    public Boolean getPrev() {
        return offsetSize == 0;
    }

	public Boolean getNext(){
        return ((offsetSize + limitSize) > totalRecs || totalRecs <= 0 || requisitionList.size() < 0 || (OffsetSize + LimitSize) == totalRecs);
    }
}