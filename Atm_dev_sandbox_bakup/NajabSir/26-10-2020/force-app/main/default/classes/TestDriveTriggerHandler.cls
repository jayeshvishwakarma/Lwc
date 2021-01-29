/**
 * @File Name          : TestDriveTriggerHandler.cls
 * @Description        : 
 * @Author             : Rajesh Ramachandran
 * @Group              : 
 * @Last Modified By   : Rajesh Ramachandran
 * @Last Modified On   : 1/6/2020, 2:24:56 AM
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    1/5/2020   Rajesh Ramachandran     Initial Version
**/
public with sharing class TestDriveTriggerHandler extends TriggerHandler {

    List<Test_Drive__c> testdrives = new List<Test_Drive__c> ();
     List<Opportunity> oppLst = new  List<Opportunity>();
    set<Id> oppId = new set<Id>();
    map<string,string> mapOppsExternalId= new map<string,string>();
    public TestDriveTriggerHandler() {
        this.testdrives= (list<Test_Drive__c>) Trigger.new;
    }

    public override void beforeInsert(){
        prepopulateFields(this.testdrives);
        createUniqueId(this.testdrives);
    }
    public void beforUpdate(){
        createUniqueId(this.testdrives);
    }
    //Rajesh - to prepopulate enquiry email so email alert functionality can be used.
    private void prepopulateFields(List<Test_Drive__c> newList){
        for (Test_Drive__c td : newList){
            td.Enquiry_Email__c = td.Enquiry_Email_Formula__c;
        }
     }
     
     //Rahul- create unique test drive and to prevent duplicate test drive
    private void createUniqueId(List<Test_Drive__c> newList){
        system.debug('inside createUniqueId' + newList.size());
        for(Test_Drive__c td : newList)
        {
        if(td.Enquiry__c != null)
            oppId.add(td.Enquiry__c);
        }
        
        system.debug('oppId size' + oppId.size());
        
        if(oppId.size()>0)
           oppLst = [Select External_Id__c, Id from Opportunity where Id in: oppId];
        
        system.debug('oppLst size'+ oppLst.size());    
        
        if(oppLst.size() > 0)    
        {
             for(Opportunity op : oppLst )
                 mapOppsExternalId.put(op.Id,op.External_Id__c);
        }
        if(newList.size() > 0 && mapOppsExternalId.size() > 0)    
        {
            for (Test_Drive__c td1 : newList)
            {
                    if(mapOppsExternalId.containsKey(td1.Enquiry__c))
                         td1.External_Id__c = td1.DMS_Booking_ID__c + '_' + mapOppsExternalId.get(td1.Enquiry__c);
                
            }
        }
    }
}