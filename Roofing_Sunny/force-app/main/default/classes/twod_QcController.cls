public class twod_QcController {
    
    public twod__claim__c objClaim{get; set;}
    public String productName{get; set;}
    public String productColour{get; set;}
    public DynaControl[] dynaControls{ get; set; }
    public List<SelectOption> defectCodeOptions {get; set;}
    public twod__Warranty_Code__c warrantyCode{get; set;}
    public Sampling_QC__c sampling{get; set;}
    public twod__claim__c claim{get; set;}
    public QC__c qc{get; set;}
    public Boolean isClassAction{get;set;}
    
    public String sampqcid {get;set;}
    public String defectCode {get;set;}
    public String primaryDescription {get;set;}
    public String secondaryDescription {get;set;}
    public String plantDescription {get;set;}
    
    public Boolean isDisabled {get;set;}
    public Boolean isDisabledFull {get;set;}
    //Tape code
    public String tapeA {get;set;}
    public String tapeB {get;set;}
    public String tapeC {get;set;}
    public String tapeD {get;set;}
    public String claimType {get;set;}
    public String ThemeCategory{get;set;}
    public twod_QcController(ApexPages.StandardController controller)
    {
        String claimId=apexpages.currentpage().getparameters().get('claim');  
        ThemeCategory=UserInfo.getUiTheme();
        if(claimId==null){            
            qc=(qc__c)controller.getRecord();            
            qc=[select Id,Name,Claim__c,Date_of_Installation__c,Date_of_Transfer__c,Defect_Details__c,Material__c,Ownership_Type__c,Plant__c,Plant__r.Name,isClassAction__c,Status_of_third_party_appeal__c,
                Lab_Comments__c,Lab_Status__c,Photo_Comments__c,Active__c,Product_Group__c,Tape_Code_A__c,Tape_Code_B__c,Tape_Code_C__c,Tape_Code_D__c,Quantity__c,material_quantity__c,Primary_Defect_Code__c,Secondary_Defect_Code__c,Other_Reason__c,Reject_Reason__c,Class_Action_Form_Received__c from qc__c where Id=:qc.Id];
            system.debug('Value of Material 2 ********************* ' + qc.Material__c);
            if(qc.Material__c!=null){
                twod__Warranty_Product__c product=[select Id,twod__Product_Name__c,Product_Colour__c from twod__Warranty_Product__c where Id=: qc.Material__c];
                productName=product.twod__Product_Name__c;
                productColour=product.Product_Colour__c;
            }
            claimId=qc.Claim__c;
            isClassAction = qc.isClassAction__c;
            system.debug('Value of isClassAction 2 ' + isClassAction);
            plantDescription=qc.Plant__r.Name;
            tapeA=qc.Tape_Code_A__c;
            tapeB=qc.Tape_Code_B__c;
            tapeC=qc.Tape_Code_C__c;
            tapeD=qc.Tape_Code_D__c;            
        }else{            
            qc=new qc__c();
        }
        objClaim= objClaim = [Select Product_Name1__c,approver__c,isLocked__c,Product_Colour_To_Be_Shipped__c,Product_Colour__c,Primary_Defect_Code__r.twod__Description__c,Affected_Walls_Other__c,Ship_To_Party__c,Ship_To_Party__r.name,Sold_To_Party__c,Sold_To_Party__r.name,Defect_Details__c,Plant__c,Plant__r.Plant_code__c,Cost_Material_Comment__c,Resolution_Code__c,
                              Product_to_be_Shipped__c,twod__Warranty_Product__r.Product_Colour__c ,twod__Warranty_Product__r.twod__Product_Name__c, Warranty_Status__c,isClassAction__c,
                              Status_of_third_party_appeal__c,Customer__c,Extended_Warranty_Registration_Number__c,First_Name_BL__c,Last_Name_BL__c,Insurance_Claimed_Date__c,
                              Insurance_claimed_Amount__c,Organization__c,Hail_Speed__c,Transferred_Date__c,Home_Insurance_applicable__c,RecordType.DeveloperName,
                              Ship_w_PO_No__c, Account__c,Address_1_BL__c,Address_1__c,Address_2_BL__c,Address_2__c,Affected_Walls__c,
                              Alert_for_Inspection__c,Applicant_Type__c,Authed_Material__c,BPCS_Ship_To__c,Building_Type__c,Business_Name_if_applicable__c,Cash_settlement_Figure__c,
                              category_of_product__c,CertainTeed_s_EX_No__c,Check_Address__c,Check_Amount__c,Check_City__c,Check_Payable_to__c,Check_State__c,Check_Zip_Code__c,
                              City_BL__c,City__c,Claim_File_Number__c,Claim_Incident__c,colour_of_Products_to_be_Shipped__c,Colour__c,Comments__c,Complaint_Code__c,
                              Contact_Email__c,Contact_Name_s__c,Contact_Name__c,Contact_Phone__c,Country_BL__c,Country__c,CreatedById,CreatedDate,
                              Credit_Date_of_Request__c,Credit_Order_For__c,Credit_Ship_To__c,CT_Notified__c,Custom_State__c,Date_Applied__c,
                              Date_Investigated__c,Date_Issued__c,Date_of_Request__c,Date_Reported__c,Delivery_Fee__c,Distributor_Ref__c,Distributor_Sold_to_Ship_To__c,
                              Distributor_s_PO__c,Does_Require_Inspection__c,Email__c,First_Name__c,Id,Inspection_Comments__c,Inspection_Details__c,Inspection__c,
                              Installation_Location_other__c,Installation_Location__c,Install_Date__c,Invoice_Number__c,Invoice_price__c,IsDeleted,Issued_to__c,
                              Issue_as_stated_on_letter__c,Labor_Payment__c,Labor_Rate__c,Labor_Reinstall_Squares__c,
                              Labor_Tear_off_Squares__c,LastActivityDate,LastModifiedById,LastModifiedDate,LastReferencedDate,
                              LastViewedDate,Last_Name__c,material_quantity__c,Material_Vocher_Date_of_Request__c,
                              Material_Voucher_Claim_Incident__c,Material__c,Misc1_cost_description__c,Misc2_cost_description__c,Misc3_cost_description__c,
                              Misc4_cost_description__c,Misc5_cost_description__c,Name,Name_BL__c,Nature_of_Problem__c,Notes__c,Number_of_sqs_Affected__c,Order_for__c,
                              Original_Product_Code__c,Original_Roofing_Contractor__c,OwnerId,OwnershipType__c,Owner__c,Payment_Total__c,Payment_to__c,Phone_BL__c,Phone__c,
                              Photos_Attachment__c,Plant_Code__c,Postal_Code_BL__c,Postal_Code__c,Prepared_by__c,Primary_Defect_Code__c,Primary_Defect_Code__r.Name,Problem__c,
                              Producing_Plant__c,Products_to_be_Shipped_Quantity__c,Product_Detail__c,Product_Group__c,Product_Name__c,Property_Name__c,Property_Type__c,Quantity__c,
                              Reason_for_claim__c,RecordTypeId,Replacement_Product_Code__c,Resolution__c,Roof_System_Application_Date__c,Salutation__c,Sampling_Details__c,
                              Sampling_Status__c,Sampling__c,Secondary_Defect_Code__c,Secondary_Defect_Code__r.Name,Send_Letter_to__c,Service_Fee__c,Settlement_Figure_Written__c,
                              Shipped_For__c,Shipping_Method__c,Shipping_Options__c,Shipping_Product__c,Ship_to__c,ShortTerm_Note__c,Squares_Applied__c,Squares_In_Whse__c,
                              Squares_Not_Applied__c,State_BL__c,State__c,Street_address__c,SystemModstamp,Tape_Code_A__c,Tape_Code_B__c,Tape_Code_C__c,TerritoryNumber__c,
                              Territory_Number__c,Total_Payment__c,Total_Squares__c,Tracking_Number__c,twod__Account__c,twod__Applicable_Cost_Categories__c,
                              twod__Applicable_Payment_Configurations__c,twod__Applicable_Payment_Definition__c,twod__Applicable_Policy__c,twod__Approved_Category1_Cost__c,
                              twod__Approved_Category2_Cost__c,twod__Approved_Category3_Cost__c,twod__Approved_Category4_Cost__c,twod__Approved_Category5_Cost__c,
                              twod__Approved_Category6_Cost__c,twod__Approved_Category7_Cost__c,twod__Approved_Category8_Cost__c,twod__Approved_Category9_Cost__c,
                              twod__Approved_Category10_Cost__c,twod__Approved_Claim_Cost__c,twod__Approved_Ignore_Sum__c,twod__Approved_Labor_Cost__c,twod__Approved_Meals_Cost__c,
                              twod__Approved_Parking_Cost__c,twod__Approved_Parts_Cost__c,twod__Approved_TravelByDistance_Cost__c,twod__Approved_TravelByHours_Cost__c,
                              twod__Campaign_Members__c,twod__CasualPart_Comments__c,twod__Causal_Part_Number__c,twod__Caused_by__c,twod__Claim_Age__c,twod__Claim_Cycle__c,
                              twod__Claim_Parts_Pending_Approval__c,twod__Claim_Status__c,twod__Claim_Submission_Time__c,twod__Claim_Type__c,twod__Date_Of_Purchase__c,
                              twod__Date_of_Repair__c,twod__Delay_Reason__c,twod__Description__c,twod__Fault_Code_Comment__c,twod__Fault_Code__c,twod__Fault_found__c,
                              twod__Field_Modification_Edited__c,twod__Final_Category1_Cost__c,twod__Final_Category2_Cost__c,twod__Final_Category3_Cost__c,
                              twod__Final_Category4_Cost__c,twod__Final_Category5_Cost__c,twod__Final_Category6_Cost__c,twod__Final_Category7_Cost__c,twod__Final_Category8_Cost__c,
                              twod__Final_Category9_Cost__c,twod__Final_Category10_Cost__c,twod__Final_Claim_Cost__c,twod__Final_Labor_Cost__c,twod__Final_Meals_Cost__c,
                              twod__Final_Parking_Cost__c,twod__Final_Parts_Cost__c,twod__Final_TravelByDistance_Cost__c,twod__Final_TravelByHours_Cost__c,twod__Host_NonHost__c,
                              twod__Inventory__c,twod__Invoice_Number__c,twod__In_Approval_Process__c,twod__Labor__c,twod__Override_Policy__c,twod__Percent_Category1_Cost__c,
                              twod__Percent_Category2_Cost__c,twod__Percent_Category3_Cost__c,twod__Percent_Category4_Cost__c,twod__Percent_Category5_Cost__c,
                              twod__Percent_Category6_Cost__c,twod__Percent_Category7_Cost__c,twod__Percent_Category8_Cost__c,twod__Percent_Category9_Cost__c,
                              twod__Percent_Category10_Cost__c,twod__Percent_Claim_Cost__c,twod__Percent_Labor_Cost__c,twod__Percent_Meals_Cost__c,twod__Percent_Parking_Cost__c,
                              twod__Percent_Parts_Cost__c,twod__Percent_TravelByDistance_Cost__c,twod__Percent_TravelByHours_Cost__c,twod__Processor__c,twod__Rate__c,
                              twod__Request_SMR__c,twod__Serial_Number__c,twod__Service_Campaign_Name__c,twod__Service_Ticket__c,twod__SMR_Reason__c,twod__Submit_Date__c,
                              twod__Total_Category1_Cost__c,twod__Total_Category2_Cost__c,twod__Total_Category3_Cost__c,twod__Total_Category4_Cost__c,twod__Total_Category5_Cost__c,
                              twod__Total_Category6_Cost__c,twod__Total_Category7_Cost__c,twod__Total_Category8_Cost__c,twod__Total_Category9_Cost__c,twod__Total_Category10_Cost__c,
                              twod__Total_Labor_Cost__c,twod__Total_Meals_Cost__c,twod__Total_Parking_Cost__c,twod__Total_Parts_Cost__c,twod__Total_TravelByDistance_Cost__c,
                              twod__Total_TravelByHours_Cost__c,twod__TravelByDistance__c,twod__TravelByHours__c,twod__TravelByLocation__c,twod__Tr_Fault_Code_Comment__c,
                              twod__Tr_Probable_Cause__c,twod__Tr_Work_Performed_Comments__c,twod__Units_Run__c,twod__Warranty_Product__c,twod__Warranty_Product__r.Name,
                              twod__Work_order__c,twod__work_Performed_comments__c,Type_of_Applicator__c,Type__c,Unit__c,Vendor__c,Voucher1_Issued_Date__c,
                              Voucher1_Issued_To__c,Voucher1_No__c,Voucher2_Issued_Date__c,Voucher2_Issued_To__c,Voucher2_No__c,Wind_Speed__c,Organization_BL__c,
                              Zip_Code_Postal_Code__c,Check_State1__c,Material_Comment__c,Is_New_Construction__c,Debit_Amount__c,Debit_Ship_To__c,Debit_Order_For__c,Territory__c,
                              Check_Country__c,Voucher1_Amount__c,Voucher2_Amount__c,Credit_Amount__c,Tape_Code_D__c,
                              Check_Zip_Code_Postal_Code__c,Product_Color__c FROM twod__Claim__c  where id=:claimId];
        
        
        
        
        //productName=objClaim.Product_Name1__c;
        //productColour=objClaim.Product_Color__c;      
        claimType=string.valueof(objClaim.twod__Claim_Type__c);
        system.debug('claimType--'+claimType);
        if(claimType!='Short_Term' && qc.Id==null){  
            qc.Product_Group__c='Residential Roofing';
            if(objClaim.Property_Type__c =='Commercial' && qc.Product_Group__c==null){
                qc.Product_Group__c='Commercial Roofing';
            }
        }
        
        objClaim.RecordTypeId = [select Id from RecordType where sobjecttype='twod__claim__c' and DeveloperName =:claimType Limit 1].Id;
        
        setupDefectTypeOptions();
        
        if(objClaim.twod__Claim_Status__c=='Pre Claim' || objClaim.twod__Claim_Status__c=='Need more Information'){
            isDisabled=false;
            isDisabledFull=false;
        }else if(objClaim.twod__Claim_Status__c=='Claim'){
            isDisabled=true;
            isDisabledFull=false;
        }else{
            isDisabled=true;
            isDisabledFull=true;
        }
        
    }
    
    public void warrantyProductChange()
    {
        productName='';
        productColour='';
        system.debug(qc.Material__c);
        if(qc.Material__c!=null){
            twod__warranty_product__c product=[select twod__Product_Name__c,Product_Colour__c from twod__warranty_product__c where Id=:qc.Material__c];
            productName=product.twod__Product_Name__c;
            productColour=product.Product_Colour__c;
        }
    }
    
    /**
* @MethodName : setupDefectTypeOptions
* @Param      : NA
* @Description: Method to initialize the default values.
*/
    private void setupDefectTypeOptions(){
        String seldefCode = apexpages.currentpage().getparameters().get('defect_code');
        sampqcid = apexpages.currentpage().getparameters().get('samp_qc');
        
        //get picklist values
        /* claimCodeList = [Select Id, Defect_Code__c, Description__c From Claim_Code__c];
defectCodeOptions = new List<SelectOption>();
defectCodeOptions.add(new SelectOption('','--None--'));
SelectOption so = null;
for(Claim_Code__c cc:claimCodeList){
so = new SelectOption(cc.Id,cc.Defect_Code__c);
defectCodeOptions.add(so);
if(seldefCode != null && seldefCode != '') {
if(cc.Id == seldefCode){
defectCode = so.getValue();
}
}
}*/
        if(qc.Primary_Defect_Code__c != null) {
            loadDynamicControls();
        }else{
            dynaControls=new DynaControl[]{};}
        //dynaControls=new DynaControl[]{};
        loadDescription();
    }
    /**
* @MethodName : loadDynamicControls
* @Param      : NA
* @Description: Method to create DynaControl object with values.
*/
    
    public PageReference loadDescription(){
        secondaryDescription='';
        if(qc.Secondary_Defect_Code__c!=null)
            secondaryDescription=[select Id,twod__description__c from twod__warranty_code__c where Id =:qc.Secondary_Defect_Code__c Limit 1].twod__description__c;
        return null;
    }
    
    public PageReference loadPlantDescription(){
        plantDescription='';
        if(qc.Plant__c!=null)
            plantDescription=[select Id,Name from Plants__c where Id =:qc.Plant__c Limit 1].Name;
        return null;
    }
    
    
    public PageReference loadDynamicControls(){
        dynaControls=new DynaControl[]{};
            DynaControl dynaControl=null;
        primaryDescription='';
        if(qc.Primary_Defect_Code__c!=null)
            primaryDescription=[select Id,twod__description__c from twod__warranty_code__c where Id =:qc.Primary_Defect_Code__c Limit 1].twod__description__c;
        List<Defect_Detail__c> defectdtllist = [Select Id, Claim__c, Claim_Question__c, Value__c From Defect_Detail__c Where QC__c = :qc.Id];
        system.debug('qc.Warranty_Code__c--->' + qc.Primary_Defect_Code__c);
        for(Claim_Question__c cqs:[select Id, Name,Control_Type__c,Options__c,Order__c, Help_Text__c,Required__c from Claim_Question__c Where Warranty_Code__c = :qc.Primary_Defect_Code__c]){
            system.debug('Claim_Question__c-->>' + cqs);
            dynaControl=new DynaControl();
            dynaControl.cq = cqs;
            dynaControl.controlLabel=cqs.Name;
            dynaControl.controlType=cqs.Control_Type__c;
            dynaControl.controlOrder=Integer.valueOf(cqs.Order__c);
            dynaControl.helpText = cqs.Help_Text__c;
            dynaControl.required=cqs.Required__c;
            dynaControl.styleClass='00&00';
            dynaControl.size=4;
            if(cqs.Options__c!=null){
                dynaControl.controlOptions=new SelectOption[]{};
                    String[] options=cqs.Options__c.split(',');
                if(options.size()>1){
                    for(String option:options){
                        dynaControl.controlOptions.add(new SelectOption(option,option));
                    }
                }else{
                    dynaControl.inputTextLabel = cqs.Options__c;
                }
            }
            if(defectdtllist.size()>0){
                for(Defect_Detail__c ddlc:defectdtllist){
                    if(ddlc.Claim_Question__c == cqs.Id){
                        dynaControl.controlVal = ddlc.Value__c;
                    }
                }
            }
            dynaControls.add(dynaControl);
            dynaControls.sort();
        }
        return null;
    }
    /**
* @MethodName : saveDynamicControls
* @Param      : NA
* @Description: Method to save DynaControl object with values.
*/
    public PageReference saveDynamicControls() {
        //List<Sampling_QC__c> sampqclist = [Select Id, Defect_Code__c From Sampling_QC__c Where Id = :sampqcid];
        //for(Sampling_QC__c sqc:sampqclist){
        //    sqc.Defect_Code__c = defectCode;
        //}
        //twod__claim__c cl=new twod__claim__c(Id=sampling.claim__c);
        //objClaim.Primary_Defect_Code__c=sampling.Warranty_Code__c;
        tapeA=tapeA.replace('&#160;',' ');
        tapeB=tapeB.replace('&#160;',' ');
        tapeC=tapeC.replace('&#160;',' ');
        tapeD=tapeD.replace('&#160;',' ');
        qc.Tape_Code_A__c=tapeA;
        qc.Tape_Code_B__c=tapeB;
        qc.Tape_Code_C__c=tapeC;
        qc.Tape_Code_D__c=tapeD;
        //sampling.TapeA__c=tapeA;
        //sampling.TapeB__c=tapeB;
        //sampling.TapeC__c=tapeC;
        //update(sampling);
        List<Defect_Detail__c> defectdtllist = [Select Id, Claim__c, Claim_Question__c From Defect_Detail__c Where QC__c = :qc.Id];
        Delete defectdtllist;
        
        List<Defect_Detail__c> defectlist = new List<Defect_Detail__c>();
        Defect_Detail__c defectdetail = null;
        qc.Claim__c=objClaim.Id;
        qc.isClassAction__c = isClassAction;
        if([select Id,Name from twod__warranty_code__c where Id =:qc.Primary_Defect_Code__c].Name=='PREM'){
            system.debug('Primary_Defect_Code__r--> PREM');            
            qc.isClassAction__c=true;
        }else{            
            qc.isClassAction__c=false;
        }
        system.debug('Value of isClassAction 1 ' + isClassAction);
        upsert qc;
        for(DynaControl dc:dynaControls){
            system.debug('val-->' + dc.controlVal);
            system.debug('required-->' + dc.required);
            if( (dc.controlVal==null || dc.controlVal=='') && dc.required==true)
            {
                system.debug('Error');
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Please enter value for '+dc.controlLabel));
                return null;
            }
            if(dc.controlVal!=null){
                defectdetail = new Defect_Detail__c();
                defectdetail.name=dc.cq.Name;
                defectdetail.QC__c = qc.Id;
                defectdetail.Claim_Question__c = dc.cq.Id;
                defectdetail.Value__c = dc.controlVal;                
                if(dc.cq.Name=='Wind Speed')
                {
                    if([select Id,Name from twod__warranty_code__c where Id =:qc.Primary_Defect_Code__c].Name=='SEAL')
                        if(dc.controlVal!='')
                        objClaim.Wind_Speed__c=Decimal.valueof(dc.controlVal);
                }
                defectlist.add(defectdetail);
            }
        }
        system.debug(defectlist);
        
        upsert(defectlist);
        update(objClaim);
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.DescribeSObjectResult r =  gd.get('twod__claim__c').getDescribe();
        String tempName = r.getName();
        String tempPrefix = r.getKeyPrefix();
        
        Integer count=[Select count() from QC__c where Claim__c=:objClaim.Id];
        system.debug('count-->'+count);        
        if(count==1 || qc.Active__c){
            twod_updateQCStatus.statusChange(qc.Id);
        }
        Pagereference pageRef;
        
        if(qc.Id !=null){
            pageRef=new Pagereference('/'+qc.Id);
        }
        else{
            pageRef=new Pagereference('/'+tempPrefix + '/o');
        }
        return pageRef;
    }
    
    public Pagereference cancel(){
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.DescribeSObjectResult r =  gd.get('twod__claim__c').getDescribe();
        String tempName = r.getName();
        String tempPrefix = r.getKeyPrefix();
        Pagereference pageRef;
        if(qc.Id !=null){
            pageRef=new Pagereference('/'+qc.Id);
        }
        else{
            pageRef=new Pagereference('/'+objClaim.Id);
        }
        return pageRef;
    }
    /**
* @ClassName  : DynaControl
* @Description: This inner class is used to dynamically generate the components.
*/
    public class DynaControl implements Comparable{
        public Claim_Question__c cq {get;set;}
        public Sampling_QC__c sq {get;set;}
        public String controlType{ get; set; }
        public String controlLabel{ get; set; }
        public String inputTextLabel{ get; set; }
        public String helpText{ get; set; }
        public SelectOption[] controlOptions{ get; set; }
        public String controlVal {get; set; }
        public Integer controlOrder {get; set; }
        public Integer size {get; set; }
        public String styleClass {get; set; }
        public Boolean required {get; set; }
        //Comparator objects
        public Integer compareTo(Object ObjToCompare) {
            DynaControl dc = (DynaControl)(ObjToCompare);
            if(this.controlOrder>dc.controlOrder){
                return 1;
            }
            if(this.controlOrder==dc.controlOrder){
                return 0;
            }
            return -1;
        }
    }
}