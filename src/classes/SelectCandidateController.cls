/*
 * Description : This controller is to retrieve all candidate and attachments related to requisition object
 *
 * Version               Author            Date (MM-DD-YYYY           Change Log 
 * 1.1                   Siddharth P        08/03/2015                  Initial Draft [Ticket No: BHGH-142 ]
 */

public class SelectCandidateController
{ 
     public List<SelectedCandidateWrapper> lstCandidateWrp { get; set; }
     public Set<Id> setOfCandidateIds                      { get; set; }
     public static String  requisitionId                   { get; set; }
     public static final String CONGABASEURL               { get; set; }
     public static final String SERVERURL                  { get; set; }
     public static final String REMAINURL                  { get; set; }
     public static final String CONGAQUERYID               { get; set; }
     public static final String CONGATEMPLATEID            { get; set; }
     
     //Constructor
     public SelectCandidateController(){
        setOfCandidateIds = new Set<Id>();
        if(String.isNotBlank(requisitionId )){
            lstCandidateWrp = fillWrapperCandidate();
        }
     }
     
     //Set the url to generate the conga composer
     static {
            requisitionId = ApexPages.currentPage().getParameters().get('id');
            CONGABASEURL  ='/apex/APXTConga4__Conga_Composer?sessionId=';
            SERVERURL  = '&serverUrl=';
            REMAINURL = '&id='+requisitionId+'&QVar0Id='+Label.QueryIdForCandidate+
                          '?pv0=';
            CONGAQUERYID  ='&QVar1Id='+Label.QueryIdForAttachment+'?pv1=';
            CONGATEMPLATEID ='&TemplateID={QVar1}';
     }
     //Method to get all the fields added in the field set
     public List<Schema.FieldSetMember> getFields() {
        return SObjectType.Candidate__c.FieldSets.SelectCandidate.getFields();
     }
     
     //Method to create a query for Candidate
     private List<Candidate__c> retriveCandidateRecords() {
        String query = 'SELECT ';
        for(Schema.FieldSetMember f : this.getFields()) {
            query += f.getFieldPath() + ', ';
        }
        
        query += ' Id FROM Candidate__c WHERE Requisition__c = \''+requisitionId + '\'';
        return Database.query(query);
    }
    
    //Method to fill the list of wrapper with list of candidate retrive from the query
    private List<SelectedCandidateWrapper> fillWrapperCandidate(){
        List<SelectedCandidateWrapper> lstWrapCandidate = new List<SelectedCandidateWrapper> ();
        for(Candidate__c objCandidate : retriveCandidateRecords()){
            lstWrapCandidate.add(new SelectedCandidateWrapper(objCandidate,false));
        }
        return lstWrapCandidate;
    }
    
    //Method to get all the ids of the candidate selected
    public void  getSelectedCandidateIds(){
        for(SelectedCandidateWrapper instWrp : lstCandidateWrp){
            if(instWrp.isSelected){
                setOfCandidateIds.add(instWrp.objCandidate.Id);
            }
        } 
    }
    
    public class SelectedCandidateWrapper{
        public Candidate__c objCandidate { get; set; }
        public Boolean isSelected        { get; set; }
        
        public SelectedCandidateWrapper(Candidate__c objCandidate, Boolean isSelected){
            this.objCandidate = objCandidate;
            this.isSelected = isSelected;
        }
    }
}