/*------------------------------------------------------------------------------------
Author:        Nitin Ghai
Description:   Create Appointment Controller

History
Date            Author                Comments
--------------------------------------------------------------------------------------
27-12-2019      Nitin Ghai            Initial Release
06-03-2020      Nitin Ghai            Added fetchWorkShopList method
14-03-2020      Sunit Kumar Chand     Added getCustomerAssets method
23-04-2020      Nitin Ghai            Added fetchPickupLoc method
15-05-2020      Nitin Ghai            Updated fetchWorkShopList & fetchDriverList method
                                      removed 2S & 3S Dealer Type Condition
18-05-2020      Nitin Ghai            Updated getUserIdByEmployeeCode method to check the SA belongs to same Dealership parent group
09-06-2020      Nitin Ghai            If SA doesnt exist in Salesforce then Owner and SA Name will be populated as CCE Agent(logged in User)
09-06-2020      Nitin Ghai            Removed String dealerClause from getSearchResults method
21-06-2020      Nitin Ghai            Added For_Code__r.For_Code__c field to be used in serviceCalculator LWC
30-06-2020      Nitin Ghai            Added new method getMMSVehicle and removed getSearchResults & getSearchResultsData method
06-07-2020      Sunit Kumar Chand     OwnerId added to query in fetchAppointmentData method
18-09-2020      Sunit Kumar Chand     added existing workorder check and empty check for dates in createWorkOrderRecord method
24-09-2020      Prashant Gahlaut      map Workshop__c with dealerSFId and also put in SOQL where clause of createWorkOrderRecord method
------------------------------------------------------------------------------------*/
public without sharing class CreateAppointment {

    public static User currUser;

    /**
    Author: Nitin Ghai
    Company: Techmatrix
    Description: This method will return the MMS Vehicles for the assigned Workshop
    Return: List<MMS_Vehicle__c>
    Inputs: RecordId(Account) WorkShop ID
    History:
    ================
    1.1A     30 June 2020      Nitin     Initial Version
    */
    @AuraEnabled
    public static List<MMS_Vehicle__c> getMMSVehicle(String workshopId){
        List<MMS_Vehicle__c> mmsVeh = new List<MMS_Vehicle__c>();
        if(String.isNotBlank(workshopId)){
            mmsVeh =  [SELECT Id,Name,Dealer__c,Location_Code__c,Parent_Group__c,Dealer_Map_Code__c,Active__c
                       FROM MMS_Vehicle__c where Dealer__c!=NULL AND Dealer__c=:workshopId];
        }
        return mmsVeh;
    }

    /**
    Author: Nitin Ghai
    Company: Techmatrix
    Description: This method is used to fetch Either WorkOrder or Account record on the basis of RecordId passed as Input parameter
    Return: Wrapper
    Inputs: RecordId(Account or WorkOrder)
    History:
    ================
    1.1A     27 Dec 2019      Nitin     Initial Version
    */
    @AuraEnabled
    public static AppointmentData fetchAppointmentData(String recordId) {
        AppointmentData ci = new AppointmentData();
        if(Id.valueOf(recordId).getSobjectType() == WorkOrder.getSObjectType()) {
            ci.workOrder = [SELECT Id, Account.Name, AssetId, Asset.Name, Asset.Registration_Number__c,Workshop__c,Workshop__r.Dealer_Map_Code__c,
                            Status, Subject, Description, Appointment_Type__c, Service_Type__c, Appointment_Datetime__c,Workshop__r.Dealer_Location__c,
                            Due_Date__c, Mileage__c, Pickup_Type__c, Pickup_Datetime__c, Pickup_Location__c, Pickup_Address__c,
                            Drop_Datetime__c, Drop_Location__c, Drop_Address__c, Address__c, SA_Id__r.Name, SA_Code__c, Slot_Time__c,
                            Slot_Code__c, MMS_Vehicle__c, RecordTypeId, Service_Number__c, Drop_Location__r.Name, Drop_Location__r.Location_Code__c,
                            Pickup_Location__r.Name,Executive_Manager__c, Pickup_Location__r.Location_Code__c
                            , MMS_Vehicle__r.Name,Pickup_Driver__c,OwnerId,
                            Pickup_Driver__r.Dealer_Employee_Code__c,Pickup_Driver__r.Name,Drop_Driver__c
                            ,Drop_Driver__r.Dealer_Employee_Code__c,Drop_Driver__r.Name
                            FROM WorkOrder WHERE Id = :recordId];
            ci.account = ci.workOrder.Account;
            ci.assetList = new List<Asset>{ ci.workOrder.Asset };
                ci.workshopList=fetchWorkShopList();
            if(String.isNotBlank(ci.workOrder.Workshop__c)){
                //ci.workshopDriverList=fetchDriverList(ci.workOrder.Driver__c);
            }
        } else if(Id.valueOf(recordId).getSobjectType() == Account.getSObjectType()) {
            Account account = [SELECT Id, Name, BillingAddress,Dealer_Map_Code__c,Dealer_Location__c,Parent_Group__c, (SELECT Id, Name, Registration_Number__c FROM Assets) FROM Account WHERE Id = :recordId];
            ci.account = account;
            ci.assetList = account.Assets;
            Id woRecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('Service_Appointment').getRecordTypeId();
            ci.workOrder = new WorkOrder(AccountId = account.Id, RecordTypeId = woRecordTypeId);
            ci.workshopList=fetchWorkShopList();
        }
        return ci;
    }

    /**
    Author: Sunit kumar chand
    Company: Techmatrix
    Description: It will find related Asset of customer
    Inputs: AccountId string,searchKey string
    Returns: List of Asset
    History:
    ================
    1.1A     11 Jan 2020      Sunit     Initial Version
    1.1A     02 Apr 2020      Sunit     added record type condition
    */
    @AuraEnabled
    public static List<Asset> getCustomerAssets(String customerId,String searchKey){
        String recordTypeId=Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Vehicle').getRecordTypeId();
        if(searchKey!=null && searchKey!='')
        {
            searchKey='%'+searchKey+'%';
            return [SELECT Id, Name, Registration_Number__c FROM Asset where RecordTypeId=:recordTypeId and Name like:searchKey and AccountId=:customerId limit 10];
        }
        else{
            return [SELECT Id, Name, Registration_Number__c FROM Asset where RecordTypeId=:recordTypeId and AccountId=:customerId limit 10];
        }

    }

    /**
    Author: Nitin Ghai
    Company: TechMatrix
    Description: This method is used in createAppointment(LWC) to fetch the available slots of SA through API callout
    Return: Map<String, String>
    Inputs: API Request & Workshop Id
    History:
    ================
    1.1A     27 Dec 2019      Nitin Ghai    Initial Version
    */
    @AuraEnabled
    public static Map<String, String> fetchAvailableSlots(Map<String, String> request,String workshopId) {
        system.debug('request------>'+request);
        AppointmentData workshopRec = fetchAppointmentData(workshopId);
        request.put('dealerCode',workshopRec.account.Dealer_Map_Code__c);
        request.put('locationCode', workshopRec.account.Dealer_Location__c);
        request.put('parentGroup', workshopRec.account.Parent_Group__c);
        return request;

    }

    /**
    Author: Sunit kumar chand
    Company: Techmatrix
    Description: It will create or update appointment
    Inputs:
    Returns:
    History:
    ================
    1.1A     29 Apr 2020      Sunit     Initial Version
    */
    @AuraEnabled
    public static BasicReturn storeAppointment(String workOrderJSONString, String DPSAppointmentNo){
        BasicReturn br=new BasicReturn();
        br.code=200;
        try{
            WorkOrder wo = (WorkOrder) JSON.deserialize(workOrderJSONString, WorkOrder.class);
            if(String.isNotBlank(DPSAppointmentNo)) {
                wo.Service_Number__c = DPSAppointmentNo;
            }
            upsert wo;
            br.createdId=wo.id;
        }
        catch(Exception ex){
            System.enqueueJob(new AsyncExceptionHandler('storeAppointment','',+' : '+ex.getStackTraceString(), '',UserInfo.getUserId(), ''));
            br.code=001;
            br.message=ex.getMessage();
            br.status='Error';
        }

        return br;

    }
    /**
    Author: Nitin Ghai
    Company: Techmatrix
    Description: This method is used to create an Appointment
    Return: Map<String,Object>
    Inputs: WorkOrder(JSON), Pickup  & Drop Driver Employee Code,Pickup & Drop Location Code & Workshop(Account) record.
    History:
    ================
    1.1A     27 Dec 2019      Nitin     Initial Version
    1.1A     9th May 2020     Nitin     If SA doesnt exist in Salesforce then Owner and
                                        SA Name will be populated as CCE Agent(logged in User)
    */
    @AuraEnabled
    public static Map<String,Object> saveAppointment(String workOrderJSONString, String empCode, String dropEmpCode, String pickupLocCode, String dropLocCode,Account workshopRecord) {
        Map<String,Object> requestDetails=new Map<String,Object>();
        try{
            if(String.isNotBlank(workOrderJSONString) && workshopRecord!=NULL) {
                WorkOrder wo = (WorkOrder) JSON.deserialize(workOrderJSONString, WorkOrder.class);
                if (currUser == null){
                    currUser = getCurrentUser();
                }
                String saEmpId = getUserIdByEmployeeCode(workshopRecord.Dealer_Map_Code__c+'_'+wo.SA_Code__c,currUser);
                wo.SA_Id__c = String.isNotBlank(saEmpId)? saEmpId : String.valueOf(currUser.Id);
                wo.OwnerId= wo.SA_Id__c;
                requestDetails = sendAppointmentUpdates(wo, currUser, empCode, dropEmpCode, pickupLocCode, dropLocCode,workshopRecord);
            }
        } catch(Exception e) {
            ExceptionHandler.stackTrace ehst = new ExceptionHandler.stackTrace();ehst.componentName = 'CreateAppointment - LWC';ehst.userId = UserInfo.getUserId();ExceptionHandler.LogError('CreateAppointment - Class',e.getMessage()+' - Line Number: '+e.getLineNumber(), 'WorkOrder Object : saveAppointment - Method', '', ehst);
        }
        return requestDetails;
    }
    /**
    Author: Nitin Ghai
    Company: Techmatrix
    Description: This method is used fetch Dealer Employee Code
    Return: String
    Inputs: Employee Code & User Object
    History:
    ================
    1.1A     27 Dec 2019      Nitin     Initial Version
    */
    @TestVisible private static String getUserIdByEmployeeCode(String employeeCode,User usRec) {
        List<User> users = [SELECT Id FROM User WHERE Dealer_Employee_Code__c = :employeeCode limit 1];
        if(!users.isEmpty()) {
            return users.get(0).Id;
        }
        return null;
    }
    /**
    Author: Sumit
    Company: Salesforce
    Description: This method is used fetch logged in user record
    Return: User
    Inputs:
    History:
    ================
    1.1A     27 Dec 2019      Sumit     Initial Version
    */
    public static User getCurrentUser() {
        return [SELECT Id, Name,Manager.Name,Manager.MobilePhone,MobilePhone, ProfileId,Dealer_Account__c,Contact.Account.Dealer_Map_Code__c, Contact.Account.Dealer_Location__c, Contact.Account.Parent_Group__c,Contact.account.Parent_Workshop_Code__c
                FROM User where Id = :UserInfo.getUserId()];
    }
    /**
    Author: Sunit kumar chand
    Company: Techmatrix
    Description: It will create API request data and return Map
    Inputs: WorkOrder Object,User Object,String(SA Code),String(Drop Employee code,String(Pickup location Code),String (Drop location Code),Workshop(Account object))
    Returns: Map<String,Object>
    History:
    ================
    1.1A     29 Apr 2020      Sunit     Initial Version
    */
    public static Map<String,Object> sendAppointmentUpdates(WorkOrder wo, User usr, String empCode, String dropEmpCode,String pickupLocCode, String dropLocCode,Account workShop) {
        Map<String,Object> requestDetails=new Map<String,Object>();
        try{
            if(wo != NULL && String.isNotBlank(workShop.Dealer_Map_Code__c) && String.isNotBlank(workShop.Dealer_Location__c) && String.isNotBlank(wo.AssetId)) {
                String requestType = 'Update Appointment';

                //BasicReturn responsefromMulesoft = new BasicReturn();
                RequestBody jsonReq = new RequestBody();
                Asset assetRec = new Asset();
                MMS_Vehicle__c mmsVeh = new MMS_Vehicle__c();
                assetRec = [Select Registration_Number__c,Name, VIN__c FROM Asset Where ID = :wo.AssetId];
                if(String.isNotBlank(wo.MMS_Vehicle__c)){
                    mmsVeh = [Select Name from MMS_Vehicle__c where Id =: wo.MMS_Vehicle__c];}

                if(String.isNotBlank(workShop.Dealer_Map_Code__c) && String.isNotBlank(workShop.Dealer_Location__c)
                   && String.isNotBlank(assetRec.Name) && wo.Mileage__c != NULL
                   && String.isNotBlank(wo.Service_Type__c) && String.isNotBlank(wo.Appointment_Type__c) && wo.Appointment_Datetime__c != NULL
                   && String.isNotBlank(wo.SA_Code__c) && String.isNotBlank(wo.Slot_Code__c) && String.isNotBlank(wo.Slot_Time__c)) {
                       jsonReq.dealerCode =Integer.valueOf(workShop.Dealer_Map_Code__c);
                       jsonreq.locationCode = workShop.Dealer_Location__c;
                       jsonreq.userID = '';
                       jsonreq.registrationNum = assetRec.Name;
                       jsonreq.odometer = wo.Mileage__c;
                       jsonreq.serviceType = wo.Service_Type__c;
                       jsonreq.appointmentType = wo.Appointment_Type__c;
                       jsonreq.appointmentDate = String.valueof((wo.Appointment_Datetime__c).date());
                       jsonreq.currentSA = wo.SA_Code__c;
                       jsonreq.slotCD = wo.Slot_Code__c;
                       jsonreq.slotTime = String.valueof((wo.Slot_Time__c).replace(':', ''));

                       if(String.isNotBlank(wo.Pickup_Type__c)) {
                           jsonreq.pickUpType = wo.Pickup_Type__c;
                       } else {
                           jsonreq.pickUpType = '';
                       }
                       if(String.isNotBlank(pickupLocCode)) {
                           jsonreq.pickUpLoc = pickupLocCode;
                       } else {
                           jsonreq.pickUpLoc = '';
                       }
                       if(wo.Pickup_Datetime__c != NULL) {
                           jsonreq.pickUpTime = String.valueof(wo.Pickup_Datetime__c).replace(' ', 'T');
                       } else {
                           jsonreq.pickUpTime = '';
                       }
                       if(String.isNotBlank(wo.Pickup_Address__c)) {
                           jsonreq.pickUpAddress = wo.Pickup_Address__c;
                       } else {
                           jsonreq.pickUpAddress = '';
                       }
                       if(String.isNotBlank(dropLocCode)) {
                           jsonreq.dropLoc = dropLocCode;
                       } else {
                           jsonreq.dropLoc = '';
                       }
                       if(wo.Drop_Datetime__c != NULL) {
                           jsonreq.dropTime = String.valueof(wo.Drop_Datetime__c).replace(' ', 'T');
                       } else {
                           jsonreq.dropTime = '';
                       }
                       if(String.isNotBlank(wo.Drop_Address__c)) {
                           jsonreq.dropAddress = wo.Drop_Address__c;
                       } else {
                           jsonreq.dropAddress = '';
                       }
                       if(String.isnotblank(empCode)) {
                           jsonreq.driver = empCode;
                       } else {
                           jsonreq.driver = '';
                       }
                       if(wo.Pickup_Type__c == 'MMS') {
                           jsonreq.VehicleNum = mmsVeh.Name;
                       } else {
                           jsonreq.VehicleNum = '';
                       }
                       if(String.isNotBlank(wo.Description)) {
                           jsonreq.pickUpRemarks = wo.Description;
                       } else {
                           jsonreq.pickUpRemarks = '';
                       }
                       jsonreq.remarksNotSelectSA = '';
                       jsonreq.demandJobs = '';
                       if(String.isNotBlank(dropEmpCode)) {
                           jsonreq.dropDriver = dropEmpCode;
                       } else {
                           jsonreq.dropDriver = '';
                       }
                       system.debug('jsonreq------>'+JSON.serialize(jsonreq));
                       String creatAppointmentJsonBody;
                       if(String.isNotBlank(wo.Id) && String.isNotBlank(wo.Service_Number__c) && jsonreq != NULL) {
                           requestDetails.put('bodyData',JSON.serialize(jsonreq));
                           requestDetails.put('apiName',System.label.Update_Appointment);
                           requestDetails.put('urlPart',wo.Service_Number__c);
                           requestDetails.put('workOrder',JSON.serialize(wo));
                       } else {
                           requestDetails.put('bodyData',JSON.serialize(jsonreq));
                           requestDetails.put('apiName',System.label.Create_Appointment);
                           requestDetails.put('urlPart','');
                           requestDetails.put('workOrder',JSON.serialize(wo));
                       }
                   } else {
                   }
            } else {
            }

        } catch(exception e) {
            ExceptionHandler.stackTrace ehst = new ExceptionHandler.stackTrace();ehst.componentName = 'CreateAppointment - LWC';ehst.userId = UserInfo.getUserId();ExceptionHandler.LogError('CreateAppointment - Class',e.getMessage()+' - Line Number: '+e.getLineNumber(), 'WorkOrder Object : sendAppointmentUpdates - Method', '', ehst);
        }
        return requestDetails;
    }
    /**
    Author: Nitin Ghai
    Company: Techmatrix
    Description: Wrapper Class to contains Account,List<Asset>,WorkOrder,List<Pickup_Driver__c> & List<Account>(workshopList)
    ================
    1.1A     09/03/2020      Nitin Ghai    Initial Version
    */
    public class AppointmentData {
        @AuraEnabled public Account account;
        @AuraEnabled public List<Asset> assetList;
        @AuraEnabled public WorkOrder workOrder;
        @AuraEnabled public List<User> workshopDriverList;
        @AuraEnabled public List<Account> workshopList; //Added
    }
    /**
    Author: Nitin
    Company: TechMatrix
    Description: This Method is getting used to fetch Workshop List
    Return: List<Account>
    Inputs:
    History:
    ================
    1.1A     17th March 2020      Nitin     Initial Version
    1.1A     19th March 2020      Nitin     Added Parent_Workshop_Code__c change
    1.1A     21st June  2020      Nitin     Added For_Code__r.For_Code__c field to be used in ServiceCalculator Apex class
	1.1A     26th Aug   2020      Sunit     Added Parent_Group__c in query
    */
    @AuraEnabled
    public static List<Account> fetchWorkShopList(){
        if (currUser == null){
            currUser = getCurrentUser();
        }
        User userRecords = currUser;
        List<Account> workshopList = new List<Account>();
        Id dealerRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId();
        if(userRecords!=NULL){
            workshopList = [Select Id,Name,Dealer_Address_F__c,Google_Link__c,Dealer_CC_Email__c,Parent_Workshop_Code__c,Dealer_CC_Phone__c,
                            Dealer_Location__c,Dealer_Map_Code__c,For_Code__c,For_Code__r.For_Code__c,Parent_Group__c,For_Code__r.Name,Region_Code__c,Dealer_Type__c,
                            Dealer_Code__c,Primary_Dealer_QCM__c FROM Account 
                            where Parent_Workshop_Code__c=:userRecords.Contact.Account.Parent_Workshop_Code__c
                            AND recordtypeid = :dealerRecTypeId
                            AND isPersonAccount=False
                            AND Parent_Workshop_Code__c!=NULL];
        }
        return workshopList;
    }
    /**
    Author: Nitin
    Company: TechMatrix
    Description:This Method is created to show Pickup and Drop Locations as Dropdown values on createAppointment LWC
    Return: List<Pickup_Location__c>
    Inputs: workshopId(Account)
    History:
    ================
    1.1A     17th March 2020      Nitin     Initial Version
    1.2A     19th March 2020      Nitin     Initial Version
    */
    @AuraEnabled
    public static List<Pickup_Location__c> fetchPickupLoc(String workshopId){
        List<Pickup_Location__c> pickUpLoc = new List<Pickup_Location__c>();
        pickUpLoc = [Select Id,Name,Location_Code__c from Pickup_Location__c where Dealer__c =: workshopId AND Dealer__c!=NULL];
        return pickUpLoc;
    }
    /**
    Author: Nitin
    Company: TechMatrix
    Description:This Method is created to show Pickup & Drop Driver data as Dropdown values on createAppointment LWC
    Return: List<Pickup_Location__c>
    Inputs: workshopId(Account)
    History:
    ================
    1.1A     17th March 2020      Nitin     Initial Version
    1.2A     19th March 2020      Nitin     Initial Version
    */
    @AuraEnabled
    public static List<User> fetchDriverList(String workshopId){
        List<User> driverList = [Select Id,Name,Dealer_Employee_Code__c FROM User WHERE AccountId=:workshopId
                                 AND Contact.Account.isPersonAccount=False AND profile.name=:label.Driver];
        return driverList;
    }

    /**
    Author: Prashant Gahlaut
    Company: TechMatrix
    Description:This Method is created to save worderOrder record from fetchAppointment LWC
    Return: string
    Inputs: 
    History:
    ================
    1.1A     3/9/2020     Prashant     Initial Version
	1.1A     18/9/2020    Sunit Chand  added existing workorder check and empty check for dates
    */
    @AuraEnabled
    public static String createWorkOrderRecord(string recievedJSONData){
        try{
            System.debug('Inside createWorkOrderRecord');
            WorkOrder wrkOrderObj = new workOrder();
            map<string,String> workOrderDeserializedMap = (map<string,String>)JSON.deserialize(recievedJSONData, map<string,String>.class);
            List<WorkOrder> workorderList=[Select Id from WorkOrder where Service_Number__c=:workOrderDeserializedMap.get('appointmentNumber') AND Workshop__c =: workOrderDeserializedMap.get('dealerSfid')];
            if(workorderList.size()==0){
            	wrkOrderObj.Mileage__c = decimal.valueOf(workOrderDeserializedMap.get('odometer'));
            	wrkOrderObj.Service_Type__c = workOrderDeserializedMap.get('serviceType');
            	wrkOrderObj.Appointment_Type__c = workOrderDeserializedMap.get('appointmentType');
            	wrkOrderObj.Appointment_Datetime__c = String.isNotEmpty(workOrderDeserializedMap.get('appointmentDateTime')) ? (DateTime)JSON.deserialize('"' + workOrderDeserializedMap.get('appointmentDateTime') + '"', DateTime.class) : null;
            	wrkOrderObj.Slot_Code__c = workOrderDeserializedMap.get('slotCD');
            	wrkOrderObj.Slot_Time__c = workOrderDeserializedMap.get('slotTime');
            	wrkOrderObj.Pickup_Type__c = workOrderDeserializedMap.get('pickUpType');
            	wrkOrderObj.Pickup_Datetime__c = String.isNotEmpty(workOrderDeserializedMap.get('pickUpTime')) ? (DateTime)JSON.deserialize('"' + workOrderDeserializedMap.get('pickUpTime') + '"', DateTime.class):null;
            	wrkOrderObj.Pickup_Address__c = workOrderDeserializedMap.get('pickUpAddress');
            	wrkOrderObj.Drop_Location__c = workOrderDeserializedMap.get('dropLocSfid') != '' ? workOrderDeserializedMap.get('dropLocSfid') : null;
            	wrkOrderObj.Drop_Datetime__c = String.isNotEmpty(workOrderDeserializedMap.get('dropTime')) ? (DateTime)JSON.deserialize('"' + workOrderDeserializedMap.get('dropTime') + '"', DateTime.class):null;
            	wrkOrderObj.Drop_Address__c = workOrderDeserializedMap.get('dropAddress');
            	wrkOrderObj.Pickup_Driver__c = workOrderDeserializedMap.get('pickupDriverSfid') != '' ? workOrderDeserializedMap.get('pickupDriverSfid') : null;
            	wrkOrderObj.MMS_Vehicle__c = workOrderDeserializedMap.get('mmsVehicleSfid') != '' ? workOrderDeserializedMap.get('mmsVehicleSfid') : null;
            	wrkOrderObj.Drop_Driver__c = workOrderDeserializedMap.get('dropDriverSdid') != '' ? workOrderDeserializedMap.get('dropDriverSdid') : null;
            	wrkOrderObj.Dealer__c = workOrderDeserializedMap.get('dealerSfid') != '' ? workOrderDeserializedMap.get('dealerSfid') : null;
            	wrkOrderObj.SA_Id__c = workOrderDeserializedMap.get('saUserSfid') != '' ? workOrderDeserializedMap.get('saUserSfid') : null;
            	wrkOrderObj.AssetId = workOrderDeserializedMap.get('vehicleSfid') != '' ? workOrderDeserializedMap.get('vehicleSfid') : null;
            	wrkOrderObj.Description = workOrderDeserializedMap.get('pickUpRemarks');
            	wrkOrderObj.Service_Number__c= workOrderDeserializedMap.get('appointmentNumber');
                wrkOrderObj.Workshop__c = workOrderDeserializedMap.get('dealerSfid') != '' ? workOrderDeserializedMap.get('dealerSfid') : null;
            	insert wrkOrderObj;   
            }
            else{
                wrkOrderObj=workorderList[0];
            }
             
            return 'Id'+wrkOrderObj.Id ;
        }catch(exception e){
            System.debug(e.getStackTraceString());
            return 'Error is '+e;
        }
    }
    
    /**
    Author: Nitin Ghai
    Company: Techmatrix
    Description: Wrapper Class to create Reauest body for Create Appointment API callout.
    ================
    1.1A     09/03/2020      Nitin Ghai    Initial Version
    */
    public class RequestBody {
        public Integer dealerCode;
        public String locationCode;
        public String userID;
        public String registrationNum;
        public Decimal odometer;
        public String serviceType;
        public String appointmentType;
        public String appointmentDate;
        public String currentSA;
        public String slotCD;
        public String slotTime;
        public String pickUpType;
        public String pickUpLoc;
        public String pickUpTime;
        public String pickUpAddress;
        public String dropLoc;
        public String dropTime;
        public String dropAddress;
        public String driver;
        public String VehicleNum;
        public String pickUpRemarks;
        public String remarksNotSelectSA;
        public String demandJobs;
        public String dropDriver;
    }
}