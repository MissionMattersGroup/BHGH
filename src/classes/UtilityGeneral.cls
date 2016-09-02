/*
 * This is a utility class that contains methods to build queries and other helper methods. All the methods in this 
 *  class are Static.
 *
 *      Author          Date (dd-mm-yyyy)           Version                 ChangeLog
 *      Twinkle P       17-11-2015                  1.0                     Initial Draft
 *      Twinkle P       19-11-2015                  1.1                     Added the create candidate method
 */
public with sharing class UtilityGeneral {
    
    private static final String STR_REC_TYPE_NAME = '1. Resume Only';
    private static final String STR_FILE_NAME     = 'Resume';
    public static Boolean temp = false ;
     //Method to check if the cover letter should be added or not
     public static boolean getRequireCoverLetterStatus(String strRequisitionId){
         
         if(String.isNotBlank(strRequisitionId)){
             return [SELECT Require_Cover_Letter__c 
                       FROM Requisition__c
                       WHERE Id =: strRequisitionId 
                       LIMIT 1].Require_Cover_Letter__c;
         }
         return false;
    }
    
    //Method to insert the Attachment for a particular object
    public static void addAttachments(Attachment objAttach, String strParentId ){
        
        if(objAttach.body != null && String.isNotBlank(strParentId)){
            
            objAttach.ParentId =  strParentId; // the record the file is attached to
            objAttach.IsPrivate = false;
           
            insertSObject(new List<Attachment>{objAttach}, Label.Error_Uploading_Attachment);
            //Clears the viewstate
            objAttach.body = null;
            objAttach = new Attachment();
        }
    }
    /*
    //Method to check if the attachment exist for a contact or not containing resume name
     public static Boolean checkAttachment(String strConId){
     System.debug('into checkAttachment======');
         if(String.isNotBlank(strConId)){
             for(Attachment objAttachment : [SELECT Id, ParentID, body, Name 
                                             FROM   Attachment 
                                             WHERE  ParentID =: strConId] ){
                 String strFileName = objAttachment.Name;
                 if(strFileName.containsIgnoreCase(STR_FILE_NAME)){
                     return false;
                 }
             }
         }
         return true;
    }
    */
    //Create a candidate for a particular job
    public static void createCandidate(String strConId , String strReqId, String strHearAboutUs, 
                                       String strHearAboutText){
        if(String.isNotBlank(strConId) && String.isNotBlank(strReqId)){
            Candidate__c objCandidate = new Candidate__c(Contact__c = strConId, Requisition__c = strReqId,
                                                          How_did_you_hear_about_us__c = strHearAboutUs,
                                                          Source_Hear_About_Us__c = strHearAboutText);
            objCandidate.RecordTypeId = Schema.SObjectType.Candidate__c.getRecordTypeInfosByName()
                                        .get(STR_REC_TYPE_NAME)
                                        .getRecordTypeId();
                                        
            insertSObject(new List<Candidate__c>{objCandidate}, Label.Error_While_Applying);
        }
    }
    
    //Method to insert an Sobject
    public static void insertSObject(List<SObject> lstSobject, String strErrorMsg){
        if(lstSobject != null && String.isNotBlank(strErrorMsg)){
            try{
                Database.insert(lstSobject);
            }
            catch(DmlException e){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Warning, strErrorMsg));
            }
        }
        
    }
}