public class twod_CTClaimPublicController {
    public twod__Claim__c claim { get; set; }
    public List<Claim_Status_Tracking__c> claimTrackingList { get; set; }
    public List<Claim_Status_Tracking__c> claimTracking { get; set; }
    public List<Attachment> newAttachments {get; set;}
    public List<ZipFile__c> formList {get; set;}    
    public static twod_CTUtil.validateBuildingLocationAddress valAddress;
    public Attachment attachment {
        get {
            if (attachment == null)
                attachment = new Attachment();
            return attachment;
        }
        set;
    }
    public Account acc { get; set; }
    public String propertyType {get; set;}
    //CERP-31 : Update Product Type/Building Type/Installation Location Hierarchy
    public String BuildingType {get; set;}
    public String downloadURL {get; set;}
    public String formName {get; set;}
    public String Organization {get; set;}
    public String formId {get; set;}
    public String claimId {get; set;}
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
    public String name {get; set;}
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
    
    //Product Info
    public integer Quantity {get; set;}
    public integer Quantity1 {get; set;}
    public String ProductDetail {get; set;}
    public String InstallationLocation {get; set;}
    public String InstallationLocationOther {get; set;}
    public String ProductGroup {get; set;}
    public String UnitsOfMeasure {get; set;}
    public Date installedDate{get;set;}
    public String NatureOfProblem {get; set;}
    
    public String errorMessage {get; set;}
    public String errorMessage1 {get; set;}
    public boolean tracking {get; set;}
    public String Doc {get;set;}
    public String ClaimNumber {get;set;}
    public boolean modalRender {get; set;}
    public Boolean EnablePoller{get; set;}
    public Id AttachmentId{get; set;}
    public boolean isSiding{get; set;}
    public boolean isRoofing{get; set;}    
    public String url {get; set;}
    public String ContentDistributionId;
    
    public twod_CTClaimPublicController() {
        errorMessage=Label.EmailMandatory;     
        claim=new twod__Claim__c();
        formId='a192800000112Mc';
        acc=new Account();
        newAttachments=new List<Attachment>{new Attachment()};
            tracking=false;
        propertyType='Residential';
        claim.Property_Type__c='Residential';
        formList=[Select Id,Name from ZipFile__c where Status__c=true ORDER BY priority__c];
        if(!formList.isEmpty())
            formName=formList[0].Name;
        claim.Country__c='United States';
        claim.Country_BL__c='United States';
        modalRender=false;
        EnablePoller=false;
        Map<string,Certain_Teed__c> CertainTeed = Certain_Teed__c.getAll(); 
        isSiding=CertainTeed.get('isSiding').BooleanValue__c;
        isRoofing = CertainTeed.get('isRoofing').BooleanValue__c;
        if(isSiding){
            UnitsOfMeasure='Affected Quantity';
        }
        if(isRoofing){
            UnitsOfMeasure='Number of Squares Affected by Concern';
        }
        //Code to get URL        
        url=ApexPages.currentPage().getUrl();
        system.debug('url-->' + url);
        String publicSite = Label.PublicSiteLabel;
        publicSite='/'+publicSite+'/';
        url=url.replace('/apex/', publicSite);
        addMore();
        
        //Claim Tracking Data Onload
        String claimTrackingId=apexpages.currentpage().getparameters().get('id');        
        if(claimTrackingId !='' && claimTrackingId !=null)
        {
            claim=[select First_Name__c,Last_Name__c,City__c,Phone__c,Name_BL__c,Tracking_Number__c,Install_Date__c,Nature_of_Problem__c,Organization__c,Zip_Code_Postal_Code__c,
                   Product_Group__c,Quantity__c,Product_Detail__c, twod__Claim_Status__c,Name,createdDate,First_Name_BL__c,Last_Name_BL__c,material_quantity__c,
                   Postal_Code__c,Email__c,Address_1__c,Address_2__c,Country__c,State__c,Unit_of_Measure__c ,
                   City_BL__c,State_BL__c,Phone_BL__c,Address_1_BL__c,Address_2_BL__c,Postal_Code_BL__c,
                   Country_BL__c  from twod__Claim__c where Id=:claimTrackingId];
            url=apexpages.currentpage().getparameters().get('url');             
            publicSite = Label.PublicSiteLabel;
            publicSite='/'+publicSite+'/';
            url=url.replace('/apex/', publicSite);
            system.debug('url-->' + url);
            claimTrackingList=[select Claim__c,Modified_By__c,Modified_Date__c,Claim_Status__c from Claim_Status_Tracking__c where Claim__c=:claim.Id ORDER BY createdDate DESC];
            claimTracking=new List<Claim_Status_Tracking__c>();
            Integer i=0;
            for(Claim_Status_Tracking__c cl:claimTrackingList)
            {
                if(cl.Claim_Status__c=='Pre Claim')
                {                    
                    cl.Claim_Status__c='Submitted';   
                    claimTracking.add(cl);
                    break;
                }
                else if(cl.Claim_Status__c=='Need more Information')
                {                    
                    cl.Claim_Status__c='Additional Information Required';    
                    claimTracking.add(cl);
                    break;
                }
                else if(cl.Claim_Status__c=='Claim')
                {                    
                    cl.Claim_Status__c='In Progress';     
                    claimTracking.add(cl);
                    break;
                }
                else if(cl.Claim_Status__c=='Submitted')
                {                    
                    cl.Claim_Status__c='Analysis Complete';
                    claimTracking.add(cl);
                    break;
                }
                else if(cl.Claim_Status__c=='Closed')
                {                    
                    cl.Claim_Status__c='Closed';
                    claimTracking.add(cl);
                    break;
                }                
            }
            tracking=true;
        }
    }
    
