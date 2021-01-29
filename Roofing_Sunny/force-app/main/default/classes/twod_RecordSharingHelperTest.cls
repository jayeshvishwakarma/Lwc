@isTest
public class twod_RecordSharingHelperTest {
    
    public static testMethod void insertObsoleteProduct(){
        insert new twod_TriggerControl__c(SetupOwnerId=UserInfo.getOrganizationId(), 
                                          twod_RecordSharingTrigger__c=true
                                         );                
        Product_Creation__c pro=new Product_Creation__c();
        pro.RecordTypeId=[Select Id from RecordType where sobjecttype='Product_Creation__c' and DeveloperName='Admin_RecordType'].Id;
        pro.Status__c='Completed';
        insert pro;
        update pro;
    }
    
    public static testMethod void updateObsoleteProduct(){
        insert new twod_TriggerControl__c(SetupOwnerId=UserInfo.getOrganizationId(), 
                                         
                                          twod_RecordSharingTrigger__c=true
                                         );        
        Product_Creation__c pro=new Product_Creation__c();
        pro.Status__c='Submitted';
        insert pro;
        
        pro.Status__c='Completed';
        update pro;
    }
}