@isTest
public class TagTriggerTest {

    @isTest
    static void testInsert() {
        Test.startTest();
        Contact testContact = (Contact)SmartFactory.createSobject('Contact');
        insert testContact;
        Tag_Value__c testNonAffiliateTagValue = new Tag_Value__c(Name = 'Non-Affiliate');
        Tag_Value__c testAffiliateTagValue = new Tag_Value__c(Name = 'Boys Hope Girls Hope STL');
        List<Tag_Value__c> testTagValueList = new List<Tag_Value__c>{testNonAffiliateTagValue, testAffiliateTagValue};
        insert testTagValueList;
        List<Tag__c> testTagList = new List<Tag__c>();
        for(Tag_Value__c tv : testTagValueList) {
            testTagList.add(new Tag__c(Tag_Name__c = tv.Id, Individual__c = testContact.Id));
        }
        insert testTagList;
        System.assertEquals(testAffiliateTagValue.Name, [SELECT Affiliates__c FROM Contact WHERE Id = :testContact.Id].Affiliates__c);
        Tag__c affiliateTag = [SELECT Id FROM Tag__c WHERE Tag_Name__r.Name = 'Boys Hope Girls Hope STL'];
        delete affiliateTag;
        System.assert(String.isBlank([SELECT Affiliates__c FROM Contact WHERE Id = :testContact.Id].Affiliates__c));
    }
}