    public PageReference copyInfo() {
        system.debug('country::' + country);
        claim.Country_BL__c=country;
        claim.State_BL__c=state;
        return null;
    }
    
    public void copy()
    {
        
    }
    
    public PageReference previewInfo() {
        system.debug('country::' + country);
        claim.Country_BL__c=country;
        claim.State_BL__c=state;
        return null;                
    }
           
 public PageReference updatePropertyType(){
     claim.Property_Type__c=propertyType;
     return null;
}
    
    public PageReference submit() {
        PageReference nextPage = null;        
        String accName;        
        //system.debug('valAddress-->'+valAddress);
        //valAddress=new twod_CTUtil.validateBuildingLocationAddress();     
        //valAddress=twod_CTUtil.addressValidation(BL_address1,BL_address2,BL_city,BL_state,BL_postalcode,BL_country,email);
        claim.City_BL__c=BL_city;
        claim.State_BL__c=BL_state;        
        claim.Address_1_BL__c=BL_address1;
        BL_address2=(BL_address2).trim();
        claim.Address_2_BL__c=BL_address2;
        claim.Postal_Code_BL__c=BL_postalcode;
        claim.Country_BL__c=BL_country;
        claim.First_Name_BL__c=BL_firstName;
        claim.Last_Name_BL__c=BL_lastName;
        
        //Account Creation
        acc=twod_CTUtil.accountCreation(BL_address1,BL_address2,BL_city,BL_state,BL_country,BL_postalcode);
        system.debug('ProductGroup:::' + ProductGroup);
        
        CertainTeed_ShortTerm_Period__c mcs = CertainTeed_ShortTerm_Period__c.getvalues(ProductGroup);
        if(mcs!=null)
            claim.Unit_of_Measure__c=mcs.Unit_of_Measure__c;
        claim.twod__Claim_Type__c='Standard';
        claim.Product_Group__c=ProductGroup;
        claim.Property_Type__c=propertyType;
        //CERP-31 : Update Product Type/Building Type/Installation Location Hierarchy
        claim.Building_Type__c=BuildingType;
        claim.First_Name__c=firstName;
        claim.Last_Name__c=lastName;
        claim.City__c=city;
        claim.Phone__c=phone;
        claim.Postal_Code__c=postalcode;
        claim.Zip_Code_Postal_Code__c=postalcode;
        claim.Email__c=email;
        
        claim.Address_1__c=address1;
        address2=(address2).trim();
        claim.Address_2__c=address2;
        claim.Country__c=country;
        claim.State__c=state;
        
        
        
        //User Entered        
        claim.City_U__c=BL_city;
        claim.State_U__c=BL_state;
        claim.Address_1_U__c=BL_address1;
        claim.Address_2_U__c=BL_address2;
        claim.Zip_Code_Postal_Code_U__c=BL_postalcode;
        claim.Country_U__c=BL_country;
        
        
        //SAP Vendor Number
        Map<string,CT_SAP_Vendor_Number__c> CTSAPVendorNumber = CT_SAP_Vendor_Number__c.getAll(); 
        
        //CT Multi currency changes
        if(claim.Country_BL__c =='Canada')
            claim.SAP_Vendor_Number__c = CTSAPVendorNumber.get('Standard_CAN').SAP_Vendor_Number__c; 
	    else 
            claim.SAP_Vendor_Number__c = CTSAPVendorNumber.get('Standard').SAP_Vendor_Number__c;
        
        
        claim.Phone_BL__c=BL_phone;
        claim.twod__Account__c=acc.Id;
        claim.customer__c=acc.Id;
        
        /*List<twod__Claim__c> lstClaim=new List<twod__Claim__c>();
        lstClaim=[SELECT Id,name FROM twod__Claim__c WHERE Customer__c =:claim.Customer__c ORDER BY CreatedDate];
        system.debug('nyclaim '+lstClaim.size());
        if(lstClaim.size()>0){
            claim.isDuplicate__c=true;
            for(twod__Claim__c c:lstClaim){
                c.isDuplicate__c=true;                            
            }
            update lstClaim;       
        }
        */
        claim.Quantity__c=Quantity;
        claim.material_quantity__c=Quantity1;
        //claim.Organization__c=Organization;
        //05-Mar-2018 - Changed to store the value in the Organization field of Building address instead of Mailing
        claim.Organization_BL__c=Organization;
        claim.Install_Date__c=installedDate;
        claim.PRODUCT_DETAIL__c=ProductDetail;
        claim.Installation_Location_other__c=InstallationLocationOther;
        claim.Installation_Location__c=InstallationLocation;
        claim.Name_BL__c=name;
        claim.Nature_of_Problem__c=NatureOfProblem;
        claim.RecordTypeId = Schema.SObjectType.twod__claim__c.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
        claim.OwnerId=[select Id from group where Name='Claim Queue' limit 1].Id;
        
        
        //Code only for Roofing
        twod_TerritoryManger ctTM=new twod_TerritoryManger();
        String zipCode;
        if(claim.Postal_Code_BL__c !=null && claim.Postal_Code_BL__c !=''){
          if(claim.Postal_Code_BL__c.contains('-')){
            String[] zip=claim.Postal_Code_BL__c.split('-');
            zipCode=zip[0];
          }
         }        
        List<String> resTM=ctTM.populateTM(claim.State_BL__c,zipCode,claim.Property_Type__c,claim.Country_BL__c); 
        if(resTM!=null && resTM.size()>0){
            Claim.Territory__c=resTM[0];
            Claim.Territory_Manager__c=resTM[1];
        }
        
        //Make Claim as Standard Type
        claim.Warranty_Registration_Type__c='Standard';
        
        //insert claim;                        
        twod_Claimhandler objhandler = new twod_Claimhandler();
        claim.Id = objhandler.createClaim(claim,null,null);
        
        claim=[select First_Name__c,Last_Name__c,City__c,Phone__c,Name_BL__c,Tracking_Number__c,Install_Date__c,Nature_of_Problem__c,Organization__c,Zip_Code_Postal_Code__c,
               Product_Group__c,Quantity__c,Product_Detail__c, twod__Claim_Status__c,Name,createdDate,First_Name_BL__c,Last_Name_BL__c,material_quantity__c,
               Postal_Code__c,Email__c,Address_1__c,Address_2__c,Country__c,State__c,Unit_of_Measure__c ,
               City_BL__c,State_BL__c,Phone_BL__c,Address_1_BL__c,Address_2_BL__c,Postal_Code_BL__c,
               Country_BL__c  from twod__Claim__c where Id=:claim.Id];
        
        system.debug('claim:::' + claim.Id);  
        List<Attachment> toInsert=new List<Attachment>();
        for (Attachment newAtt : newAttachments)
        {
            if (newAtt.Body!=null)
            {
                newAtt.parentId=claim.Id;
                toInsert.add(newAtt);
            }
        }
        insert toInsert;
        newAttachments.clear();
        newAttachments.add(new Attachment());
        PageReference pg1 =new PageReference('/apex/ClaimDetail?type=transfer');
        return pg1;     
    }       
    
