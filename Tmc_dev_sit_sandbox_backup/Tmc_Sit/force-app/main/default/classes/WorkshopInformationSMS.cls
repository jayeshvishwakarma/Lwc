/*------------------------------------------------------------------------------------
Author:        Nitin Ghai
Description:   Workshop Information SMS

History
Date            Author                  Comments
--------------------------------------------------------------------------------------
17-02-2020      Nitin Ghai              This class is used to fetch workshop Details and Create a MC Record which will be used 
                                        by SFMC to send SMS to Customer regarding Workshop Details
03-06-2020      Nitin Ghai              Added wrapper class to fetch workshop List and Customer record
------------------------------------------------------------------------------------*/
public without sharing class WorkshopInformationSMS {
    
    /**
    Author: Nitin Ghai
    Company: Techmatrix
    Description: This method will fetch the list of Workshop
    Inputs: 
    Returns: List<Account>
    History:
    ================
    1.1A     17-02-2020      Nitin Ghai    Initial Version
    */
    @AuraEnabled
    public static wrapperClass fetchWorkShopDetails(String customerRecId){
        wrapperClass wrap = new wrapperClass();
        wrap.workshopRec=CreateAppointment.fetchWorkShopList();
        wrap.customerRec=[Select Id,Name,PersonMobilePhone,PersonContactId from Account WHERE Id=:customerRecId AND isPersonAccount=True]; 
        return wrap;
    }
     /**
    Author: Nitin Ghai
    Company: Techmatrix
    Description: This method is be used to create MC Communication Record, further MC Record will be used by SFMC to send SMS to Customer regarding Workshop Details.
    Inputs: Account ID(Workshop), Task Id, Customer Name, Customer Mobile, Customer Id & PersonContactId
    Returns: Object(BasicReturn)
    History:
    ================
    1.1A     17-02-2020      Nitin Ghai    Initial Version
    */
    @AuraEnabled
    public static BasicReturn createMcCommunicationrecord(String workshopId, String customerName,String customerMobile,String customerId,String personConId, String templateId){
        BasicReturn result = new BasicReturn();
        result.code = 0;
        result.status = 'Error';
        try{
            User us = CreateAppointment.getCurrentUser();
            Account workshopRec = [Select ID,Name,Dealer_Address_F__c,Google_Link__c,Dealer_CC_Email__c,Dealer_CC_Phone__c from Account where ID =: workshopId];
            MC_Communication__c mcRecord = new MC_Communication__c();
            mcRecord.Dealer_Field_1__c=workshopRec.Name;
            mcRecord.Address__c=workshopRec.Dealer_Address_F__c;
            mcRecord.General_Field_5__c=workshopRec.Google_Link__c;
            mcRecord.Email_1__c=workshopRec.Dealer_CC_Email__c;
            mcRecord.Type__c=ConstantsUtility.WorkshopInformation;
            mcRecord.General_Field_7__c=workshopRec.Id;
            mcRecord.Customer_Field_1__c=customerName;
            //mcRecord.Internal_User_2__c=us.Manager.Name;
            mcRecord.General_Field_8__c=customerId;
            mcRecord.General_Field_9__c=personConId;
			mcRecord.General_Field_10__c=templateId;
            if(us.ProfileId == Label.CCM_User){
                mcRecord.Internal_User_2__c=us.Name;
                if(String.isNotBlank(us.MobilePhone) && us.MobilePhone.length()==10){
                    mcRecord.Phone_4__c='91'+us.MobilePhone;
                }else if(String.isNotBlank(us.MobilePhone)&& us.MobilePhone.length()>10){
                    mcRecord.Phone_4__c=us.MobilePhone;
                }
            }else {
                mcRecord.Internal_User_2__c=us.Manager.Name;
                if(String.isNotBlank(us.Manager.MobilePhone) && us.Manager.MobilePhone.length()==10){
                    mcRecord.Phone_4__c='91'+us.Manager.MobilePhone;
                }else if(String.isNotBlank(us.Manager.MobilePhone)&& us.Manager.MobilePhone.length()>10){
                    mcRecord.Phone_4__c=us.Manager.MobilePhone;
                }
            }
			
            if(String.isNotBlank(workshopRec.Dealer_CC_Phone__c) && workshopRec.Dealer_CC_Phone__c.length()==10){
                mcRecord.Phone_3__c='91'+workshopRec.Dealer_CC_Phone__c;
            }
            else if(String.isNotBlank(workshopRec.Dealer_CC_Phone__c) && workshopRec.Dealer_CC_Phone__c.length()>10){
                mcRecord.Phone_3__c=workshopRec.Dealer_CC_Phone__c;
            }
            if(String.isNotBlank(customerMobile) && customerMobile.length()==10)
                mcRecord.Phone_1__c='91'+customerMobile;
            else if(String.isNotBlank(customerMobile) && customerMobile.length()>10){
                mcRecord.Phone_1__c=customerMobile;
            }
                
            insert mcRecord;
            result.message = 'Success';
            result.status = 'Success';
            result.createdId=mcRecord.Id;
            
        }catch(exception e){
            result.message = e.getMessage();ExceptionHandler.stackTrace ehst=new ExceptionHandler.stackTrace();ehst.componentName='WorkshopInformationSMS - LWC';ehst.userId=UserInfo.getUserId();ExceptionHandler.LogError('WorkshopInformationSMS - Class',e.getMessage()+' - Line Number: '+e.getLineNumber(), 'Account object : createMcCommunicationrecord - Method', '', ehst);
        }
        return result;
    }
    /**
    Author: Nitin Ghai
    Company: Techmatrix
    Description: Wrapper Class to contain Workshop and Customer Record.
    Wrapper Class to contain workshop record record
    Wrapper Class to contain customer record
    ================
    1.1A     03/06/2020      Nitin Ghai    Initial Version
    */
    public class wrapperClass{
        @AuraEnabled public List<Account> workshopRec {get;set;}
        @AuraEnabled public List<Account> customerRec {get;set;}
    }
    
}