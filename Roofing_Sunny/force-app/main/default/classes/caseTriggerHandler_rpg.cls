/**
* @author: Mukesh Bhardwaj
* @date: 5/9/2013
* @description: Handler class for CaseTrigger. Used to control all Case trigger events.
* @history:
    1. 05/09/2013: Mukesh Bhardwaj: Added beforeUpdateAction1 method
*/
    
public with sharing class caseTriggerHandler_rpg {
    
    public void updateBusinessHours(List<Case> caseListNew){
        // Query for the default business hours
        BusinessHours bh = [SELECT Id FROM BusinessHours WHERE IsDefault=true];
        
        if(bh != null)
        {
            for (Case c : caseListNew)
            {
                c.BusinessHoursId = bh.Id;
            }
        }
    }
    //Before insert Action 2: Update TM and Warehouse User
    public void updateTM(List<Case> caseListNew, Map<Id,Case> oldMap){
        Map<String, Order> orderMap = new Map<String, Order>();
        for(Case record : caseListNew){
            if(String.isNotBlank(record.Order__c)){
                orderMap.put(record.Order__c, null);
            }
        }
        for(Order record : [SELECT Id, Manufacturing_Plant__r.Dispatch_Email__c, Region_rpg__r.Pricing_Coordinator__c, 
                            Region_rpg__r.Regional_Sales_Manager__c, Manufacturing_Plant__r.Logistics_Coordinator__c, 
                            Ship_To__r.Res_TM__c, Ship_To__r.Com_TM__c FROM Order WHERE Id IN : orderMap.keySet()]){
            orderMap.put(record.Id, record);
        }
        if(oldMap == null) //in case of insert
        {
            Set<Id> accIdSet = new Set<Id>();
            Map<Id, Id> caseTMMap = new Map<Id,Id>();
            for(Case c : caseListNew)
            {
                /*if(c.TM_Calc__c != null && c.TM_Calc__c != '')
                {
                    System.debug('c.TM_Calc__c:::'+c.TM_Calc__c);
                    c.TM__c = c.TM_Calc__c;
                }
                if(c.Warehouse_User_Calc__c != null && c.Warehouse_User_Calc__c != '')
                    c.Warehouse_User__c = c.Warehouse_User_Calc__c;
                if(c.Regional_Manager_Calc__c != null && c.Regional_Manager_Calc__c != '')
                    c.RSM__c = c.Regional_Manager_Calc__c;
                if(c.Pricing_Coordinator_Calc__c != null && c.Pricing_Coordinator_Calc__c != '')
                    c.Pricing_Coordinator__c = c.Pricing_Coordinator_Calc__c;
                if(c.Dispatch_Email_Calc__c != null && c.Dispatch_Email_Calc__c != '')
                    c.Dispatch_Email__c = c.Dispatch_Email_Calc__c;*/
                    
                
                if(orderMap.containsKey(c.Order__c) && orderMap.get(c.Order__c) != null) {
                    if(String.isBlank(orderMap.get(c.Order__c).Ship_To__r.Res_TM__c)){
                        c.TM__c = orderMap.get(c.Order__c).Ship_To__r.Com_TM__c;
                    }else{
                        c.TM__c = orderMap.get(c.Order__c).Ship_To__r.Res_TM__c;
                    }                    
                    
                    if(String.isNotBlank(orderMap.get(c.Order__c).Manufacturing_Plant__r.Logistics_Coordinator__c))
                        c.Warehouse_User__c = orderMap.get(c.Order__c).Manufacturing_Plant__r.Logistics_Coordinator__c;
                    if(String.isNotBlank(orderMap.get(c.Order__c).Region_rpg__r.Regional_Sales_Manager__c))
                        c.RSM__c = orderMap.get(c.Order__c).Region_rpg__r.Regional_Sales_Manager__c;
                    if(String.isNotBlank(orderMap.get(c.Order__c).Region_rpg__r.Pricing_Coordinator__c))
                        c.Pricing_Coordinator__c = orderMap.get(c.Order__c).Region_rpg__r.Pricing_Coordinator__c;
                    if(String.isNotBlank(orderMap.get(c.Order__c).Manufacturing_Plant__r.Dispatch_Email__c))
                        c.Dispatch_Email__c = orderMap.get(c.Order__c).Manufacturing_Plant__r.Dispatch_Email__c;
                }
            }
        }
        else
        {
            Set<Id> caseIdSet = new Set<Id>();
            for(Case c: caseListNew)
            {
                if(c.Order__c != null && c.Order__c != oldMap.get(c.Id).Order__c)
                {
                    /*if(c.TM_Calc__c != null && c.TM_Calc__c != '')
                    {
                        System.debug('c.TM_Calc__c:::'+c.TM_Calc__c);
                        c.TM__c = c.TM_Calc__c;
                    }
                    if(c.Warehouse_User_Calc__c != null && c.Warehouse_User_Calc__c != '')
                        c.Warehouse_User__c = c.Warehouse_User_Calc__c;
                    if(c.Regional_Manager_Calc__c != null && c.Regional_Manager_Calc__c != '')
                        c.RSM__c = c.Regional_Manager_Calc__c;
                    if(c.Pricing_Coordinator_Calc__c != null && c.Pricing_Coordinator_Calc__c != '')
                        c.Pricing_Coordinator__c = c.Pricing_Coordinator_Calc__c;
                    if(c.Dispatch_Email_Calc__c != null && c.Dispatch_Email_Calc__c != '')
                        c.Dispatch_Email__c = c.Dispatch_Email_Calc__c;*/
                        
                    if(orderMap.containsKey(c.Order__c) && orderMap.get(c.Order__c) != null) {
                        if(String.isBlank(orderMap.get(c.Order__c).Ship_To__r.Res_TM__c)){
                            c.TM__c = orderMap.get(c.Order__c).Ship_To__r.Com_TM__c;
                        }else{
                            c.TM__c = orderMap.get(c.Order__c).Ship_To__r.Res_TM__c;
                        }                    
                        
                        if(String.isNotBlank(orderMap.get(c.Order__c).Manufacturing_Plant__r.Logistics_Coordinator__c))
                            c.Warehouse_User__c = orderMap.get(c.Order__c).Manufacturing_Plant__r.Logistics_Coordinator__c;
                        if(String.isNotBlank(orderMap.get(c.Order__c).Region_rpg__r.Regional_Sales_Manager__c))
                            c.RSM__c = orderMap.get(c.Order__c).Region_rpg__r.Regional_Sales_Manager__c;
                        if(String.isNotBlank(orderMap.get(c.Order__c).Region_rpg__r.Pricing_Coordinator__c))
                            c.Pricing_Coordinator__c = orderMap.get(c.Order__c).Region_rpg__r.Pricing_Coordinator__c;
                        if(String.isNotBlank(orderMap.get(c.Order__c).Manufacturing_Plant__r.Dispatch_Email__c))
                            c.Dispatch_Email__c = orderMap.get(c.Order__c).Manufacturing_Plant__r.Dispatch_Email__c;
                    }
                }
            }
        }
    }
    // method to apply assignment rules for portal cases
     public void portalCaseAssignment(List<Case> cases){
        List<case> portalCases = new List<case>();
         SET<Id> set_reportTypeIds = new SET<Id>();
         //for(RecordType portalRecortType : [SELECT Id,Name FROM RecordType WHERE SobjectType='Case' AND Name in ('Portal', 'Service Case')]){
         for(RecordType portalRecortType : [SELECT Id,Name FROM RecordType WHERE SobjectType='Case' AND Name ='Portal']){
             set_reportTypeIds.add(portalRecortType.id);
         }
         for(Case c : cases){
             if(set_reportTypeIds.contains(c.RecordTypeId)){             
                 portalCases.add(new Case(id = c.id));      
             } 
         }         
        if(portalCases.size() > 0){
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule = true;
            Database.update(portalCases, dmo); 
        }        
    }
    
   //This method is to format the Documents__c field data into Html format
    public static void formatDocumentData(case csNew, case csOld){
        String fileName;
        String htmlUrl = '';
        String documentdata;
        String[] urls;              
        if(csNew.Documents__c != null && csNew.Documents__c != ''){
            
            documentdata = csNew.Documents__c;           
            if(!documentdata.contains('<a')){
                urls = documentdata.split(',');
                if(urls.size()>0){
                    for(String strUrl : urls){
                        if(strUrl != ''){
                            strUrl = strUrl.replace('<br>', '');
                            fileName = getFileName(strUrl); 
                            if(htmlUrl == ''){
                                htmlUrl = getHtmlLink(strUrl,fileName);
                            }
                            else{
                                htmlUrl = htmlUrl + '<br>' + getHtmlLink(strUrl,fileName);
                            } 
                        }
                        
                    }
                }
                if(csOld != null){
                    if(csOld.Documents__c != '' && csOld.Documents__c != null){
                     csNew.Documents__c = csOld.Documents__c + '<br>' +  htmlUrl;
                    }
                    else{
                         csNew.Documents__c = htmlUrl;
                    }
                }
                else{
                    csNew.Documents__c = htmlUrl;
                }
              
               
            }
            
        }
    }
  //This method is to get the file name from the document url  
    private static string getFileName(String url){
        Integer startIndex;
        Integer endIndex;
        string strFileName;
        system.debug('url-->' + url);
        startIndex= url.lastindexOf('/');
        endIndex = url.indexOf('?');
        if(startIndex != -1 && endIndex != -1){
            strFileName =  url.substring(startIndex + 1,endIndex);
        }
        else if(startIndex != -1){
            strFileName =  url.substring(startIndex + 1);
        }
        else{
            strFileName = url;
        }
        return strFileName;
    }
    //This method is to format the url into html format
    private static string getHtmlLink(String url, String fileName){
        string strHtmlUrl;
        strHtmlUrl = '<a href="' + url + '" target="_blank">' + fileName + '</a>';       
        return strHtmlUrl;
    }
}