    @remoteAction 
    public static twod_CTUtil.validateBuildingLocationAddress verifyBuildingLocation(String address1,String address2,String cityName,String stateName,String zipCode,String country,String email){        
        //valAddress=new twod_CTUtil.validateBuildingLocationAddress();     
        valAddress=twod_CTUtil.addressValidation(address1,address2,cityName,stateName,zipCode,country,email);
        system.debug('valAddress-->' + valAddress);
        return valAddress;
    }
    
    public pageReference ProductGroupChange(){
        CertainTeed_ShortTerm_Period__c mcs = CertainTeed_ShortTerm_Period__c.getvalues(ProductGroup);
        system.debug('ProductGroup::' + mcs);        
        system.debug('ProductGroup::' + ProductGroup);
        UnitsOfMeasure='';
        if(isRoofing){
            UnitsOfMeasure='Number of Squares Affected by Concern';        
        }
        else{
            UnitsOfMeasure='Affected Quantity';        
        }
        if(mcs!=null){
            if(isRoofing){
            UnitsOfMeasure=UnitsOfMeasure;        
            }
            else{
                UnitsOfMeasure=UnitsOfMeasure + ' in ' + mcs.Unit_of_Measure__c;        
            }
        }
        return null;
        
    }
    
    public void addMore()
    {
        // append NUM_ATTACHMENTS_TO_ADD to the new attachments list
        for (Integer idx=0; idx<9; idx++)
        {
            newAttachments.add(new Attachment());
        }
    } 
    
