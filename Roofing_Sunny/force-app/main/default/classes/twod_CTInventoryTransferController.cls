public class twod_CTInventoryTransferController {
    public twod__Warranty_Registration__c wr { get; set; }
    public twod__Warranty_Registration__c wrt { get; set; }
    public sobject warrantyRegistration { get; set; }
    
    public Warranty_Transfer__c wt { get; set; }    
    public Warranty_Transfer__c wtt { get; set; }
    
    public List<Attachment> newAttachments {get; set;}
    public List<Attachment> newAttachmentsCopied {get; set;}
    public Attachment attachment {
        get {
            if (attachment == null)
                attachment = new Attachment();
            return attachment;
        }
        set;
    }
    public Account acc { get; set; }
    public static twod_CTUtil.validateBuildingLocationAddress valAddress{get;set;}
    public String propertyType {get; set;}
    public String Organization {get; set;}
    public String firstName {get; set;}
    public String lastName {get; set;}
    public String address1 {get; set;}
    public String address2 {get; set;}
    public String email {get; set;}
    public String phone {get; set;}
    public String city {get; set;}
    public String state {get; set;}
    public String country {get; set;}
    public String postalcode {get; set;}
    //Transfer
    public String BL_firstName {get; set;}
    public String BL_lastName {get; set;}
    public String BL_address1 {get; set;}
    public String BL_address2 {get; set;}
    public String BL_email {get; set;}
    public String BL_phone {get; set;}
    public String BL_city {get; set;}
    public String BL_state {get; set;}
    public String BL_country {get; set;}
    public String BL_postalcode {get; set;}
    public String BuildingType {get; set;}
    public String ProductName {get; set;}
    public String ProductGroup {get; set;}
    public String UnitsOfMeasure {get; set;}
    public Date installedDate{get;set;}
    public Date TransferedDate{get;set;}
    public Double Quantity {get; set;}
    public String ProductDetail {get; set;}
    public String InstallationLocation {get; set;}
    public String InstallationLocationOther {get; set;}
    public String errorMessage {get; set;}
    public String errorMessage1 {get; set;}
    public String recordType {get; set;}
    public String url {get; set;}
    public Boolean render {get; set;}
    public Boolean attachmentRender {get ;  set ; }
    public boolean isSiding{get; set;}
    public boolean isRoofing{get; set;}  
    
    public twod_CTInventoryTransferController() {
        errorMessage=Label.EmailMandatory;                     
        newAttachments=new List<Attachment>{new Attachment()};
            addMore();
        recordType = ApexPages.currentPage().getParameters().get('type');
        system.debug('recordType::::'+recordType);
        attachmentRender=false;
        render=false;
        if(recordType=='transfer')
        {
            render=true;
            system.debug('render::::'+render);
            if(Label.AttachementWarrantyTransfer=='true')
            {
                attachmentRender=true;
            }           
        }
        else
        {
            system.debug('inside if');
            if(Label.AttachementWarrantyRegistration=='true')
            {
                system.debug('inside if if');
                attachmentRender=true;
            }
        }
        
        wr = new twod__Warranty_Registration__c(); 
        wt=new Warranty_Transfer__c();
        acc=new Account();
        wr.put('Organisation__c', '');            
        propertyType='Residential'; 
        
        //Calling function to change the Record Type
        updateRecordType();
            
        system.debug('::::::' + attachmentRender);
        wr.Country__c='United States';
        wr.Country_BL__c='United States';
        Map<string,Certain_Teed__c> CertainTeed = Certain_Teed__c.getAll(); 
        isSiding=CertainTeed.get('isSiding').BooleanValue__c;
            isRoofing = CertainTeed.get('isRoofing').BooleanValue__c;
        //CertainTeed_ShortTerm_Period__c mcs = CertainTeed_ShortTerm_Period__c.getAllvalues();
        
        //Code to get URL
        url=ApexPages.currentPage().getUrl();
        String publicSite = Label.PublicSiteLabel;
        publicSite='/'+publicSite+'/';
        url=url.replace('/apex/', publicSite);
        system.debug('url-->' + url);
        
    }
    
    @remoteAction 
    public static twod_CTUtil.validateBuildingLocationAddress verifyBuildingLocation(String address1,String address2,String cityName,String stateName,String zipCode,String country,String email){        
        valAddress=new twod_CTUtil.validateBuildingLocationAddress();     
        valAddress=twod_CTUtil.addressValidation(address1,address2,cityName,stateName,zipCode,country,email);
        return valAddress;
    }
    
    public PageReference copyInfo() {
        system.debug('country::' + country);
        wr.put('Country_BL__c', country);
        wr.put('State_BL__c', state);       
        wt.put('Country_BL__c', country);
        wt.put('State_BL__c', state);       
        
        newAttachmentsCopied=newAttachments;
        system.debug(newAttachmentsCopied);
        return null;
    }
    
    public PageReference previewInfo() {
        system.debug('country::' + country);
        wr.put('Country_BL__c', country);
        wr.put('State_BL__c', state);       
        wt.put('Country_BL__c', country);
        wt.put('State_BL__c', state);       
        
        newAttachmentsCopied=newAttachments;
        system.debug(newAttachmentsCopied);
        return null;
    }
    
    public PageReference submit() {
        PageReference nextPage = null;
        system.debug('propertyType:::' + country);
        return null;      
    }       
    
    public PageReference updateRecordType(){
        if(propertyType=='Residential')
        {                        
            Id rtId=[select Id,DeveloperName from recordtype where DeveloperName='Residential' and SobjectType='twod__Warranty_Registration__c' limit 1].Id;
            system.debug('rtIdsss--' + rtId);
            wr.put('RecordtypeId',rtId);            
        }
        else
        {
            Id rtId=[select Id,DeveloperName from recordtype where DeveloperName='Commercial' and SobjectType='twod__Warranty_Registration__c' limit 1].Id;
            wr.put('RecordtypeId', rtId);
        }
        return null;
    }
        
    public pageReference ProductGroupChange(){
        CertainTeed_ShortTerm_Period__c mcs = CertainTeed_ShortTerm_Period__c.getvalues(ProductGroup);
        system.debug('ProductGroup::' + mcs);        
        system.debug('ProductGroup::' + ProductGroup);
        UnitsOfMeasure='';
        if(mcs!=null)
            UnitsOfMeasure='in ' + mcs.Unit_of_Measure__c;        
        return null;
        
    }
    public void copy()
    {
        newAttachmentsCopied=newAttachments;
        system.debug(newAttachmentsCopied);
    }
    
    public PageReference download()
    {
        PageReference pg1 =new PageReference('/apex/CTDownload');
        return pg1;    
    }
    
    public PageReference upload() {
        
        //Account Creation
        //acc=twod_CTUtil.accountCreation(BL_address1,BL_address2,BL_city,BL_state,BL_country,BL_postalcode);        
        system.debug('Date-->>>' +installedDate );
        if(render)
        {
            objectInsertion(wt);
        }
        else
        {
            objectInsertion(wr);
        }
        
        try{
            if(render)
            {
                insert wt;   
                wtt = [select Name from Warranty_Transfer__c where Id=:wt.Id];           
                warrantyRegistration=wt;
            }
            else
            {
                system.debug('wr---->>>' + wr);
                insert wr;   
                wrt = [select Tracking_Number__c from twod__Warranty_Registration__c where Id=:wr.Id];           
                warrantyRegistration=wr;
            }
            
            List<Attachment> toInsert=new List<Attachment>();
            system.debug('--');
            system.debug(newAttachmentsCopied);
            for (Attachment newAtt : newAttachmentsCopied)
            {
                if (newAtt.Body!=null)
                {
                    newAtt.parentId=wr.Id;
                    toInsert.add(newAtt);
                }
            }
            insert toInsert;
            newAttachments.clear();
            newAttachmentsCopied.clear();
            newAttachments.add(new Attachment());
            
            
            PageReference pg1 =new PageReference('/apex/CTInventoryTransferDetail');
            if(render)
                pg1 =new PageReference('/apex/CTInventoryTransferDetail?type=transfer');
            return pg1;                 
        }
        catch(Exception e)
        {
            PageReference pg1 =new PageReference('/apex/InMaintenance');
            return pg1;  
        }
        
    }
    
    public void objectInsertion(sobject wr)
    {
        if(propertyType=='Residential')
        {            
            if(render==true)
            {
                wr.put('First_Name__c', firstName);
                Id rtId=[select Id,DeveloperName from recordtype where DeveloperName='Residential' and SobjectType='Warranty_Transfer__c' limit 1].Id;
                wr.put('RecordtypeId',rtId);
            }
            else{
                Id rtId=[select Id,DeveloperName from recordtype where DeveloperName='Residential' and SobjectType='twod__Warranty_Registration__c' limit 1].Id;
                system.debug('rtId--' + rtId);
                wr.put('RecordtypeId',rtId);
                wr.put('Name', firstName);
            }wr.put('Last_Name__c', lastName); 
            wr.put('Organisation__c', '');            
        }
        else
        {
            if(render==true)
            {
                wr.put('First_Name__c', firstName);
                Id rtId=[select Id,DeveloperName from recordtype where DeveloperName='Commercial' and SobjectType='Warranty_Transfer__c' limit 1].Id;
                wr.put('RecordtypeId', rtId );
            }
            else{
                wr.put('Name', firstName);
                Id rtId=[select Id,DeveloperName from recordtype where DeveloperName='Commercial' and SobjectType='twod__Warranty_Registration__c' limit 1].Id;
                wr.put('RecordtypeId', rtId);
            }
            wr.put('Last_Name__c', lastName);
            wr.put('Organisation__c', Organization);            
        }
        if(render==true)
        {
            wr.put('Install_Date__c', installedDate);
            wr.put('Account__c', acc.Id);
        }
        else
        {            
            wr.put('twod__Registration_Date__c', system.today());
            wr.put('Install_Date__c', installedDate);
            wr.put('twod__Customer__c', acc.Id);
        }
        CertainTeed_ShortTerm_Period__c mcs = CertainTeed_ShortTerm_Period__c.getvalues(ProductGroup);        
        wr.put('City__c', city);
        wr.put('Phone__c', phone);
        wr.put('Postal_Code__c', postalcode);
        wr.put('Email__c', email);
        wr.put('Address_1__c', address1);
        address2=(address2).trim();
        wr.put('Address_2__c', address2);
        wr.put('Country__c', country);
        wr.put('State__c', state);
        wr.put('Property_Type__c', propertyType);
        wr.put('Product_Group__c', ProductGroup);
        wr.put('Product_Name__c', ProductName);
        wr.put('First_Name_BL__c', BL_firstName);
        wr.put('Last_Name_BL__c', BL_lastName);
        
        wr.put('City_U__c', BL_city);
        wr.put('State_U__c', BL_state);    
        wr.put('Address_1_U__c', BL_address1);
        wr.put('Address_2_U__c', BL_address2);
        wr.put('Postal_Code_U__c', BL_postalcode);
        wr.put('Country_U__c', BL_country);
        
        //Validated Addresss
        //valAddress=new twod_CTUtil.validateBuildingLocationAddress();     
        //valAddress=twod_CTUtil.addressValidation(BL_address1,BL_address2,BL_city,BL_state,BL_postalcode,BL_country,email);
        wr.put('City_BL__c', BL_city);
        wr.put('State_BL__c',BL_state);    
        wr.put('Address_1_BL__c', BL_address1);
        BL_address2=(BL_address2).trim();
        wr.put('Address_2_BL__c', BL_address2);
        wr.put('Postal_Code_BL__c', BL_postalcode);
        wr.put('Country_BL__c', BL_country);
        
        wr.put('Building_Type__c', BuildingType);
        wr.put('Quantity__c', Quantity);
        wr.put('Transfered_Date__c', TransferedDate);
        wr.put('PRODUCT_DETAIL__c', ProductDetail);
        wr.put('Installation_Location_other__c', InstallationLocationOther);
        wr.put('Installation_Location__c', InstallationLocation);
        if(mcs!=null)
            wr.put('Unit_of_Measure__c',mcs.Unit_of_Measure__c);        
    }
    public void addMore()
    {
        // append NUM_ATTACHMENTS_TO_ADD to the new attachments list
        for (Integer idx=0; idx<9; idx++)
        {
            newAttachments.add(new Attachment());
        }
    }    
    
    
    // Determines what kind of rendering to use for the page request
    public String renderingService { get; private set; }
    
    // Allow the page to set the PDF file name
    public String renderedFileName { 
        get; 
        set { renderedFileName = this.sanitizeFileName(value); }
    }
    
    // Rendered content MIME type, used to affect HTTP response
    public String renderedContentType {
        get {
            String renderedContentType = 'text/html'; // the default
            
            if( ! this.renderingAsHtml() ) {
                // Provides a MIME type for a PDF document 
                renderedContentType = 'application/pdf';
                
                // Add a file name for the PDF file
                if( this.renderedFileName != null) {
                    // This is supposed to set the file name, but it doesn't work
                    renderedContentType += '#' + this.renderedFileName;
                    
                    // This is a work-around to set the file name
                    ApexPages.currentPage().getHeaders().put(
                        'content-disposition', 'attachment; filename=' + 
                        this.renderedFileName);
                }
            }
            
            return renderedContentType;
        }
    }
    
    // Are we rendering to HTML or PDF?
    public Boolean renderingAsHtml() {
        return ( (renderingService == null) || 
                ( ! renderingService.startsWith('PDF')) );
    }
    
    // Action method to save (or "print") to PDF
    public PageReference saveToPdf() {
        renderingService = 'PDF';
        
        if(render)
        {
           renderedFileName='WarrantyTransfer-'+ wtt.Name +'.pdf'; 
        }
        else
        {
          renderedFileName='WarrantyRegistration-'+ wrt.Tracking_Number__c+'.pdf';   
        }
        String s=this.renderedContentType;
        return null;
    }
    
    // Private helper -- basic, conservative santization
    public String sanitizeFileName(String unsafeName) {
        String allowedCharacters = '0-9a-zA-Z-_.';
        String sanitizedName = 
            unsafeName.replaceAll('[^' + allowedCharacters + ']', '');
        // You might also want to check filename length, 
        // that the filename ends in '.pdf', etc.
        return(sanitizedName);
    }
    
   
    
}