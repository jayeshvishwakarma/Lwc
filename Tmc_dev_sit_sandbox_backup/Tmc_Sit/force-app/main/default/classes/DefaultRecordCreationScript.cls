/**
    * @Autho:- Anuj Kumar
    * @Company-: Techmatrix Consulting
    * @Description-: Class to Create Default record for fresh sandbox.
    * =============================================================
    * Version   Date            Author      Modification
    * =============================================================
    * 1.0       24 Feb 2020    Anuj Kumar     Intial Version
    **/
public class DefaultRecordCreationScript implements SandboxPostCopy{
    
    public void runApexClass(SandboxContext context) {
        createRecords();
    }

    
    public static final String TSM_USER_NAME = 'Test TSM Maruti';
    
    /*------------------------------------------------------------------------------------
        Description     To Generate Default Records for Org
        params          
    ------------------------------------------------------------------------------------*/
    public static void createRecords(){
        
        //Create For Code Records
        List<For_Code__c> forCodeList = createForCode();
        
        //Create Contacts records
        List<Account> accPartnerAccount = createDealerCustomer(forCodeList[0].Id);
        
        // Create contact partner user for earch dealer account
        createContactPartnerUser(accPartnerAccount);
        
        // Create default product record
        createDefaultProducts();
        
        // Create default person Account
        createDefaultPersonAccount();
        
        // Create default Address Master (Tehsil, village, city)
        createDefaultMasterAddress();
        
        //Create default Product Master (Color Variant Master, Price Master, Scheme Master, MCP Master)
        if(forCodeList != Null && forCodeList.size() > 0)
            createDefaultProductWithMaster(forCodeList[0].Id);
        
        // Create corporate, corporate group and Its LineItem
        createCorporateRecords();
        
    }
    
    /*------------------------------------------------------------------------------------
        Description     To Generate For Code records
        params          
    ------------------------------------------------------------------------------------*/
    public static List<For_Code__c> createForCode(){
        List<For_Code__c> forCodeList = new List<For_Code__c>();
        for(For_Code__c fr : TestDataFactory.createTestForCode(1)){
            fr.Name = 'DELHI';
            forCodeList.add(fr);
        }
        
        insert forCodeList;
        return forCodeList;
    }
    
    /*------------------------------------------------------------------------------------
        Description     To Generate Dealer Account records and enable them as a partner
        params          ForCode Id
    ------------------------------------------------------------------------------------*/
    public static List<Account> createDealerCustomer(string forCodeId ){
        // Create Dealer Accounts Records
        List<Account> accList = new List<Account>();
        Integer i = 0;
        for(Account acc : TestDataFactory.createBusinessAccount(3, 'Dealer')){
            
            if(i == 0){
                acc.Name = 'DD MOTORS (A DIVISION OF DD INDUSTRIES LTD) WAZIRPUR OUTLET';
                acc.Parent_Group__c = 'DDMOT';
                acc.Dealer_Code__c = '08B5';
                acc.Dealer_Map_Code__c = '10845';
                acc.Dealer_Category__c = 'DDL';
                acc.Dealer_Location__c = 'WAS';
                acc.Outlet_Code__c = '00';
                acc.Region_Code__c = 'C1';
                acc.Dealer_Type__c = 'S';
                acc.Service_Dealer_Code__c = '08B5';
                acc.Spare_Dealer_Code__c = '08B5';
                acc.Stock_Yard_Values__c = 'Y;N';
            }else if(i == 1){
                acc.Name = 'DD MOTORS (A DIVISION OF DD INDUSTRIES LTD) NARELA-SAL';
                acc.Parent_Group__c = 'DDMOT';
                acc.Dealer_Code__c = '08DB';
                acc.Dealer_Map_Code__c = '13164';
                acc.Dealer_Category__c = 'DDL';
                acc.Dealer_Location__c = 'PUY';
                acc.Outlet_Code__c = '0A';
                acc.Region_Code__c = 'C1';
                acc.Dealer_Type__c = 'S';
                acc.Service_Dealer_Code__c = '08DB';
                acc.Spare_Dealer_Code__c = '08DB';
                acc.Stock_Yard_Values__c = 'Y;N';
            }else if(i == 2){
                acc.Name = 'PREM MOTORS PVT. LTD. DELHI-S(NEXA)';
                acc.Parent_Group__c = 'PREM';
                acc.Dealer_Code__c = '08NK';
                acc.Dealer_Map_Code__c = '12357';
                acc.Dealer_Category__c = 'DDL';
                acc.Dealer_Location__c = 'GUO';
                acc.Outlet_Code__c = '0A';
                acc.Region_Code__c = 'C1';
                acc.Dealer_Type__c = 'S';
                acc.Stock_Yard_Values__c = 'Y';
            }
            
            acc.For_Code__c = forCodeId;
            accList.add(acc);
            i++;
        }
        if(accList != Null && accList.size() > 2){
            accList[0].Channel__c = 'EXC'; // For Nexa
            accList[1].Channel__c = 'NRM'; // For Arena
            accList[2].Channel__c = 'COM'; // For Commercial
        }
        
        insert accList;
        
        List<Account> accPartnerAccount = new List<Account>();
        
        for(Account acc : accList){
            if(acc.Id != null){
                acc.IsPartner = True;
                accPartnerAccount.add(acc);
            }
        }
        
        update accPartnerAccount;
        
        return accPartnerAccount;
    }
    