    public PageReference check()
    {
        if(claimId!=null)
        {
            claimId='CR'+claimId;
            claimId=claimId.trim();
        }if(lastName!=null)
            lastName=lastName.trim();
        if(postalcode!=null)
            postalcode=postalcode.trim();
        try{
            claim=[select Id,First_Name__c,Last_Name__c,City__c,Phone__c,Name_BL__c,Tracking_Number__c,Unit_of_Measure__c,
                   Install_Date__c,twod__Claim_Status__c,Product_Group__c,Quantity__c,Product_Detail__c, createdDate,Zip_Code_Postal_Code__c,
                   Postal_Code__c,Email__c,Address_1__c,Address_2__c,Country__c,State__c,Nature_of_Problem__c ,Organization__c,material_quantity__c,
                   City_BL__c,State_BL__c,Phone_BL__c,Address_1_BL__c,Address_2_BL__c,Postal_Code_BL__c,First_Name_BL__c,Last_Name_BL__c,
                   Country_BL__c  from twod__Claim__c where Name =: claimId and Last_Name_BL__c =: lastName and Postal_Code_BL__c like :('%' + postalcode+ '%')];                        
            PageReference pg1 =new PageReference('/apex/ClaimDetail?id='+claim.Id+'&url='+url);
            pg1.setRedirect(true);
            return pg1;
        }
        catch(Exception e)
        {            
            errorMessage1='No match found.Please Check the Entered details';
            return null;
        }
    }
    
