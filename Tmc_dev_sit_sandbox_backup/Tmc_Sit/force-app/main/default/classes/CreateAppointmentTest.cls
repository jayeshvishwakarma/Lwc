/**
* @File Name          : CreateAppointmentTest.cls
* @Description        : It is utilized to Create CreateAppointment & CancelAppointment Apex Test Class
* @Author             : Nitin Ghai
* @Group              : 
* Apex Class          : CreateAppointment & CancelAppointment
* @Last Modified By   : 
* @Last Modified On   : 7/01/2020
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                    Modification
*==============================================================================
* 1.0    7/01/2020                   Nitin Ghai               Initial Version
* 1.1    29/05/2020                  Nitin Ghai               Added Method to to cover CancelAppointment Apex Class 
**/

@isTest
public class CreateAppointmentTest {

    @TestSetup public static void run(){
		System.runAs([select Id from User where Id = :UserInfo.getUserId()][0]) {
             test.startTest();
            
            // To Create Dealer records
            List<Account> dealerAccount =TestDataFactory.createBusinessAccount(1,'Dealer');
            dealerAccount[0].Dealer_Map_Code__c='1044';
            dealerAccount[0].Dealer_Location__c='OKF';
            insert dealerAccount;
            
            // To create Contact records
            List<Contact> contactRec = TestDataFactory.createTestContact(1,dealerAccount[0].Id);
            insert contactRec;
            
            Profile profileRec = [SELECT Id,Name FROM Profile WHERE Name =: System.Label.Service_CCE_Profile LIMIT 1];
            
            //UserRole ur = [SELECT Id,Name FROM UserRole LIMIT 1]; 
            UserRole ur = new UserRole(name = 'TEST ROLE');
            insert ur;
            //To Create Partner User records
            List<User> partnerUser = TestDataFactory.createUserData('Portal',profileRec.Name,contactRec);
            partnerUser[0].Dealer_Employee_Code__c='1044_1044';
            partnerUser[0].PortalRole = 'Manager';
            //insert partnerUser;
            //List<User> us = [Select Id,Name,Contact.Account.Dealer_Map_Code__c,Contact.Account.Dealer_Location__c from User where ContactId=:contactRec[0].Id];
            
           
            
            // To create MMS Vehcile Record
            List<MMS_Vehicle__c> mmsVehicleRecord = TestDataFactory.CreateMMSVehicleRecords(1,dealerAccount[0].Id,dealerAccount[0].Dealer_Map_Code__c,dealerAccount[0].Dealer_Location__c);
            insert mmsVehicleRecord;
            
            //To Create Customer records
            List<Account> customerRec = TestDataFactory.createPersonAccount(1);
            insert customerRec;
            
            
            // To Create Asset record and Link with Customer record
            List<Asset> assetRec = TestDataFactory.CreateAssetsRecords(1);
            assetRec[0].AccountId=customerRec[0].Id;
            assetRec[0].Registration_Number__c='HR30R7914';
            insert assetRec[0];
            
            
            // To create Work Order records
            List<WorkOrder> workOrdRec = TestDataFactory.CreateWorkOrderRecords(1,'Service Appointment',String.valueOf(assetRec[0].Id),String.valueOf(customerRec[0].Id),dealerAccount[0].Id);
            workOrdRec[0].SA_Code__c='1044';
            workOrdRec[0].MMS_Vehicle__c=mmsVehicleRecord[0].Id;
            //workOrdRec[0].Service_Number__c='SB892283893';
            insert workOrdRec;
            
            // To Create Pickup Location Records
            List<Pickup_Location__c> pickLocRec = TestDataFactory.createPickupLocation(1,dealerAccount[0].Id);
            pickLocRec[0].Location_Code__c='Test';   
            insert pickLocRec;
            
            test.stopTest();
    	}
    }
    
