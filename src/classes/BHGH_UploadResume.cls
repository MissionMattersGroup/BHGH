/*
 * Description : This Page to upload resume for particular contact
 *
 * Version               Author            Date (DD-MM-YYYY)           Change Log
 * 1.1                   Twinkle P          11/11/2015                 Initial Draft
 * 1.2                   Twinkle P          17/11/2015                 Add a functionality to add cover letter
 *                                                                     as per ticket no  BHGH2-50
 * 1.3                   Twinkle P          18/11/2015                 Resolved the issue on saving the upload file if 
 *                                                                     cover letter is blank
 */
public with sharing class BHGH_UploadResume{

   //Fetch the attachment in contact contains resume
    private static final String STR_FILE_NAME     = System.Label.Resume; //String To check name of the attachment as 'Resume'
    public static final String STR_APPEND_FILE_NAME      = 'Resume.';
    public Attachment objAttachment               {
                                                    get {
                                                      if (objAttachment == null)
                                                        objAttachment = new Attachment();
                                                      return objAttachment;
                                                    }
                                                  set;}
    public Attachment objAttachmentForReq         {
                                                    get {
                                                        if (objAttachmentForReq == null) {
                                                            objAttachmentForReq = new Attachment();
                                                        }
                                                        return objAttachmentForReq;
                                                    }
                                                  set;
                                                  }
    public Boolean    displaySection                   { get; set; }
    public String     requisitionId                    { get; set; }
    public String     straffiliateID                   { get; set; }
    public Boolean    showUpperPanel                   { get; set; }
    public String     idConFromPopup                   { get; set; }
    public String     idFromPopup                      { get; set; }
    public String     strSelectedOption                { get; set; }
    
    public String    attachmentName                    { get; set; }
    public String    coverLetterName                   { get; set; }
    public String    affiliateName                     { get; set; }
    public String    strHearAboutUs                    { get; set; }
    public String    strHearAboutUsText                { get; set; }
    public Boolean   displayErrorMessage;
     
    // constructor for controller extension called when user clicks on yes and popup is shown
    public BHGH_UploadResume(CandidateResumeUploadController controller) {
        showUpperPanel           = true;
        straffiliateID           = ApexPages.currentPage().getParameters().get('affiliateID');
        requisitionId            = ApexPages.currentPage().getParameters().get('selectPositionRec');
        idConFromPopup           = ApexPages.currentPage().getParameters().get('popupContactId');
        strSelectedOption        = ApexPages.currentPage().getParameters().get('selectionOption');
        strHearAboutUs           = ApexPages.currentPage().getParameters().get('strHearAboutUs');
        strHearAboutUsText       = ApexPages.currentPage().getParameters().get('strTextForHearUs');
        displayErrorMessage      = false;
        
        if(straffiliateID != null) {
            List<Account> lstAcc = [Select id, Name 
                                    FROM Account 
                                    WHERE id= :straffiliateID];
            if(!lstAcc.isEmpty()) {
                attachmentName = lstAcc[0].Name;
            }
        }
        
        if(requisitionId != null ) {
            List<Requisition__c> lstReq = [Select id, Name, Affiliate_Name__c 
                                           FROM Requisition__c 
                                           WHERE id= :requisitionId];
            if(!lstReq.isEmpty()) {
                coverLetterName = lstReq[0].Name;
                affiliateName  = lstReq[0].Affiliate_Name__c ;
            }
        }
    }
    
    //default constructor called when page is loaded
    public BHGH_UploadResume() {
        showUpperPanel           = true;
        displaySection           = true;
        straffiliateID           = ApexPages.currentPage().getParameters().get('affiliateID');
        requisitionId            = ApexPages.currentPage().getParameters().get('selectPositionRec');
        idConFromPopup           = ApexPages.currentPage().getParameters().get('popupContactId');
        strSelectedOption        = ApexPages.currentPage().getParameters().get('selectionOption');
        strHearAboutUs           = ApexPages.currentPage().getParameters().get('strHearAboutUs');
        strHearAboutUsText       = ApexPages.currentPage().getParameters().get('strTextForHearUs');
        displayErrorMessage      = false;
        
         if(straffiliateID != null) {
            List<Account> lstAcc = [SELECT id, Name 
                                    FROM Account 
                                    WHERE id= :straffiliateID];
            if(!lstAcc.isEmpty()) {
                attachmentName = lstAcc[0].Name;
            }
         }
        
        if(requisitionId != null ) {
            List<Requisition__c> lstReq = [SELECT id, Name, Affiliate_Name__c 
                                           FROM Requisition__c 
                                           WHERE id= :requisitionId];
            if(!lstReq.isEmpty()) {
                coverLetterName = lstReq[0].Name;
                affiliateName  = lstReq[0].Affiliate_Name__c ;
            }
        }
    }
    
    /*
    Description : This method displays popup for adding cover letter when user clicks on Yes
    Input       : 
    Output      : Returns Errors(page messages) and page(on success)
    */
    public PageReference coverPopupDisplay(){
        pageReference pageRef;
        
        if(String.isNotBlank(requisitionId) && String.isNotBlank(idConFromPopup)){
            
            pageRef = getAddAttachments();
            
            if(pageRef == null) {
                
                // If Cover Letter is not Null
                if(objAttachmentForReq != null && objAttachmentForReq.body != null) { 
                    if(displayErrorMessage == false) {
                    // Add CV to requisition and create candidate
                    UtilityGeneral.addAttachments(objAttachmentForReq, idConFromPopup);
                    UtilityGeneral.createCandidate(idConFromPopup, requisitionId, strHearAboutUs,strHearAboutUsText);
                    showUpperPanel = false;
                    }
                }
                //If cover letter is Null
                else {
                    // Check if Cover Letter is required 
                    if(UtilityGeneral.getRequireCoverLetterStatus(requisitionId) ) {
                        // If Cover Letter is required dipslay message as Cover Letter is Required
                        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,
                                       Label.BHGH_UploadResume_CoverLetterRequired));
                        showUpperPanel = true;
                    }
                    // If Cover Letter is not required
                    else {
                        if(objAttachment != null) {
                            // If Resume is not Null the create candidate record
                            UtilityGeneral.createCandidate(idConFromPopup, requisitionId,strHearAboutUs,
                            strHearAboutUsText);
                            
                        }
                    }
                }
            }
        }
        return null; 
    } 
    
    /*
    Description : This method inserts attachments(Resume) to user's records
    Input       :
    Output      : Returns Errors(page messages) and page(on success)
    */
    public PageReference getAddAttachments(){
        
        if(strSelectedOption != null) {
            
            // If option selected by user is 'NO'
            if(strSelectedOption.EqualsIgnoreCase(System.Label.BHGH_Upload_New_Version_Resume)) {
            
                // If Resume is not null 
                if(objAttachment.body != null) {
                    
                    // If filename contains the word 'Resume'
                    if(objAttachment.Name.containsIgnoreCase(System.Label.Resume)) {
                        
                        // If Cover Letter is required
                        if((UtilityGeneral.getRequireCoverLetterStatus(requisitionId))) {
                            // If Cover Letter is null
                            if(objAttachmentForReq.body == null) {
                                showUpperPanel = true;
                            }
                            else {
                                //If Cover Letter is not Null
                                UtilityGeneral.addAttachments(objAttachment , idConFromPopup);
                                showUpperPanel = false;
                            }
                        }
                        // If Cover Letter is not required add resume
                        else {
                            UtilityGeneral.addAttachments(objAttachment , idConFromPopup);
                            showUpperPanel = false;
                        }
                    }
                    
                    // If filename does not contain the word 'Resume'
                    else {
                        
                        // If Cover Letter required
                        if((UtilityGeneral.getRequireCoverLetterStatus(requisitionId))) {
                            // If Cover Letter is Null
                            if(objAttachmentForReq.body == null) {
                                showUpperPanel = true;
                            }
                            // If Cover Letter is not Null Add Resume
                            else {
                                
                                objAttachment.Name = objAttachment.Name.substringBeforeLast('.') +
                                                     STR_APPEND_FILE_NAME +
                                                     objAttachment.Name.substringAfterLast('.') ;
                                UtilityGeneral.addAttachments(objAttachment , idConFromPopup);
                                showUpperPanel = false;
                            }
                        }
                        // If Cover Letter Not required add Resume
                        else {
                            objAttachment.Name = objAttachment.Name.substringBeforeLast('.') +
                                                 STR_APPEND_FILE_NAME +
                                                 objAttachment.Name.substringAfterLast('.') ;
                            UtilityGeneral.addAttachments(objAttachment , idConFromPopup);
                            showUpperPanel = false;
                        }
                    }
                }
                else {
                    // Display message as Attach file with the Name Resume
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,
                                                System.Label.BHGH_Attach_Resume)); 
                   // objAttachmentForReq = null;
                    showUpperPanel = true;
                    displayErrorMessage = true;
                }
            }
        }
        return null; 
    }
     
    /*
    Description : This method calls coverPopupDisplay() to add cover letter if cover letter is required
                  else calls getAddAttachments() to add attachment(Resume) to user's records
                  when user clicks on Next button
    Input       :
    Output      : Returns Errors(page messages) and page(on success)
    */
    public PageReference addCoverLetter(){
        
        if(String.isNotBlank(requisitionId)) {
            
            return coverPopupDisplay();
        }
        return getAddAttachments();
     }
     
    /*
    Description : This method redirects to first page of application:JobSearchPage
                  when user clicks on Cancel
    Input       :
    Output      : Redirects to JobSearchPage
    */
    public PageReference cancel(){
        PageReference pageRef = Page.JobSearchPage;
        return pageRef;
     }
     
    /*
    Description : This method calls method of utility class to identify 
                  whether cover letter is required for Requisition or not
    Input       :
    Output      : Returns True if cover letter is required else returns False
    */
    public Boolean getRequireCoverLetterStatus(){
        return UtilityGeneral.getRequireCoverLetterStatus(requisitionId);
    }
    
    /*
    Description : This method redirects to JobSearchPage when user clicks on Return
    Input       : 
    Output      : Redirects to JobSearchPage
    */
    public pageReference returnToJobSearch() {
        PageReference searchPg = Page.JobSearchPage;
        searchPg.getParameters().put('affiliateID', strAffiliateId);
        searchPg.setRedirect(true);
        return searchPg;
    }
    
}