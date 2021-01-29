/**
 * @File Name          : CustomerVisibilityTriggerHandler.cls
 * @Description        : This trigger utility class  grant access to customer account records
 * @Author             : Subhojit Chakraborty
 * @Group              : 
 * @Last Modified By   : Subhojit Chakraborty
 * @Last Modified On   : 12/03/2019, 03:37:23 PM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                    Modification
 *==============================================================================
 * 1.0    12/03/2019, 03:37:23 PM   Subhojit Chakraborty     Initial Version
 * 
 */ 
public without sharing class CustomerVisibilityTriggerHandler extends TriggerHandler {
  
    private Map<Id, Customer_Visibility__c> newCVMap;
    private List<Customer_Visibility__c> newCVList;
    private Map<Id,Customer_Visibility__c> oldCVMap;
    
   
    
    //constructor
    public CustomerVisibilityTriggerHandler() {
        this.newCVMap = (Map<Id, Customer_Visibility__c>) Trigger.newMap;
        this.newCVList = (list<Customer_Visibility__c>) Trigger.New;
        this.oldCVMap = (Map<Id,Customer_Visibility__c>) Trigger.oldMap;
    }
    public override void beforeInsert(){
        //Populate DMS user name
        populateMSILUserName(this.newCVList);
        //Grant access to record.
        CustomerRecordVisibilityUtility.grantAccessToCustomerAccount(newCVList,false,false,true);
       /* if(mapresponse!=null && mapresponse.containsKey('FAILURE') && mapresponse.get('FAILURE').size()>0)
          throw  new CustomerRecordVisibilityUtility.CustomerVisibilityException(JSON.serialize(this.newCVList));*/
                                                                                
    }
    private void populateMSILUserName(List<Customer_Visibility__c> lstNewList){
        Set<Id> setMSILUserIDSF=new Set<Id>();
        List<User> lstUser=new List<User>();
        
        for(Customer_Visibility__c ocVVar: lstNewList){
            if(ocVVar.Related_User__c!=null)
              setMSILUserIDSF.add(ocVVar.Related_User__c);
        }
        Map<Id,User> mapUser=new Map<Id,User>([select Id,DMS_username__c from User where Id IN :setMSILUserIDSF]);
         for(Customer_Visibility__c ocVVar: lstNewList){
            if(ocVVar.Related_User__c!=null && mapUser.containsKey(ocVVar.Related_User__c))
              ocVVar.MSIL_User_ID__c=mapUser.get(ocVVar.Related_User__c).DMS_username__c;
        }
    }
}