    @isTest public static void testMethod1(){
        test.startTest();
        BasicReturn result = new BasicReturn();
        result.code = 0;
        result.status = 'Error';
        List<WorkOrder> workRec = [Select Id,AssetId,Mileage__c,Service_Type__c,Workshop__c	,Appointment_Type__c,Appointment_Datetime__c,SA_Code__c,Slot_Code__c,Slot_Time__c,AccountId 
                                   ,Pickup_Type__c,Pickup_Datetime__c,Pickup_Address__c,Drop_Datetime__c,Drop_Address__c,Description,Service_Number__c,MMS_Vehicle__c
                                   From WorkOrder where Status='New' AND SA_Code__c='1044' LIMIT 1];
        
        List<User> us = [Select Id,Name,Contact.Account.Dealer_Map_Code__c,Contact.Account.Dealer_Location__c,Contact.Account.Parent_Group__c from User where isPortalEnabled = true and profile.name =: System.Label.Service_CCE_Profile limit 2];
        
        List<Account> customerRec = [Select Id from Account WHERE isPersonAccount=True AND LastName='account'];
        
        List<Account> workShopRec = [Select Id,Dealer_Map_Code__c,Dealer_Location__c from Account WHERE isPersonAccount=False AND Dealer_Map_Code__c='1044' AND Dealer_Location__c='OKF'];        
        //Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        system.debug('workRec[0]---->'+workRec[0]);
        
        CreateAppointment.saveAppointment(String.valueOf(workRec[0]),'Test1','Test2','Test3','Test4',workShopRec[0]);
        CreateAppointment.sendAppointmentUpdates(workRec[0],us[0],'Test','Test1','Test2','Test3',workShopRec[0]);
        
        Map<String,String> mapRec = new Map<String,String>();
        
        CreateAppointment.fetchAppointmentData(workRec[0].Id);
        CreateAppointment.fetchAppointmentData(customerRec[0].Id);
        CreateAppointment.fetchAvailableSlots(mapRec,String.valueof(workRec[0].Workshop__c));
        CreateAppointment.getMMSVehicle(workRec[0].Id);
        CreateAppointment.getUserIdByEmployeeCode('1044_1044',us[0]);
        CreateAppointment.RequestBody wrapper = new CreateAppointment.RequestBody();
        CreateAppointment.getCustomerAssets(customerRec[0].Id,'Ciaz');
        CancelAppointment.fetchWorkShopRec(workRec[0].Id);
        CreateAppointment.storeAppointment(JSON.serialize(workRec[0].Id),'SB892283893');
        CreateAppointment.fetchPickupLoc(workRec[0].Id);
        CreateAppointment.fetchDriverList(customerRec[0].Id);
        
        test.stopTest();
    }
    
    @isTest public static void testMethod2(){
        
        test.startTest();
        BasicReturn result = new BasicReturn();
        result.code = 0;
        result.status = 'Error';
        
        List<WorkOrder> updateWorkOrdRec = new List<WorkOrder>();
        for(WorkOrder work : [Select Id,AssetId,Mileage__c,Service_Type__c,Appointment_Type__c,Workshop__c,Appointment_Datetime__c,SA_Code__c,Slot_Code__c,Slot_Time__c,AccountId 
                              ,Pickup_Type__c,Pickup_Address__c,Drop_Datetime__c,Drop_Address__c,Description,Service_Number__c
                              From WorkOrder where Status='New' AND SA_Code__c='1044' LIMIT 1]){
                                  work.Pickup_Type__c='';
                                  work.Pickup_Datetime__c=null;
                                  work.Pickup_Address__c='';
                                  work.Drop_Datetime__c=null;
                                  work.Drop_Address__c='';
                                  work.Description='';
                                  work.MMS_Vehicle__c=null;
                                  work.Pickup_Type__c='MMS';
                                  work.Service_Number__c='SB892283893';
                                  updateWorkOrdRec.add(work);
                              }
        update updateWorkOrdRec;
        String workOrderJSON = JSON.serialize(updateWorkOrdRec[0]);
        
        List<User> us = [Select Id,Name,Contact.Account.Dealer_Map_Code__c,Contact.Account.Dealer_Location__c,Contact.Account.Parent_Group__c from User where isPortalEnabled = true and profile.name =: System.Label.Service_CCE_Profile limit 2];
        system.debug('us---->'+us[0].Contact.Account.Dealer_Map_Code__c);
        system.debug('us---->'+us[0].Contact.Account.Dealer_Location__c);
        system.debug('updateWorkOrdRec---->'+updateWorkOrdRec[0]);
        map<String,string> workorderMap = new map<string,string>();
        workorderMap.put('odometer','123');
        workorderMap.put('serviceType','FR1');
        workorderMap.put('appointmentType','CAMP');
        workorderMap.put('slotCD','test');
        workorderMap.put('slotTime','test');
        
        List<Account> customerRec = [Select Id from Account WHERE isPersonAccount=True AND LastName='account'];
        
        List<Account> workShopRec = [Select Id,Dealer_Map_Code__c,Dealer_Location__c from Account WHERE isPersonAccount=False AND Dealer_Map_Code__c='1044' AND Dealer_Location__c='OKF']; 
        system.debug('workShopRec----->'+workShopRec);
        CreateAppointment.saveAppointment(String.valueOf(updateWorkOrdRec[0]),'Test1','Test2','Test3','Test4',workShopRec[0]);
        CreateAppointment.sendAppointmentUpdates(updateWorkOrdRec[0],us[0],'result','','','',workShopRec[0]);
        CreateAppointment.createWorkOrderRecord(JSON.serialize(workorderMap));
        
        Map<String,String> mapRec = new Map<String,String>();
        
        CreateAppointment.fetchAppointmentData(updateWorkOrdRec[0].Id);
        CreateAppointment.fetchAppointmentData(customerRec[0].Id);
        CreateAppointment.fetchAvailableSlots(mapRec,String.valueof(updateWorkOrdRec[0].Workshop__c));
        CreateAppointment.getUserIdByEmployeeCode('1044_1044',us[0]);
        CreateAppointment.getMMSVehicle(workShopRec[0].Id);
        CreateAppointment.getCustomerAssets(customerRec[0].Id,'');
        CreateAppointment.storeAppointment(JSON.serialize(workShopRec[0].Id),'');
        
        
        
        test.stopTest();
    }
}