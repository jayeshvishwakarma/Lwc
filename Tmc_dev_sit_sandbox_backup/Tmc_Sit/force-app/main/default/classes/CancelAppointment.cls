/**
* @File Name          : CancelAppointment.cls
* @Description        : It is used to Fetch Dealer Map Code, Dealer Location Code, Status, Service Number & Appointment Date and Time from Workshop(Account).
* @Author             : Nitin Ghai
* @Group              : 
* @Last Modified By   : Sunit Kumar Chand
* @Last Modified On   : 06/07/2020, 04:29:00 PM
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0   27/05/2020, 05:29:00 PM        Nitin Ghai                 Initial Version
* 1.1A  06/07/2020, 04:29:00 PM        Sunit Kumar Chand          OwnerId added to query
**/
public without sharing class CancelAppointment {
    /**
    Author: Nitin Ghai
    Company: Techmatrix
    Description: It is used to Fetch Dealer Map Code, Dealer Location Code, Status, Service Number & Appointment Date and Time from Workshop(Account).
    Inputs: WorkOrder(Appointment) Record Id
    Returns: WorkOrder
    History:
    ================
    1.1A     27/05/2020      Nitin Ghai    Initial Version
    */
    @AuraEnabled
    public static WorkOrder fetchWorkShopRec(String appointmentId){
        WorkOrder appointmentRec = [Select Id,Status,Service_Number__c,Appointment_Datetime__c,
                                    Appointment_Cancellation_Reason__c,Workshop__r.Dealer_Map_Code__c,
                                    Workshop__r.Dealer_Location__c,OwnerId 
                                    FROM WorkOrder where Id=:appointmentId];
        return appointmentRec;
    }

}