    /*------------------------------------------------------------------------------------
        Description     To Generate Contact (Partner Users under each dealers account)
        params          Dealer Account List
    ------------------------------------------------------------------------------------*/
    public static void createContactPartnerUser(List<Account> accPartnerAccount){
        Map<String, string> profileMap = getProfileInfo();
        
        // create Tsm User
        List<String> tsmProfileData = profileMap.containsKey('tsm') ? profileMap.get('tsm').split('#') : new List<String>();
        if(tsmProfileData != Null && tsmProfileData.size() > 1){
            generateTSMUserDetails(tsmProfileData[0], tsmProfileData[1]);
        }
        
        List<Contact> contactList = new List<Contact>();
        Map<String, List<Contact>> accIdWithContactsMap = new Map<String, List<Contact>>();
        
        for(Account acc : accPartnerAccount){
            List<Contact> conList = TestDataFactory.createTestContact(6, acc.Id);
            
            if(conList != Null && conList.size() > 5){
                
               conList[0].lastName = 'Hostess';
               conList[1].lastName = 'Vehicle DSE';
               conList[2].lastName = 'Accessories DSE';
               conList[3].lastName = 'Team Lead';
               conList[4].lastName = 'Showroom Manager'; 
               conList[5].lastName = 'CEO';  
            }
            
            accIdWithContactsMap.put(acc.Id, conList);
            
            contactList.addAll(conList);
        }
        
        insert contactList;
        
        string accIdWithConMapStr = JSON.serialize(accIdWithContactsMap);
        
        // Create Partner Users
        generateUserDetails(accIdWithConMapStr, profileMap, TSM_USER_NAME);
        
        
        
    }
    
     /*------------------------------------------------------------------------------------
        Description     To profile deatils from DataBase
        params          
    ------------------------------------------------------------------------------------*/
    public static Map<String, string> getProfileInfo(){
        
        Map<String,string> profileMap = new Map<String, String>();
        
        Set<String> profileNameSet = new Set<String>{'Dealer Hostess', 'Dealer Sales Executive', 
                    'Dealer Accessories User', 'Dealer Team Leads/Managers', 'Dealer CEO/Owner', 'Maruti Sales User'};
        
        for(Profile pro : [Select id, Name from Profile Where Name In: profileNameSet]){
            
            switch on pro.Name{
                
                when 'Dealer Hostess'{
                    profileMap.put('hostess', pro.Id+'#'+pro.Name);
                }
                when 'Dealer Sales Executive'{
                    profileMap.put('vehicle dse', pro.Id+'#'+pro.Name);
                }
                when 'Dealer Accessories User'{
                    profileMap.put('accessories dse', pro.Id+'#'+pro.Name);
                }
                when 'Dealer Team Leads/Managers'{
                    profileMap.put('team lead', pro.Id+'#'+pro.Name);
                    profileMap.put('showroom manager', pro.Id+'#'+pro.Name);
                }
                when 'Dealer CEO/Owner'{
                    profileMap.put('ceo', pro.Id+'#'+pro.Name);
                }
                when 'Maruti Sales User'{
                    profileMap.put('tsm', pro.Id+'#'+pro.Name);
                }
            }
            
        }
        
        return profileMap;
    }
    
