/**
 * @File Name          : StockCheckCtrl.cls
 * @Description        : This class is used to check the stock availability.
 * @Author             : Anuj Kumar
 * @Group              :
 * @Last Modified By   : Anuj Kumar
 * @Last Modified On   : 24/7/2019 05:30 PM
 
 * @Modification Log   :
 *==============================================================================
 * Ver         Date                     Author                Modification    
 *==============================================================================
 * 1.0    24/7/2019 11:17 AM          Anuj Kumar            Initial Version
 * 1.1    08/01/2020 11:17 AM          Zakir                DE600 changes the DropDown Limit from 5 to 10 .
 
**/

public with sharing class StockCheckCtrl {
   
    @AuraEnabled(cacheable=true)
    public static OutletOrForCodeInfo retriveOutletAndForCodeInfo(){
        String roleCheck='%'+ConstantsUtility.TSM_ROLE+'%';
        //roleCheck='%TSM%';
        OutletOrForCodeInfo obj = new OutletOrForCodeInfo();
        String profileName = isHostessProfile();
        if(profileName == system.label.Hostess_Profile_Name || profileName==system.label.Finance_Profile_Name){
            obj.hideComponent = true;
        }else{
            obj.hideComponent = false;
        }
       
        if(obj.hideComponent){
            return obj;
        }
       
        string usrId =  UserInfo.getUserId();
       
        List<User> userData = new List<User>();
        System.debug(usrId);
        if(isUserAccessPermission()){
            userData = [Select id, Name , Title, contactId,Designation__c from User where Id =: usrId And IsPortalEnabled = True And
                        Designation__c NOT IN: ConstantsUtility.userTitleCEOGMSet Limit 1];
        }
        System.debug(userData);
        if(userData.size() > 0 && userData[0].contactId != Null){
            List<Contact> conList = new List<Contact>();
           
            if(isContactAccessPermission()){
                conList = [Select id, accountId, account.Dealer_Location__c, account.Dealer_Map_Code__c, account.Parent_Group__c
                           From Contact
                           where accountId != null And id =: userData[0].contactId];
            }
            System.debug(conList);
            if(conList != Null && conList.size() > 0){
                obj.dealerMapCode = conList[0].account.Dealer_Map_Code__c;
                obj.locationCode = conList[0].account.Dealer_Location__c;
                obj.parentCode = conList[0].account.Parent_Group__c;
            }
        }else{
            List<User> gmOrCeoTitleUserData = new List<User>();
           
            gmOrCeoTitleUserData = [Select id, Name , Title, contactId,Designation__c from User where Id =: usrId And IsPortalEnabled = True And
                                    Designation__c IN: ConstantsUtility.userTitleCEOGMSet Limit 1];
            if(gmOrCeoTitleUserData != Null && gmOrCeoTitleUserData.size() > 0 && gmOrCeoTitleUserData[0].contactId != Null){
                List<Contact> conList = new List<Contact>();
               
                conList = [Select id, accountId, account.Parent_Group__c from Contact where accountId != null
                                         And Id =: gmOrCeoTitleUserData[0].contactId And account.Dealer_Map_Code__c != Null];
                if(conList != Null && conList.size() > 0){
                    string parentGroup = conList[0].account.Parent_Group__c;
                   
                    obj.accountList = [Select id, Name, Dealer_Location__c, BillingCity, Consingnee_Code__c from Account where Recordtype.Name=:ConstantsUtility.DEALER_RECORDTYPE
                                       and Parent_Group__c =: parentGroup];
                }
            }else{
               
                List<User> tsmUserData = new List<User>();
            System.debug(roleCheck);
                tsmUserData = [Select id, Name , Title from User where Id =: usrId And IsPortalEnabled = False And
                               userrole.name like:roleCheck  Limit 1];
                               //Title IN: ConstantsUtility.userTitleTSMSet Limit 1];
                System.debug('tsmUserData--'+tsmUserData.size());
                if(tsmUserData != Null && tsmUserData.size() > 0 && isAccountAccessPermission()){
                    obj.accountList = [Select id, Name, Dealer_Location__c, BillingCity, Consingnee_Code__c from Account where Territory_Sales_Manager__c =: tsmUserData[0].Id];
                }else{
				  // Added for ATM Use case
                 string[] profileNames = label.Stock_Check_Profiles.split(',');
                 boolean ATMcheck=false;
                 list<profile> profList = [Select id from profile where name in :profileNames];
                 if(profList.size()>0){
                    for(profile prof : profList){
                        if(prof.id == userInfo.getProfileId()){
                            ATMcheck=true; 
                        }
                    }
                }
                if(ATMcheck){
                    obj.isATM = true;
                    obj.hideComponent = false;
                    obj.showAccountSearch=false; 
                }
                //
				else{
                    tsmUserData = [Select id, Name , Title from User where Id =: usrId And IsPortalEnabled = False And
                                   (NOT userrole.name like:roleCheck) Limit 1];
                                   // Title NOT IN: ConstantsUtility.userTitleTSMSet Limit 1];
                                   
                    if(tsmUserData != null && tsmUserData.size() > 0){
                        obj.hideComponent = False;
                        obj.showAccountSearch=True;
                    }
                }
				}
               
            }
        }
       
        return obj;
    }
	 
    /*
        @Author:                  Gitika
        @Created Date :           8-Oct-2020
        @Discription:             This function is used to get AccountList when Internal user will search for outlet/Consingnee code
        @Date Of Modification :   8-Oct-2020
    */
    @AuraEnabled
    public static wrapperofAccountlistAndCityMap getDealers(String state){
        wrapperofAccountlistAndCityMap wrapper = new wrapperofAccountlistAndCityMap();
        map<string,string> mapOfCityIdWithName = new map<String,string>();
		list<Account> accList = new list<Account>();
        set<string> cityIds = new set<String>();
        
        for (Account acc : [Select Id,Name,Consingnee_Code__c,BillingCity,Dealer_Map_Code__c,Parent_Group__c,Dealer_Location__c from Account 
           where Recordtype.Name=:ConstantsUtility.DEALER_RECORDTYPE and  BillingState =:State and BillingCity != null]){
		   accList.add(acc);
		   cityIds.add(acc.BillingCity);
		   }
        if(accList.size()>0){
            wrapper.accountList= accList;
            for(City__c city : [SELECT Name,Id FROM City__c where id in :cityIds]){
                mapOfCityIdWithName.put(city.id,city.Name);  
            }
            wrapper.mapOfCity=mapOfCityIdWithName;
         
        }
    

        return wrapper;
}

public class wrapperofAccountlistAndCityMap{
    @AuraEnabled public list<account> accountList = new list<account>(); 
    @AuraEnabled public map<string,string> mapOfCity = new map<string,string>();   
}
   
    /*
        @Author:                  Sunit Kumar Chand
        @Created Date :           19-Nov-2019
        @Discription:             This function is used to get AccountList when Internal user will search for outlet/Consingnee code
        @Date Of Modification :   19-Nov-2019
    */
    @AuraEnabled
    public static BasicReturn getAccounts(String name){
       
        BasicReturn br=new BasicReturn();
        try
        {
            String st='%'+name+'%';
            List<Account> accList=[Select Id,Name,Consingnee_Code__c,Dealer_Map_Code__c,Parent_Group__c,Dealer_Location__c from Account where Recordtype.Name=:ConstantsUtility.DEALER_RECORDTYPE and( Name like:st or Consingnee_Code__c like:st) limit 20];
            br.status='Success';
            br.dataList=accList;
            br.code=200;
        }
        catch(Exception e)
        {
           System.debug(e.getStackTraceString());
           br.status='Error';
           br.code=0;
           br.message=e.getMessage();
        }
        return br;
       
    }
   
    /*
        @Author:                  Anuj Kumar
        @Created Date :           18-Nov-2019
        @Discription:             To check current user profile is hostess or not.
        @Date Of Modification :   18-Nov-2019
    */
    @AuraEnabled(cacheable=true)
    public static String isHostessProfile(){
        String profileName = '';
        Id profileId = userInfo.getProfileId();
        if(profileId != Null){
            List<Profile> profileInfo = new List<Profile>([Select Id, Name from Profile where Id =: profileId]);    
            profileName = (profileInfo != null && profileInfo.size() > 0) ? profileInfo[0].Name : '';
        }
        return profileName;
    }
   
    /*
        @Author:                  Anuj Kumar
        @Created Date :           26/July/2019
        @Discription:             Get the Outlet And For Code Information for a perticular account.
        @Date Of Modification :   29/July/2019
    */
    @AuraEnabled(cacheable=true)
    public static OutletOrForCodeInfo retriveOutletAndForCodeFromAccount(String accountId){
       
        OutletOrForCodeInfo obj = new OutletOrForCodeInfo();
        if(string.IsNotBlank(accountId)){
            List<Account> accList = new List<Account>();
           
            if(isAccountAccessPermission()){
                accList = [Select id, Dealer_Map_Code__c, Dealer_Location__c, Parent_Group__c,Consingnee_Code__c from Account Where Id =: accountId];
            }
           
            if(accList != Null && accList.size() > 0){
                obj.dealerMapCode = accList[0].Dealer_Map_Code__c;
                obj.locationCode = accList[0].Dealer_Location__c;
                obj.parentCode = accList[0].Parent_Group__c;
                obj.consingneeCode=accList[0].Consingnee_Code__c;
            }
        }
       
        return obj;
    }
   
   
    /**
        @Author:                  Prabhat - Techmatrix
        @Created Date :           04th Feb 2020
        @Discription:             Get model picklist values based on Dealership channel (Nexa, Arena etc)
        Returns: String
        History:
        ================
        1.0     Added as part of enhancement - DE 506 - Prabhat 04th Feb 2020
       
    */
    @AuraEnabled(cacheable=true)
    public static map<String,String> retrieveModelPicklist(){
   
        map<String,String> modelPicklist = new map<String,String>();
       
        //Get logged in user channel
        String currentUserChannel = getCurrentUserChannel();
       
        //If current user is an internal user, set current channel as All
        if(String.isBlank(currentUserChannel)){
            currentUserChannel = 'All';
        }
       
        //Set current user channel as Nexa or Arena if not blank
        currentUserChannel =  (currentUserChannel == 'COM') ? ConstantsUtility.COMMERCIAL_LINEOFBUSINESS : (currentUserChannel == ConstantsUtility.CHANNEL_TYPE) ? ConstantsUtility.NEXA_LINEOFBUSINESS : ConstantsUtility.ARENA_LINEOFBUSINESS;
       
        //Get dependent picklist value map
        Map<String, List<String>> dependentValues = RetriveDependentPicklistData.getDependentMap(new Opportunity(), 'Dealership_Channel__c', 'Model_Code__c');
       
        //Get all the picklist values based on current user channel
        List<String> picklistValues = dependentValues.containsKey(currentUserChannel) ? dependentValues.get(currentUserChannel) : new list<String>();
       
        //Fetch the label-value map from picklist schema
        Schema.DescribeFieldResult fieldResult = Opportunity.Model_Code__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        map<String,String> valueLabelMap = new map<String,String>();
        for( Schema.PicklistEntry f : ple){
           valueLabelMap.put(f.getValue(),f.getLabel());
        }      
       
        //Create a map of Model picklist values label and API
        if(picklistValues !=null && picklistValues.size()>0){
            for(String modelApiName : picklistValues){
                modelPicklist.put(valueLabelMap.get(modelApiName),modelApiName);
            }
        }
       
        return modelPicklist;
    }
   
   
   
    /**
        @Author:                  Prabhat - Techmatrix
        @Created Date :           04th Feb 2020
        @Discription:             Get current user channel
        Returns: String
        History:
        ================
        1.0     Added as part of enhancement - DE 506 - Prabhat 04th Feb 2020
       
    */
    public static String getCurrentUserChannel(){
        //Query logged in user channel
        List<User> currentUser = [Select Id,Contact.Account.Channel__c FROM User WHERE Id=:UserInfo.getUserId()];
        //Put it a string variable
        String dealerChannel = (currentUser.size()>0 && currentUser[0].Contact.Account.Channel__c!=null) ? currentUser[0].Contact.Account.Channel__c : '';
       
        return dealerChannel;
    }
     
   
   
    /**
        @Author:                  Anuj Kumar
        @Created Date :           26/July/2019
        @Discription:             Search the Model Varient infromation from a perticular Name.
        Inputs: Object name, Record Id
        Returns: List of line item records (Opportunity/Quote line Items)
        History:
        ================
        1.0     19 Aug 2019      Prabhat     Initial Version
        1.1    08/01/2020        Zakir                DE600 changes the DropDown Limit from 5 to 10 .
       
    */
    @AuraEnabled(cacheable=true)
    public static List<Product2> retriveModelVarient(String name,String type, String variant){
        String productRecordTypeId = Schema.Sobjecttype.Product2.getRecordTypeInfosByName().get(ConstantsUtility.VARIANT_CONST).getRecordTypeId();
       
        //Get current user channel
        
        String dealerChannel = [Select Id, Channel__c FROM User WHERE Id=:UserInfo.getUserId()][0].Channel__c;
        Set<String> chennelSet = ConstantsUtility.getChannelSet(dealerChannel);
        
        if(String.isNotBlank(Name)){
            string nameData = '%'+Name.trim()+'%';
            List<Product2> prodList = new List<Product2>();
           
            string query = 'Select Id, Name,ProductCode from Product2';
            if(isProductAccessPermission() && String.isNotBlank(productRecordTypeId) && type=='C'){
                query += ' where RecordTypeId =: productRecordTypeId And Name Like : nameData AND Enquiry__c =\''+ConstantsUtility.YES + '\'' ;
               
                //Added as part of enhancement - DE 506 - Prabhat 04th Feb 2020
                if(String.isNotBlank(dealerChannel)){
                    query += ' AND Channel__c IN: chennelSet';
                }
            }
            else if(type=='A'){
                query += ' where Recordtype.Name =\''+ConstantsUtility.ACCESSORIES_CONST + '\' And (Name Like : nameData OR ProductCode Like : nameData )';
               
                if(string.isNotBlank(variant)){
                    query += 'AND Variant_LKP__c=:variant';
                }
            }
           
            query += ' AND IsActive = True Order By CreatedDate Desc Limit 10';
            
            system.debug('== query '+query);
            
            return DataBase.query(query);
        }
        return new List<product2>();
    }
    
    /**
        @Author:                  Anuj Kumar
        @Created Date :           31/July/2019
        @Discription:             Search the pruduct record for a perticular Name and code.
        Inputs:                   Object name, Record Id
        Returns:                  List of Product records
        History:
        ==========================================================================
        1.0     31 July 2019      Anuj     Initial Version
       
    */
    @AuraEnabled(cacheable=true)
    public static List<Product2> retrieveParts(String type, String searchTerm){
        
        system.debug('== type '+type);
        system.debug('== searchTerm '+searchTerm);
        
        String accessoriesRecordTypeId = Schema.Sobjecttype.Product2.getRecordTypeInfosByName().get(ConstantsUtility.ACCESSORIES_CONST).getRecordTypeId();
        String partsRecordTypeId = Schema.Sobjecttype.Product2.getRecordTypeInfosByName().get(ConstantsUtility.PARTS).getRecordTypeId();
        
        string query = '';
        List<Product2> productList = new List<Product2>();
        
        string searchValue = '';
        if(String.isNotBlank(searchTerm)){
            searchValue = '%'+searchTerm.trim()+'%';
        }
        
        if(String.isNotBlank(type) && type == 'Accessories'){
            query = 'Select Id, Name,ProductCode from Product2 where RecordtypeId =: accessoriesRecordTypeId And (Name Like : searchValue OR ProductCode Like : searchValue )  Order By CreatedDate Desc Limit 10';
        }else if(String.isNotBlank(type) && type != 'Accessories'){
            query += 'Select Id, Name,ProductCode from Product2 where RecordtypeId =: partsRecordTypeId And Part_Category__c =: type And (Name Like : searchValue OR ProductCode Like : searchValue ) Order By CreatedDate Desc Limit 10';
        }
      //  try{
          if(String.isNotBlank(query)){
              productList = DataBase.query(query);
          }
      /*  }catch(Exception ex){
            ExceptionHandler.stackTrace ehst = new ExceptionHandler.stackTrace(); ehst.componentName = 'StockCheck'; ehst.userId=UserInfo.getUserId(); ExceptionHandler.LogError('StockCheck', ex.getMessage(), 'StockCheck', '', ehst);
        }
        */
        
        return productList;
    }
    
   
    /*
        @Author:                  Anuj Kumar
        @Created Date :           26/July/2019
        @Discription:             Retrive the Color Varient infromation for a perticular Product.
        @Date Of Modification :   29/July/2019
    */
    @AuraEnabled(cacheable=true)
    public static List<Color_Variant_Master__c> retriveColorVarient(String productId){

        if(String.isNotBlank(productId)){
            List<Color_Variant_Master__c> colorVarientList = new List<Color_Variant_Master__c>();
           
            if(isColorVariantAccessPermission()){
                colorVarientList = [SELECT Id, Name, Color_Code__c, Variant__r.ProductCode
                                    From Color_Variant_Master__c
                                    Where Variant__c =: productId];
            }
            return colorVarientList;
        }
        return new List<Color_Variant_Master__c>();
    }
   
   
    /*
        @Author:                  Anuj Kumar
        @Created Date :           26/July/2019
        @Discription:             Retrive the Stock Availability for product on the basis of OutletCode, ForCode, VarientCode and ColorCode
        @Date Of Modification :   29/July/2019
    */
    @AuraEnabled(cacheable=true)
    public static String getResponse(){
       
        string tempResponse = '{"messageId":"96c884d3-4339-42a0-b8b8-81ca48101b6c","status":"Success","ProductStockList":[{"Model":"abcde","ModelDescription":"Model Description","Variant":"abcdefgh","VariantDescription":"Variant Description","Colour":"abcd","ColourDescription":"Color Description","InTransit":12345,"Allotted":12345,"Available":12345},{"Model":"abcde","ModelDescription":"Model Description","Variant":"abcdefgh","VariantDescription":"Variant Description","Colour":"abcd","ColourDescription":"Color Description","InTransit":12345,"Allotted":12345,"Available":12345},{"Model":"abcde","ModelDescription":"Model Description","Variant":"abcdefgh","VariantDescription":"Variant Description","Colour":"abcd","ColourDescription":"Color Description","InTransit":12345,"Allotted":12345,"Available":12345}]}';
       
        return tempResponse;
    }
   
    /*
        @Author:                  Anuj Kumar
        @Created Date :           26/July/2019
        @Discription:             Wrapper class used to hold the information for outletCode, forCode and List of Account.
        @Date Of Modification :   29/July/2019
    */
    public class OutletOrForCodeInfo{
        @AuraEnabled public string dealerMapCode;
        @AuraEnabled public string locationCode;
        @AuraEnabled public string parentCode;
        @AuraEnabled public string consingneeCode;
        @AuraEnabled public List<Account> accountList;
        @AuraEnabled public Boolean hideComponent;
        @AuraEnabled public Boolean showAccountSearch;
		@AuraEnabled public Boolean isATM=false;
    }
   
    /*******       TO Handle The Object And Field Permissions    ********/
   
    /*
        @Author:                  Anuj Kumar
        @Created Date :           06/07/2019
        @Discription:             To Check the access permissions for User.
        @Date Of Modification :   06/07/2019
    */
    public static Boolean isUserAccessPermission(){
        if(CheckObjectAndField.objectCURDPermission('User', ConstantsUtility.IsAccessible) &&
           CheckObjectAndField.fieldCURDPermission('User', ConstantsUtility.IsAccessible, 'Name') &&
           CheckObjectAndField.fieldCURDPermission('User', ConstantsUtility.IsAccessible, 'Title')){
            return True;
        }else{
            return false;
        }
    }
   
    /*
        @Author:                  Anuj Kumar
        @Created Date :           06/07/2019
        @Discription:             To Check the access permissions for Product.
        @Date Of Modification :   06/07/2019
    */
    public static Boolean isProductAccessPermission(){
        if(CheckObjectAndField.objectCURDPermission('Product2', ConstantsUtility.IsAccessible) &&
           CheckObjectAndField.fieldCURDPermission('Product2', ConstantsUtility.IsAccessible, 'Name')){
            return True;
        }else{
            return false;
        }
    }
   
   
    /*
        @Author:                  Anuj Kumar
        @Created Date :           06/07/2019
        @Discription:             To Check the access permissions for Contact.
        @Date Of Modification :   06/07/2019
    */
    public static Boolean isContactAccessPermission(){
        if(CheckObjectAndField.objectCURDPermission('Contact', ConstantsUtility.IsAccessible) &&
           CheckObjectAndField.fieldCURDPermission('Contact', ConstantsUtility.IsAccessible, 'accountId') &&
           CheckObjectAndField.fieldCURDPermission('Account', ConstantsUtility.IsAccessible, 'Dealer_Location__c') &&
           CheckObjectAndField.fieldCURDPermission('Account', ConstantsUtility.IsAccessible, 'Dealer_Map_Code__c') &&
           CheckObjectAndField.fieldCURDPermission('Account', ConstantsUtility.IsAccessible, 'Parent_Group__c')){
            return True;
        }else{
            return false;
        }
    }
   
    /*
        @Author:                  Anuj Kumar
        @Created Date :           06/07/2019
        @Discription:             To Check the access permissions for Account.
        @Date Of Modification :   06/07/2019
    */
    public static Boolean isAccountAccessPermission(){
        if(CheckObjectAndField.objectCURDPermission('Account', ConstantsUtility.IsAccessible) &&
           CheckObjectAndField.fieldCURDPermission('Account', ConstantsUtility.IsAccessible, 'Dealer_Location__c') &&
           CheckObjectAndField.fieldCURDPermission('Account', ConstantsUtility.IsAccessible, 'Dealer_Map_Code__c') &&
           CheckObjectAndField.fieldCURDPermission('Account', ConstantsUtility.IsAccessible, 'Parent_Group__c')){
            return True;
        }else{
            return false;
        }
    }
   
   
    /*
        @Author:                  Anuj Kumar
        @Created Date :           06/07/2019
        @Discription:             To Check the access permissions for ColorVariant.
        @Date Of Modification :   06/07/2019
    */
    public static Boolean isColorVariantAccessPermission(){
        if(CheckObjectAndField.objectCURDPermission('Color_Variant_Master__c', ConstantsUtility.IsAccessible) &&
           CheckObjectAndField.fieldCURDPermission('Color_Variant_Master__c', ConstantsUtility.IsAccessible, 'Name') &&
           CheckObjectAndField.fieldCURDPermission('Color_Variant_Master__c', ConstantsUtility.IsAccessible, 'Color_Code__c') &&
           CheckObjectAndField.fieldCURDPermission('Color_Variant_Master__c', ConstantsUtility.IsAccessible, 'Variant__c')){
            return True;
        }else{
            return false;
        }
    }
    
    /*
        @Author:                  Rahul Sharma/MSIL
        @Created Date :           26/May/2019
        @Discription:             Check user designation for parent level check
    */
    @AuraEnabled
    public static Boolean checkUserDesignation(){

        Boolean flag = false;
        String str = label.MSIL_StockParentLevelDesig;
        list<String> allowedDesignation = str.split(',');
        system.debug('user '+UserInfo.getUserId() + allowedDesignation);
        List<User> usrLst = [Select Id, Designation__c from user where id =: UserInfo.getUserId()];
        System.debug('user For Integration'+usrLst.size());
        if(usrLst.size() > 0)
        {
            system.debug('452 && '+allowedDesignation.contains(usrLst[0].Designation__c ));
            if(allowedDesignation.contains(usrLst[0].Designation__c ))
                flag = true;
        }  
        system.debug('flag '+flag );
        return flag;        
        
    } 
    
    /*
        @Author:                  Rahul Sharma/MSIL
        @Created Date :           26/May/2019
        @Discription:             Retrive dealer detail for parent level check
    */
    @AuraEnabled
    public static OutletOrForCodeInfo retriveDelaerDataWhenParentSelected(){
        
        OutletOrForCodeInfo obj = new OutletOrForCodeInfo();
        String str = label.MSIL_StockParentLevelDesig;
        list<String> allowedDesignation = str.split(',');
        List<User> usrLst = [Select Id, Designation__c,ContactId from user where id =: UserInfo.getUserId() and Designation__c In: allowedDesignation];
        if(usrLst.size() > 0)
        {
            List<Contact> conLst = [Select Id,account.Dealer_Location__c, account.Dealer_Map_Code__c, account.Parent_Group__c from contact where id =: usrLst[0].ContactId];
            if(conLst.size() > 0)
            {
                obj.dealerMapCode = conLst[0].account.Dealer_Map_Code__c;
                obj.locationCode = conLst[0].account.Dealer_Location__c;
                obj.parentCode = conLst[0].account.Parent_Group__c;
            }  
                   
       }
        return obj;
       }
       
   }