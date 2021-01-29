/**
* @File Name          : AccountTriggerHandler.cls
* @Description        : Trigger handler class for Account
* @Author             : 
* @Group              : 
* @Last Modified By   : Nishant Prajapati
* @Last Modified On   : 09/9/2019, 3:12:16 PM
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0    7/05/2019, 9:14:54 PM                                Initial Version 
**/

//CODE REVIEWED BY: Prabhat Sharma

public class AccountTriggerHandler extends TriggerHandler {
  
    private Map<Id, Account> newAccMap;
    private List<Account> newAccList;
    private Map<Id,Account> oldAccMap;
    
    private static Id dealerRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get(ConstantsUtility.DEALER_ENQUIRY).getRecordTypeId();
    
    //constructor
    public AccountTriggerHandler() {
        this.newAccMap = (Map<Id, Account>) Trigger.newMap;
        this.newAccList = (list<Account>) Trigger.New;
        this.oldAccMap = (Map<Id,Account>) Trigger.oldMap;
    }

    public void before(){
        //Method to update the customer names to upper Case
        capitalizeName();
        updateMobileSFMCField();
        
    }
    
   
      
    public override void beforeInsert() {
    before();
    system.debug('this.newAccList----->'+this.newAccList);
    }

    // add overrides for other contexts
    public override void beforeUpdate() {
        before();
        //Update SVOCID time stamp json when SVOC ID is updated
        updateSVOCIdTimeStamp();
        //Restrict field changes for Dealer Admin
        restrictDealerAdminsFieldChanges();
        
    }
    
    public override void afterInsert(){
        //Assign permissions to Dealer Admin
        enableDealerAdminPermission();  
        
        //Add Primary TSM to Account Team
        addPrimaryTSM();
    }
    
    public override void afterUpdate(){
        //Assign permissions to Dealer Admin
        enableDealerAdminPermission();  
        //Add Primary TSM to Account Team
        addPrimaryTSM();
    }

    /**
        Author: Nishant Prajapati
        Company: Techmatrix
        Description: Method to update the Customers name to upper case 
        Inputs: None
        Returns: void
        History:
        ====================================================
        1.0     11 Sept 2019  Nishant Prajapati  Initial Version
    **/
    public void capitalizeName(){
      
      //Loop thorugh all accounts
      for (Account acc : this.newAccList){
          if(trigger.isInsert || (trigger.isUpdate && (this.oldAccMap.get(acc.Id).FirstName != acc.FirstName || 
                                  this.oldAccMap.get(acc.Id).LastName != acc.LastName || 
                                  this.oldAccMap.get(acc.Id).MiddleName != acc.MiddleName))){
              acc.FirstName = String.isNotBlank(acc.FirstName) ? acc.FirstName.toUpperCase() : '';
              acc.LastName = String.isNotBlank(acc.LastName) ? acc.lastname.toUpperCase() :'';
              acc.MiddleName = String.isNotBlank(acc.MiddleName) ? acc.middlename.toUpperCase() : '';
          }
      }
    }

    /**
        Author: Nishant Prajapati
        Company: Techmatrix
        Description: Method to update the SVOC change date time stamp
        Inputs: None
        Returns: void
        History:
        ====================================================
        1.0     11 Sept 2019  Nishant Prajapati  Initial Version
    **/
    public void updateSVOCIdTimeStamp(){
        //Loop thorugh all accounts
        for (Account acc : this.newAccList){
            String data = ConstantsUtility.SVOCID_CONST+ConstantsUtility.COLON+acc.SVOC_ID__c+ConstantsUtility.COMMA;
            data+=ConstantsUtility.TIMESTAMP_CONST+ConstantsUtility.COLON+String.valueOf(Datetime.now());
            
            //Update the details in specified field
            acc.LastModified_SVOC_Time_Stamp__c = data;
        }
    }
    