    //Method to download the form
    public PageReference downloadTest()
    {        
        downloadURL=null;
        if(claim.Product_Group__c!=null && isSiding){
            formName=[Select Id,Name from ZipFile__c where Name like: '%'+claim.Product_Group__c+'%' LIMIT 1].Name;
        }
        //formName='Vinyl Siding Claim Form.docx';
        //claim.Id='a062800000BEiIZ';
        ClaimNumber=claim.Id;
        try{
            downloadURL=[select Id,DistributionPublicUrl from ContentDistribution where Name=:formName+'.docx' and RelatedRecordId=:ClaimNumber LIMIT 1].DistributionPublicUrl;     
            modalRender=true;
        EnablePoller=true;
            system.debug('downloadURL-->'+downloadURL);
        }
        catch(exception e){
            modalRender=true;
        EnablePoller=true;
            twod_zipperFuture.sendMail(formName,claim.Id);
        }
        /*try{
formId=[select Id,Name from ZipFile__c where name like: formName limit 1].Id; 
}
catch(exception e)
{

}
AttachmentChange a=new AttachmentChange();
system.debug('formId::' + formId);
ClaimNumber=claim.Id;
a.FaultCodeFunc(claim.Id,formId);


Attachment sampleAttachment = [SELECT ParentId,Body,Name FROM Attachment WHERE ParentId=:formId and Name=:formName];
twod_Zippex sampleZip = new Zippex(sampleAttachment.Body);
Attachment sampleAttachmentNew = [SELECT ParentId, Body FROM Attachment WHERE ParentId=:formId and Name='word/documentOri.xml'];
Blob fileData = sampleAttachmentNew.Body;
sampleZip.addFile('word/document.xml',fileData, null);
Blob b=sampleZip.getZipArchive();
Attachment ins=new Attachment();
ins.Body=b;
ins.ParentId=claim.Id;
ins.Name=sampleAttachment.Name;
insert ins; 

PageReference pg=new PageReference('/servlet/servlet.FileDownload?file='+ins.Id);
pg.setRedirect(false);                
return pg;          */
        
        
        return null;
    }
    
    public PageReference download()
    {
        PageReference pg1 =new PageReference('/apex/CTDownload');
        return pg1;    
    }
    
    public void actionPoller()
    {
        system.debug('modalRender outside try'+modalRender);
        try{
            system.debug('formName-->'+formName);
            system.debug('formName'+formName);
            system.debug('ClaimNumber'+ClaimNumber);            
            AttachmentId=[select Id,Name from Attachment where ParentId=:ClaimNumber and name =:formName+'.docx' LIMIT 1].Id;            
            system.debug('modalRender outside 1st'+modalRender);

            if(AttachmentId!=null){
                Attachment att=[Select Id,body from Attachment where Id=:AttachmentId];
                ContentDistribution cd=new ContentDistribution();
                try{
                    ContentDistributionId=[select Id,DistributionPublicUrl from ContentDistribution where Name=:formName+'.docx' and RelatedRecordId=:ClaimNumber LIMIT 1].Id; 
                }
                catch(exception e){
                    if(ContentDistributionId==null){      
                        formName=formName+'.docx';
                        ContentVersion content = new ContentVersion();
                        content.versionData = att.body;
                        content.title = formName;
                        content.pathOnClient = formName;
                        insert content;                                    
                        cd.ContentVersionId=content.Id;
                        cd.PreferencesAllowPDFDownload=true;
                        cd.Name=formName;
                        cd.RelatedRecordId=claim.Id;
                        cd.PreferencesAllowOriginalDownload=false;
                        cd.PreferencesNotifyOnVisit=false;
                        insert cd;
                        ContentDistributionId=cd.Id;                    
                    }
                }
                if(ContentDistributionId!=null){
                    system.debug('ContentDistributionId-->'+ContentDistributionId);
                    cd=[select Id,DistributionPublicUrl from ContentDistribution where Id=:ContentDistributionId];
                    downloadURL=cd.DistributionPublicUrl;
                    ContentDistributionId=null;
                    system.debug('DistributionPublicUrl' + cd.DistributionPublicUrl);
                }
            }
            if(AttachmentId!=null &&  modalRender==true)
            {                
                modalRender=false;
                system.debug('modalRender inside 1st'+modalRender);
                //return null;
            }
            system.debug('modalRender outside 2nd'+modalRender);
            if(AttachmentId!=null)
            {
                modalRender=false;
                EnablePoller=false;
                system.debug('modalRender inside 2nd'+modalRender);
                formList=[Select Id,Name from ZipFile__c where Status__c=true];
                if(!formList.isEmpty())
                    formName=formList[0].Name;
                // PageReference pg=new PageReference('/servlet/servlet.FileDownload?file='+AttachmentId);
                // pg.setRedirect(false);                
                // return pg;
                //return null;
            }
        }
        catch(Exception e){
            modalRender=true;
            //return null;
        }
        //return null;
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