    /*------------------------------------------------------------------------------------
        Description     To generate TSM User data
        params          List of contacts
    ------------------------------------------------------------------------------------*/
    @future
    public static void generateTSMUserDetails(String profileId, string profileName){
        
        User usr = TestDataFactory.generateUserData(new contact(), profileId, profileName);
        usr.userName = usr.userName + '.' +string.valueOf(UserInfo.getUserName().substringAfterLast('.'));
        usr.LastName = TSM_USER_NAME;
        
        
        insert usr;
    }
    
    /*------------------------------------------------------------------------------------
        Description     To generate Partner User data
        params          Map of accountId with list of contact in string formate and map profile Id and name
    ------------------------------------------------------------------------------------*/
    @future
    public static void generateUserDetails(string accIdWithConMapStr, Map<String,string> profileMap, string tsmUserName){
        
        List<User> tsmUserList = [Select id, LastName from User Where LastName =: tsmUserName];
        
        Map<String, List<Contact>> accIdWithContactsMap = (Map<String, List<Contact>>)JSON.deserialize(accIdWithConMapStr, Map<String, List<Contact>>.class);
    
        
        List<User> userList = new List<User>();
        integer i = 1;
        for(String accId : accIdWithContactsMap.keySet()){
            string dealerMapCode = '1305'+string.valueOf(i);
            for(Contact con : accIdWithContactsMap.get(accId)){
                
                List<String> profileInfo = profileMap.containsKey(con.lastName.tolowerCase()) ? profileMap.get(con.lastName.tolowerCase()).split('#') : new List<String>();
                if(profileInfo != Null && profileInfo.size() > 1){
                
                    if(con.LastName == 'Hostess'){
                        User usr = TestDataFactory.generateUserData(con, profileInfo[0], profileInfo[1]);
                        usr.LastName = con.LastName;
                        usr.Designation__c = 'LHS';
                        usr.MSPIN__c = '123451';
                        usr.Dealer_Employee_Code__c = dealerMapCode+usr.MSPIN__c;
                        usr.userName = dealerMapCode+'_'+usr.MSPIN__c+'@marutitest.com.'+string.valueOf(UserInfo.getUserName().substringAfterLast('.'));
                        
                        userList.add(usr);
                    }else if(con.LastName == 'Vehicle DSE'){
                        User usr = TestDataFactory.generateUserData(con, profileInfo[0], profileInfo[1]);
                        usr.LastName = con.LastName;
                        usr.Designation__c = 'SAE';
                        usr.MSPIN__c = '123452';
                        usr.Dealer_Employee_Code__c = dealerMapCode+usr.MSPIN__c;
                        usr.userName = dealerMapCode+'_'+usr.MSPIN__c+'@marutitest.com.'+string.valueOf(UserInfo.getUserName().substringAfterLast('.'));
                        
                        userList.add(usr);
                    }else if(con.LastName == 'Accessories DSE'){
                        User usr = TestDataFactory.generateUserData(con, profileInfo[0], profileInfo[1]);
                        usr.LastName = con.LastName;
                        usr.Designation__c = 'MSE';
                        usr.MSPIN__c = '123453';
                        usr.Dealer_Employee_Code__c = dealerMapCode+usr.MSPIN__c;
                        usr.userName = dealerMapCode+'_'+usr.MSPIN__c+'@marutitest.com.'+string.valueOf(UserInfo.getUserName().substringAfterLast('.'));
                        
                        userList.add(usr);
                    }else if(con.LastName == 'Team Lead'){
                        User usr = TestDataFactory.generateUserData(con, profileInfo[0], profileInfo[1]);
                        usr.LastName = con.LastName;
                        usr.Designation__c = 'TL';
                        usr.MSPIN__c = '123454';
                        usr.Dealer_Employee_Code__c = dealerMapCode+usr.MSPIN__c;
                        usr.userName = dealerMapCode+'_'+usr.MSPIN__c+'@marutitest.com.'+string.valueOf(UserInfo.getUserName().substringAfterLast('.'));
                        
                        userList.add(usr);
                    }else if(con.LastName == 'Showroom Manager'){
                        User usr = TestDataFactory.generateUserData(con, profileInfo[0], profileInfo[1]);
                        usr.LastName = con.LastName;
                        usr.Designation__c = 'NSM';
                        usr.MSPIN__c = '123455';
                        usr.Dealer_Employee_Code__c = dealerMapCode+usr.MSPIN__c;
                        usr.userName = dealerMapCode+'_'+usr.MSPIN__c+'@marutitest.com.'+string.valueOf(UserInfo.getUserName().substringAfterLast('.'));
                        
                        userList.add(usr);
                    }else if(con.LastName == 'CEO'){
                        User usr = TestDataFactory.generateUserData(con, profileInfo[0], profileInfo[1]);
                        usr.LastName = con.LastName;
                        usr.Designation__c = 'CEO';
                        usr.MSPIN__c = '123456';
                        usr.Dealer_Employee_Code__c = dealerMapCode+usr.MSPIN__c;
                        usr.userName = dealerMapCode+'_'+usr.MSPIN__c+'@marutitest.com.'+string.valueOf(UserInfo.getUserName().substringAfterLast('.'));
                        
                        usr.ManagerId = (tsmUserList != null && tsmUserList.size() > 0) ? tsmUserList[0].Id : null;
                        
                        userList.add(usr);
                    }    
                }
                
            }
            i++;
        }
        
        if(userList != Null && userList.size() > 0){
            Insert userList;
            
            Map<String, String> designationWithUserIdMap = new Map<String, String>();
            for(user usr : userList)
                designationWithUserIdMap.put(usr.Designation__c.toLowerCase(), usr.Id);
            
            List<User> userWithManagerList = new List<user>();
            
            List<String> usrIdList = new List<String>();
            
            for(user usr : userList){
                
                if(usr.Designation__c != null && usr.Designation__c == 'LHS' && designationWithUserIdMap.containsKey(('NSM').toLowerCase())){
                    usr.ManagerId = designationWithUserIdMap.get(('NSM').toLowerCase());
                    userWithManagerList.add(usr);
                }else if(usr.Designation__c != null && usr.Designation__c == 'SAE' && designationWithUserIdMap.containsKey(('TL').toLowerCase())){
                    usr.ManagerId = designationWithUserIdMap.get(('TL').toLowerCase());
                    userWithManagerList.add(usr);
                }else if(usr.Designation__c != null && usr.Designation__c == 'MSE' && designationWithUserIdMap.containsKey(('TL').toLowerCase())){
                    usr.ManagerId = designationWithUserIdMap.get(('TL').toLowerCase());
                    userWithManagerList.add(usr);
                }else if(usr.Designation__c != null && usr.Designation__c == 'TL' && designationWithUserIdMap.containsKey(('NSM').toLowerCase())){
                    usr.ManagerId = designationWithUserIdMap.get(('NSM').toLowerCase());
                    userWithManagerList.add(usr);
                }else if(usr.Designation__c != null && usr.Designation__c == 'NSM' && designationWithUserIdMap.containsKey(('CEO').toLowerCase())){
                    usr.ManagerId = designationWithUserIdMap.get(('CEO').toLowerCase());
                    userWithManagerList.add(usr);
                }
                
                usrIdList.add(usr.Id);
            }
            
            
            if(userWithManagerList != Null && userWithManagerList.size() > 0){
                update userWithManagerList;
            }
            // Create User Account
            System.enqueueJob(new CreateUserAccounts(usrIdList));    
        }
    }
    