    /**
        Author: Nishant Prajapati
        Company: Techmatrix
        Description: Method to prefix mobile no. with 91 in a different field
        Inputs: None
        Returns: void
        History:
        ====================================================
        1.0     06 Nov 2019  Nishant Prajapati  Initial Version
    **/
    public void updateMobileSFMCField(){
        for (Account acc : this.newAccList){
            if(acc.IsPersonAccount){
                acc.Mobile_SFMC__c= ConstantsUtility.COUNTRY_CODE+String.valueof(acc.PersonMobilePhone);
            }
        }
    }
    
    
    
    /**
        Author: Prabhat Sharma
        Company: Techmatrix
        Description: Method to add the dealer admin to the Account Team to provide access to edit SPOC and Business Hour fields
        Inputs: None
        Returns: void
        History:
        ====================================================
        1.0  27 Nov 2019  Prabhat Sharma  Initial Version
    **/
    public void enableDealerAdminPermission(){
        
        //List to hold the account records 
        list<Account> accountFilteredList = new list<Account>();
        //List for insert Account Team Members
        list<AccountTeamMember> accountTeamMemberToInsert = new list<AccountTeamMember>();
        
        //loop through trigger.new
        for(Account acc : this.newAccList){
            //condition check for insert and update 
            if((trigger.isInsert && (acc.Dealer_Administrator__c !=null)) || 
               (trigger.isUpdate && (acc.Dealer_Administrator__c!=null && this.oldAccMap.get(acc.Id).Dealer_Administrator__c != acc.Dealer_Administrator__c))){
                accountFilteredList.add(acc);
            }
        }
        
        //Loop through the valid list of Account records to create the Account Team Member
        if(accountFilteredList.size()>0){
            
            //set variable to store the account ids and to be passed in the future method
            set<Id> dealerAdminIds = new set<Id>();
            
            //Query Previously added admins
            List<AccountTeamMember> previousAdmins = new list<AccountTeamMember>([SELECT Id FROM AccountTeamMember WHERE AccountId in: accountFilteredList and TeamMemberRole =: ConstantsUtility.DEALER_ADMIN]);
            
            //Delete if any exists
            if(previousAdmins.size()>0){
                delete previousAdmins;
            }
            
            
            //Below logic to check if permission set is already assigned to the users
            Id permissionSetId;
            //Get the Permission Set Id
            List<PermissionSet> adminPermissionSet  = new list<PermissionSet>([SELECT Id FROM PermissionSet WHERE 
                                                                               PermissionSet.Label =: ConstantsUtility.PERMISSION_SET_NAME]);
            
            set<Id> existingUserIds = new set<Id>();
            //If the permission set exists
            if(adminPermissionSet.size()>0){
                permissionSetId = adminPermissionSet[0].Id;
                //Loop through all the permission set
                for(PermissionSetAssignment existPerm : [SELECT Id,AssigneeId,PermissionSetId FROM PermissionSetAssignment WHERE PermissionSetId=:adminPermissionSet[0].Id]){
                    existingUserIds.add(existPerm.AssigneeId);
                }
            }
                          
            
            //Loop through all the valid accounts and create Account team members
            for(Account acct : accountFilteredList){
                AccountTeamMember accMember=new AccountTeamMember();
                //Map the Account Id
                accMember.AccountId = acct.Id;
                //Map the dealer admin user
                accMember.UserId = acct.Dealer_Administrator__c;
                //Map the dealer admin role
                accMember.TeamMemberRole = ConstantsUtility.DEALER_ADMIN;
                //Provide record edit access 
                accMember.AccountAccessLevel = ConstantsUtility.EDIT_ACCESS;
                accountTeamMemberToInsert.add(accMember); 
                
                //Add the dealer account ids
                if(!existingUserIds.contains(acct.Dealer_Administrator__c)){
                    dealerAdminIds.add(acct.Dealer_Administrator__c);
                }
            }
            
            //Create Account Team Member Records
            if(accountTeamMemberToInsert.size()>0){
                insert accountTeamMemberToInsert;
                
                //call future method to assign permission set to filtered users
                if(dealerAdminIds.size()>0){
                    assignPermissionSettoUsers(dealerAdminIds,permissionSetId);
                }
            }
        }
    }
    
    
    
