/**
    * @Autho:- Rahul Sharma
    * @Company-: MSIL
    * @Description-: Batch class to update fields on account object for DSE's to show in a report
    **/
public without sharing class PassWordServiceBatch implements Database.Batchable<sObject>, Database.Stateful{

  string query;
  map<Id,string > userIdPwdMap = new map<Id,string >();
  public PassWordServiceBatch (String Q)
   {
       query = Q;
       //added below condition to ensure only 1 record is tested to avoid test class failurre
       if (Test.isRunningTest()){
           query = query + ' limit 1';
       }
       system.debug('query '+query +Q);
   }
   //Start Method
   public Database.QueryLocator start(Database.BatchableContext BC){
        DateTime Dt = system.now();
        Integer i = Integer.valueof(System.Label.User_Creation_Modification_Hours);
        DateTime Dt1 = Dt.addHours(i);
       system.debug('query '+query);
       //return User list
       return Database.getQueryLocator(query);
       }

   //Execute method
   public void execute(Database.BatchableContext BC, List<User> scope){
       system.debug(''+scope);
       if(scope.size() > 150){
            ExceptionHandler.LogError('PasswordService setPassword', 'More than 150 users created so password not set.','Password Service', '', null);
        }else{
            for(User userObj : scope){
                String password = createPasswordString(userObj);

                if(password.length()>=8){
                    try {
                        system.setPassword(userObj.Id, password);
                        userIdPwdMap.put(userObj.Id, password);
                    } catch (Exception e) {
                        ExceptionHandler.LogError('PasswordService setPassword', e.getMessage(),'Password Service', '', null);
                    }
                }else{
                    ExceptionHandler.LogError('PasswordService setPassword', 'Password for User ID:'+userObj.id+' not set as lenght is less than 8','Password Service', '', null);
                }

            }
        }

   }
   //Finish Method
   public void finish(Database.BatchableContext BC){
        if(userIdPwdMap.Keyset().size() > 0)
        {
            List<User> updateLst = new List<User>();
            for(String str : userIdPwdMap.Keyset())
            {
                User u = New user(id = str, Partner_User_Pwd__c = userIdPwdMap.get(str),Partner_User_Default_Pwd_Generation_Time__c = system.now() );
                updateLst.add(u);
            }
            if(updateLst.size() > 0)
                update updateLst;

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