    /*------------------------------------------------------------------------------------
        Description     To generate deafult product records
        params          
    ------------------------------------------------------------------------------------*/
    public static void createDefaultProducts(){
        
        map<string,Default_Product_Records__mdt > producMdtMap = new map<string,Default_Product_Records__mdt >();
        List<PriceBookEntry> pbeToInsert = new list<PriceBookEntry>();
        List<Product2> productToInsert = new list<Product2>();
        
        
        //Loop through metadata to create the product records
        for(Default_Product_Records__mdt  prod : [SELECT MasterLabel,RecordType_Name__c,Unit_Price__c from Default_Product_Records__mdt]){
            
            Product2 productObj = new Product2();
            productObj.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get(prod.RecordType_Name__c).getRecordTypeId();
            productObj.Name = prod.MasterLabel;
            productObj.Fuel_Type__c =ConstantsUtility.FUEL_TYPE; //Setting this with default values as required on field level
            productObj.Channel__c = ConstantsUtility.CHANNEL_TYPE; //Setting this with default values as required on field level
            productObj.Start_Date__c = ConstantsUtility.START_DATE; //Setting this with default values as required on field level
            productObj.End_Date__c = ConstantsUtility.END_DATE; //Setting this with default values as required on field level
            productObj.Model__c = ConstantsUtility.MODEL; //Setting this with default values as required on field level
            productToInsert.add(productObj);
            
            producMdtMap.put(prod.MasterLabel,prod);
        }
        
        //Insert Product records
        if(productToInsert.size()>0) 
            insert productToInsert;
        
        //Get standard Pricebook Id from Custom Setting
        String pricebook2Id = '';
        StandardPriceBookId__c lsPB = StandardPriceBookId__c.getInstance();        
        if (lsPB != null){
            pricebook2Id = lsPB.PriceBookId__c;
        }
        
        //Loop thorugh all the Products created
        if(productToInsert.size()>0){
            for(Product2 prod : productToInsert){
                PricebookEntry pbe = new PricebookEntry();
                pbe.Pricebook2Id = pricebook2Id;
                pbe.Product2Id = prod.Id;
                pbe.UnitPrice = producMdtMap.get(prod.Name).Unit_Price__c;
                pbeToInsert.add(pbe);
            }
        }
        
        //Create Pricebook Entries
        if(pbeToInsert.size()>0)
            insert pbeToInsert;
        // Create Default Asset record
        createDefaultAsset(productToInsert);
        
    }
    
