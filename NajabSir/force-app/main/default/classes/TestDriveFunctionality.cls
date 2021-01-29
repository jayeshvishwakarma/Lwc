/**
 * @File Name          : TestDriveFunctionality.cls
 * @Description        : This class is used for TestDrive creation and updation
 * @Author             : Rajesh Ramachandran
 * @Group              : 
 * @Last Modified By   : Rajesh Ramachandran
 * @Last Modified On   : 12/21/2019, 6:59:48 AM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                    Modification
 *==============================================================================
 * 1.0    7/11/2019, 6:52:23 AM   Rajesh Ramachandran     Initial Version
 * 1.1    08/01/2019              Sunit Kumar Chand       Add proper error handling
 * 1.2    09/25/2019              Sunit Kumar Chand       Commented findVariants function
**/
public without sharing class TestDriveFunctionality{


    /**
       Author: Sunit kumar chand
       Company: Techmatrix
       Description: It will find variant from products
       Inputs: Model string,Variant string
       Returns: List of Products
       History:
       ================
       1.0     11 Jul 2019      Sunit     Initial Version
    */
    @AuraEnabled(cacheable=true)
    public static BasicReturn findVariants(String searchVar)
    {
        List<Product2> proList=null;
        BasicReturn br=new BasicReturn();
        try{
            if(String.isNotBlank(searchVar) && Schema.sObjectType.Product2.fields.Family.isAccessible()){
                 proList= [Select Id, Name, Family,ProductCode from Product2 where Recordtype.Name=:ConstantsUtility.TD_PRODUCT_VARIANT_RECORDTYPE and IsActive = True and Model__c =:searchVar ];
                 br.code=200;
                 br.status='Success';
                 br.message='Success';
                 br.dataList=proList;
            }
        }
        catch(Exception e){
            e.getStackTraceString();
            br.code=0;
            br.status='Error';
            br.message=e.getMessage();
        }
        return br;
    }
    @AuraEnabled(cacheable=true)
    public static BasicReturn findVariantsForStockCheck(String searchVar)
    {
        List<Product2> proList=null;
        BasicReturn br=new BasicReturn();
        try{
            if(String.isNotBlank(searchVar) && Schema.sObjectType.Product2.fields.Family.isAccessible()){
                 proList= [Select Id, Name, Family,ProductCode from Product2 where Recordtype.Name=:ConstantsUtility.TD_PRODUCT_VARIANT_RECORDTYPE and IsActive = True and Model__c =:searchVar];
                 br.code=200;
                 br.status='Success';
                 br.message='Success';
                 br.dataList=proList;
            }
        }
        catch(Exception e){
            e.getStackTraceString();
            br.code=0;
            br.status='Error';
            br.message=e.getMessage();
        }
        return br;
    }
    
    /**
       Author: Sunit kumar chand
       Company: Techmatrix
       Description: It will find VIN from Asset
       Inputs: Variant string,Model string
       Returns: List of Asset
       History:
       ================
       1.0     11 Jul 2019      Sunit     Initial Version
    */
    @AuraEnabled
    public static List<Asset> findVIN(String selectedName,String dealerAccount,String fuleType){ 
       
        List<Asset> assetsList=new List<Asset>();
        try{
            if(Schema.sObjectType.Asset.fields.SerialNumber.isAccessible()){
               String dealershipId = dealerAccount;
                if(fuleType!=''&& fuleType!=null){
                    //Loop through Asset and filter out non purchased Assets
                    for(Asset assetObj : [Select Id,SerialNumber,Product2.Name,VIN__c,Product2.ProductCode,Name,Status from Asset Where Recordtype.Name=:ConstantsUtility.TESTDRIVE_RECORDTYPE 
                                            and AccountId=:dealershipId and Product2.Model__c =:selectedName and Product2.Fuel_Type__c=:fuleType]){

                        if((string.isNotEmpty(assetObj.VIN__c))&&(assetObj.VIN__c.startsWithIgnoreCase('__TD__'))){
                            assetObj.VIN__c = assetObj.VIN__c.replace('__TD__','');
                        }

                                            
                        if(assetObj.Status!= ConstantsUtility.ASSET_PURCHASED){
                            assetsList.add(assetObj);
                        }
                    }
                }
                else{
                    for(Asset assetObj : [Select Id,SerialNumber,Product2.Name,VIN__c,Product2.ProductCode,Name,Status from Asset Where Recordtype.Name=:ConstantsUtility.TESTDRIVE_RECORDTYPE 
                                            and AccountId=:dealershipId and Product2.Model__c =:selectedName]){

                        if((string.isNotEmpty(assetObj.VIN__c))&&(assetObj.VIN__c.startsWithIgnoreCase('__TD__'))){
                            assetObj.VIN__c = assetObj.VIN__c.replace('__TD__','');
                        }


                        if(assetObj.Status!= ConstantsUtility.ASSET_PURCHASED){
                            assetsList.add(assetObj);
                        }
                    }
                }         
            }
        }
        catch(Exception e){
            e.getStackTraceString();   
        }
        return assetsList;
    }
     
    
    
    
    /**
       Author: Sunit kumar chand
       Company: Techmatrix
       Description: This function is used to create test drive record on Salesforce
       Inputs: Variant string,Model string
       Returns: List of Asset
       History:
       ================
       1.0     11 Jul 2019      Sunit     Initial Version
    */
    @AuraEnabled
    public static BasicReturn createTestDriveSF(String data){
        Test_Drive__c tc=new Test_Drive__c();
        BasicReturn br=new BasicReturn();
        
        try{
            Map<String,Object> jsonData= (Map<String,Object>)JSON.deserializeUntyped(data);
            tc.Enquiry__c=(String)jsonData.get('enquiryId');
            tc.Contact__c=(String)jsonData.get('contactId');
            tc.Status__c=(String)jsonData.get('status');
            tc.Test_Drive_Vehicle__c=(String)jsonData.get('assetId');
            
            String bookingDate=(String)jsonData.get('bookingDate');
            String bookingStartTime=(String)jsonData.get('startTime');
            String bookingEndTime=(String)jsonData.get('endTime');
            
            String[] dateSplit=bookingDate.split('-');
            String[] startTimeSplit=bookingStartTime.split(':');
            String[] endTimeSplit=bookingEndTime.split(':');
            
            if(tc.Status__c=='COMPLETED'){
                DateTime accStartDateTime=DateTime.newInstance(Integer.valueof(dateSplit[0]), Integer.valueof(dateSplit[1]), Integer.valueof(dateSplit[2]),Integer.valueof(startTimeSplit[0]),Integer.valueof(startTimeSplit[1]),00);
                DateTime accEndDateTime=DateTime.newInstance(Integer.valueof(dateSplit[0]), Integer.valueof(dateSplit[1]), Integer.valueof(dateSplit[2]),Integer.valueof(endTimeSplit[0]),Integer.valueof(endTimeSplit[1]),00);
                tc.Actual_Start__c=accStartDateTime;
                tc.Actual_End__c=accEndDateTime;
                tc.KM_Driven__c=Decimal.valueOf((String)jsonData.get('kmDriven'));
                tc.Satisfied_with_the_Test_Drive__c=(String)jsonData.get('satisfied');
                tc.Test_Drive_Feedback__c=(String)jsonData.get('feedback');
                tc.Duration__c=(Decimal)jsonData.get('duration');
                
                //Update Opportunity
                updateOpportunity(tc.Enquiry__c);
                
            }else{
                DateTime startDateTime = DateTime.newInstance(Integer.valueof(dateSplit[0]), Integer.valueof(dateSplit[1]), Integer.valueof(dateSplit[2]), startTimeSplit.size()>0?Integer.valueof(startTimeSplit[0]):Integer.valueof(bookingStartTime), startTimeSplit.size()>1?(Integer.valueof(startTimeSplit[1])==3?30:Integer.valueof(startTimeSplit[1])):0, 0);
                DateTime endDateTime = DateTime.newInstance(Integer.valueof(dateSplit[0]), Integer.valueof(dateSplit[1]), Integer.valueof(dateSplit[2]), endTimeSplit.size()>0?Integer.valueof(endTimeSplit[0]):Integer.valueof(bookingEndTime), endTimeSplit.size()>1?(Integer.valueof(endTimeSplit[1])==3?30:Integer.valueof(endTimeSplit[1])):0, 0);
                tc.Scheduled_Start__c=startDateTime;
                tc.Scheduled_End__c=endDateTime;
            }
            
            tc.DMS_Booking_ID__c=(String)jsonData.get('bookingId');
            tc.Location__c=(String)jsonData.get('location');
            tc.Fuel_Type__c=(String)jsonData.get('fuelType');
            tc.SVOC_Customer__c=(String)jsonData.get('svocCustomer');
            
            if(Schema.sObjectType.Test_Drive__c.fields.Status__c.IsCreateable()){
                insert tc;
                br.code=200;
                br.status='Success';
                br.message=ConstantsUtility.TEST_DRIVE_SUCCESS_MESSAGE;
                br.createdId=tc.Id;
            }
        }catch(Exception e){
            br.code=0;
            br.status='Error';
            br.message=e.getMessage();
       }
        return br;
    }


    /**
       Author: Sunit kumar chand
       Company: Techmatrix
       Description: This method will return test drive record
       Inputs: Id of Test Drive object
       Returns: Test drive record
       History:
       ================
       1.0     11 Jul 2019      Sunit     Initial Version
    */
    @AuraEnabled(cacheable=true)
    public static Test_Drive__c getTestDrive(String id)
    {
        Test_Drive__c td=null;
        try{  
            if(Schema.sObjectType.Test_Drive__c.fields.Name.isAccessible()){
                td=[select Id,Name,DMS_Booking_ID__c,Location__c,Enquiry__r.Name,Status__c,Variant__c,
                    Scheduled_Start__c,Scheduled_End__c,Enquiry__r.DMS_Enquiry_Name__c,Enquiry__r.Customer__r.PersonContactId,
                    Enquiry__r.DSE_MSPIN__c,Enquiry__r.Customer__c,Test_Drive_Vehicle__r.Product2.Model__c,
                    Test_Drive_Vehicle__r.VIN__c,Enquiry__c,Test_Drive_Vehicle__r.Product2.ProductCode from Test_Drive__c where Id=:id];
                
                
                Integer offset = UserInfo.getTimezone().getOffset(td.Scheduled_Start__c);
                td.Scheduled_Start__c = td.Scheduled_Start__c.addSeconds(offset/1000);
                td.Scheduled_End__c = td.Scheduled_End__c.addSeconds(offset/1000);
            }
        }
        
        catch(Exception e){
            e.getStackTraceString();
        }
        return td;
    }
    
    
    /**
       Author: Sunit kumar chand
       Company: Techmatrix
       Description: This method will update test drive record
       Inputs: Test drive data in string format
       Returns: boolean
       History:
       ================
       1.0     12 Jul 2019      Sunit     Initial Version
    */
    @AuraEnabled
    public static BasicReturn updateTestDrive(String data){
        Boolean updated=false;
        BasicReturn br= new BasicReturn();
        try{
            
            UpdateTestDriveDeserialize utdd=(UpdateTestDriveDeserialize)JSON.deserialize(data, UpdateTestDriveDeserialize.class);
            
            Test_Drive__c tc=new Test_Drive__c();
            tc.Id=utdd.id;
            String[] dateSplit=utdd.selectedDate.split('-');
            String[] startTimeSplit=utdd.startTime.split(':');
            String[] endTimeSplit=utdd.endTime.split(':');
            
            if(utdd.status=='COMPLETED'){
                DateTime accStartDateTime=DateTime.newInstance(Integer.valueof(dateSplit[0]), Integer.valueof(dateSplit[1]), Integer.valueof(dateSplit[2]),Integer.valueof(startTimeSplit[0]),Integer.valueof(startTimeSplit[1]),00);
                DateTime accEndDateTime=DateTime.newInstance(Integer.valueof(dateSplit[0]), Integer.valueof(dateSplit[1]), Integer.valueof(dateSplit[2]),Integer.valueof(endTimeSplit[0]),Integer.valueof(endTimeSplit[1]),00);
                tc.Actual_Start__c=accStartDateTime;
                tc.Actual_End__c=accEndDateTime;
                tc.KM_Driven__c=Decimal.valueOf(utdd.kmDriven);
                tc.Duration__c=Decimal.valueOf(utdd.duration);
                tc.DMS_Booking_ID__c=utdd.bookingId;
                tc.Satisfied_with_the_Test_Drive__c=utdd.satisfied;
                tc.Test_Drive_Feedback__c=utdd.feedback;
                
                //Update Opportunity
                updateOpportunity(utdd.enquiryId);
                
                
            }
            else{
                DateTime startDateTime = DateTime.newInstance(Integer.valueof(dateSplit[0]), Integer.valueof(dateSplit[1]), Integer.valueof(dateSplit[2]), startTimeSplit.size()>0?Integer.valueof(startTimeSplit[0]):Integer.valueof(startTimeSplit), startTimeSplit.size()>1?(Integer.valueof(startTimeSplit[1])==3?30:Integer.valueof(startTimeSplit[1])):0, 0);
                DateTime endDateTime = DateTime.newInstance(Integer.valueof(dateSplit[0]), Integer.valueof(dateSplit[1]), Integer.valueof(dateSplit[2]), endTimeSplit.size()>0?Integer.valueof(endTimeSplit[0]):Integer.valueof(endTimeSplit), endTimeSplit.size()>1?(Integer.valueof(endTimeSplit[1])==3?30:Integer.valueof(endTimeSplit[1])):0, 0);
                tc.Scheduled_Start__c=startDateTime;
                tc.Scheduled_End__c=endDateTime;
            }
            
            String[] oldDatesplit=utdd.oldStartDate.split('T')[0].split('-');
            String[] oldTimesplit=utdd.oldStartDate.split('T')[1].split(':');
            DateTime oldStartDateTime = DateTime.newInstance(Integer.valueof(oldDatesplit[0]), Integer.valueof(oldDatesplit[1]), Integer.valueof(oldDatesplit[2]),Integer.valueof(oldTimesplit[0]), Integer.valueof(oldTimesplit[1]), 0);
            tc.Location__c=utdd.location;
            tc.Status__c=utdd.status;
            tc.Old_Scheduled_Start_Date_Time__c=oldStartDateTime;
            
            if(Schema.sObjectType.Test_Drive__c.fields.Status__c.isUpdateable()){
                update tc;
                /*** This part is used to create MC_Communication__c record for MC use ***/
                if(utdd.status!='COMPLETED'){
                    set<Id> testDriveId=new set<Id>();
                    testDriveId.add(utdd.id);
                    GenerateFilePublicURL.CreateMCRecord(ConstantsUtility.TD_RESCHEDULE,testDriveId,ConstantsUtility.TEST_DRIVE, '');
                }
                
                updated=true;
                br.code=200;
                br.status='Success';
                br.message='Test drive is updated.';
            } 
        }
        catch(Exception e){
            System.debug(e.getStackTraceString()); 
            br.code=0;
            br.status='Error';
            br.message=e.getMessage();
        }
        return br;
    }


    /**
       Author: Prabhat Sharma
       Company: Techmatrix
       Description: Method to update the Opportunity when Test Drive has been given
       History:
       ================
       1.0     23 Dec 2019      Prabhat     Initial Version
    */
    public static void updateOpportunity(String opportunityId){
    
        List<Opportunity> updateOpportunity = new list<Opportunity>();
        
        for(Opportunity opp : [SELECT Id,Test_Drive_Given__c FROM Opportunity WHERE Id=:opportunityId]){
            if(String.isBlank(opp.Test_Drive_Given__c) || opp.Test_Drive_Given__c == 'N'){
                opp.Test_Drive_Given__c = ConstantsUtility.BCR_SENT;
                updateOpportunity.add(opp);
            }
        }
        
        //Update Opportunity
        if(updateOpportunity.size()>0){
            TriggerHandler.bypass('OpportunityTriggerHandler');
            update updateOpportunity;
            TriggerHandler.clearBypass('OpportunityTriggerHandler');
        }
    }
    
    
    
    /**
       Author: Sunit kumar chand
       Company: Techmatrix
       Description: This class is used for deserialization
       History:
       ================
       1.0     11 Jul 2019      Sunit     Initial Version
    */
    public class UpdateTestDriveDeserialize {
        public String id;
        public String status;
        public String location;
        public String selectedDate;
        public String selectedSlot;
        public String startTime;
        public String endTime;
        public String oldStartDate;
        public String kmDriven;
        public String bookingId;
        public String satisfied;
        public String feedback;
        public String duration;
        public String enquiryId;

    }
}