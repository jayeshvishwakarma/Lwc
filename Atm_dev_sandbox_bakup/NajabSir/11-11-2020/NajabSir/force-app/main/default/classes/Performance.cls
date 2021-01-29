/**
 * @File Name          : Performance.cls
 * @Description        : it is utilized in case of testing performance for Various Use cases 
 * @Author             : 
 * @Group              : 
 * @Last Modified By   : Ravi Gupta
 * @Last Modified On   : 12/08/2019
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    12/08/2019, 11:00:01 AM         Ravi Gupta     			  Initial Version
**/
public with sharing class Performance {
    /**
        Author: Ravi Gupta
        Company: Techmatrix
        Description: This method returns the List of Use cases stored in metadata
        Inputs: 
        Returns: void
        History:
        ================
        1.0     6 Aug 2019      Ravi     Initial Version
    */
    @AuraEnabled
    public static List<Performance__mdt> getPerformanceTest() {
           /*  List<PerformanceWrap> pwList=  new List<PerformanceWrap>();
        for (Performance__mdt  uc : [SELECT Id,MasterLabel,Class__c FROM Performance__mdt WHERE Active__c=true]){
            PerformanceWrap pw=  new PerformanceWrap();
            pw.prfrm = uc;
            pwList.add(pw);
        }
        return pwList; */
        return [SELECT Id,MasterLabel,Class__c FROM Performance__mdt WHERE Active__c=true Order by MasterLabel];
    }
    
    /**
        Author: Ravi Gupta
        Company: Techmatrix
        Description: This method basically call Batch and ProcessData and count execution time depending upon use case
        Inputs: 
        Returns: void
        History:
        ================
        1.0     12 Aug 2019      Ravi     Initial Version
    */

      @AuraEnabled
    public  static string ExecuteTestScript(string pList){
        List<PerformanceWrap> wraplist  = new List<PerformanceWrap>();
        PerformanceBatch perVar = new PerformanceBatch();
        wraplist =   (List<PerformanceWrap>)System.JSON.deserialize(pList, List<PerformanceWrap>.class);
        system.debug('wraplist'+wraplist);       
            integer count=0;
            set<id> recId = new Set<id>();
            for(PerformanceWrap wrapObj:wraplist){
                recId.add(wrapObj.RecordID);
            }
            system.debug('recId'+recId);
            boolean isActive=true;
            perVar.query='SELECT Id,MasterLabel,Class__c FROM Performance__mdt WHERE   Id=:recId ';
            system.debug('perVar.query'+perVar.query);
            perVar.recId = recId;
            ID batchprocessid = Database.executeBatch(perVar,1);
            return 'Success';
    }

    // Capturing data of Custom Metadata Record
    public class PerformanceWrap{
        public boolean isCheck =false;
        public String ClassName;
        public String RecordID;
        public String MasterLabel;
        public Performance__mdt prfrm;
        
    }
}