    /*------------------------------------------------------------------------------------
        Description     To generate deafult person account records
        params          
    ------------------------------------------------------------------------------------*/
    public static void createDefaultPersonAccount(){
        
        List<Account> personAccountList = new List<Account>();
        string defaultSVOCId = '1136772';
        integer i = 0;
        for(Account acc : TestDataFactory.createPersonAccount(10)){
            acc.SVOC_ID__c = defaultSVOCId + string.valueOf(i);
            personAccountList.add(acc);
            i++;
        }
        
        insert personAccountList;
    }
    
    /*------------------------------------------------------------------------------------
        Description     To generate deafult Asset records
        params          
    ------------------------------------------------------------------------------------*/
    public static void createDefaultAsset(List<Product2> productToInsert){
        
        Id accessoriesRT = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Accessories').getRecordTypeId();
        Id insuranceRT = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Insurance').getRecordTypeId();
        Id loyaltyRT = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Loyalty').getRecordTypeId();
        Id testDriveRT = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Test Drive').getRecordTypeId();
        Id vehicleRT = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Vehicle').getRecordTypeId();
        
        List<Account> accountList = TestDataFactory.createBusinessAccount(1, 'Dealer');
        Insert accountList;
        
        List<Asset> assetList = new List<Asset>();
        integer i = 0; 
        for(Asset ast : TestDataFactory.CreateAssetsRecords(productToInsert)){
            ast.accountId  = accountList[0].Id;
            if(i == 0)
                ast.recordTypeId = accessoriesRT;
            else if(i == 1)
                ast.recordTypeId = insuranceRT;
            else if(i == 2)
                ast.recordTypeId = testDriveRT;
            else if(i == 3)
                ast.recordTypeId = loyaltyRT;
            else if(i == 4)
                ast.recordTypeId = vehicleRT;
            else
                ast.recordTypeId = vehicleRT;
                
            assetList.add(ast);
            i++;
        }
        
        Insert assetList;
    }
    
