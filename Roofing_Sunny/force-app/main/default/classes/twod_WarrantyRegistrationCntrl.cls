public class twod_WarrantyRegistrationCntrl {
    public twod__Warranty_Registration__c wr{ get; set; }    
    public boolean isNewConsEnable{ get; set; }
    public boolean isNewConsEnableMailing{ get; set; }
    public boolean isCommercial{ get; set; }
    public boolean isEdit{ get; set; }
    public twod_WarrantyRegistrationCntrl(ApexPages.StandardController controller) {
        isEdit=false;
        wr = (twod__Warranty_Registration__c) controller.getRecord();
        isCommercial=false;
        isNewConsEnable=false;
        if(wr.Id!=null){
            wr=[Select Id,RecordTypeId,Name,Last_Name__c,Address_1__c,Address_2__c,City__c,Postal_Code__c,Country__c,State__c,Email__c,Phone__c,Install_Date__c,Organisation__c,
                Is_New_Construction__c,Building_Type__c,Organisation_BL__c,First_Name_BL__c,Last_Name_BL__c,Address_1_BL__c,Address_2_BL__c,City_BL__c,Is_New_Construction_Mailing_Address__c,
                Postal_Code_BL__c,Country_BL__c,State_BL__c,twod__Registration_Date__c,Product_Detail__c,Installation_Location__c,Product_Group__c,Installation_Location_other__c,
                Quantity__c,Unit_of_Measure__c from twod__Warranty_Registration__c where Id=:wr.Id];
            
            isNewConsEnable=wr.Is_New_Construction__c;
            isNewConsEnableMailing=wr.Is_New_Construction_Mailing_Address__c;
            isEdit=true;
        }        
        if(wr.RecordTypeId==null){
            wr.RecordTypeId=ApexPages.currentPage().getParameters().get('RecordType');        
        }   
        if([Select Name from RecordType where Id=:wr.RecordTypeId ].Name == 'Commercial'){
            isCommercial=true;
        }
        if(wr.twod__Registration_Date__c==null){wr.twod__Registration_Date__c=system.today();}
        system.debug('isNewConsEnable--'+isNewConsEnable);
        system.debug('isEdit--'+isEdit);
    }  
    
    public PageReference quickSave(){
        
        if(wr.Email__c==null){wr.Email__c=' ';}
        if(wr.Address_2__c==null){wr.Address_2__c=' ';}
        twod_CTUtil.validateBuildingLocationAddress ac=verifyBuildingLocation(wr.Address_1__c,wr.Address_2__c,wr.City__c,wr.State__c,wr.Postal_Code__c,wr.Country__c,wr.Email__c);        
        if(ac.status=='Success' || wr.Is_New_Construction_Mailing_Address__c){
            if(ac.status=='Success'){
                system.debug('Mailing Address verified');
                wr.Address_1__c=ac.address1;
                wr.Address_2__c=ac.address2;
                wr.City__c=ac.cityName;
                wr.State__c=ac.stateName;
                wr.Postal_Code__c=ac.zipCode;
                wr.Country__c=ac.country;                
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Mailing Address Validated Successfully'));
            }
            if(wr.Address_2_BL__c==null){wr.Address_2_BL__c=' ';}
            twod_CTUtil.validateBuildingLocationAddress ba=new twod_CTUtil.validateBuildingLocationAddress();
            if(!isEdit){                
                ba=verifyBuildingLocation(wr.Address_1_BL__c,wr.Address_2_BL__c,wr.City_BL__c,wr.State_BL__c,wr.Postal_Code_BL__c,wr.Country_BL__c,'');
            }            
            if(isEdit || ba.status=='Success'){
                system.debug('Building Address verified');
                system.debug(ba);
                if(!isEdit){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Building Address Validated Successfully'));                
                    wr.Address_1_BL__c=ba.address1;
                    wr.Address_2_BL__c=ba.address2;
                    wr.City_BL__c=ba.cityName;
                    wr.State_BL__c=ba.stateName;
                    wr.Postal_Code_BL__c=ba.zipCode;
                    wr.Country_BL__c=ba.country;      
                }
            }
            else{ 
                system.debug('Error Building Address verified');
                if(isNewConsEnable!=true || !wr.Is_New_Construction__c){
                    isNewConsEnable=true;
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Building Address : '+ba.errorMessage));                    
                    return null;
                }
            }
        }else{
            system.debug('Error Mailing Address verified');
            if(isNewConsEnableMailing!=true || !wr.Is_New_Construction_Mailing_Address__c){
                isNewConsEnableMailing=true;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Mailing Address : '+ac.errorMessage));                    
                return null;
            }
        }
        try{
            upsert wr;
            PageReference pageRef = new PageReference('/'+wr.Id);
            return pageRef;
        }
        catch(exception e){
            ApexPages.addmessages(e);
            return null;
        }        
    }
    
    public PageReference cancel(){
        PageReference pageRef;
        if(wr.Id!=null){
            pageRef = new PageReference('/'+wr.Id);
        }
        else{
            Schema.DescribeSObjectResult r = twod__Warranty_Registration__c.sObjectType.getDescribe();
            String keyPrefix = r.getKeyPrefix();
            pageRef = new PageReference('/'+keyPrefix+'/o');
        }
        return pageRef;
    }
    
    @remoteAction 
    public static twod_CTUtil.validateBuildingLocationAddress verifyBuildingLocation(String address1,String address2,String cityName,String stateName,String zipCode,String country,String email){        
        twod_CTUtil.validateBuildingLocationAddress valAddress=new twod_CTUtil.validateBuildingLocationAddress();     
        valAddress=twod_CTUtil.addressValidation(address1,address2,cityName,stateName,zipCode,country,email);
        return valAddress;
    }
}