/**
 * @description       : Send Suzuki Connect cases to PANA CRM Team
 * @author            : Nitin
 * @group             : 
 * @last modified on  : 06-01-2021
 * @last modified by  : Nitin
 * Modifications Log 
 * Ver   Date         Author                Modification
 * 1.0   06-01-2021   Nitin   Initial Version
**/
public class panaCrmCaseCreate implements Database.Batchable<sobject>, Database.AllowsCallouts{
    String suzukiConnectRecTypeId=ConstantsUtility.DEALER_SUZUKI_CONNECT_CASE_RECORD_TYPE_ID;String success=ConstantsUtility.API_RESPONSE_CONST;
    public String query = 'Select ID,PanaCRM_Case_Creation_Status__c,VIN_No__c,IMEI_No__c,TCU_No__c,Sim_No__c,TCU_Dealer_Name__c,TCU_Dealer_Address__c,Dealer_Phone__c,TCU_Sale_Date__c,TCU_Expiry_Date__c,First_Name__c,Middle_Name__c,Last_Name__c,Customer_Address__c,TCU_Customer_State__c,TCU_Customer_City__c,CaseNumber,TCU_Customer_Country__c,Pin_Code__c,Model__c,Service_Activation_Date__c,TCU_Service_Status__c,Mobile_Number__c,Odometer_Reading__c from Case where RecordTypeId=:suzukiConnectRecTypeId AND PanaCRM_Case_Creation_Status__c!=:success LIMIT 5';
    public Database.QueryLocator start(Database.BatchableContext BC) {
        system.debug('query-------->'+Database.getQueryLocator(query));
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Case> records) {
        List<Case> CaseRec = new List<Case>();
        BasicReturn br=new BasicReturn();
        Http http = new Http();
        MuleSoft_API_Details__mdt[] apiDetail= [SELECT MasterLabel, QualifiedApiName, Endpoint__c, TimeOut_Value__c,
                                                x_channel_id__c, x_channel_token__c,Method_Type__c,Header_Parameter__c,
                                                x_transaction_id__c,Authorization__c,Parameters__c,Content_Type__c,
                                                client_id__c,client_secret__c 
                                                FROM MuleSoft_API_Details__mdt WHERE DeveloperName ='PanaCRM_Case_Creation'];
        if(apiDetail.size() > 0 && records.size() > 0){
            Map<String, Object> mulesoftAPIDetailMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(apiDetail[0]));
            for (Case cs : records){
                system.debug('cs---->'+cs.Id);
                String middleName=cs.Middle_Name__c==null?'':cs.Middle_Name__c;
                CaseTriggerStrategyHelper.PanaCRMRecordCreation panaCRM=new CaseTriggerStrategyHelper.PanaCRMRecordCreation(cs.VIN_No__c,cs.IMEI_No__c,cs.TCU_No__c,cs.Sim_No__c,
                                                                                                                            cs.TCU_Dealer_Name__c,cs.TCU_Dealer_Address__c,
                                                                                                                            cs.Dealer_Phone__c,String.valueOf(cs.TCU_Sale_Date__c),String.valueOf(cs.TCU_Expiry_Date__c),
                                                                                                                            cs.First_Name__c+' '+middleName+' '+cs.Last_Name__c,
                                                                                                                            cs.Mobile_Number__c,cs.Customer_Address__c,cs.TCU_Customer_State__c,
                                                                                                                            cs.TCU_Customer_City__c,cs.TCU_Customer_Country__c,cs.Pin_Code__c,
                                                                                                                            cs.CaseNumber,cs.Model__c,String.valueOf(cs.Service_Activation_Date__c),
                                                                                                                            cs.TCU_Service_Status__c,cs.Mobile_Number__c,String.valueOf(cs.Odometer_Reading__c),'');
                //Create API request
                HttpRequest req = new HttpRequest();
                //Set Request Method Type
                req.setMethod(apiDetail[0].Method_Type__c);
                //Set the Request body for API request type as POST
                if(apiDetail[0].Method_Type__c==ConstantsUtility.POST_REQUEST){
                    req.setBody(JSON.serialize(panaCRM));
                }
                String endPoint=apiDetail[0].Endpoint__c;
                System.debug('endPoint--->'+endPoint);
                req.setEndpoint(endPoint.replaceAll(' ', '%20'));
                String[] headerArray=apiDetail[0].Header_Parameter__c.split(';');
                for(String header:headerArray)
                {
                    String label=header;
                    header+='__c';
                    System.debug('label Check:- '+label);
                    System.debug('Header Check:- '+header.replaceFirst('-', '_'));
                    System.debug(mulesoftAPIDetailMap.get(header.replaceFirst('-', '_')));
                    System.debug(mulesoftAPIDetailMap.get('client_id__c'));
                    req.setHeader(label,(String)mulesoftAPIDetailMap.get(header.replaceFirst('-', '_')));
                }
                req.setHeader('Accept','application/json');
                System.debug('Before Continuation');
                HttpResponse response = http.send(req);
                if(response.getStatusCode()==200){
                    cs.PanaCRM_Case_Creation_Status__c='Success';     
                }
            }
            
        }
        
        if(records.size()>0){
            Update records;
        }
    }
    
    public void finish(Database.BatchableContext BC){    
    }
}