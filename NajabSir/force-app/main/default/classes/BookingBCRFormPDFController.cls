/* 
* @File Name          : BookingBCRFormPDFController.cls
* @Description        : This class generates BCR form as a PDF
* @Author             : 
* @Group              : 
* @Last Modified By   : Prabhat Sharma
* @Last Modified On   : 8/26/2019, 01:05:33 AM
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                    Modification
*==============================================================================
* 1.0     8/26/2019, 01:05:33 AM      Prabhat Sharma             Initial Version
**/

//CODE REVIEW DONE: By Prabhat Sharma

public with sharing class BookingBCRFormPDFController {
    
    //Opporunity record variable
    public Opportunity oppRecord {get;set;}
   
    //Hold the Loyalty Card Lable basis on Nexa and Arena
    public string loyaltyCardLabel {get;set;}
    
    //Hold the Total Accessories Cost Lable basis on Nexa and Arena
    public string totalAccessoriesLabel {get;set;}
    
    //Accessories list variable
    public list<opportunitylineitem> accessoriesitemlist{get;set;} 

    //Price Details
    public Decimal variantTotalPrice{get;set;}
    //Price Details For MC Communication
    public Decimal registrationTotalPrice{get;set;}
    //Total extended warranty price
    public Decimal extendedWarrantyTotalPrice{get;set;}
    //Total MCP price
    public Decimal mcpTotalPrice{get;set;}
    //Total Insurance price 
    public Decimal marutiInsuranceTotalPrice{get;set;}
    //Total Accessories price   
    public Decimal accessoriesTotalPrice {get;set;}
    //Total Loyalty price
    public Decimal loyaltyTotalPrice{get;set;}

    //Total sum of otehr charges
    public Decimal sumofOtherCharges {get;set;}
    //Total sum of discounts
    public Decimal sumOfDiscounts {get;set;}
    //Total sum of schemes
    public Decimal sumOfSchemes {get;set;}
    //Total sum of exchange bonus
    public Decimal sumOfExchangeBonus {get;set;}
    //Total sum of other discounts
    public Decimal sumOfOtherDiscounts {get;set;}
    //Total sum of Road Tax
    public Decimal sumofRoadTax {get;set;}
    //Receipt Details
    public List<List<String>> receiptDetails {get;set;}

    //Terms and Conditions
    public List<Terms_Condition__mdt> termsAndConditionsList {get;set;}
    //Customer Undertaking List
    public List<Terms_Condition__mdt> customerUndertakingList {get;set;}

   
    //Current user Channel
    public String currentUserChannel {get;set;}
   
   
    //Constructor
    public BookingBCRFormPDFController(){
       
        currentUserChannel = [SELECT Id,Channel__c FROM User WHERE Id=:UserInfo.getUserId()].Channel__c;
        
        //initializing variables.
        accessoriesitemlist = new list<opportunitylineitem>();
        oppRecord= new Opportunity();
        //opp = new Opportunity();

        variantTotalPrice = 0;
        registrationTotalPrice = 0;
        extendedWarrantyTotalPrice = 0;
        mcpTotalPrice = 0;
        marutiInsuranceTotalPrice = 0;
        accessoriesTotalPrice = 0;
        loyaltyTotalPrice = 0;
        sumofOtherCharges = 0;
        sumOfDiscounts = 0;
        sumOfSchemes = 0;
        sumOfExchangeBonus = 0;
        sumOfOtherDiscounts = 0;
        sumofRoadTax = 0;
        
        //Get the enquiry ID
        String enquiryId = ApexPages.currentPage().getParameters().get('id');

        //Query all the relevent fields that needs to be displayed 
        List<Opportunity> oppList = new list<Opportunity>([SELECT id,Dealership__c,Dealership__r.Name,Dealership__r.Phone,Dealership__r.Channel__c,Dealership__r.GST_Number__pc,
                                                           First_Name__c, Last_Name__c,Mobile__c,Issue_Date__c, Receipt_Details__c,
                                                           Customer_Type__c,GST_Number__c,Birthdate__c,BillTo_Address_Line__c,BillTo_Address_Line_2__c,
                                                           BillTo_Address_Line_3__c,BillTo_City__r.Name, BillTo_Pincode__r.Name, Email__c,
                                                           BillTo_State__c,BillTo_City_x__c,Bill_To_District_F__c,
                                                           BillTo_Tehsil__r.Name,BillTo_Village__r.Name, Name,PAN__c,ShipTo_Address_Line__c,ShipTo_Address_Line_2__c, ShipTo_Address_Line_3__c, ShipTo_State__c ,
                                                           ShipTo_City_x__c,ShipTo_City__r.Name,Ship_To_District_F__c,ShipTo_Pincode__r.Name,ShipTo_Tehsil__r.Name,
                                                           ShipTo_Village__r.Name,Model_of_Interest__c,Variant__r.Family,Variant__r.Name,Color__r.Name,Booking_Date__c,
                                                           Tentative_Waiting_Period__c,Tentative_Delivery_Date__c,Booking_Amount__c,Final_On_Road_Price__c,
                                                           Exchange_Registration__c,Exchange_Evaluation_Date__c,Finance_Amount__c,EMI_Tenure__c,EMI_Rate__c,
                                                           Dealership__r.BillingStreet, Dealership__r.Billingcity, Dealership__r.BillingPostalCode,
                                                           Dealership__r.BillingState,Dealership__r.BillingCountry,
                                                           DMS_Enquiry_Name__c, Booking_Number__c,Employer_name__r.name,type,Exchange_Model__c,Exchange_Vehicle__r.name,
                                                           Exchange_Offered_Price__c,Exchange_KM__c,EMI_Premium__c,Cash_Payment__c,Owner.Name,Owner.MSPIN__c,
                                                           Owner.Manager.Name,Owner.Manager.MSPIN__c,Owner.Manager.Manager.Name, Owner.Manager.Manager.MSPIN__c,
                                                           Owner.MobilePhone,Owner.email,Owner.Manager.MobilePhone,Owner.Manager.Manager.MobilePhone,
                                                           Owner.Channel__c, SVOC_ID__c,Amount,Owner.Profile.Name, Financier__r.name FROM Opportunity WHERE Id=:enquiryId]);
        

        if(oppList.size()>0)
            oppRecord = oppList[0];
            
        if(oppList.size()>0){
            if(oppRecord.Owner.Channel__c != null && oppRecord.Owner.Channel__c == 'Nexa'){
                loyaltyCardLabel = 'MyNEXA Card';
                totalAccessoriesLabel = 'Genuine NEXA Accessories Cost';
            }
            else if(oppRecord.Owner.Channel__c != null && oppRecord.Owner.Channel__c == 'Arena'){
                loyaltyCardLabel = 'Loyalty Card';
                totalAccessoriesLabel = 'Total Accessories Cost';
            }
        }
        //Query all the line items
        list<opportunitylineitem> opplineitemlist = new list<opportunitylineitem>([Select type__c,TotalPrice,
                                                                                    Product2.Name,ProductCode,Quantity,
                                                                                    UnitPrice from OpportunityLineItem 
                                                                                    WHERE OpportunityId =:enquiryId]);

        
        //Loop through all Opportunity Line Items add the price based on type of Line Items
        for(opportunitylineitem oli : opplineitemlist){
            //For Line item of type Variant
            if(oli.Type__c == ConstantsUtility.VARIANT_CONST)
                variantTotalPrice += oli.TotalPrice;
            //For Line item of type Registration cost
            if(oli.Type__c == ConstantsUtility.REGISTRATION_CONST)
                registrationTotalPrice += oli.TotalPrice;
            //For Line item of type Extended Warranty Cost
            if(oli.Type__c == ConstantsUtility.EX_WARRANTY_CONST)
                extendedWarrantyTotalPrice  += oli.TotalPrice;
            //For Line item of type MCP 
            if(oli.Type__c == ConstantsUtility.MCP_CONST)
                mcpTotalPrice  += oli.TotalPrice;
            //For Line item of type Insurance 
            if(oli.Type__c == ConstantsUtility.INSURANCE_CONST)
                MarutiInsuranceTotalPrice  += oli.TotalPrice;
            //For Line item of type Accessories
            if(oli.Type__c == ConstantsUtility.ACCESSORIES_CONST){
                accessoriesTotalPrice  += oli.TotalPrice;
                accessoriesitemlist.add(oli);
            }
            //For Line item of type Loyalty
            if(oli.Type__c == ConstantsUtility.LOYALTY_CONST)
                LoyaltyTotalPrice  += oli.TotalPrice;
            //For Line item of type Municipal Charges
            if(oli.Type__c == ConstantsUtility.MUNICIPAL_CH_CONST || 
                oli.Type__c == ConstantsUtility.NUM_PLATE_CONST)
                sumofOtherCharges  += oli.TotalPrice;
            //For Line item of type Offer
            if(oli.Product2.Name == ConstantsUtility.OFFER_CONST)
                sumOfDiscounts  += oli.TotalPrice;
            //For Line item of type Schemes
            if(oli.Type__c == ConstantsUtility.SCHEMES_CONST)
                sumOfSchemes  += oli.TotalPrice;
            //For Line item of type Exchange Bonus
            if(oli.Product2.Name  == ConstantsUtility.EXCH_BONUS_CONST)
                sumOfExchangeBonus  += oli.TotalPrice;
            //For Line item of type Other Discount
            if(oli.Product2.Name  == ConstantsUtility.OTH_DISC_CONST)
                sumOfOtherDiscounts  += oli.TotalPrice;
            //For Line item of type Road tax
            if(oli.Product2.Name  == ConstantsUtility.ROAD_TAX_CONST)
                sumofRoadTax  += oli.TotalPrice;
            
        }
        //Terms and Condition functionality
        termsAndConditionsDetails();
        
        // Fetch Receipt Details
        // Added By-: Nishant   Date-: 11/11/2019
        if(String.isNotBlank(oppRecord.Receipt_Details__c)){
            string dataList= oppRecord.Receipt_Details__c.stripHtmlTags();
            receiptDetails= new List<List<String>>();
            List<String> records= dataList.split('#');
            if(records.size() > 0){
                for(String row : records){
                    List<String> record= row.split('\\|');
                    receiptDetails.add(record);
                }
                
            }
        }
    }
    
    
    /**
        Author: Prabhat Sharma
        Company: Techmatrix
        Description: This method will fetch terms and condition details. 
        Inputs: none
        Returns: void
        History:
        ================
        1.0     28 Aug 2019      Prabhat     Initial Version
    **/

    public void termsAndConditionsDetails(){

        //List for terms and conditions
        termsAndConditionsList = new list<Terms_Condition__mdt>();
        //List for customer undertaking
        customerUndertakingList = new list<Terms_Condition__mdt>();

        //loop through the metadata and sepearate a list of Customer Undertaking and Terms & Consitions
        for(Terms_Condition__mdt terms : [SELECT MasterLabel,Display_Text__c,Detail_Type__c,Sort_Order__c  
                                            FROM Terms_Condition__mdt order by Sort_Order__c  asc]){
            
            if(terms.Detail_Type__c==ConstantsUtility.TERMS_N_CONDITIONS)
                termsAndConditionsList.add(terms);
            else
                customerUndertakingList.add(terms);

        }
    }
 
     
    
    /**
        Author: Prabhat Sharma
        Company: Techmatrix
        Description: This method will create PDF for BCR form and save it as a PDF under the record. 
        Inputs: Enquiry record ID
        Returns: void
        History:
        ================
        1.0     28 Aug 2019      Prabhat     Initial Version
    **/
    @AuraEnabled
    public static void downloadBCRDocument(String recordId,
                                            String btnLabels, String pageName, 
                                            String fileName, String fieldName, String networkid){
                                                
                                                
        try{ 
            String mcType = ConstantsUtility.BCR_CONST;
            //Delete previously generated delivery checklist pdf                                        
            if(pageName.contains(ConstantsUtility.DELIVERY_CONST)){
                mcType = fileName;
                set<Id> tempSet = new set<Id>();
                
                List<ContentDocumentLink> cdocLink = new list<ContentDocumentLink>([SELECT Id,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:recordId]);
                
                for(ContentDocumentLink doc : cdocLink){
                    tempSet.add(doc.ContentDocumentId);
                }
                
                if(tempSet.size()>0){
                    List<ContentVersion> conversionList = new list<ContentVersion>([SELECT id,title,ContentDocumentId FROM ContentVersion WHERE 
                                                                                    ContentDocumentId in:tempSet and title like:'Delivery%']);
                    if(conversionList.size()>0){
                        List<ContentDocumentLink> cdocLinks = new list<ContentDocumentLink>([SELECT Id FROM ContentDocumentLink WHERE 
                                                                                             ContentDocumentId=:conversionList[0].ContentDocumentId and LinkedEntityId=:recordId]);
                        
                        if(cdocLinks.size()>0)
                            delete cdocLinks;
                    } 
                }
            } 
            
            
            //Blob to store the body of the PDF
            Blob body;
            
            //Create page reference for BCR VF Page
            PageReference pdf = new PageReference('/apex/'+pageName+'?id='+recordId);
            
            //Exclude test class API callout error with this condition
            if(!test.isRunningTest()){
                body = pdf.getContentAsPDF();
            }else{
                body = blob.valueof('TEST');
            }      
            
            //Encode the Blob Body
            String base64Encoded = EncodingUtil.base64Encode(body); 
            
            //Creating Salesforce File
            ContentVersion content = new ContentVersion();
            content.title = fileName+'_'+String.valueOf(DateTime.Now());  //File Name
            content.VersionData = EncodingUtil.base64Decode(base64Encoded);  //File body
            content.PathOnclient = fileName+'.pdf';  //File extension   
            content.networkId = String.isNotBlank(networkId) ? networkId : Network.getNetworkId();
            insert content;
            
            //Content document for linking the file to parent entity
            ContentDocumentLink docLink = new ContentDocumentLink();
            //Fetch ContentdocumentId from Content Version 
            docLink.ContentDocumentId = [select Id,ContentDocumentId from ContentVersion WHERE Id =:content.Id].ContentDocumentId;
            docLink.LinkedEntityId = recordId; //Id of the parent record
            docLink.ShareType = 'I'; //Inferred Permission. Determined by the user's access to parent record.
            insert docLink;
            
            //Get the public URL
            String publicPDF = GenerateFilePublicURL.CreateAttachmentPublicLink(content.Id);
            
            //Create a marketing communication record
            List<MC_Communication__c> mcRecords=GenerateFilePublicURL.CreateMCRecord(mcType,new set<Id>{recordId},ConstantsUtility.Opportunity, publicPDF);
            
            //Update send BCR time if Save and Send is clicked
            if(btnLabels == ConstantsUtility.BTN_LABEL_CONST){
                Opportunity oppToUpdate = new Opportunity();
                oppToUpdate.Id = recordId;
                //Update DateTime or BCR Flags
                if(pageName.contains(ConstantsUtility.DELIVERY_CONST)){
                    oppToUpdate.put(fieldName,DateTime.now());
                }else{
                    oppToUpdate.put(fieldName,ConstantsUtility.BCR_SENT);   
                }
                System.debug(oppToUpdate);
                System.debug(oppToUpdate.Send_BCR_Time__c);
                //Update the details on Opportunity
                update oppToUpdate; 
            }
            
            //ADDED BY SUNIT - INTERIM EMAIL SOLUTION
            List<GlobalSwitchOn__c > gs = GlobalSwitchOn__c.getall().values();
            if(gs[0].Send_Email__c==true){
                SendEmailwithAttachment sewa=new SendEmailwithAttachment();
                sewa.sendMail('', mcRecords[0].id, 'BCR', mcRecords[0].General_Field_1__c,docLink.ContentDocumentId ,mcRecords[0].Email_2__c );
            }
            
        }catch(Exception ex){
            ExceptionHandler.LogError('BCR Save/Save and Send', 
                                       ex.getMessage(),
                                       'Opportunity', 
                                       recordId, null);
        }
    }
    
    /**
        Author: Prabhat Sharma
        Company: Techmatrix
        Description: This method update the Send BCR Time with current date time
        Inputs: Enquiry record ID
        Returns: void 
        History:
        ================
        1.0     06 Nov 2019      Prabhat     Initial Version
    **/
    @AuraEnabled
    public static String updateSendBCRTimeonOpp(String recordId){
        try{
            Opportunity opp = new Opportunity();
            opp.Id = recordId;
            opp.Send_BCR_Time__c = DateTime.now();
              
            update opp; 
            
            return 'Success: Request to generate BCR has been sent successfully!';
        }
        catch(Exception ex){ExceptionHandler.LogError('Update Send BCR Time',  ex.getMessage(), 'Opportunity',  recordId, null);return 'Error: '+ex.getMessage();
        }
    }
}