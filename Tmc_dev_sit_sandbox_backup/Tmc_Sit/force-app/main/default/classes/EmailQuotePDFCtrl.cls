/**
 * @File Name          : EmailQuotePDFCtrl.cls
 * @Description        : This class is used to Create quote PDF.
 * @Author             : Anuj Kumar
 * @Group              :
 * @Last Modified By   : Rajesh Ramachandran
 * @Last Modified On   : 1/12/2020, 7:18:58 AM
 * @Modification Log   :
 *==============================================================================
 * Ver         Date                     Author                Modification
 *==============================================================================
 * 1.0    25/08/2019 11:17 AM          Anuj Kumar            Initial Version
 * 1.1    27/09/2019 11:17 AM          Prabhat Sharma        Added Public URL generation logic for MC
**/

public with sharing class EmailQuotePDFCtrl {



    Public static string opportunityId;

    /*
        @Author:                  Prabhat Sharma
        @Created Date :           20/11/2019
        @Discription:             To Retrive map of picklist ApI name and label for model code picklist
        @Date Of Modification :   20/11/2019
    */
    public static map<String,String> modelCodeLabelMap(){

        map<String,String> modelMap = new map<String,String>();

        Schema.DescribeFieldResult fieldResult = Opportunity.Model_Code__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            modelMap.put(pickListVal.getValue(),pickListVal.getLabel());
        }

        return modelMap;
    }

    /*
        @Author:                  Anuj Kumar
        @Created Date :           27/08/2019
        @Discription:             To Retrive QuoteTemplate from Custom Setting.
        @Date Of Modification :   27/08/2019
    */
    @AuraEnabled
    public static String retriveQuoteTemplateInfo(String recordId){
        String templateId;
        Boolean isPortalUser;


        List<Quote> quoteList;
        if(isQuoteAccessPermission()){
            quoteList = new List<Quote> (
                [Select Id, opportunityId, opportunity.Line_Of_Business__c FROM Quote WHERE Id =: recordId AND opportunityId != Null]
            );
            if(quoteList != Null && quoteList.size() > 0){
                opportunityId = quoteList[0].opportunityId;
            }
        }else{
            return 'Insufficient Privileges error';
        }

        List<User> userData = new List<User>();


        if(CheckObjectAndField.isAccessible('User') && CheckObjectAndField.isFieldAccessible('User', 'Name') && CheckObjectAndField.isFieldAccessible('User', 'Title') && CheckObjectAndField.isFieldAccessible('User', 'contactId')){
            userData = [Select id, Name , Title, IsPortalEnabled from User where Id =:UserInfo.getUserId() Limit 1];
        }
        if(userData != null && userData.size() > 0){
            isPortalUser = userData[0].IsPortalEnabled;
        }

        //Generate Quote
        if(quoteList != null && quoteList.size() > 0 && quoteList[0].opportunityId != null && quoteList[0].opportunity.Line_Of_Business__c != Null ){

            if(isPortalUser){
                // FOR PORTAL USER ONLY
                insertQuoteTemplate(recordId, quoteList[0].opportunity.Line_Of_Business__c);
            }else{
                // FOR INTERNAL USER ONLY
                generateQuoteTemplate(recordId, quoteList[0].opportunity.Line_Of_Business__c);
            }

            Quote_Template_Infos__c quoteTemplate = Quote_Template_Infos__c.getOrgDefaults();

            //Check line of business
            templateId = quoteList[0].opportunity.Line_Of_Business__c ==ConstantsUtility.NEXA_LINEOFBUSINESS ? quoteTemplate.Quote_Nexa__c : quoteTemplate.Quote_Arena__c;

        }

        return templateId;
    }

    /*
        @Author:                  Anuj Kumar
        @Created Date :           25/08/2019
        @Discription:             Generate quote PDF Method for Internal User Only.
        @Date Of Modification :   25/08/2019
    */
    @future(callout=true)
    public static void generateQuoteTemplate(String recordId, String lineOfBusiness) {
        //Get template IDs from Custom setting
        Quote_Template_Infos__c quoteTemplate = Quote_Template_Infos__c.getOrgDefaults();
        //Check line of business
        String templateId = lineOfBusiness==ConstantsUtility.NEXA_LINEOFBUSINESS ? quoteTemplate.Quote_Nexa__c : quoteTemplate.Quote_Arena__c;
        //Insert quote template for portal users
        insertQuoteTemplate(recordId, lineOfBusiness);
    }

    /*
        @Author:                  Anuj Kumar
        @Created Date :           25/08/2019
        @Discription:             Generate quote PDF Method.
        @Date Of Modification :   25/08/2019
    */
    public static void insertQuoteTemplate(String recordId, String lineOfBusiness) {
        //Get template IDs from Custom setting
        Quote_Template_Infos__c quoteTemplate = Quote_Template_Infos__c.getOrgDefaults();
        String templateId = '';
        //Check line of business
        //String templateId = lineOfBusiness == ConstantsUtility.NEXA_LINEOFBUSINESS ? quoteTemplate.Quote_Nexa__c : quoteTemplate.Quote_Arena__c;

        if(lineOfBusiness == ConstantsUtility.NEXA_LINEOFBUSINESS){
            templateId = quoteTemplate.Quote_Nexa__c;
        }else if(lineOfBusiness == ConstantsUtility.COMMERCIAL_LINEOFBUSINESS){
            templateId = quoteTemplate.Quote_Commercial__c;
        }else if(lineOfBusiness == ConstantsUtility.PARTS){
            templateId = quoteTemplate.Quote_Parts__c;
        }else{
            templateId = quoteTemplate.Quote_Arena__c;
        }

        PageReference pr = new PageReference(GenerateFilePublicURL.baseURL()+'/quote/quoteTemplateDataViewer.apexp?id=' + recordId + '&summlid=' + templateId);

        QuoteDocument qd = new QuoteDocument();
        try{
            Blob b;

            if(!test.isRunningTest()){
                b = pr.getContentAsPDF();
            }else{
                b = blob.valueOf('Test Data');
            }

            qd.Document = b;
            qd.QuoteId = recordId;

            if(isQuoteDocumentCreatePermission()){
                insert qd;
            }
        }catch(Exception ex){
            ExceptionHandler.stackTrace ehst = new ExceptionHandler.stackTrace(); ehst.componentName='EmailQuotePDF'; ehst.userId=UserInfo.getUserId(); ExceptionHandler.LogError('EmailQuotePDF', ex.getMessage(), 'EmailQuotePDF', '', ehst);
        }
        createPublicLinkForFile(recordId);
    }

    /*
        @Author:                  Anuj Kumar
        @Created Date :           30/09/2019
        @Discription:             Generate public link for file.
        @Date Of Modification :   30/09/2019
    */
    @AuraEnabled
    public static void createPublicLinkForFile(String recordId){

        map<String,String> modelCodeLabel = new map<String,String>(modelCodeLabelMap());

        //To create MC Communication record
        List<ContentDocumentLink> cdLink = new list<ContentDocumentLink>([SELECT ContentDocumentId,LinkedEntityId,LinkedEntity.name FROM ContentDocumentLink
                                                                         WHERE LinkedEntityId=:recordId ORDER BY SystemModstamp DESC]);
        if(cdLink.size()>0){
            //Create a marketing communication record
            List<Quote> quoteRecord = new list<Quote>([SELECT OpportunityId,Opportunity.First_Name__c,Opportunity.Last_Name__c,Opportunity.Model_Code__c FROM Quote WHERE Id=:recordId]);

            //to rename file
            ContentDocument cd = [SELECT Id,Title, Description  FROM contentDocument where id =: cdLink[0].ContentDocumentId];
            cd.title = (quoteRecord[0].Opportunity.First_Name__c != null ? quoteRecord[0].Opportunity.First_Name__c +'_' : '') +
                       (quoteRecord[0].Opportunity.Last_Name__c != null ? quoteRecord[0].Opportunity.Last_Name__c  +'_' : '')+
                       (modelCodeLabel.get(quoteRecord[0].Opportunity.Model_Code__c) != null ? modelCodeLabel.get(quoteRecord[0].Opportunity.Model_Code__c) : '') +'_'
                       +String.valueOf(system.today());
            update cd;

            List<ContentVersion> conVersion = new list<ContentVersion>([SELECT Id FROM ContentVersion WHERE ContentDocumentId=:cdLink[0].ContentDocumentId]);
            //Get the public URL
            String publicPDF = GenerateFilePublicURL.CreateAttachmentPublicLink(conVersion[0].Id);


            List<MC_Communication__c> mcRecords=GenerateFilePublicURL.CreateMCRecord(ConstantsUtility.QUOTE, new Set<Id> {quoteRecord[0].OpportunityId}, ConstantsUtility.OPPORTUNITY, publicPDF);
            List<GlobalSwitchOn__c > gs = GlobalSwitchOn__c.getall().values();
            //System.debug(gs);
            if(gs != null && gs.size() > 0 && gs[0].Send_Email__c==true){
                SendEmailwithAttachment sewa=new SendEmailwithAttachment();
                sewa.sendMail('', mcRecords[0].id, 'Quotation', mcRecords[0].General_Field_1__c,cdLink[0].ContentDocumentId ,mcRecords[0].Email_2__c );
            }
        }
    }


    /*******       TO Handle The Object And Field Permissions    ********/

    /*
        @Author:                  Anuj Kumar
        @Created Date :           25/08/2019
        @Discription:             To Check the access permissions for Quote.
        @Date Of Modification :   25/08/2019
    */
    public static Boolean isQuoteAccessPermission(){
        if(CheckObjectAndField.isAccessible('Quote') && CheckObjectAndField.isFieldAccessible('Quote', 'opportunityId') && CheckObjectAndField.isFieldAccessible('Opportunity', 'Line_Of_Business__c')){
           return True;
        }else{
           return false;
        }
    }

    /*
        @Author:                  Anuj Kumar
        @Created Date :           25/08/2019
        @Discription:             To Check the create permissions for QuoteDocument.
        @Date Of Modification :   25/08/2019
    */
    public static Boolean isQuoteDocumentCreatePermission(){
        if(CheckObjectAndField.isCreateable('QuoteDocument') && CheckObjectAndField.isFieldCreateable('QuoteDocument', 'Document') && CheckObjectAndField.isFieldCreateable('QuoteDocument', 'QuoteId')){
           return True;
        }else{
            return false;
        }
    }

}