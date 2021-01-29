@isTest
public class UtilLead {
    //Create a camaign
    public static Campaign createCampaignRec(){
        Campaign campObj = new Campaign(Name = 'Test Campaign 1', IsActive = True, Type = 'aCRM');
        insert campObj;
        System.assert(campObj.Id != null, 'Fail to create campaign!');
        return campObj;
    }
    //Create a new Product record
    private static Product2 createProductRec(){
        Product2 variant = new Product2();
        Id recTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Variants').getRecordTypeId();
        variant.RecordTypeId = recTypeId;
        variant.Name = 'Test variant';
        variant.Fuel_Type__c = 'PET';
        variant.Family = 'ALTO 800';
        variant.Channel__c = 'EXC';
        variant.IsActive = true;
        variant.Model__c = 'AN';
        variant.Enquiry__c = 'Yes';
        insert variant;
        System.assert(variant.Id != null, 'Fail to create product!');
        return variant;
    }
    //create a new variant's color
    private static Color_Variant_Master__c createVariantColor(Id productId){
        Color_Variant_Master__c color = new Color_Variant_Master__c();
        color.Name = 'White';
        color.Color_Code__c = 'White';
        color.Color_Type__c = 'M';
        color.Variant__c = productId;
        color.Active__c = true;
        insert color;
        System.assert(color.Id != null, 'Fail to create Color variant!');
        return color;
    }
    //Create a new Account record
    private static Account createAccount(){
        Id accId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Dealer').getRecordTypeId();
        Account accObj = new Account(Name = 'Test Account', RecordTypeId = accId);
        insert accObj;
        System.assert(accObj.Id != null, 'Fail to create Account!');
        return accObj;
    }
    //Create a new dealer city record
    private static City__c createDealerCity(){
        City__c dealerCity = new City__c(Name = 'Ajmer');
        insert dealerCity;
        System.assert(dealerCity.Id != null, 'Fail to create Dealer city!');
        return dealerCity;
    }
    //Create a Lead
    public static Lead createLeadRec(Id campaignId, String recordTypeName){
        String recordType = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
        Product2 variant = createProductRec();
        Color_Variant_Master__c color = createVariantColor(variant.Id);
        Account dealer = createAccount();
        City__c dealerCity = createDealerCity();
        Lead leadObj = new Lead();
        leadObj.Title__c = 'Mr';
        leadObj.FirstName = 'Test';
        leadObj.lastName = 'Lead';
        leadObj.Salutation = 'Mr.';
        leadObj.LeadSource = 'EMA';
        leadObj.AdEventName__c = campaignId;
        leadObj.Email = 'test22@gmail.com';
        leadObj.Test_Drive_Given__c = 'Y';
        leadObj.Customer_Type__c = 'I';
        leadObj.Upsell_Cross_Sell_Tele_Caller__c = 'MSGA';
        //leadObj.Campaign_Type__c = campaignRec.Name;
        leadObj.Sales_Model__c = 'BA';
        leadObj.Enq_Model__c = 'AN';
        leadObj.Variant__c = variant.Id;
        leadObj.Color__c = color.Id;
        leadObj.Gender__c = 'M';
        leadObj.MobilePhone = '9123456789';
        leadObj.Sales_Email__c = 'test123@gmail.com';
        leadObj.Enquiry_Dealership__c = dealer.Id;
        leadObj.Enquiry_Dealer_City__c = dealerCity.Id;
        leadObj.RecordTypeId = recordType;
        leadObj.Purchase_Interest__c = '<= 1 month';
        leadObj.Interested_in_New_Car__c = 'Yes';
        insert leadObj;
        System.assert(leadObj.Id != null, 'Fail to create a Lead!');
        return leadObj;
    }
    
    //Create a new survey question CTI record
    public static Survey_Question_CTI__c createQuestion(String parentQuesId, Id campaignId){
        Survey_Question_CTI__c ques = new Survey_Question_CTI__c();
        ques.Answer_Type__c = 'Text';
        ques.Sequence_Number__c = String.isNotBlank(parentQuesId)? 1 : 2;
        ques.Question_Name__c = 'First Name of {{!Lead.FirstName__c}}';
        ques.Pre_Question_Script__c = '{{!Greeting}}, SIR/MADAM my name is {{!User.Name}}.I am calling from Maruti Suzuki India Ltd.May I Speak with {{!Lead.FirstName__c}} {{!Lead.LastName__c}}?Do you want to change a Name?';
        ques.Post_Question_Script__c = 'Customer Type : <span class=customer-type>{{!Lead.Lead_Score__c}}</span>';
        ques.Survey__c = campaignId;
        ques.isStart__c = true;
        ques.Is_Required__c	 = true;
        ques.Target_Field__c = 'FirstName__c';
        ques.Language_Type__c = 'English';
        if(String.isNotBlank(parentQuesId)) ques.Parent_Language_Question__c = parentQuesId;
        insert ques;
        System.assert(ques.Id != null, 'Fail to create Survey Question!');
        return ques;
    }
    //Create a new survey answer CTI record
    public static Survey_Answer_CTI__c createAnswer(Id questionId){
        Survey_Answer_CTI__c answer = new Survey_Answer_CTI__c();
        answer.Display_Value__c = 'ALTO 800';
        answer.Actual_Value__c = 'AK';
        answer.Parent_Question__c = questionId;
        answer.Next_Question__c = 'SQN-000002';
        answer.Sequence_Number__c = 1;
        answer.Language_Type__c = 'English';
        insert answer;
        System.assert(answer.Id != null, 'Fail to create Survey Answer!');
        return answer;
    }
    //Create a new survey response CTI record
    public static Survey_Response_CTI__c createResponse(Id leadId, Id questionId){
        Survey_Response_CTI__c responseObj = new Survey_Response_CTI__c();
        responseObj.Response__c = 'Text';
        responseObj.Survey_Question__c = questionId;
        responseObj.Unique_ID__c = leadId+'_-_FirstName__c';
        responseObj.Lead__c = leadId;
        responseObj.ResponseText__c = 'Text';
        insert responseObj;
        System.assert(responseObj.Id != null, 'Fail to create Survey Response!');
        return responseObj;
    }
}