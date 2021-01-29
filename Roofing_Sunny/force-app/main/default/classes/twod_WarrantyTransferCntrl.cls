public class twod_WarrantyTransferCntrl {
    public Warranty_Transfer__c wt{ get; set; }    
    public boolean isNewConsEnable{ get; set; }
    public boolean isNewConsEnableMailing{ get; set; }    
    public boolean isCommercial{ get; set; }
    public boolean isEdit{ get; set; }
    public twod_WarrantyTransferCntrl(ApexPages.StandardController controller) {
        isEdit=false;
        wt = (Warranty_Transfer__c) controller.getRecord();
        isCommercial=false;
        isNewConsEnable=false;
        if(wt.Id!=null){
            wt=[Select Id,RecordTypeId,Name,First_Name__c,Last_Name__c,Address_1__c,Address_2__c,City__c,Postal_Code__c,Country__c,State__c,Email__c,Phone__c,Is_New_Construction_Mailing_Address__c,
                Is_New_Construction__c,Building_Type__c,First_Name_BL__c,Last_Name_BL__c,Address_1_BL__c,Address_2_BL__c,City_BL__c,Organisation__c,Install_Date__c,Organisation_BL__c,
                Postal_Code_BL__c,Country_BL__c,State_BL__c,Transfered_Date__c,Product_Detail__c,Installation_Location__c,Product_Group__c,Installation_Location_other__c,
                Quantity__c,Unit_of_Measure__c from Warranty_Transfer__c where Id=:wt.Id];
            
            isNewConsEnable=wt.Is_New_Construction__c;
            isNewConsEnableMailing=wt.Is_New_Construction_Mailing_Address__c;
            isEdit=true;
        }        
        if(wt.RecordTypeId==null){
            wt.RecordTypeId=ApexPages.currentPage().getParameters().get('RecordType');        
        }   
        if([Select Name from RecordType where Id=:wt.RecordTypeId].Name == 'Commercial'){
            isCommercial=true;
        }
        system.debug('isNewConsEnable--'+isNewConsEnable);
        if(wt.Transfered_Date__c==null){wt.Transfered_Date__c=system.today();}
        
    }  
    
    public PageReference quickSave(){
        if(wt.Email__c==null){wt.Email__c=' ';}
        if(wt.Address_2__c==null){wt.Address_2__c=' ';}
        twod_CTUtil.validateBuildingLocationAddress ac=verifyBuildingLocation(wt.Address_1__c,wt.Address_2__c,wt.City__c,wt.State__c,wt.Postal_Code__c,wt.Country__c,wt.Email__c);
        if(ac.status=='Success'  || wt.Is_New_Construction_Mailing_Address__c){
            if(ac.status=='Success'){
                system.debug('Mailing Address verified');
                wt.Address_1__c=ac.address1;
                wt.Address_2__c=ac.address2;
                wt.City__c=ac.cityName;
                wt.State__c=ac.stateName;
                wt.Postal_Code__c=ac.zipCode;
                wt.Country__c=ac.country;                
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Mailing Address Validated Successfully'));
            }
            if(wt.Address_2_BL__c==null){wt.Address_2_BL__c=' ';}
            twod_CTUtil.validateBuildingLocationAddress ba=new twod_CTUtil.validateBuildingLocationAddress();
            if(!isEdit){                
                ba=verifyBuildingLocation(wt.Address_1_BL__c,wt.Address_2_BL__c,wt.City_BL__c,wt.State_BL__c,wt.Postal_Code_BL__c,wt.Country_BL__c,'');
            }            
            if(isEdit || ba.status=='Success'){
                system.debug('Building Address verified');
                system.debug(ba);
                if(!isEdit){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Building Address Validated Successfully'));                
                    wt.Address_1_BL__c=ba.address1;
                    wt.Address_2_BL__c=ba.address2;
                    wt.City_BL__c=ba.cityName;
                    wt.State_BL__c=ba.stateName;
                    wt.Postal_Code_BL__c=ba.zipCode;
                    wt.Country_BL__c=ba.country;        
                }
            }else
            { system.debug('Error Building Address verified');
             if(isNewConsEnable!=true || !wt.Is_New_Construction__c){
                 isNewConsEnable=true;
                 ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Building Address : '+ba.errorMessage));                    
                 return null;
             }
            }
        }else{
            system.debug('Error Mailing Address verified');
            if(isNewConsEnableMailing!=true || !wt.Is_New_Construction_Mailing_Address__c){
                isNewConsEnableMailing=true;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Mailing Address : '+ac.errorMessage));                    
                return null;
            }
        }
        try{
            upsert wt;
            PageReference pageRef = new PageReference('/'+wt.Id);
            return pageRef;
        }
        catch(exception e){
            ApexPages.addmessages(e);
            return null;
        }        
    }
    
    public PageReference cancel(){
        PageReference pageRef;
        if(wt.Id!=null){
            pageRef = new PageReference('/'+wt.Id);
        }
        else{
            Schema.DescribeSObjectResult r = Warranty_Transfer__c.sObjectType.getDescribe();
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