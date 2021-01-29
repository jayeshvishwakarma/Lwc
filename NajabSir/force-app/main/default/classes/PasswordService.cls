/**
* @Author:  Rahul Raghunathan
* @Company-: Salesforce
* @Description-: Service class to generate password for partner users
* =============================================================
* Version   Date            Author      Modification
* =============================================================
* 1.0       01 Oct 2019    Prabhat     Intial Version
* 1.1       28 Jan 2020    Prabhat     updating to make it schedulable
**/
public with sharing class PasswordService implements Queueable,Schedulable{
    
    set<id> userIds; //Variable used for storing the IDs of the users.
    Boolean isCTIUsers; //Variable used to Identify CTI Users Added by Anas
    public PasswordService(set<id> passIds,Boolean isCTIUsers) {
        this.userIds = passIds;
        this.isCTIUsers = isCTIUsers;
    }
    
    
    //Execute Method for Queable Apex
    public void execute(QueueableContext context) {
        executePassService();
    }
    
    //Execute method for Schdule job    
    public void execute(SchedulableContext sc){
        //Execute the job.
        executePassService();
        //Clean up schedule jobs which have completed execution but havent been scheduled for future runs
        for( CronTrigger cro :[select id 
                               from CronTrigger 
                               where NextFireTime = null]){
                                   system.abortJob(cro.id);
                               }                           
        
        
    }
    
    
    //Execute method 
    public void executePassService() {
        if(userIds.size() > 150){
            ExceptionHandler.LogError('PasswordService setPassword', 'More than 150 users created so password not set.','Password Service', '', null);
        }else{
            if(!isCTIUsers){
                for(User userObj : Database.query(label.User_Object_Password_Query)){
                    String password = createPasswordString(userObj);
                    
                    if(password.length()>=8){
                        try {
                            system.setPassword(userObj.Id, password);                        
                        } catch (Exception e) {
                            ExceptionHandler.LogError('PasswordService setPassword', e.getMessage(),'Password Service', '', null);
                        }
                    }else{
                        ExceptionHandler.LogError('PasswordService setPassword', 'Password for User ID:'+userObj.id+' not set as lenght is less than 8','Password Service', '', null);
                    }
                }   
            }
            //Added by Anas
            else {
                for(User userObj : Database.query(label.Call_Center_Agent_Query)) {
                    String password = userObj.CTI_User_Id__c+ConstantsUtility.C_ALPHABET+userObj.Location_Prefix__c;
                    if(password.length()>=8){
                        try {
                            system.setPassword(userObj.Id,password);                        
                        } catch (Exception e) {
                            ExceptionHandler.LogError('PasswordService setPassword for CTI Users', e.getMessage(),'Password Service', '', null);
                        }
                    }
                }    
            }
        }    
    }
    
    
    // Generate password string
    //Changed the method to have delaer code in password in place of delaer map code
    private string createPasswordString(User usrObj){
        String pass = '';
        //List<String> dealerCodes = usrObj.Dealer_Employee_Code__c!=null ? usrObj.Dealer_Employee_Code__c.split('_') : new list<String>();
        //String> dealerMapCode = usrObj.Dealer_Employee_Code__c!=null ? usrObj.Dealer_Employee_Code__c.split('_') : '';
        String dealerCode = usrObj.Contact.Account.Dealer_Code__c!=null ? usrObj.Contact.Account.Dealer_Code__c : '';
        String dealerCode1 = dealerCode.toLowercase();
        User userNewObj = new User();
        userNewObj.Dealer_Employee_Code__c = dealerCode1;
        userNewObj.MSPIN__c = usrObj.MSPIN__c + ConstantsUtility.M_ALPHABET;
        
        List<String> passwordFields = label.Partner_Users_Password_Pattern.split(',');
        
        for(Integer i=0;i<passwordFields.size();i++){
            pass+= userNewObj.get(passwordFields[i]);
        }
        
        //pass+= '3';
        
        system.debug('pass--->'+pass);
        
        /*ass = u.FirstName!=null?u.FirstName.replaceall(' ',''):'';
            for(integer i = pass.length(), i < 4, i++){
            	pass += 'a'; 
            }
		*/
        
        //pass += u.MSPIN__c!=null?u.MSPIN__c:'';
        //pass +=dealerCode.size()>0 ? dealerCode[0] : '';
        return pass;
    }
}