    /*------------------------------------------------------------------------------------
        Description     To generate deafult Tehsil, village and city
        params          
    ------------------------------------------------------------------------------------*/
    public static void createDefaultMasterAddress(){
        string tehsilCode = 'UP0000104';
        List<Tehsil__c> tehsilList = new List<Tehsil__c>();
        for(integer i=0; i<9; i++){
            Tehsil__c tehsilObj = new Tehsil__c();
            if(i == 0 || i == 2 || i== 4)
                tehsilObj.Name = 'Dadri';
            else 
                tehsilObj.Name = 'Jewar';
            tehsilObj.District__c = 'Gautam Buddha Nagar';
            tehsilObj.State__c = 'UP';
            tehsilObj.Tehsil_Code__c = tehsilCode + string.valueOf(i);
            tehsilList.add(tehsilObj);
        }
    
        
        if(tehsilList.size() > 0){
            
            Insert tehsilList;
            
            List<Village__c> villageList = new List<Village__c>();
            
            string villageCode = 'VIL33270';
            for(integer i = 0; i < tehsilList.size(); i++){
                Village__c vl = new Village__c();
                if(tehsilList[i].Name == 'Dadri'){
                    if(i == 0) vl.Name = 'Chautpur';
                    if(i == 2) vl.Name = 'Mahiuddin Pur Kanawni';
                    if(i == 4) vl.Name = 'Chhajarsi';
                }else if(tehsilList[i].Name == 'Jewar'){
                    if(i == 1) vl.Name = 'Rakhera';
                    if(i == 3) vl.Name = 'Ismail Nagar Urf Bhoyra';
                    if(i == 5) vl.Name = 'Hasanpur';
                    if(i == 6) vl.Name = 'Chakbirampur';
                    if(i == 7) vl.Name = 'Birampur';
                    if(i == 8) vl.Name = 'Shahpur Nagala';
                }
                
                
                vl.Tehsil__c = tehsilList[i].id;
                vl.Village_Code__c = villageCode + string.valueOf(i);
                villageList.add(vl);
            }
            
            insert villageList;
        }
        
        List<City__c> cityList = new List<City__c>();
        string cityCode = '45';
        for(integer i = 0; i< 10; i++){
            
            City__c cty = new City__c();
            cty.city_code__c = cityCode + string.valueOf(i);
            cty.State__c = 'UP';
            if(i == 0) cty.Name = 'BIJNORE';
            if(i == 1) cty.Name = 'BAHRAICH';
            if(i == 2) cty.Name = 'MAHARAJ GANJ';
            if(i == 3) cty.Name = 'BARBANKI';
            if(i == 4) cty.Name = 'SITAPUR';
            if(i == 5) cty.Name = 'HARDOI';
            if(i == 6) cty.Name = 'GONDA';
            if(i == 7) cty.Name = 'UNNAO';
            if(i == 8) cty.Name = 'SHAHJAHANPUR';
            if(i == 9) cty.Name = 'BIJNORE';
            if(i == 0 || i == 2 || i== 4 || i == 8)
                cty.Region__c = 'C1';
            else 
                cty.Region__c = 'N3';
            
            cityList.add(cty);
        }
        
        //Insert cityList;
    }
    
