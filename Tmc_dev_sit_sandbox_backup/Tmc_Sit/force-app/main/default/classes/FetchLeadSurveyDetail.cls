public class FetchLeadSurveyDetail{
    
    public static final string REGEX = '\\{\\{![a-zA-Z0-9.__()]*\\}\\}';
    
    public static final string GREETINGS = '{{!Greeting}}';
    
    public static Map<String, List<String>> objectWithAllFieldsMap = new Map<String, List<String>>();
    public static Map<String, String> mergeaFieldValuesMap = new Map<String, String>();
    
    @AuraEnabled(cacheable=true)
    public static surveyDetails getDetails(String surveyTakerId, String SelectedLang){
        
        SurveyDetails sd = new SurveyDetails();
        List<Survey_Question_CTI__c> quesIdWIthQuestionObjectList = new List<Survey_Question_CTI__c>();
        List<Survey_Question_CTI__c> surveyQuesList = new List<Survey_Question_CTI__c>();
        Map<String, List<Survey_Answer_CTI__c>> quesIdWIthAnwsersMap = new Map<String, List<Survey_Answer_CTI__c>>();
        List<Survey_Response_CTI__c> responseList = new List<Survey_Response_CTI__c>();
        
        List<Survey_Question_CTI__c> questionList = new List<Survey_Question_CTI__c>();
        
        Schema.DescribeFieldResult languageFieldResult = Campaign.Language_Type__c.getDescribe();
        List<Schema.PicklistEntry> languageFieldResultEntry = languageFieldResult.getPicklistValues();
        
        //Lead
        Lead surveyTaker = new Lead();
        
        List<String> selectedLangugae = new List<String>();
        
        List<Id> ansIdList = new List<Id>();
        
        //New Edition
        Map<String, Survey_Response_CTI__c> responseMap = new Map<String, Survey_Response_CTI__c>();
        String thanksMsg = '';
        
        if(String.isNotBlank(surveyTakerId)){
            for(Lead leadObj : [Select Id, Campaign_Type__c, AdEventName__c, Is_Completed__c, Upsell_Cross_Sell_Tele_Caller__c, Lead_Score__c, Status, Reg_Num__c from Lead where Id =: surveyTakerId LIMIT 1]){
                surveyTaker = leadObj;
            }
            
            Campaign survey = new Campaign();
            for(Campaign sur : [Select id , Name, Sub_Header__c, Type, Status, Question_type__c, Language_Type__c,
                                (Select id, Pre_Question_Script__c, Post_Question_Script__c, Sequence_Number__c, Parent_Language_Question__c,
                                 Applicability_of_Scnerios__c,Target_Field__c, Answer_Type__c,isStart__c
                                 from Survey_Questions__r where Parent_Language_Question__c = null Order By Sequence_Number__c ASC Nulls Last)
                                from Campaign
                                where Id =: surveyTaker.AdEventName__c AND Type = 'aCRM']){
                                    
                                    questionList.addAll(sur.Survey_Questions__r);
                                    
                                    survey.Id = sur.Id;
                                    survey.Name = sur.Name;
                                    survey.Sub_Header__c = sur.Sub_Header__c;
                                    survey.Type = sur.Type;
                                    survey.Status = sur.Status;
                                    survey.Question_type__c = sur.Question_type__c;
                                    
                                    system.debug('== sur.Language_Type__c '+sur.Language_Type__c);
                                    
                                    selectedLangugae = String.isNOtBlank(sur.Language_Type__c) ? sur.Language_Type__c.split(';') : new List<String>();
                                    
                                    
                                }
            
            
            responseList = [Select id, Name, Response__c, Response_Submitted__c, Survey_Question__c, Lead__c,
                            Unique_ID__c, Survey_Question__r.Answer_Type__c, Survey_Question__r.Lookup_Object_Name__c from Survey_Response_CTI__c
                            where Lead__c =: surveyTakerId];
            // If response is not inserted then need to pre-populate isStar question's fields value
            if(responseList.size() == 0){
                //New Edition
                for(Survey_Question_CTI__c questionObj : questionList){
                    if(String.isNotBlank(questionObj.Target_Field__c) && questionObj.isStart__c){
                        Survey_Response_CTI__c responseObj = new Survey_Response_CTI__c();
                        responseObj.Lead__c = surveyTakerId;
                        responseObj.Survey_Question__c = questionObj.Id;
                        responseObj.Unique_ID__c = surveyTakerId+'_-_'+questionObj.Target_Field__c;
                        responseObj.Survey_Question__r = new Survey_Question_CTI__c(Answer_Type__c = questionObj.Answer_Type__c, isStart__c = questionObj.isStart__c);
                        responseMap.put(questionObj.Target_Field__c, responseObj);
                    }
                }
                if(responseMap.size() > 0){
                    List<String> fields = new List<String>();
                    fields.addAll(responseMap.keySet());
                    String query = 'Select id, '+ string.join(fields,',') + ' From Lead Where ID =: surveyTakerId ';
                    List<Lead> leads = (List<Lead>) database.query(query);
                    if(leads.size() > 0){
                        for(String fieldName : fields){
                            Survey_Response_CTI__c responseObj = responseMap.get(fieldName);
                            responseObj.Response__c = (String)leads[0].get(fieldName);
                            responseList.add(responseObj);
                        }
                    }
                }
            }else{
                String query = 'Select id, Variant__c, Color__c, Enquiry_Dealership__c, Enquiry_Dealer_City__c, Variant__r.Name, Color__r.Name, Enquiry_Dealership__r.Name, Enquiry_Dealer_City__r.Name From Lead Where ID =: surveyTakerId ';
                List<Lead> leads = (List<Lead>) database.query(query);
                if(leads.size() > 0){
                    sd.lookupJson = new Map<String, String>();
                    if(String.isNotBlank(leads[0].Variant__c)){
                        String json = '[{"title" : "' + leads[0].Variant__r.Name+ '", "id" : "' + leads[0].Variant__c +'"}]';
                        sd.lookupJson.put(leads[0].Variant__c, json);
                    }
                    if(String.isNotBlank(leads[0].Color__c)){
                        String json = '[{"title" : "' + leads[0].Color__r.Name+ '", "id" : "' + leads[0].Color__c +'"}]';
                        sd.lookupJson.put(leads[0].Color__c, json);
                    }
                    if(String.isNotBlank(leads[0].Enquiry_Dealership__c)){
                        String json = '[{"title" : "' + leads[0].Enquiry_Dealership__r.Name+ '", "id" : "' + leads[0].Enquiry_Dealership__c +'"}]';
                        sd.lookupJson.put(leads[0].Enquiry_Dealership__c, json);
                    }
                    if(String.isNotBlank(leads[0].Enquiry_Dealer_City__c)){
                        String json = '[{"title" : "' + leads[0].Enquiry_Dealer_City__r.Name+ '", "id" : "' + leads[0].Enquiry_Dealer_City__c +'"}]';
                        sd.lookupJson.put(leads[0].Enquiry_Dealer_City__c, json);
                    }
                }
            }
            if(!questionList.isEmpty()){
                
                for(Survey_Question_CTI__c sq : [Select id, Name, isStart__c, Question_Name__c, Pre_Question_Script__c,
                                                 Sequence_Number__c, Answer_Type__c, Post_Question_Script__c, Is_End__c, Section__c,Parent_Language_Question__c,
                                                 Applicability_of_Scnerios__c,Target_Field__c,Is_Required__c,Where_Clause__c,Lookup_Object_Name__c,
                                                 (Select id, Name, isStart__c, Question_Name__c, Pre_Question_Script__c,Language_Type__c, Sequence_Number__c, 
                                                  Answer_Type__c, Post_Question_Script__c, Is_End__c, Section__c,Parent_Language_Question__c, Applicability_of_Scnerios__c,Target_Field__c,Is_Required__c
                                                  ,Where_Clause__c,Lookup_Object_Name__c from Survey_Questions__r where Language_Type__c=:SelectedLang)
                                                 from Survey_Question_CTI__c where Id In: questionList  Order By Sequence_Number__c ASC Nulls Last])
                {
                    
                    if(String.isNotBlank(sq.Pre_Question_Script__c) || String.isNotBlank(sq.Post_Question_Script__c) || String.isNotBlank(sq.Question_Name__c) || 
                       (sq.Survey_Questions__r.size()>0 && (String.isNotBlank(sq.Survey_Questions__r[0].Pre_Question_Script__c) || 
                                                            String.isNotBlank(sq.Survey_Questions__r[0].Post_Question_Script__c) || String.isNotBlank(sq.Survey_Questions__r[0].Question_Name__c))))
                    {
                        String script = (sq.Pre_Question_Script__c != null ? sq.Pre_Question_Script__c : '') +
                            (sq.Post_Question_Script__c != null ? sq.Post_Question_Script__c : '')+
                            (sq.Question_Name__c != null ? sq.Question_Name__c : '')+
                            (sq.Survey_Questions__r.size()>0 ? sq.Survey_Questions__r[0].Pre_Question_Script__c != null ? sq.Survey_Questions__r[0].Pre_Question_Script__c:'':'')+
                            (sq.Survey_Questions__r.size()>0 ? sq.Survey_Questions__r[0].Question_Name__c != null ? sq.Survey_Questions__r[0].Question_Name__c:'':'')+
                            (sq.Survey_Questions__r.size()>0 ? sq.Survey_Questions__r[0].Post_Question_Script__c != null ? sq.Survey_Questions__r[0].Post_Question_Script__c:'':'');
                        
                        retrieveMergeFieldValue(script);
                    }
                    surveyQuesList.add(sq);
                    
                }
                List<LanguageType> LanguageTypeList = new List<LanguageType>();
                system.debug('== selectedLangugae '+selectedLangugae);
                
                for( Schema.PicklistEntry field : languageFieldResultEntry){
                    LanguageType lt = new LanguageType();
                    
                    lt.label = field.getLabel();
                    lt.value = field.getValue();
                    if(!selectedLangugae.isEmpty() && selectedLangugae.contains(field.getValue())){
                        LanguageTypeList.add(lt);
                    }
                }
                
                system.debug('== objectWithAllFieldsMap '+objectWithAllFieldsMap);
                
                if(!objectWithAllFieldsMap.isEmpty()){
                    if(objectWithAllFieldsMap.containsKey('User')){
                        String currentUserID = UserInfo.getUserId();
                        String query = 'Select id, '+ string.join(objectWithAllFieldsMap.get('User'),',') + ' From User Where ID =: currentUserID ';
                        List<user> userList = (List<user>) database.query(query);
                        system.debug('== userList '+userList);
                        for(User obj : userList){
                            for(String str : objectWithAllFieldsMap.get('User')){
                                String scriptKey = '{{!User.'+str+'}}';
                                
                                system.debug('== Field Value '+str+ ' == ' + getValue(obj, str));
                                String fieldValue = String.valueOf(getValue(obj, str));
                                
                                if(mergeaFieldValuesMap.containsKey(scriptKey))
                                    mergeaFieldValuesMap.put(scriptKey, fieldValue);
                            }
                        }
                    }
                    
                    if(objectWithAllFieldsMap.containsKey('Lead')){
                        String query = 'Select id, '+ string.join(objectWithAllFieldsMap.get('Lead'),',') + ' From Lead Where ID =: surveyTakerId ';
                        System.debug('query : '+query);
                        List<Lead> surveyTakerList = (List<Lead>) database.query(query);
                        system.debug('== surveyTakerList '+surveyTakerList);
                        
                        for(Lead obj : surveyTakerList){
                            for(String str : objectWithAllFieldsMap.get('Lead')){
                                
                                String scriptKey = '{{!Lead.'+str+'}}';
                                string fieldName = str;
                                system.debug('fieldName : '+fieldName);
                                if(fieldName.startsWith('toLabel')){
                                    fieldName = fieldName.substringAfter('toLabel(').substringBefore(')');
                                    system.debug('== fieldName '+fieldName);
                                }
                                
                                system.debug('== Field Value '+fieldName+ ' == ' + getValue(obj, fieldName));
                                String fieldValue = String.valueOf(getValue(obj, fieldName));
                                system.debug('fieldValue : '+fieldValue);
                                if(mergeaFieldValuesMap.containsKey(scriptKey))
                                    mergeaFieldValuesMap.put(scriptKey, fieldValue);
                                
                            }
                        }
                    }
                }
                
                system.debug('== mergeaFieldValuesMap '+mergeaFieldValuesMap);
                
                for(Survey_Question_CTI__c sq : surveyQuesList){
                    String preScript = sq.Pre_Question_Script__c;
                    String postScript = sq.Post_Question_Script__c;
                    String quesScript = sq.Question_Name__c;
                    String selLangPreScript = sq.Survey_Questions__r.size()>0 ? sq.Survey_Questions__r[0].Pre_Question_Script__c:'';
                    String selLangPostScript = sq.Survey_Questions__r.size()>0 ? sq.Survey_Questions__r[0].Post_Question_Script__c:'';
                    String selLangQuesScript = sq.Survey_Questions__r.size()>0 ? sq.Survey_Questions__r[0].Question_Name__c:'';
                    
                    
                    for(String scriptKey : mergeaFieldValuesMap.keySet()){
                        if(String.isNOtBlank(preScript) && preScript.contains(scriptKey)){
                            preScript = preScript.replace(scriptKey, mergeaFieldValuesMap.get(scriptKey) != null ? mergeaFieldValuesMap.get(scriptKey) : '');
                            preScript = preScript.replace('&lt;', '<');
                            preScript = preScript.replace('&gt;', '>');
                            sq.Pre_Question_Script__c = preScript;
                        }
                        if(String.isNOtBlank(postScript) && postScript.contains(scriptKey)){
                            postScript = postScript.replace(scriptKey, mergeaFieldValuesMap.get(scriptKey) != null ? mergeaFieldValuesMap.get(scriptKey) : '');
                            postScript = postScript.replace('&lt;', '<');
                            postScript = postScript.replace('&gt;', '>');
                            sq.Post_Question_Script__c = postScript;
                        }
                        if(String.isNOtBlank(quesScript) && quesScript.contains(scriptKey)){
                            quesScript = quesScript.replace(scriptKey, mergeaFieldValuesMap.get(scriptKey) != null ? mergeaFieldValuesMap.get(scriptKey) : '');
                            sq.Question_Name__c = quesScript;
                        }
                        if(String.isNOtBlank(selLangPreScript) && selLangPreScript.contains(scriptKey)){
                            selLangPreScript = selLangPreScript.replace(scriptKey, mergeaFieldValuesMap.get(scriptKey) != null ? mergeaFieldValuesMap.get(scriptKey) : '');
                            selLangPreScript = selLangPreScript.replace('&lt;', '<');
                            selLangPreScript = selLangPreScript.replace('&gt;', '>');
                            sq.Survey_Questions__r[0].Pre_Question_Script__c = selLangPreScript;
                        }
                        if(String.isNOtBlank(selLangPostScript) && selLangPostScript.contains(scriptKey)){
                            selLangPostScript = selLangPostScript.replace(scriptKey, mergeaFieldValuesMap.get(scriptKey) != null ? mergeaFieldValuesMap.get(scriptKey) : '');
                            selLangPostScript = selLangPostScript.replace('&lt;', '<');
                            selLangPostScript = selLangPostScript.replace('&gt;', '>');
                            sq.Survey_Questions__r[0].Post_Question_Script__c = selLangPostScript;
                        }
                        if(String.isNOtBlank(selLangQuesScript) && selLangQuesScript.contains(scriptKey)){
                            selLangQuesScript = selLangQuesScript.replace(scriptKey, mergeaFieldValuesMap.get(scriptKey) != null ? mergeaFieldValuesMap.get(scriptKey) : '');
                            sq.Survey_Questions__r[0].Question_Name__c = selLangQuesScript;
                        }
                        if(String.isEmpty(postScript) && String.isEmpty(quesScript) && String.isEmpty(sq.Answer_Type__c) && String.isNotEmpty(preScript)){
                            thanksMsg = String.isNotBlank(selLangPreScript) ? selLangPreScript : preScript;
                        }
                    }
                    system.debug('== Sequence_Number__c '+sq.Sequence_Number__c);
                    
                    quesIdWIthQuestionObjectList.add(sq);
                }
                
                for(Survey_Answer_CTI__c surveyAns : [Select id, Name, Display_Value__c,Actual_Value__c, Next_Question__c, Parent_Question__c, Shadow_field__c, Type__c, Sequence_Number__c,
                                                      (Select id, Name, Display_Value__c,Actual_Value__c, Next_Question__c, Parent_Question__c, Shadow_field__c, Type__c, Sequence_Number__c from Survey_Answers__r
                                                       where Language_Type__c=:SelectedLang)
                                                      from Survey_Answer_CTI__c where Parent_Question__c IN:questionList AND Parent_Language_Answer__c = null Order By Sequence_Number__c ASC]){
                                                          if(!quesIdWIthAnwsersMap.containsKey(surveyAns.Parent_Question__c)){
                                                              quesIdWIthAnwsersMap.put(surveyAns.Parent_Question__c, new List<Survey_Answer_CTI__c>());
                                                          }
                                                          quesIdWIthAnwsersMap.get(surveyAns.Parent_Question__c).add(surveyAns);
                                                      }
                sd.survey = survey;
                sd.surveyTaker = surveyTaker;
                sd.quesIdWIthQuestionObjectList = quesIdWIthQuestionObjectList;
                sd.quesIdWIthAnwsersMap = quesIdWIthAnwsersMap;
                sd.responseList = responseList;
                sd.LanguageTypeList = LanguageTypeList;
                sd.thankYouMsg = thanksMsg;
            }
        }
        system.debug('== sd '+sd);
        
        return sd;
    }
    
    public static List<String> retrieveMergeFieldValue(String mergeFieldData){
        
        List<String> objectWithFieldList = new List<String>();
        
        Pattern regexPattern = Pattern.compile(REGEX);
        
        if(String.isNotBlank(mergeFieldData)){
            Matcher matcherValue = regexPattern.matcher(mergeFieldData);
            while (matcherValue.find()) {
                
                string matchStr = matcherValue.group();
                system.debug('== matchStr '+matchStr);
                
                if(matchStr == GREETINGS){
                    mergeaFieldValuesMap.put(matchStr, getGreeting());
                }else{
                    mergeaFieldValuesMap.put(matchStr, '');
                }
                
                if(String.isNotBlank(matchStr) && matchStr.contains('{{!') && matchStr.contains('}}') && matchStr.contains('.')){
                    
                    system.debug('== all fields '+ matchStr.removeStart('{{!').removeEnd('}}'));
                    String objectWithFields = matchStr.removeStart('{{!').removeEnd('}}');
                    
                    string objectName = objectWithFields.substringBefore('.');
                    String fieldName = objectWithFields.substringAfter('.');
                    
                    if(!objectWithAllFieldsMap.containsKey(objectName))
                        objectWithAllFieldsMap.put(objectName, new List<String>());
                    if(!objectWithAllFieldsMap.get(objectName).contains(fieldName))
                        objectWithAllFieldsMap.get(objectName).add(fieldName);
                }
            }
        }
        
        return objectWithFieldList;
    }
    
    public static string getGreeting(){
        String greeting = '';
        List<String> hrMinList = system.Now().format('HH:mm').split(':');
        Integer hr = Integer.valueOf(hrMinList[0]);
        Integer min = Integer.valueOf(hrMinList[1]);
        
        if((hr < 12 && min < 60 && min != 1) || (hr == 12 && min == 0)){
            greeting = 'Good Morning';
        }else if((hr == 17 && min < 01) || (hr >= 12 && hr < 17 && min > 0) || (hr == 18 && min == 0)){
            greeting = 'Good Afternoon';
        }else if((hr == 23 && min < 60) || (hr >= 17 && hr < 23 && min > 0)){
            greeting = 'Good Evening';
        }
        
        system.debug('== greeting '+greeting);
        return greeting;
    }
    
    public static Object getValue(SObject record, String path) {
        try {
            SObject temp = record;
            String[] parts = path.split('\\.');
            while(parts.size() > 1) {
                temp = temp.getSObject(parts.remove(0));
            }
            return temp.get(parts[0]);
        } catch(Exception e) {
            return null;
        }
    }
    
    
    public class surveyDetails{
        @AuraEnabled public Lead surveyTaker;
        @AuraEnabled public Campaign survey;
        @AuraEnabled public List<Survey_Question_CTI__c> quesIdWIthQuestionObjectList;
        @AuraEnabled public Map<String, List<Survey_Answer_CTI__c>> quesIdWIthAnwsersMap;
        @AuraEnabled public List<Survey_Response_CTI__c> responseList;//Need to comment
        @AuraEnabled public List<LanguageType> LanguageTypeList;
        @AuraEnabled public Map<String, String> lookupJson;
        @AuraEnabled public String userName = UserInfo.getName();
        @AuraEnabled public String thankYouMsg;
    }
    
    public Class LanguageType {
        @AuraEnabled public string label;
        @AuraEnabled public string value;
    }
    
    @AuraEnabled
    public static String submitSurveyResponse(String response, Boolean isCompleted, String leadId) {
        string errorMessage = '';
        Savepoint sp = Database.setSavepoint();
        
        system.debug('== response '+response);
        if(string.isNotBlank(response)){
            
            List<Survey_Response_CTI__c> responseList =  (List<Survey_Response_CTI__c>)JSON.deserialize(response, List<Survey_Response_CTI__c>.class);
            system.debug('== responseList '+responseList);
            
            if(!responseList.isEmpty()){
                Lead updateLead = new Lead(Id = leadId);
                for(Survey_Response_CTI__c sr : responseList){
                    if(String.isNotBlank(sr.Unique_ID__c)){
                        List<String> leadIdWithFieldName = sr.Unique_ID__c.split('_-_');
                        if(leadIdWithFieldName.size() > 1){
                            String fieldName = leadIdWithFieldName[1] ;
                            System.debug('responce : '+fieldName);
                            System.debug('responce : '+sr.Response__c);
                            if(fieldName == 'Purchased_Date_Current_Model__c' || fieldName == 'TV_Next_FollowUp_Date__c'){
                                updateLead.put(fieldName , (String.isNotBlank(sr.Response__c) ? Date.valueOf(sr.Response__c) : null));
                            }else if(fieldName == 'Expected_Drive_Km__c'){
                                updateLead.put(fieldName , (String.isNotBlank(sr.Response__c) ? Decimal.valueOf(sr.Response__c) : null));
                            }else if(fieldName == 'Current_Model__c'){
                                updateLead.put(fieldName , sr.Response__c);
                                //updateLead.put('Sales_Model__c' , sr.Response__c);
                            }else if(fieldName == 'Exchange_Old_Car__c' ){
                                if(sr.Response__c == 'Yes'){
                                    updateLead.put('Buyer_Type__c' , '01');
                                }else if(sr.Response__c == 'No'){
                                    updateLead.put('Buyer_Type__c' , '02');
                                }
                                updateLead.put(fieldName , sr.Response__c);
                            }else if(fieldName == 'Interested_in_TV__c'){
                                updateLead.put(fieldName , sr.Response__c);
                                updateLead.put('Enquiry_Dealer_Type__c', 'TV');
                            }else if(fieldName == 'Buy_car_from_same_dealer__c' && sr.Response__c == 'Yes'){
                                //updateLead.put('Enquiry_Dealer_City__c', updateLead.Sales_Dealership__c);
                                List<Lead> leadList = [SELECT Sales_Dealership__c FROM Lead WHERE Id =: leadId LIMIT 1];
                                if(leadList.size() > 0)
                                	updateLead.Enquiry_Dealership__c = leadList[0].Sales_Dealership__c;
                            }else
                                updateLead.put(fieldName , sr.Response__c);
                        }
                        
                    }
                }
                updateLead.Is_Completed__c = isCompleted;
                if(isCompleted){
                    updateLead.DPS_Sync_Status__c = 'Pending';
                    updateLead.Integration_Sync_Time__c = DateTime.Now();
                }
                try{
                    Update updateLead;
                    
                    /*Lead leadObjStatuUpdate = [Select Id, Lead_Score__c, Status from Lead Where Id =: leadId];
                    if(leadObjStatuUpdate.Lead_Score__c == 'Deferred' || leadObjStatuUpdate.Lead_Score__c == 'Warm' || leadObjStatuUpdate.Lead_Score__c == 'Cold'){
                        if(leadObjStatuUpdate.Lead_Score__c == 'Deferred'){
                            leadObjStatuUpdate.Status = 'Converted_Lost';
                        }else if(leadObjStatuUpdate.Lead_Score__c == 'Warm' || leadObjStatuUpdate.Lead_Score__c == 'Cold'){
                            leadObjStatuUpdate.Status = 'Follow Up';
                        }
                        Update leadObjStatuUpdate;
                    }*/
                    List<Lead> leadList = [SELECT Id, Interested_in_New_Car__c, isConverted, Is_Completed__c, 
                                        Lead_Score__c, Upsell_Cross_Sell_Tele_Caller__c, Interested_in_TV__c FROM Lead WHERE Id =: updateLead.Id LIMIT 1];
                    try{
                        if(leadList.size() > 0){
                            if (isCompleted && leadList[0].Interested_in_TV__c == 'Yes') {
                                String err = createTVLead(updateLead);
                                System.debug('err: '+err);
                                if(String.isNotBlank(err)){
                                    return err;
                                }
                            }
                            if(!leadList[0].isConverted && leadList[0].Is_Completed__c ){
                                if(leadList[0].Interested_in_New_Car__c == 'Yes' && leadList[0].Lead_Score__c == 'Hot'){
                                    LeadHandler.autoLeadConvert(leadList, ConstantsUtility.OPPORTUNITY_VEHICLE_SALES_RECORDTYPE);
                                }else if(leadList[0].Interested_in_TV__c == 'No' && leadList[0].Upsell_Cross_Sell_Tele_Caller__c.contains('MSGA')){
                                    LeadHandler.autoLeadConvert(leadList, ConstantsUtility.ACCESSORIES_SALES_CONST);
                                }
                            }
                        }
                    }catch(DMLException e){
                        String errorMsg = '';
                        for(integer i=0; i < e.getNumDml(); i++){
                            errorMsg +=  e.getDmlMessage(i) + '\n';
                        }
                        return errorMsg;
                    }
                    
                }catch(DMLException e){
                    String errorMsg = '';
                    for(integer i=0; i < e.getNumDml(); i++){
                        errorMsg +=  e.getDmlMessage(i) + '\n';
                    }
                    return errorMsg;
                }
                
                system.debug('== updateLead '+updateLead);
                
                Schema.SObjectField externalIdField = Survey_Response_CTI__c.Fields.Unique_ID__c;
                Database.UpsertResult[] srList = Database.upsert(responseList, externalIdField, false);
                
                system.debug('== srList '+srList);
                
                for (Database.UpsertResult sr : srList) {
                    if (!sr.isSuccess()) {
                        // Operation failed, so get all errors
                        for(Database.Error err : sr.getErrors()) {
                            errorMessage += ' error has occurred.' + err.getStatusCode() + ': ' + err.getMessage();
                        }
                    }
                }
                system.debug('== errorMessage '+errorMessage);
                if(String.isNotBlank(errorMessage)){
                    Database.rollback(sp);
                }
            }
        }
        
        if(String.isNotBlank(errorMessage)){
            ExceptionHandler.stackTrace ehst=new ExceptionHandler.stackTrace(); 
            ehst.componentName='Survey Taker Question LWC'; 
            ehst.userId=UserInfo.getUserId(); 
            ExceptionHandler.LogError('Survey Taker Question LWC CTRL', errorMessage, 'Survey Taker Question LWC Ctrl', '', ehst);
            return 'error';
        }
        
        return 'success';
    }
    @AuraEnabled(cacheable=true)
    public static List<sObject> retriveLookupResult(String objectName, String fields, String name, String queryConditions){
        if(String.isNotBlank(name)){
            string nameData = '%'+name.trim()+'%';
            List<sObject> result = new List<sObject>();
            
            string query = 'Select Id, ' + fields + ' from ' + objectName;
            query += ' where Id != null AND Name LIKE: nameData ';
            if(String.isNotBlank(queryConditions)){
                query += queryConditions;
            }
            query += ' Order By CreatedDate Desc Limit 10';
            
            system.debug('== query '+query);
            
            return DataBase.query(query);
        }
        return new List<sObject>();
    }
    @AuraEnabled(cacheable = true)
    public static List<Account> fetchDealerWorkshopList(String forCodeId, String variantId){
        system.debug('forCodeId---->'+variantId);
        List<Account> dealers = new List<Account>();
        if(String.isNotBlank(forCodeId)){
            
            String dealerQuery = 'Select Id, Name, BillingPostalCode, Channel__c, Dealer_Type__c,';
            dealerQuery += 'Dealer_Category__c, For_Code__r.Name, Dealer_Address_F__c, For_Code__r.For_Code__c,';
            dealerQuery += 'Parent_Group__c, Dealer_Map_Code__c, Dealer_Location__c';
            dealerQuery += ' from Account where RecordType.DeveloperName = \'Dealer\' AND For_Code__c =: forCodeId';
            if(String.isNotBlank(variantId)){
                List<Product2> products = [Select Id, Channel__c from Product2 where Id =: variantId];
                if(products.size() > 0){
                    dealerQuery += ' AND Channel__c = \'' + products[0].Channel__c +'\'';
                }
            }
            dealers = Database.query(dealerQuery);
        }
        System.debug('dealerList: '+dealers);
        return dealers;
    }
    
    @AuraEnabled(cacheable = true)
    public static List<For_Code__c> fetchForCode(){
        return [Select Id,Name from For_Code__c where For_Code__c != NULL];
    }
    private static String createTVLead(Lead leadObj){
        String TV_RecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Inbound_True_Value_Prospect').getRecordTypeId();
        Lead leadTVObj = new Lead();
        leadTVObj.RecordTypeId = TV_RecTypeId;
        leadTVObj.aCRM__c = leadObj.Id;
        leadTVObj.Buying_Type__c = leadObj.Buying_Type__c;
        //leadTVObj.TV_Title__c = leadObj.Title_Enquiry__c;
        leadTVObj.TV_First_Name__c = leadObj.FirstName__c;
        leadTVObj.TV_Last_Name__c = leadObj.LastName__c;
        leadTVObj.Primary_Mobile__c = leadObj.Primary_Mobile__c;
        leadTVObj.Email = leadObj.Email;
        leadTVObj.TV_Dealership__c = leadObj.TV_Dealership__c;
        leadTVObj.Make__c = leadObj.Make__c;
        leadTVObj.Model__c = leadObj.Model__c;
        leadTVObj.TV_Variant__c = leadObj.TV_Variant__c;
        leadTVObj.TV_Next_FollowUp_Date__c = leadObj.TV_Next_FollowUp_Date__c;
        leadTVObj.TV_Next_Action__c = leadObj.TV_Next_Action__c;
        leadTVObj.TV_Next_Stage__c = leadObj.TV_Next_Stage__c;
        leadTVObj.Interested_in_TV__c = leadObj.Interested_in_TV__c;
        leadTVObj.FirstName = leadObj.FirstName__c;
        leadTVObj.LastName = leadObj.LastName__c;
        leadTVObj.Description = leadObj.VOC__c;
        leadTVObj.Is_Completed__c = true;
        try {
            insert leadTVObj;
            return '';
        } catch(DMLException e){
            String errorMsg = '';
            for(integer i=0; i < e.getNumDml(); i++){
                errorMsg +=  e.getDmlMessage(i) + '\n';
            }
            return errorMsg;
        }
    }
}