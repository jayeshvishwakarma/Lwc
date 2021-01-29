@isTest(SeeAllData=true)
public class RHX_TEST_c2g_codaInvoice {
    static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
            FROM c2g__codaInvoice__c order by lastmodifieddate desc LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new c2g__codaInvoice__c()
            );
        }
        
        rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
        
        if(sourceList[0].Id!=null){
            // inserting custom setting records
            PaymentTransactionSetting__c setting = new PaymentTransactionSetting__c(Name = 'config',
                                                                                    End_URL__c = 'https://www.pay.nl/demo_ppt/finish_url',
                                                                                    Merchant_User_Name__c='test@gmail.com',
                                                                                    Password__c = '5Xn*B!5U$dt3234',
                                                                                    Redirect_URL__c='https://rest-api.pay.nl/v7/Transaction/start/json',
                                                                                    Service_Id__c = 'SL-5516-2570',
                                                                                    Token__c = '6eb4bb2f8b67d08a7cf9b3e9cdae31d62def1315');
               //insert setting;  
            //try{
                c2g__codaInvoice__c  invoiceObj = new c2g__codaInvoice__c(id=sourceList[0].Id, Paynl_Payment__c = true, Insert_Cloud_N_Diensten__c = false);
                update invoiceObj;
                
                
           // }catch(Exception e){
                // calling manually to SalesInvoiceTriggerHelper class
                SalesInvoiceTriggerHelper.UpdatePayNLTransactionId(new Set<Id>{sourceList[0].Id});
           // }
               //done by ranu on 13th may for create salesinvoice line items.
               try{
                    c2g__codaInvoice__c  salesInvoiceObj = new c2g__codaInvoice__c(id=sourceList[0].Id, Insert_Cloud_N_Diensten__c= true);
                    update salesInvoiceObj;
                }catch(Exception e){}
        }
        
        
    }
}