    /**
        Author: Prabhat Sharma
        Company: Techmatrix
        Description: Method to assign permission set to dealer admins
        Inputs: None
        Returns: void
        History:
        ====================================================
        1.0  27 Nov 2019  Prabhat Sharma  Initial Version
    **/
    @future
    public static void assignPermissionSettoUsers(set<Id> accountFilteredList, Id permissionSetId){
        //List for insert permission set assignment records
        list<PermissionSetAssignment> permnissionSetAssignList = new list<PermissionSetAssignment>();
        
        for(Id dealerAccountId : accountFilteredList){
            //Initializing Permission Set Assignment
            PermissionSetAssignment psa = new permissionSetAssignment();
            psa.PermissionSetId = permissionSetId;
            psa.AssigneeId = dealerAccountId;
            permnissionSetAssignList.add(psa);
        }
        
        //Assign Permission sets
        if(permnissionSetAssignList.size()>0){
            insert permnissionSetAssignList;
        }
    }
    
    
    /**
        Author: Prabhat Sharma
        Company: Techmatrix
        Description: Method to restric admins to edit certain fields only
        Inputs: None
        Returns: void
        History:
        ====================================================
        1.0  27 Nov 2019  Prabhat Sharma  Initial Version
    **/
    public void restrictDealerAdminsFieldChanges(){
        //Varible to store the log in user id
        string usrId =  UserInfo.getUserId();
        //map to store all the fields from account
        map<string,Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(ConstantsUtility.ACCOUNT_OBJ).getDescribe().fields.getMap();
        //Set to store the Dealer Admin Ids from account
        set<id> dealerSet = new set<id>();
        
        //loop through trigger.new
        for(Account acc : this.newAccList){
            if( acc.RecordTypeId==dealerRecordType && acc.Dealer_Administrator__c != null)
                dealerSet.add(acc.Dealer_Administrator__c); 
        }
        
        //size check
        if(dealerSet.size()>0){
            //loop through trigger.new
            for(Account newAcc : this.newAccList){
                //checking the log in user is Dealer or not 
                if(newAcc.Dealer_Administrator__c!= null && dealerSet.contains(usrId)){
                    //Creating the old account record using coming record AccountId 
                    Account oldAcc = this.oldAccMap.get(newAcc.id);
                    //loop through fieldMap keyset
                    for(String fields : fieldMap.keyset()){
                        //condition check
                        if((newAcc.get(fields) != oldAcc.get(fields)) && ((!fields.contains(ConstantsUtility.SPOC_FIELDS)) && 
                                                                          (!fields.contains(ConstantsUtility.BUSINESS_HRS)) &&
                                                                          (!fields.contains(ConstantsUtility.SVOC_LSTMODIFIED))))
                            newAcc.addError(ConstantsUtility.ERROR_MSG);
                    }
                }
            }   
        }
    }
    
    /**
        Author: Rahul Sharma
        Company: MSIL
        Description: Method to Add primary TSM to Dealer account team
        Inputs: None
        Returns: void
       **/
    public void addPrimaryTSM(){
         
        list<AccountTeamMember> accountTeamMemberToInsert = new list<AccountTeamMember>();
        Id AccRecTypeId2 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Dealer').getRecordTypeId();
        //loop through trigger.new
        for(Account acct : this.newAccList){
        
                if(acct.Territory_Sales_Manager__c != null && acct.RecordTypeId  == AccRecTypeId2)
                {
                AccountTeamMember accMember=new AccountTeamMember();
                accMember.AccountId = acct.Id;
                accMember.UserId = acct.Territory_Sales_Manager__c;
                accMember.TeamMemberRole = 'Sales Manager';
                accMember.AccountAccessLevel = 'Edit';
                accMember.OpportunityAccessLevel = 'Read';
                accountTeamMemberToInsert.add(accMember); 
                }
        }           
         //Create Account Team Member Records
         if(accountTeamMemberToInsert.size()>0)
                insert accountTeamMemberToInsert;           
    }
   
}