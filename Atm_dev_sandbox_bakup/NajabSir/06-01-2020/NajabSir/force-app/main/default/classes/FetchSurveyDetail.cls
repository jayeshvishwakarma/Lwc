/**
 * @File Name          : FetchSurveyDetail.cls
 * @Description        : This class is used to fetch the survey details.
 * @Author             : Anuj Kumar
 * @Group              :
 * @Last Modified By   :
 * @Last Modified On   :
 * @Modification Log   :
 *==============================================================================
 * Ver         Date                     Author                Modification
 *==============================================================================
 * 1.0       23/09/2020                Anuj Kumar            Initial Version
**/

public class FetchSurveyDetail{

    public static final string REGEX = '\\{\\{![a-zA-Z0-9.__()]*\\}\\}';

    public static final string GREETINGS = '{{!Greeting}}';

    public static Map<String, List<String>> objectWithAllFieldsMap = new Map<String, List<String>>();
    public static Map<String, String> mergeaFieldValuesMap = new Map<String, String>();

    /*------------------------------------------------------------------------------------
        Description     To fetch survey question records
        params          surveyTakerId - Id of surveyTaker current record
    ------------------------------------------------------------------------------------*/


    @AuraEnabled(cacheable=true)
    //public static surveyDetails getDetails(String surveyTakerId){
    //String SelectedLang = 'English';
    public static surveyDetails getDetails(String surveyTakerId, String SelectedLang){

        SurveyDetails sd = new SurveyDetails();
        List<Survey_Question_CTI__c> quesIdWIthQuestionObjectList = new List<Survey_Question_CTI__c>();
        List<Survey_Question_CTI__c> surveyQuesList = new List<Survey_Question_CTI__c>();
        Map<String, List<Survey_Answer_CTI__c>> quesIdWIthAnwsersMap = new Map<String, List<Survey_Answer_CTI__c>>();
        List<Survey_Response_CTI__c> responseList = new List<Survey_Response_CTI__c>();

        List<Survey_Question_CTI__c> questionList = new List<Survey_Question_CTI__c>();

        Schema.DescribeFieldResult languageFieldResult = Campaign.Language_Type__c.getDescribe();
        List<Schema.PicklistEntry> languageFieldResultEntry = languageFieldResult.getPicklistValues();

        //Survey Taker
        Survey_Taker_CTI__c surveyTaker = new Survey_Taker_CTI__c();

        List<String> selectedLangugae = new List<String>();

        List<Id> ansIdList = new List<Id>();

        if(String.isNotBlank(surveyTakerId)){
            Campaign survey = new Campaign();
            for(Campaign sur : [Select id , Name, Sub_Header__c, Type, Status, Question_type__c, Language_Type__c,
                        (Select id, Pre_Question_Script__c, Post_Question_Script__c, Sequence_Number__c, Parent_Language_Question__c,
                        Applicability_of_Scnerios__c, Not_Applicable_Next_Question__c,Is_Applicable_Question__c,Default_Help_Text__c, MultiSelect_Limit__c
                        from Survey_Questions__r where Parent_Language_Question__c = null Order By Sequence_Number__c ASC Nulls Last),
                        (Select id, Survey_Submitted_Time__c, Is_Completed__c from Survey_Takers__r)
                    from Campaign
                    where Id IN (Select Survey__c from Survey_Taker_CTI__c where Id =: surveyTakerId)]){

                questionList.addAll(sur.Survey_Questions__r);

                survey.Id = sur.Id;
                survey.Name = sur.Name;
                survey.Sub_Header__c = sur.Sub_Header__c;
                survey.Type = sur.Type;
                survey.Status = sur.Status;
                survey.Question_type__c = sur.Question_type__c;

                system.debug('== sur.Language_Type__c '+sur.Language_Type__c);
                selectedLangugae = String.isNOtBlank(sur.Language_Type__c) ? sur.Language_Type__c.split(';') : new List<String>();

                for(Survey_Taker_CTI__c st : sur.Survey_Takers__r){
                    if(st.id == surveyTakerId){
                        surveyTaker = st;
                    }
                }

                /* for(Survey_Question_CTI__c sq : sur.Survey_Questions__r){

                    if(String.isNotBlank(sq.Pre_Question_Script__c) || String.isNotBlank(sq.Post_Question_Script__c)){
                        String script = (sq.Pre_Question_Script__c != null ? sq.Pre_Question_Script__c : '') +
                                        (sq.Post_Question_Script__c != null ? sq.Post_Question_Script__c : '');
                        retrieveMergeFieldValue(script);
                    }
                } */
            }



            responseList = [Select id, Name, Response__c, Response_Submitted__c, Survey_Question__c, Survey_Taker__c,
                                Unique_ID__c, Survey_Question__r.Answer_Type__c from Survey_Response_CTI__c
                                where Survey_Taker__c =: surveyTakerId AND
                                Response_Submitted__c =: surveyTaker.Survey_Submitted_Time__c];


            if(!questionList.isEmpty()){
                for(Survey_Question_CTI__c sq : [Select id, Name, isStart__c, Question_Name__c, Pre_Question_Script__c,
                            Sequence_Number__c,Is_Applicable_Question__c,Not_Applicable_Next_Question__c, Answer_Type__c, Post_Question_Script__c, Is_End__c, Section__c,Parent_Language_Question__c,
                            Applicability_of_Scnerios__c,Default_Help_Text__c,Address_Line_1__c,Address_Line_2__c,Address_Line_3__c,City__c,State__c,Pincode__c,MultiSelect_Limit__c,
                            (Select id, Name, isStart__c, Question_Name__c, Pre_Question_Script__c,Language_Type__c, Sequence_Number__c,
                            Answer_Type__c, Post_Question_Script__c,Not_Applicable_Next_Question__c, Is_End__c, Section__c,Parent_Language_Question__c,Default_Help_Text__c,MultiSelect_Limit__c
                            from Survey_Questions__r where Language_Type__c=:SelectedLang)
                        from Survey_Question_CTI__c where Id In: questionList  Order By Sequence_Number__c ASC Nulls Last])
                {
					system.debug('sq ' + sq);
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
                    //ansIdList.addAll(sq.Survey_Answers__r);
                    //if(String.isNotBlank(sq.Pre_Question_Script__c) && sq.Pre_Question_Script__c.contains('{{!') && sq.Pre_Question_Script__c.contains('}}')){


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

                    if(objectWithAllFieldsMap.containsKey('Survey_Taker_CTI__c')){
                        String query = 'Select id, '+ string.join(objectWithAllFieldsMap.get('Survey_Taker_CTI__c'),',') + ' From Survey_Taker_CTI__c Where ID =: surveyTakerId ';
                        List<Survey_Taker_CTI__c> surveyTakerList = (List<Survey_Taker_CTI__c>) database.query(query);
                        system.debug('== surveyTakerList '+surveyTakerList);

                        for(survey_taker_cti__c obj : surveyTakerList){
                            for(String str : objectWithAllFieldsMap.get('Survey_Taker_CTI__c')){
                                String scriptKey = '{{!Survey_Taker_CTI__c.'+str+'}}';
                                string fieldName = str;
                                if(fieldName.startsWith('toLabel')){
                                    fieldName = fieldName.substringAfter('toLabel(').substringBefore(')');
                                    system.debug('== fieldName '+fieldName);
                                }

                                system.debug('== Field Value '+fieldName+ ' == ' + getValue(obj, fieldName));
                                String fieldValue = String.valueOf(getValue(obj, fieldName));

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
                            sq.Pre_Question_Script__c = preScript;
                        }
                        if(String.isNOtBlank(postScript) && postScript.contains(scriptKey)){
                            postScript = postScript.replace(scriptKey, mergeaFieldValuesMap.get(scriptKey) != null ? mergeaFieldValuesMap.get(scriptKey) : '');
                            sq.Post_Question_Script__c = postScript;
                        }
                        if(String.isNOtBlank(quesScript) && quesScript.contains(scriptKey)){
                            quesScript = quesScript.replace(scriptKey, mergeaFieldValuesMap.get(scriptKey) != null ? mergeaFieldValuesMap.get(scriptKey) : '');
                            sq.Question_Name__c = quesScript;
                        }
                        if(String.isNOtBlank(selLangPreScript) && selLangPreScript.contains(scriptKey)){
                            selLangPreScript = selLangPreScript.replace(scriptKey, mergeaFieldValuesMap.get(scriptKey) != null ? mergeaFieldValuesMap.get(scriptKey) : '');
                            sq.Survey_Questions__r[0].Pre_Question_Script__c = selLangPreScript;
                        }
                        if(String.isNOtBlank(selLangPostScript) && selLangPostScript.contains(scriptKey)){
                            selLangPostScript = selLangPostScript.replace(scriptKey, mergeaFieldValuesMap.get(scriptKey) != null ? mergeaFieldValuesMap.get(scriptKey) : '');
                            sq.Survey_Questions__r[0].Post_Question_Script__c = selLangPostScript;
                        }
                        if(String.isNOtBlank(selLangQuesScript) && selLangQuesScript.contains(scriptKey)){
                            selLangQuesScript = selLangQuesScript.replace(scriptKey, mergeaFieldValuesMap.get(scriptKey) != null ? mergeaFieldValuesMap.get(scriptKey) : '');
                            sq.Survey_Questions__r[0].Question_Name__c = selLangQuesScript;
                        }
                    }
                    //}
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
            }


        }


        system.debug('== sd '+sd);

        return sd;
    }


    public static List<String> retrieveMergeFieldValue(String mergeFieldData){

        List<String> objectWithFieldList = new List<String>();

        Pattern regexPattern = Pattern.compile(REGEX);
        system.debug('regexPattern ' + regexPattern);
        system.debug('REGEX ' + REGEX);
        if(String.isNotBlank(mergeFieldData)){
            system.debug('mergeFieldData ' + mergeFieldData);
            Matcher matcherValue = regexPattern.matcher(mergeFieldData);
            system.debug('matcherValue ' + matcherValue);
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
        @AuraEnabled public Survey_Taker_CTI__c surveyTaker;
        @AuraEnabled public Campaign survey;
        @AuraEnabled public List<Survey_Question_CTI__c> quesIdWIthQuestionObjectList;
        @AuraEnabled public Map<String, List<Survey_Answer_CTI__c>> quesIdWIthAnwsersMap;
        @AuraEnabled public List<Survey_Response_CTI__c> responseList;
        @AuraEnabled public List<LanguageType> LanguageTypeList;
    }


    public Class LanguageType {
        @AuraEnabled public string label;
        @AuraEnabled public string value;
    }

    @AuraEnabled
    public static String submitSurveyResponse(String response, Boolean isCompleted, Survey_Question_CTI__c addressQuesData, Survey_Taker_CTI__c addressTakerData) {
        string errorMessage = '';
        Savepoint sp = Database.setSavepoint();

        system.debug('== response '+response);
        system.debug('== addressQuesData '+addressQuesData);
        system.debug('== addressTakerData '+addressTakerData);
        //String response1 = '[{"Response__c":"Yes","Survey_Question__c":"a1W1s000000BT5UEAW","Survey_Taker__c":"a1X1s0000004VXQ","Unique_ID__c":"a1X1s0000004VXQEA2a1W1s000000BT5UEAW"},{"Response__c":"Excellent","Survey_Question__c":"a1W1s000000BT5yEAG","Survey_Taker__c":"a1X1s0000004VXQ","Unique_ID__c":"a1X1s0000004VXQEA2a1W1s000000BT5yEAG"}]';
        if(string.isNotBlank(response)){

            List<Survey_Response_CTI__c> surveyResponseList = new List<Survey_Response_CTI__c>();

            List<Survey_Response_CTI__c> responseList = new List<Survey_Response_CTI__c>();
            responseList = (List<Survey_Response_CTI__c>)JSON.deserialize(response, List<Survey_Response_CTI__c>.class);
            system.debug('== responseList '+responseList);

            if(!responseList.isEmpty()){
                DateTime currentStamp = DateTime.Now();
                try{
                    if(addressQuesData!= null && addressQuesData.Id != null){
                        system.debug('== updateaddressQuesData '+addressQuesData);
                        update addressQuesData;
                    }
                        system.debug('== updateaddressQuesData @@@@'+addressQuesData);

                    Survey_Taker_CTI__c takerObj = [select id,Survey_Start_Time__c from Survey_Taker_CTI__c where id=:addressTakerData.Id limit 1];
                    addressTakerData.Survey_Start_Time__c = (takerObj.Survey_Start_Time__c == null) ? currentStamp : takerObj.Survey_Start_Time__c;
                    addressTakerData.Last_Agent__c = UserInfo.getUserId();
                    addressTakerData.Survey_Submitted_Time__c=currentStamp;
                    addressTakerData.Is_Completed__c = isCompleted;
                    update addressTakerData;
                    system.debug('== updateaddressTakerData '+addressTakerData);

                    /* update new Survey_Taker_CTI__c(
                        Id = responseList[0].Survey_Taker__c,
                        Survey_Submitted_Time__c = currentStamp, Is_Completed__c = isCompleted); */



                for(Survey_Response_CTI__c sr : responseList){
                    if(sr.Response_Submitted__c == null){
                        sr.Response_Submitted__c = currentStamp;
                    }
                    surveyResponseList.add(sr);
                }

                system.debug('== surveyResponseList '+surveyResponseList);

                Schema.SObjectField externalIdField = Survey_Response_CTI__c.Fields.Unique_ID__c;
                Database.UpsertResult[] srList = Database.upsert(surveyResponseList, externalIdField, false);

                }catch(DmlException e) {
                    for (Integer i = 0; i < e.getNumDml(); i ++) {
                        //Get Validation Rule & Trigger Error Messages
                        errorMessage =+ e.getDmlMessage(i) + '\n';
                    }
                }catch(Exception e){
                    errorMessage =+ e.getMessage() + '\n';
                }
                system.debug('== errorMessage '+errorMessage);
            }

        }

        system.debug('== errorMessage '+errorMessage);

        if(String.isNotBlank(errorMessage)){
            ExceptionHandler.stackTrace ehst=new ExceptionHandler.stackTrace(); ehst.componentName='Survey Taker Question LWC'; ehst.userId=UserInfo.getUserId(); ExceptionHandler.LogError('Survey Taker Question LWC CTRL', errorMessage, 'Survey Taker Question LWC Ctrl', '', ehst);
            return 'error';
        }

        return 'success';
    }


}