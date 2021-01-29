/**
* @Author:  Rahul Raghunathan
* @Company-: Salesforce
* @Description-: Service class to update the phone and designation of the contact user
* =============================================================
* Version   Date            Author      Modification
* =============================================================
* 1.0       15 Oct 2020    Rahul R      Intial Version
**/

public with sharing class ContactUpdate implements Schedulable{

    Map<Id,User> mapContactIdToUser; //Variable used for storing the IDs of the users.

    public ContactUpdate(Map<Id,User> mapContactIdToUser) {
        this.mapContactIdToUser = mapContactIdToUser;
    }

        //Execute method for Schdule job    
    public void execute(SchedulableContext sc){
        //Execute the job.
        updateContacts();
        //Clean up schedule jobs which have completed execution but havent been scheduled for future runs
         for( CronTrigger cro :[select id 
                                from CronTrigger 
                                where NextFireTime = null]){
            system.abortJob(cro.id);
        }                           
    }


    //Execute method 
    public void updateContacts() {

        try {
            //List to store contact those needs to be updated
            List<Contact> listContactToUpdate = new List<Contact>();
            //Iterating over the mapContactIdToUser.keySet() to get the contact Id
            for(Id conId : mapContactIdToUser.keySet()) {
                //Creating new instance of Contact
                Contact con = new Contact();
                con.Id = conId;
                con.Phone = mapContactIdToUser.get(conId).Phone;
                con.Designation__c = mapContactIdToUser.get(conId).Designation__c;
                listContactToUpdate.add(con);
            }
            
            //Update contact records
            if(listContactToUpdate.size() > 0) {
                update listContactToUpdate;
            }     
        }
        catch(Exception e) {
            ExceptionHandler.LogError('UserTriggerHandler', e.getMessage()+':'+e.getLineNumber(), 'Update Phone and Designation of Contact', '', null);    
        }


    }

}