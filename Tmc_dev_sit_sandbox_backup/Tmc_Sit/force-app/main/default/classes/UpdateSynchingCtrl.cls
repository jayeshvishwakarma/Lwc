/**
 * @File Name          : UpdateSynchingCtrl.cls
 * @Description        : This class is used to Start and Stop quote syncing with opportunity(Enquiry).
 * @Author             : Anuj Kumar
 * @Group              : 
 * @Last Modified By   : Anuj Kumar
 * @Last Modified On   : 25/08/2019 10:15 AM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                Modification
 *==============================================================================
 * 1.0    25/08/2019 11:17 AM          Anuj Kumar            Initial Version
**/

public with sharing class UpdateSynchingCtrl {
    
    /*
        @Author:                  Anuj Kumar
        @Created Date :           25/08/2019
        @Discription:             To Check from which Condition syncing is start.
        @Date Of Modification :   25/08/2019
    */
    @AuraEnabled(cacheable=true)
    public static QuoteInfo retriveQuoteSyncType(String recordId){
        QuoteInfo qi = new QuoteInfo();
        Integer quoteLineItemCount = 0;
        Integer opportunityLineItemCount = 0;
        
        if(String.isNotBlank(recordId)){
            String opportunityId = '';
            List<Quote> quoteList;
            if(isQuoteAccessPermission()){
                quoteList = new List<Quote> ([Select Id, isSyncing, opportunityId, opportunity.StageName FROM Quote WHERE Id =: recordId]);
            }
            if(quoteList != null && quoteList.size() > 0 && quoteList[0].opportunityId != null){
                opportunityId = quoteList[0].opportunityId;
                qi.enquiryStageName = quoteList[0].opportunity.StageName != null ? quoteList[0].opportunity.StageName : null;
                qi.isSyncing = quoteList[0].isSyncing;
            }else{
                opportunityId = '';
            }
            List<QuoteLineItem> quoteLineItemList;
            if(isQuoteLineItemAccessPermission()){
                quoteLineItemList = new List<QuoteLineItem> ([Select Id FROM QuoteLineItem WHERE quoteId =: recordId]);
            }
            
            if(quoteLineItemList != null && quoteLineItemList.size() > 0){
                quoteLineItemCount = quoteLineItemList.size();
            }else{
                quoteLineItemCount = 0;
            }
        
            List<OpportunityLineItem> opportunityLineItemList;
            if(isOpportunityLineItemAccessPermission()){
                opportunityLineItemList = new List<OpportunityLineItem> ([Select Id FROM OpportunityLineItem WHERE opportunityId =: opportunityId]);
            }
            if(opportunityLineItemList != null && opportunityLineItemList.size() > 0){
                opportunityLineItemCount = opportunityLineItemList.size();
            }else{
                opportunityLineItemCount = 0;
            }
            
            return generateQuoteInfoWrapper(qi, quoteLineItemCount, opportunityLineItemCount);
        }
        return null;
    }
    
    public static QuoteInfo generateQuoteInfoWrapper(QuoteInfo qi, Integer quoteLineItemCount, Integer opportunityLineItemCount){
        
        if(quoteLineItemCount == 0 && opportunityLineItemCount == 0){
            qi.quoteLineItemCount = quoteLineItemCount;
            qi.opportunityLineItemCount = opportunityLineItemCount;
            qi.message = system.label.Quote_No_And_Opp_No;
            return qi;
        }else if(quoteLineItemCount == 0 && opportunityLineItemCount > 0){
            qi.quoteLineItemCount = quoteLineItemCount;
            qi.opportunityLineItemCount = opportunityLineItemCount;
            qi.message = system.label.Quote_No_And_Opp_Yes;
            return qi;
        }else if(quoteLineItemCount > 0 && opportunityLineItemCount == 0){
            qi.quoteLineItemCount = quoteLineItemCount;
            qi.opportunityLineItemCount = opportunityLineItemCount;
            qi.message = system.label.Quote_Yes_And_Opp_No;
            return qi;
        }else if(quoteLineItemCount > 0 && opportunityLineItemCount > 0){
            qi.quoteLineItemCount = quoteLineItemCount;
            qi.opportunityLineItemCount = opportunityLineItemCount;
            qi.message = system.label.Quote_Yes_And_Opp_Yes;
            return qi;
        }
        
        return qi;
    }
    
    /*
        @Author:                  Anuj Kumar
        @Created Date :           25/08/2019
        @Discription:             To update syncing at quote.
        @Date Of Modification :   25/08/2019
    */
    @AuraEnabled
    public static CopyQuoteResult updateSyncing(String quoteId, Boolean isSyncing, String quoteName, String opportunityName, String oppId){
        
        CopyQuoteResult obj = new CopyQuoteResult();
        
        String successMessage = '';
        String errorMessage =  '';
        
        system.debug('== isSyncing '+isSyncing);
        
        if(String.isNotBlank(oppId) && String.isNotBlank(quoteId) && isSyncing != null){
            try{
                List<Quote> quoteList;
                if(isQuoteAccessPermission()){
                    quoteList = new List<Quote> ([Select Id, Line_Item_Summary__c, Variant__c, Color__c FROM Quote WHERE Id =: quoteId]);
                }
                
                List<QuoteLineItem> variantQuoteLineRecord = [Select id, Type__c, Product2Id, Product2.Model__c from QuoteLineItem 
                                                        where quoteId =: quoteId And Type__c =: ConstantsUtility.VARIANT_CONST Limit 1];
                
                List<Opportunity> opportunityList = [Select id, recordType.Name, Model_Code__c, Variant__c, Variant_Modified_Count__c 
                                                    from Opportunity Where Id =: oppId];
                
                Opportunity opp = new Opportunity();
                opp.Id = oppId;
                
                if(quoteList != null && quoteList.size() > 0 && isSyncing == false){
                    opp.Line_Item_Summary__c = quoteList[0].Line_Item_Summary__c;
                    opp.Variant__c = quoteList[0].Variant__c;
                    opp.Color__c = quoteList[0].Color__c;
                    opp.SyncedQuoteId = quoteId;
                }else if(quoteList != null && quoteList.size() > 0 && isSyncing){
                    opp.SyncedQuoteId = Null;
                }
                
                system.debug('== variantQuoteLineRecord  '+variantQuoteLineRecord);
                system.debug('== opportunityList  '+opportunityList);
                
                if(!opportunityList.isEmpty() && opportunityList[0].recordType.Name == ConstantsUtility.PARTS){
                    TriggerHandler.bypass('OpportunityTriggerHandler');
                    Update opp;
                    TriggerHandler.clearBypass('OpportunityTriggerHandler');
                    
                    obj.type = 'success';
                    obj.message = system.label.Copied_to_Pre_Booking;
                    
                    return obj;
                }
                
                if(variantQuoteLineRecord != Null && variantQuoteLineRecord.size() > 0 && opportunityList != Null && opportunityList.size() > 0){
                    
                    system.debug('== Check 4 Condition');
                    
                    if(variantQuoteLineRecord[0].Product2Id != Null && 
                        variantQuoteLineRecord[0].Product2.Model__c == opportunityList[0].Model_Code__c){
                        system.debug('== Check 1 if Model equals');
                        
                        if(opportunityList[0].Variant__c != variantQuoteLineRecord[0].Product2Id && opportunityList[0].Variant_Modified_Count__c > 1){
                            system.debug('== Check 2 Variant Not equals');
                            obj.type = 'error';
                            obj.message = system.label.Different_Enq_Model_and_Count_Greater_than_one;
                            return obj;
                            
                        }else if((opportunityList[0].Variant__c != variantQuoteLineRecord[0].Product2Id  || 
                                opportunityList[0].Variant__c == variantQuoteLineRecord[0].Product2Id)
                                && opportunityList[0].Variant_Modified_Count__c < 2){
                            system.debug('== Check 3 allow');
                            if(isOpportunityUpdatePermission()){
                                if(opportunityList[0].Variant__c != variantQuoteLineRecord[0].Product2Id){
                                    opp.Variant_Modified_Count__c = opportunityList[0].Variant_Modified_Count__c + 1;
                                }
                                TriggerHandler.bypass('OpportunityTriggerHandler');
                                Update opp;
                                TriggerHandler.clearBypass('OpportunityTriggerHandler');
                                
                                
                                obj.type = 'success';
                                obj.message = system.label.Copied_to_Pre_Booking;
                                
                                return obj;
                            }else{ obj.type = 'error'; obj.message = 'Insufficient Privileges error'; return obj;}
                        }else if(opportunityList[0].Variant__c == variantQuoteLineRecord[0].Product2Id && opportunityList[0].Variant_Modified_Count__c == 2){
                            if(isOpportunityUpdatePermission()){
                                if(opportunityList[0].Variant__c != variantQuoteLineRecord[0].Product2Id){
                                    opp.Variant_Modified_Count__c = opportunityList[0].Variant_Modified_Count__c + 1;
                                }
                                TriggerHandler.bypass('OpportunityTriggerHandler');
                                Update opp;
                                TriggerHandler.clearBypass('OpportunityTriggerHandler');
                                
                                obj.type = 'success';
                                obj.message = system.label.Copied_to_Pre_Booking;
                                
                                return obj;
                            }else{ obj.type = 'error'; obj.message = 'Insufficient Privileges error'; return obj; }
                        }
                    }else{ obj.type = 'error'; obj.message = system.label.Different_Enq_Model; return obj; }
                }
            }catch(Exception ex){ errorMessage = ex.getMessage(); ExceptionHandler.stackTrace ehst=new ExceptionHandler.stackTrace(); ehst.componentName='Update Sync'; ehst.userId=UserInfo.getUserId(); ExceptionHandler.LogError('Update Sync', ex.getMessage(), 'Update Sync', '', ehst); obj.type = 'error'; obj.message = errorMessage; return obj;}
        }
        
        return obj;
    }
    
    /*
        @Author:                  Anuj Kumar
        @Created Date :           27/08/2019
        @Discription:             Wrapper class used to return the Enquiry Approval Status and Task Details.
        @Date Of Modification :   27/08/2019
    */
    public class QuoteInfo{
        
        @AuraEnabled public String message;
        @AuraEnabled public Integer quoteLineItemCount;
        @AuraEnabled public Integer opportunityLineItemCount;
        @AuraEnabled public String enquiryStageName;
        @AuraEnabled public Boolean isSyncing;
        
    }
    
    public class CopyQuoteResult{
        
        @AuraEnabled public String message;
        @AuraEnabled public String type;
    }
    
    /*******       TO Handle The Object And Field Permissions    ********/
    
    /*
        @Author:                  Anuj Kumar
        @Created Date :           25/08/2019
        @Discription:             To Check the access permissions for Quote.
        @Date Of Modification :   25/08/2019
    */
    public static Boolean isQuoteAccessPermission(){
        if(CheckObjectAndField.isAccessible('Quote') && CheckObjectAndField.isFieldAccessible('Quote', 'opportunityId')){
            return True;
        }else{
            return false;
        }
    }
    
    /*
        @Author:                  Anuj Kumar
        @Created Date :           25/08/2019
        @Discription:             To Check the access permissions for QuoteLineItem.
        @Date Of Modification :   25/08/2019
    */
    public static Boolean isQuoteLineItemAccessPermission(){
        if(CheckObjectAndField.isAccessible('QuoteLineItem')){
            return True;
        }else{
            return false;
        }
    }
    
    /*
        @Author:                  Anuj Kumar
        @Created Date :           25/08/2019
        @Discription:             To Check the access permissions for OpportunityLineItem.
        @Date Of Modification :   25/08/2019
    */
    public static Boolean isOpportunityLineItemAccessPermission(){
        if(CheckObjectAndField.isAccessible('OpportunityLineItem')){
            return True;
        }else{
            return false;
        }
    }
    
     /*
        @Author:                  Anuj Kumar
        @Created Date :           25/08/2019
        @Discription:             To Check the update permissions for opportunity.
        @Date Of Modification :   25/08/2019
    */
    public static Boolean isOpportunityUpdatePermission(){
        if(CheckObjectAndField.isUpdateable('opportunity')){
            return True;
        }else{
            return false;
        }
    }
    
}