    public static void createDefaultProductWithMaster(String forCodeId){
        
        List<Product2> proList = new List<Product2>();
        
        List<Product2> productList = TestDataFactory.createProducts('Variants', 4);
        
        for(Integer i = 0; i< productList.size(); i++){
            
            Product2 pro = productList[i];
            pro.Extended_Warranty_1_year__c = 1000;
            pro.Extended_Warranty_2_year__c = 2000;
            pro.Extended_Warranty_3_year__c = 3000;
            pro.Loyalty_Amount__c = 1500;
            
            if(i == 0){
                pro.Name = 'MARUTI BALENO ALPHA';
                pro.productCode = 'BARDCL2';
                pro.Family = 'BALENO';
                pro.Channel__c = 'EXC';
                pro.Model__c = 'BA';
                
            }else if(i == 1){
                pro.Name = 'MARUTI CIAZ ZXI+';
                pro.productCode = 'CIR4CL2';
                pro.Family = 'CIAZ';
                pro.Channel__c = 'EXC';
                pro.Model__c = 'CI';
                
            }else if(i == 2){
                pro.Name = 'ALTO K10 LXI';
                pro.productCode = 'AKR4CS2';
                pro.Family = 'ALTO K10';
                pro.Channel__c = 'NRM';
                pro.Model__c = 'AK';
                
            }else if(i == 3){
                pro.Name = 'DZIRE DIESEL ZDI';
                pro.productCode = 'DMRDCL5';
                pro.Family = 'NEW SWIFT DZIRE';
                pro.Channel__c = 'NRM';
                pro.Model__c = 'DM';
            }
            
            
            proList.add(pro);
        }
        
        Insert proList;
        
        if(proList != null && proList.size() > 3){
            List<PriceBookEntry> pbeList = new List<PriceBookEntry>();
            Pricebook2 pb = [select id, name from Pricebook2 where isStandard = true limit 1];
            
            List<Color_Variant_Master__c> colorList = new List<Color_Variant_Master__c>();
            List<Price_Master__c> priceMasterList = new List<Price_Master__c>();
            for(Integer i = 0; i< proList.size(); i++){
                PriceBookEntry pbe = new PriceBookEntry();  //TestDataFactory.createPriceBookEntryList(1, proList[i].Id);
                pbe.UnitPrice = 1;
                pbe.Product2Id = proList[i].Id;
                pbe.IsActive = true;
                if(pb != Null && pb.id != Null)
                    pbe.Pricebook2Id = pb.Id;
                pbeList.add(pbe);
                
                colorList.addAll(TestDataFactory.createColorVarientRealetdToProduct(1, proList[i].Id));
                
                List<Price_Master__c> pm = (TestDataFactory.createPriceMaster(1, proList[i].Id, forCodeId));
                if(pm != Null){
                    Price_Master__c priceMaster = pm[0];
                    priceMaster.External_ID__c = proList[i].productCode+'_'+'M';
                    priceMaster.Color_Type__c = 'M';
                    priceMasterList.add(priceMaster);
                }
                
            }
            
            if(pbeList.size() > 0){
                insert pbeList;
            }
            if(colorList.size() > 0){
                insert colorList;
            }
            if(priceMasterList.size() > 0){
                insert priceMasterList;
            }
        }
        
        // Scheme Master Data For Exchange Bonus
        List<Scheme_Master__c> smList1 = TestDataFactory.createSchemeMaster(1, 'Exchange Bonus');
        insert smList1;
         
        // Scheme Master Data For Scheme
        List<Scheme_Master__c> smList2 = TestDataFactory.createSchemeMaster(2, 'Scheme');
        insert smList2;
        
        //MCP Master Creation
        List<MCP_Master__c> mcpMasterList = TestDataFactory.createMCPMaster(1);
        insert mcpMasterList;
    }
    
    public static void createCorporateRecords(){
        
        // Create Corporate
        List<Corporate__c> corList = new List<Corporate__c>();
        for(Corporate__c corp : TestDataFactory.createCorporate(10)){
            corp.Name = 'National Rural Health Mission (NRHM)';
            corp.Actual_Name__c = 'National Rural Health Mission (NRHM)';
            corp.Active__c  = true;
            
            corList.add(corp);
        }
        insert corList;
        
        List<Corporate_Group__c> corpGrpList = new List<Corporate_Group__c>();
        string corpGropCode = '10013';
        for(Integer i = 0; i<corList.size(); i++ ){
            Corporate_Group__c cg = new Corporate_Group__c();
            cg.Name = 'HEALTH';
            cg.Active__c = true;
            cg.Corporate_Group_Code__c = corpGropCode + string.valueOf(i);
            
            corpGrpList.add(cg);
        }
        //insert corpGrpList;
        
        List<Corporate_Group_Line_Items__c> coprGrpLineList = new List<Corporate_Group_Line_Items__c>();
        for(Integer i = 0; i<corList.size(); i++ ){
            
            Corporate_Group_Line_Items__c cgLi = new Corporate_Group_Line_Items__c();
            cgli.Active__c = true;
            cgli.Corporate__c = corList[i].Id;
            cgli.Corporate_Group__c = corpGrpList[i].Id;
            
            coprGrpLineList.add(cgli);
        }
        
        //insert coprGrpLineList;
    }
    
    
    
    
    
}