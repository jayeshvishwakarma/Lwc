@isTest
public class twod_WarrantyTransferCntrlTest {
    
    public static testMethod void insertWR(){
        insert new twod_TriggerControl__c(SetupOwnerId=UserInfo.getOrganizationId(), 
                                          twod_AccountCreationWarrantyTransferTrig__c=true
                                         );     
        
        Warranty_Transfer__c wr=new Warranty_Transfer__c();
        wr.Transfered_Date__c=system.today();
        wr.Address_1__c='Test';
        wr.Address_2__c='Address 2';
        wr.City__c='City';
        wr.State__c='Alabama (AL)';
        wr.Country__c='United States';
        wr.Postal_Code__c='12345';
        wr.Address_1_BL__c='Test';
        wr.Address_2_BL__c='Address 2';
        wr.City_BL__c='City';
        wr.State_BL__c='Alabama (AL)';
        wr.Country_BL__c='United States';
        wr.Postal_Code_BL__c='12345';
        wr.Email__c='test@test.com';
        wr.RecordTypeId=[Select Id,Name from RecordType where sobjecttype='Warranty_Transfer__c' and Name = 'Commercial'].Id;
        insert wr;
        system.debug('wr.RecordTypeId--'+wr.RecordTypeId);
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new twod_MockHttpResponseGenerator());         
        ApexPages.StandardController sc = new ApexPages.StandardController(wr);        
        twod_WarrantyTransferCntrl pctl = new twod_WarrantyTransferCntrl(sc);        
        pctl.isEdit=false;  
        pctl.quickSave();
        pctl.cancel();
        Test.stopTest();
    }
    
    public static testMethod void CloseWR(){
        insert new twod_TriggerControl__c(SetupOwnerId=UserInfo.getOrganizationId(), 
                                          twod_AccountCreationWarrantyTransferTrig__c=true
                                         );     
        Warranty_Transfer__c wr=new Warranty_Transfer__c();
        wr.RecordTypeId=[Select Id,Name from RecordType where sobjecttype='Warranty_Transfer__c' and Name = 'Commercial'].Id;
        ApexPages.StandardController sc = new ApexPages.StandardController(wr);        
        twod_WarrantyTransferCntrl pctl = new twod_WarrantyTransferCntrl(sc);        
        pctl.cancel();
    }
}