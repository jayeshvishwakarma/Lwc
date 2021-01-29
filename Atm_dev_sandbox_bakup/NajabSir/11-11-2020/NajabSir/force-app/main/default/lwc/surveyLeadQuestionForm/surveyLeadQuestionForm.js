import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getDetails from '@salesforce/apex/FetchLeadSurveyDetail.getDetails';
import submitSurveyResponse from '@salesforce/apex/FetchLeadSurveyDetail.submitSurveyResponse';
import retriveLookupResult from '@salesforce/apex/FetchLeadSurveyDetail.retriveLookupResult';
import fetchForCode from '@salesforce/apex/FetchLeadSurveyDetail.fetchForCode';
import { NavigationMixin } from 'lightning/navigation';
export default class SurveyLeadQuestionForm extends NavigationMixin(LightningElement) {
    @api recordId;
    // String type Variables
    header = '';
    subHeader = '';
    selectedModelLabel = '';
    variantName = '';
    dealerName = '';
    dealerCity = '';
    selectedCurrentModelLabel = '';
    vehicRegNum = '';
    dealerType = '';
    dealerCityId = '';
    thankYouMsg = '';
    channel = '';
    dealerQuestionId = '';
    makeType = '';
    customerType = '';
    selectedLanguage = 'English';
    selectedModelId = '';
    fuelType = '';
    // Undefined type Variables
    CompleteMsg;
    survey;
    lookupValueMap;
    selectedModel;
    forCodeList;
    @track selectedVariant;
    lookupDynamicContainerNumber;

    // Boolean type Variables
    isFormFinished = false;
    readOnlyMode = false;
    isResponseExist = false;
    isCEI = false;
    isAccordianLoading = false;
    isFollowUp = false;
    isModalOpen = false;
    isMsga = false;
    showAllQuesOnLoad = true;
    isLoading = true;

    // Array type Variables
    @track questionList = [];
    allQuestionList = [];
    isStartQuestionList = [];
    mapData = [];
    quesIdAnwsersListMap = [];
    allAvailableLanguage = [];

    // Map type Variables
    quesIdWIthAnwsersMap = new Map();
    quesIdVsResponse = new Map();
    quesNameVsQuesId = new Map();
    secNameVsQuesList = new Map();

    @wire(fetchForCode)
    wiredFetchForCode({ data, error }) {
        if (data) {
            this.forCodeList = data;
        } else {
            console.log('error===========', error);
        }
    }
    @wire(getDetails, { surveyTakerId: '$recordId', SelectedLang: '$selectedLanguage' })
    wiredUserList({ data, error }) {
        if (data && data.survey) {
            console.log('data: ', data);
            this.readOnlyMode = false;
            this.thankYouMsg = data.thankYouMsg;
            //this.CompleteMsg = '<br/><br/>Thank you Sir/Ma’am for your time and information, you were speaking with ' + data.userName + ', have a nice day.';
            this.survey = data.survey;
            this.isFollowUp = data.surveyTaker.Status.toLowerCase() == 'follow up' ? true : false;
            this.isCEI = (this.survey && this.survey.Type === 'CEI') ? true : false;
            // This is for autopopulate Registration number for enquiry
            this.vehicRegNum = data.surveyTaker.Reg_Num__c;
            //this.quesIdWIthAnwsersMap = data.quesIdWIthAnwsersMap;
            this.allQuestionList = data.quesIdWIthQuestionObjectList;
            // This is for all lookup type question values
            this.lookupValueMap = data.lookupJson !== undefined ? data.lookupJson : {};
            for (var key in data.quesIdWIthAnwsersMap) {
                this.quesIdAnwsersListMap.push({ key: key, value: data.quesIdWIthAnwsersMap[key] });
            }
            if (data.LanguageTypeList) {
                this.allAvailableLanguage = data.LanguageTypeList;
            }
            if (this.survey && this.survey.Question_type__c) {
                this.showAllQuesOnLoad = (this.survey.Question_type__c === 'Incremental') ? true : false;
            }
            // Making question's response for prepopulate form 
            for (let i = 0; i < data.responseList.length; i++) {
                let responseObj = data.responseList[i];
                let item = {};
                item.Response__c = responseObj.Response__c;
                item.Survey_Question__c = responseObj.Survey_Question__c;
                item.Lead__c = responseObj.Lead__c;
                item.Unique_ID__c = responseObj.Unique_ID__c;
                item.Answer_Type__c = responseObj.Survey_Question__r.Answer_Type__c;
                item.Lookup_Object_Name__c = responseObj.Survey_Question__r.Lookup_Object_Name__c;
                this.quesIdVsResponse.set(responseObj.Survey_Question__c, item);
                // If response records is not exist then need to hide thank you msg
                if (!responseObj.Survey_Question__r.isStart__c)
                    this.isResponseExist = true;
            }
            // If Lead survey is completed and Lead Score is "Deferred"
            // Then making the form desabled
            if (data.surveyTaker && data.surveyTaker.Is_Completed__c && data.surveyTaker.Lead_Score__c == 'Deferred') {
                this.readOnlyMode = data.surveyTaker.Is_Completed__c;
            }
            // Checking lead is MSGA or not
            if (data.surveyTaker && data.surveyTaker.Upsell_Cross_Sell_Tele_Caller__c && data.surveyTaker.Upsell_Cross_Sell_Tele_Caller__c.includes("MSGA")) {
                this.isMsga = true;
            }
            // Making form 
            if (data.quesIdWIthAnwsersMap && data.quesIdWIthQuestionObjectList) {
                let increment = 1;
                for (var value of data.quesIdWIthQuestionObjectList) {
                    let ques = value;
                    let answerData = {};
                    let optionValue = [];
                    let secName;
                    this.quesNameVsQuesId.set(ques.Name, ques.Id);
                    let ansList = this.quesIdAnwsersListMap.find((item) => item.key === ques.Id);
                    if (ques.isStart__c) {
                        this.isStartQuestionList.push(ques);
                    }
                    // Making Option values for Radio Button, Picklist (DropDown) and Multi Select type questions
                    if (ques && ques.Answer_Type__c === 'Radio Button' || ques.Answer_Type__c === 'Picklist (DropDown)' || ques.Answer_Type__c === 'Multi Select') {
                        for (var ans of ansList.value) {
                            optionValue.push({
                                label: ans.Survey_Answers__r ? ans.Survey_Answers__r[0].Display_Value__c : ans.Display_Value__c,
                                value: ans.Actual_Value__c
                            });

                        }
                    }

                    answerData.questionId = ques.Id;
                    answerData.options = optionValue;
                    //answerData.answerList = ques.Survey_Answers__r;
                    answerData.isTextarea = ques.Answer_Type__c === 'Text Area' ? true : false;
                    answerData.isRadio = ques.Answer_Type__c === 'Radio Button' ? true : false;
                    answerData.isPicklist = ques.Answer_Type__c === 'Picklist (DropDown)' ? true : false;
                    answerData.isMultiPicklist = ques.Answer_Type__c === 'Multi Select' ? true : false;
                    answerData.isText = ques.Answer_Type__c === 'Text' ? true : false;
                    answerData.isDate = ques.Answer_Type__c === 'Date' ? true : false;
                    answerData.isLookup = ques.Answer_Type__c === 'Lookup' ? true : false;
                    // Dealer lookup we are using seprate component 
                    answerData.isDealerLookup = ques.Answer_Type__c === 'Lookup' && ques.Target_Field__c === 'Enquiry_Dealership__c' ? true : false;
                    this.quesIdWIthAnwsersMap.set(ques.Id, answerData);
                    if (!this.showAllQuesOnLoad) {
                        if (ques.isStart__c && !ques.Section__c) {
                            secName = 'IsStart';
                        } else if (ques.Is_End__c && !ques.Section__c) {
                            secName = 'IsEnd';
                        } else if (!ques.Section__c) {
                            secName = 'blank';
                        } else {
                            secName = ques.Section__c;
                        }
                        if (!this.secNameVsQuesList.has(secName)) {
                            this.secNameVsQuesList.set(secName, []);
                        }
                        let secQuesList = this.addQuestions(ques, increment);
                        this.secNameVsQuesList.get(secName).push(secQuesList);
                    }
                    increment++;
                }
            }
            if (!this.showAllQuesOnLoad) {
                for (let secKey of this.secNameVsQuesList.keys()) {
                    let singleSectionObj = {};
                    singleSectionObj.name = secKey;
                    singleSectionObj.showData = false;
                    if (secKey !== 'blank' && secKey !== 'IsStart' && secKey !== 'IsEnd') {
                        singleSectionObj.showAccordian = true;
                    } else {
                        singleSectionObj.showAccordian = false;
                        singleSectionObj.showData = true;
                    }
                    singleSectionObj.value = this.secNameVsQuesList.get(secKey);
                    this.mapData.push(singleSectionObj);
                }
            } else {
                let count = 1;
                for (let i = 0; i < this.isStartQuestionList.length; i++) {
                    let currentItem = this.isStartQuestionList[i];
                    if (this.isCEI && i === (this.isStartQuestionList.length - 1)) {
                        this.applicableCEIQuesId = currentItem.Id;
                        if (this.isResponseExist && this.quesIdVsResponse.has(this.applicableCEIQuesId)) {
                            let responseObj = this.quesIdVsResponse.get(this.applicableCEIQuesId);
                            this.applicableCEIValue = responseObj.Response__c;
                        }
                    }
                    this.addQuestions(currentItem, count);
                    count++;
                }
            }
            this.header = this.survey.Name;
            this.subHeader = this.survey.Sub_Header__c;
            this.isLoading = false;
        } else if (error) {
            this.isLoading = false;
            console.log('== User error ', error);
        } else {
            this.isLoading = false;
        }
    }
    addQuestions(quesObj, srNum) {
        let objectName = {};
        let responseValue;
        let responseObj;
        let resposeData;
        if (this.quesIdVsResponse.has(quesObj.Id)) {
            responseObj = this.quesIdVsResponse.get(quesObj.Id);
            if (responseObj.Response__c && (responseObj.Answer_Type__c === 'Multi Select' || responseObj.Response__c.includes(','))) {
                resposeData = responseObj.Response__c.split(',');
            } else if (responseObj.Response__c && responseObj.Answer_Type__c === 'Lookup' && responseObj.Lookup_Object_Name__c) {
                if (responseObj.Response__c in this.lookupValueMap) {
                    resposeData = JSON.parse(this.lookupValueMap[responseObj.Response__c]);
                    // We are using seperate component for dealer so we are pulling Dealer name
                    if (quesObj.Target_Field__c === 'Enquiry_Dealership__c') {
                        resposeData = resposeData[0].title;
                    }
                    // Getting Variant id
                    else if (quesObj.Target_Field__c === 'Variant__c' || quesObj.Target_Field__c === 'TV_Variant__c') {
                        this.selectedVariant = resposeData[0].id;
                        console.log('variant: ', this.selectedVariant);
                    }
                }
            } else {
                resposeData = responseObj.Response__c;
                if (quesObj.Target_Field__c == 'Enq_Model__c') {// Getting enquiry model
                    this.selectedModel = resposeData;
                } else if (quesObj.Target_Field__c == 'Enquiry_Dealer_Type__c') {// Getting dealer type
                    this.dealerType = resposeData;
                } else if (quesObj.Target_Field__c == 'Make__c') {// Getting make type
                    this.makeType = resposeData;
                } else if (quesObj.Target_Field__c == 'Enquiry_Fuel_Type__c') {
                    this.fuelType = resposeData;
                }
            }
        } else {
            // Assigning Sales reg. num. to enquiry reg. num.
            if (this.vehicRegNum != '' && quesObj.Target_Field__c == 'Enq_Vehic_Reg_Num__c') {
                resposeData = this.vehicRegNum;
            }
        }
        responseValue = resposeData;
        if (this.allQuestionList) {
            objectName.srNum = srNum;
            let ques = {};
            ques.Id = quesObj.Id;
            ques.Target_Field__c = quesObj.Target_Field__c ? quesObj.Target_Field__c : '';
            ques.Is_Required__c = quesObj.Is_Required__c;
            ques.Where_Clause__c = quesObj.Where_Clause__c;
            ques.Lookup_Object_Name__c = quesObj.Lookup_Object_Name__c;
            ques.Pre_Question_Script__c = quesObj.Survey_Questions__r && quesObj.Survey_Questions__r[0].Pre_Question_Script__c ? quesObj.Survey_Questions__r[0].Pre_Question_Script__c : quesObj.Pre_Question_Script__c;
            ques.Question_Name__c = quesObj.Survey_Questions__r ? quesObj.Survey_Questions__r[0].Question_Name__c : quesObj.Question_Name__c;
            ques.Post_Question_Script__c = quesObj.Survey_Questions__r && quesObj.Survey_Questions__r[0].Post_Question_Script__c ? quesObj.Survey_Questions__r[0].Post_Question_Script__c : quesObj.Post_Question_Script__c;
            ques.hasNextQues = true;
            // Dynamic changing content based on value select
            if (ques.Post_Question_Script__c !== undefined && ques.Post_Question_Script__c != '') {
                if (ques.Post_Question_Script__c.includes('<span class=Enq_Model__c>')) {
                    if (this.selectedModelLabel != '')
                        ques.Post_Question_Script__c = ques.Post_Question_Script__c.replace(/<span class=Enq_Model__c>[\s\S]*?<\/span>/, '<span class=Enq_Model__c>' + this.selectedModelLabel + '<\/span>');
                    if (this.variantName != '')
                        ques.Post_Question_Script__c = ques.Post_Question_Script__c.replace(/<span class=Variant__r.Name>[\s\S]*?<\/span>/, '<span class=Variant__r.Name>' + this.variantName + '<\/span>');
                    if (this.dealerName != '') {
                        ques.Post_Question_Script__c = ques.Post_Question_Script__c.replace(/<span class=Enquiry_Dealership__r.Name>[\s\S]*?<\/span>/, '<span class=Enquiry_Dealership__r.Name>' + this.dealerName + '<\/span>');
                        ques.Post_Question_Script__c = ques.Post_Question_Script__c.replace(/<span class=Enquiry_Dealership__r.Name1>[\s\S]*?<\/span>/, '<span class=Enquiry_Dealership__r.Name1>' + this.dealerName + '<\/span>');
                    }

                    if (this.dealerCity != '')
                        ques.Post_Question_Script__c = ques.Post_Question_Script__c.replace(/<span class=Enquiry_Dealer_City__r.Name>[\s\S]*?<\/span>/, '<span class=Enquiry_Dealer_City__r.Name>' + this.dealerCity + '<\/span>');
                    this.lookupDynamicContainerNumber = srNum - 1;
                }
            }
            if (ques.Pre_Question_Script__c !== undefined && ques.Pre_Question_Script__c != '') {
                if (ques.Pre_Question_Script__c.includes('<span class=sales-model>')) {
                    if (this.selectedCurrentModelLabel != '')
                        ques.Pre_Question_Script__c = ques.Pre_Question_Script__c.replace(/<span class=sales-model>[\s\S]*?<\/span>/, '<span class=sales-model>' + this.selectedCurrentModelLabel + '<\/span>');

                }
                if (!this.isFollowUp && ques.Pre_Question_Script__c.includes('<span class=follow-up>')) {
                    ques.Pre_Question_Script__c = ques.Pre_Question_Script__c.replace(/<span class=follow-up>[\s\S]*?<\/span>/, '<span class=follow-up><\/span>');
                }
            }
            if (ques.Question_Name__c == undefined || ques.Question_Name__c == '') {
                ques.hasNextQues = false;
            }
            objectName.ques = ques;
            if (this.quesIdWIthAnwsersMap) {
                let answerDetails = this.quesIdWIthAnwsersMap.get(quesObj.Id);
                if (answerDetails) {
                    objectName.isTextarea = answerDetails.isTextarea;
                    objectName.isText = answerDetails.isText;
                    objectName.isDate = answerDetails.isDate;
                    objectName.isLookup = answerDetails.isLookup;
                    objectName.isDealerLookup = answerDetails.isDealerLookup;
                    objectName.isRadio = answerDetails.isRadio;
                    objectName.isPicklist = answerDetails.isPicklist;
                    objectName.isMultiPicklist = answerDetails.isMultiPicklist;
                    objectName.answerOptions = answerDetails.options;
                    objectName.selectedValue = responseValue;
                }
            }
            this.questionList.push(objectName);
            if (this.showAllQuesOnLoad === false) {
                return objectName;
            }
            if (this.isResponseExist && responseObj && this.showAllQuesOnLoad) {
                this.addNextQues(responseObj.Survey_Question__c, responseValue);
            }
        }
        return null;
    }

    addNextQues(quesId, selectedValue) {
        let currentQuestion = this.allQuestionList.find((item) => item.Id === quesId);
        let nextQuestionId;
        let ansList = this.quesIdAnwsersListMap.find((item) => item.key === quesId);
        if (ansList) {
            for (var ans of ansList.value) {
                if (currentQuestion.Answer_Type__c === 'Text Area' || currentQuestion.Answer_Type__c === 'Text' || currentQuestion.Answer_Type__c === 'Date') {
                    nextQuestionId = ans.Next_Question__c;
                    break;
                }
                else if (ans.Actual_Value__c === selectedValue) {
                    // If TV is No and lead is not msga then thank you msg should be shown else next question should be
                    if (currentQuestion.Target_Field__c == 'Interested_in_TV__c' && ((selectedValue == 'No' && this.isMsga) || selectedValue == 'Yes')) {
                        nextQuestionId = ans.Next_Question__c;
                        this.CompleteMsg = undefined;
                        // If selected values is yes then dealer type should be TV
                        if (selectedValue == 'Yes') {
                            this.dealerType = 'TV';
                        }
                        break;
                    } else if (currentQuestion.Target_Field__c == 'Interested_in_TV__c' && selectedValue == 'No' && !this.isMsga) {
                        this.CompleteMsg = '<br/>' + this.thankYouMsg;
                        break;
                    } else if (currentQuestion.Target_Field__c != 'Interested_in_TV__c') {
                        nextQuestionId = ans.Next_Question__c;
                        break;
                    }
                }
            }
        }
        let nextQuestionList;
        if (nextQuestionId) {
            nextQuestionList = nextQuestionId.split(',');
            for (var nextque of nextQuestionList) {
                let nextQId = this.quesNameVsQuesId.get(nextque);
                let nextQuestion = this.allQuestionList.find((item) => item.Id === nextQId);
                if (nextQuestion) {
                    this.isFormFinished = false;
                    this.addQuestions(nextQuestion, (this.questionList.length + 1));
                }
            }
        } else {
            this.isFormFinished = true;
        }
        this.isLoading = false;
    }

    handleLanguageChange(event) {
        this.isLoading = true;
        this.isFormFinished = false;
        this.mapData = [];
        this.questionList = [];
        this.allQuestionList = [];
        this.isStartQuestionList = [];
        this.allAvailableLanguage = [];
        this.quesIdAnwsersListMap = [];
        this.quesIdVsResponse = new Map();
        this.quesNameVsQuesId = new Map();
        this.secNameVsQuesList = new Map();
        this.selectedLanguage = event.target.value;
    }

    handleChange(event) {
        this.isResponseExist = false;
        this.isLoading = true;
        let quesId;
        let selectedValue;
        if (event.target.name) {
            quesId = event.target.name;
        }
        if (event.target.value) {
            selectedValue = event.target.value;
        }
        if (this.isCEI) {
            this.applicableCEIValue = (this.applicableCEIQuesId === quesId) ? selectedValue : this.applicableCEIValue;
        }
        let selectedIndx = event.currentTarget.getAttribute("data-key");
        if (selectedValue && typeof selectedValue === 'object') {
            let actualValue = '';
            let selectedData = JSON.stringify(selectedValue);
            actualValue = JSON.parse(selectedData).join();
            selectedValue = actualValue;
        }
        let currentQuestion = this.allQuestionList.find((item) => item.Id === quesId);
        const targetFieldName = event.currentTarget.dataset.field;
        if (!this.quesIdVsResponse.has(quesId)) {
            let responseObj = {};
            responseObj.Response__c = selectedValue;
            responseObj.Survey_Question__c = quesId;
            responseObj.Lead__c = this.recordId;
            responseObj.Unique_ID__c = this.recordId + (targetFieldName !== undefined && targetFieldName !== '' ? '_-_' + targetFieldName : '');
            this.quesIdVsResponse.set(quesId, responseObj);
        }
        // Deleting all unrelated question which has been created
        else if (!(currentQuestion.isStart__c && (selectedIndx != (this.isStartQuestionList.length - 1)))) {
            let responseObj = this.quesIdVsResponse.get(quesId);
            responseObj.Response__c = selectedValue;
            this.quesIdVsResponse.set(quesId, responseObj);
            let removedElement = parseInt(this.questionList.length) - (parseInt(selectedIndx) + parseInt(1));
            let queslength = parseInt(this.questionList.length);
            for (let i = 0; i < removedElement; i++) {
                let removeInd = parseInt(queslength) - (parseInt(i) + parseInt(1));
                let mapkey = this.questionList[removeInd].ques.Id;
                this.quesIdVsResponse.delete(mapkey);
                this.questionList.pop();
            }
        } else if (this.quesIdVsResponse.has(quesId)) {
            let responseObj = this.quesIdVsResponse.get(quesId);
            responseObj.Response__c = selectedValue;
            this.quesIdVsResponse.set(quesId, responseObj);
        }
        if (this.showAllQuesOnLoad) {
            if (this.isCEI && (!(currentQuestion.isStart__c && (selectedIndx != (this.isStartQuestionList.length - 1))))) {
                let selQues;
                let startIndex = parseInt(selectedIndx) + parseInt(1);
                for (let i = startIndex; i < this.allQuestionList.length; i++) {
                    let tmpQues = this.allQuestionList[i];
                    let nextQuesApplicableValues = tmpQues.Applicability_of_Scnerios__c ? tmpQues.Applicability_of_Scnerios__c.split(';') : '';
                    if (nextQuesApplicableValues.includes(this.applicableCEIValue)) {
                        let prevIndex = parseInt(i) - parseInt(1);
                        selQues = this.allQuestionList[prevIndex];
                        break;
                    }
                }
                if (selQues) {
                    this.addNextQues(selQues.Id, selectedValue);
                }
            } else {
                this.addNextQues(quesId, selectedValue);
            }
            // Variant and color should be empty if Enq_model get changed
            if (targetFieldName !== undefined && targetFieldName == 'Enq_Model__c') {
                const modelOptions = event.target.options;
                setTimeout(() => {
                    this.selectedModel = selectedValue;
                    this.selectedModelLabel = modelOptions.find(opt => opt.value === selectedValue).label;
                    const variantIndx = parseInt(selectedIndx) + 1;
                    //const colorIndex = variantIndx + 1;
                    this.template.querySelector('[data-key="' + variantIndx + '"]').setSelection([]);
                    //this.template.querySelector('[data-key="' + colorIndex + '"]').setSelection([]);
                }, 100);
            } else if (targetFieldName == 'Purchase_Interest__c') {
                if (selectedValue == 'H')//<= 1 month
                    this.customerType = 'Hot';
                else if (selectedValue == 'W')//1-2 months
                    this.customerType = 'Warm';
                else if (selectedValue == 'C')//1-2 months
                    this.customerType = 'Cold';
                else
                    this.customerType = 'Deferred';

                if (this.questionList[parseInt(selectedIndx)].ques.Post_Question_Script__c.includes('<span class=customer-type>')) {
                    this.questionList[parseInt(selectedIndx)].ques.Post_Question_Script__c = this.questionList[parseInt(selectedIndx)].ques.Post_Question_Script__c.replace(/<span class=customer-type>[\s\S]*?<\/span>/, '<span class=customer-type>' + this.customerType + '<\/span>');
                }
            } else if (targetFieldName !== undefined && targetFieldName == 'Current_Model__c') {
                this.selectedCurrentModelLabel = event.target.options.find(opt => opt.value === selectedValue).label
            } else if (targetFieldName !== undefined && targetFieldName == 'Enquiry_Dealer_Type__c') {
                this.dealerType = selectedValue;
            }
            // Model and Variant should be empty if Make type get changed
            else if (targetFieldName !== undefined && targetFieldName == 'Make__c') {
                this.makeType = selectedValue;
                setTimeout(() => {
                    const modelIndx = parseInt(selectedIndx) + 1;
                    const variantIndex = modelIndx + 1;
                    this.template.querySelector('[data-key="' + modelIndx + '"]').setSelection([]);
                    this.template.querySelector('[data-key="' + variantIndex + '"]').setSelection([]);
                }, 100);
            }
            else if (targetFieldName !== undefined && targetFieldName == 'Enquiry_Fuel_Type__c') {
                this.fuelType = selectedValue;
            } else if (targetFieldName !== undefined && targetFieldName == 'Interested_in_MSGA__c') {
                // For MSGA Variant should be empty because dealer filter should be without variant in MSGA
                this.selectedVariant = undefined;
            }
        }
        this.isLoading = false;
    }
    onBlurHandler(event) {
        this.isLoading = true;
        let quesId;
        let selectedValue;
        if (event.target.name) {
            quesId = event.target.name;
        }
        if (event.target.value) {
            selectedValue = event.target.value;
        }
        let selectedIndx = event.currentTarget.getAttribute("data-key");
        const targetFieldName = event.currentTarget.dataset.field;
        if (!this.quesIdVsResponse.has(quesId)) {
            let responseObj = {};
            responseObj.Response__c = selectedValue;
            responseObj.Survey_Question__c = quesId;
            responseObj.Lead__c = this.recordId;
            responseObj.Unique_ID__c = this.recordId + (targetFieldName !== undefined && targetFieldName !== '' ? '_-_' + targetFieldName : '');
            this.quesIdVsResponse.set(quesId, responseObj);
            let currentQuestion = this.allQuestionList.find((item) => item.Id === quesId);
            let nextQuestionId;
            let ansList = this.quesIdAnwsersListMap.find((item) => item.key === quesId);
            if (ansList) {
                for (var ans of ansList.value) {
                    nextQuestionId = ans.Next_Question__c;
                }
            }
            let nextQuestionList;
            if (nextQuestionId) {
                nextQuestionList = nextQuestionId.split(',');
                for (var nextque of nextQuestionList) {
                    let nextQId = this.quesNameVsQuesId.get(nextque);
                    let nextQuestion = this.allQuestionList.find((item) => item.Id === nextQId);
                    if (nextQuestion) {
                        this.isFormFinished = false;
                        this.addQuestions(nextQuestion, (this.questionList.length + 1));
                    }
                }
            } else {
                this.isFormFinished = true;
            }

        } else {
            let responseObj = this.quesIdVsResponse.get(quesId);
            responseObj.Response__c = selectedValue;
            this.quesIdVsResponse.set(quesId, responseObj);
        }
        this.isLoading = false;
    }

    handleAccordianChange(event) {
        this.isAccordianLoading = true;
        let selectedIndx = event.currentTarget.getAttribute("data-key");
        let singleObj = this.mapData[selectedIndx];
        singleObj.showData = !singleObj.showData;
        this.mapData[selectedIndx] = singleObj;
        this.isAccordianLoading = false;
    }
    handleCustomSearch(event) {
        const objectAPIName = event.currentTarget.dataset.objectname;
        const targetFieldName = event.currentTarget.dataset.field;
        let query = event.currentTarget.dataset.query !== undefined ? event.currentTarget.dataset.query : '';
        let fields = 'Name';
        if (objectAPIName == 'Product2' && targetFieldName == 'TV_Variant__c') {
            query += ' AND Model_Master_LKP__c =\'' + this.selectedModelId + '\'';
        } else if (objectAPIName == 'Product2') {
            query += ' AND Model__c =\'' + this.selectedModel + '\' AND Enquiry__c = \'Yes\' AND Fuel_Type__c =\'' + this.fuelType + '\'';
        } else if (objectAPIName == 'Model_Master__c') {
            query += ' AND Make_Type__c =\'' + this.makeType + '\'';
            fields += ', Model_Code__c';
        }
        /*else if (objectAPIName == 'Color_Variant_Master__c') {
            query += ' AND Variant__c =\'' + this.selectedVariant + '\'';
        } else if (objectAPIName == 'Account') {
            query += ' AND Dealer_Type__c =\'' + this.dealerType + '\' AND For_Code__c =\'' + this.dealerCityId + '\'';
        }*/
        retriveLookupResult({
            objectName: objectAPIName,
            fields: fields,
            name: event.detail.searchTerm,
            queryConditions: query
        })
            .then(result => {
                //console.log('== == ON Custom Search 3 Result ', result);
                this.records = result;
                let formatedResult = [];
                if (result) {
                    for (let data of result) {
                        if (data) {
                            let obj = { id: data.Id, title: data.Name };
                            // If Lookup type is Model Master then we need Model code for variant filter
                            if (objectAPIName == 'Model_Master__c' && 'Model_Code__c' in data) {
                                obj['Model_Code__c'] = data.Model_Code__c;
                            }
                            formatedResult.push(obj);
                        }
                    }
                }
                if (formatedResult) {
                    this.template.querySelector('[data-field="' + targetFieldName + '"]').updateSearchResults(formatedResult);
                }

            }).catch(error => {
                console.log('== == ON Custom Search 3 Error ', error);
            })

    }

    handleLookup(event) {
        const targetFieldName = event.currentTarget.dataset.field;
        const questionId = event.currentTarget.name;
        let selectedIndx = parseInt(event.currentTarget.getAttribute("data-key"));
        if (event.detail.value) {
            const selectedRecordId = event.detail.value;
            const selectedLookup = this.template.querySelector('[data-key="' + selectedIndx + '"]').getData();
            if (targetFieldName !== undefined && (targetFieldName == 'Variant__c' || targetFieldName == 'TV_Variant__c')) {
                this.selectedVariant = selectedRecordId;
                console.log('Variant lookup: ', this.selectedVariant);
                /*if (selectedLookup.selection)
                    this.variantName = selectedLookup.selection[0].title;*/
            } else if (targetFieldName !== undefined && targetFieldName == 'Model__c') {
                if (selectedLookup.selection && selectedLookup.selection.length > 0 && 'Model_Code__c' in selectedLookup.selection[0]) {
                    this.selectedModel = selectedLookup.selection[0].Model_Code__c;
                }
                this.selectedModelId = selectedRecordId;
            }
            /*else if (targetFieldName !== undefined && targetFieldName == 'Enquiry_Dealership__c') {
               if (selectedLookup.selection)
                   this.dealerName = selectedLookup.selection[0].title;
               if (this.lookupDynamicContainerNumber && this.questionList.length > this.lookupDynamicContainerNumber) {
                   this.questionList[this.lookupDynamicContainerNumber].ques.Post_Question_Script__c = this.questionList[this.lookupDynamicContainerNumber].ques.Post_Question_Script__c.replace(/<span class=Enquiry_Dealership__r.Name>[\s\S]*?<\/span>/, '<span class=Enquiry_Dealership__r.Name>' + this.dealerName + '<\/span>');
                   this.questionList[this.lookupDynamicContainerNumber].ques.Post_Question_Script__c = this.questionList[this.lookupDynamicContainerNumber].ques.Post_Question_Script__c.replace(/<span class=Enquiry_Dealership__r.Name1>[\s\S]*?<\/span>/, '<span class=Enquiry_Dealership__r.Name1>' + this.dealerName + '<\/span>');
               }
            }else if (targetFieldName !== undefined && targetFieldName == 'Enquiry_Dealer_City__c') {
               this.dealerCityId = selectedRecordId;
               if (selectedLookup.selection)
                   this.dealerCity = selectedLookup.selection[0].title;
               if (this.lookupDynamicContainerNumber && this.questionList.length > this.lookupDynamicContainerNumber)
                   this.questionList[this.lookupDynamicContainerNumber].ques.Post_Question_Script__c = this.questionList[this.lookupDynamicContainerNumber].ques.Post_Question_Script__c.replace(/<span class=Enquiry_Dealer_City__r.Name>[\s\S]*?<\/span>/, '<span class=Enquiry_Dealer_City__r.Name>' + this.dealerCity + '<\/span>');
            }*/
            if (!this.quesIdVsResponse.has(questionId)) {
                let responseObj = {};
                responseObj.Response__c = selectedRecordId;
                responseObj.Survey_Question__c = questionId;
                responseObj.Lead__c = this.recordId;
                responseObj.Unique_ID__c = this.recordId + (targetFieldName !== undefined && targetFieldName !== '' ? '_-_' + targetFieldName : '');
                this.quesIdVsResponse.set(questionId, responseObj);
            } else {
                let responseObj = this.quesIdVsResponse.get(questionId);
                responseObj.Response__c = selectedRecordId;
                this.quesIdVsResponse.set(questionId, responseObj);
            }
        } else if (event.detail.value === undefined) {
            if (this.quesIdVsResponse.has(questionId)) {
                this.quesIdVsResponse.delete(questionId);
                if (targetFieldName !== undefined && targetFieldName == 'Model__c') {
                    this.resetLookup((selectedIndx + 1));
                    this.selectedModel = '';
                }
                /*if (targetFieldName !== undefined && targetFieldName == 'Variant__c') {
                    selectedIndx = selectedIndx + 1;
                    this.questionList[selectedIndx].selectedValue = null;
                    let quesId = this.template.querySelector('[data-key="' + selectedIndx + '"]').getAttribute("data-questionid");
                    if (this.quesIdVsResponse.has(quesId)) {
                        this.quesIdVsResponse.delete(quesId);
                    }
                    this.template.querySelector('[data-key="' + selectedIndx + '"]').setSelection([]);
                    this.variantName = '';
                } elseif (targetFieldName !== undefined && targetFieldName == 'Enquiry_Dealership__c') {
                    this.dealerName = '';
                    if (this.lookupDynamicContainerNumber && this.questionList.length > this.lookupDynamicContainerNumber) {
                        this.questionList[this.lookupDynamicContainerNumber].ques.Post_Question_Script__c = this.questionList[this.lookupDynamicContainerNumber].ques.Post_Question_Script__c.replace(/<span class=Enquiry_Dealership__r.Name>[\s\S]*?<\/span>/, '<span class=Enquiry_Dealership__r.Name>' + this.dealerName + '<\/span>');
                        this.questionList[this.lookupDynamicContainerNumber].ques.Post_Question_Script__c = this.questionList[this.lookupDynamicContainerNumber].ques.Post_Question_Script__c.replace(/<span class=Enquiry_Dealership__r.Name1>[\s\S]*?<\/span>/, '<span class=Enquiry_Dealership__r.Name1>' + this.dealerName + '<\/span>');
                    }


                } else if (targetFieldName !== undefined && targetFieldName == 'Enquiry_Dealer_City__c') {
                    this.dealerCity = '';
                    if (this.lookupDynamicContainerNumber && this.questionList.length > this.lookupDynamicContainerNumber)
                        this.questionList[this.lookupDynamicContainerNumber].ques.Post_Question_Script__c = this.questionList[this.lookupDynamicContainerNumber].ques.Post_Question_Script__c.replace(/<span class=Enquiry_Dealer_City__r.Name>[\s\S]*?<\/span>/, '<span class=Enquiry_Dealer_City__r.Name>' + this.dealerCity + '<\/span>');
                }*/
            }

        }
        this.isLoading = false;
    }
    resetLookup(selectedIndx) {
        this.questionList[selectedIndx].selectedValue = null;
        let quesId = this.template.querySelector('[data-key="' + selectedIndx + '"]').getAttribute("data-questionid");
        if (this.quesIdVsResponse.has(quesId)) {
            this.quesIdVsResponse.delete(quesId);
        }
        this.template.querySelector('[data-key="' + selectedIndx + '"]').setSelection([]);
    }
    saveSurvey() {
        this.handleSurveyResponse(false);
    }
    submitSurvey() {
        this.handleSurveyResponse(true);
    }
    handleSurveyResponse(isCompleted) {
        let isValid = Array.from(this.template.querySelectorAll('lightning-combobox,lightning-input'))
            .reduce((validSoFar, inputCmp) => {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);
        Array.from(this.template.querySelectorAll('c-lookup-input-field')).forEach((element) => {
            if (!element.reportValidity()) {
                isValid = false;
            }
        })
        if (isValid) {
            this.isLoading = true;
            let reponseList = [];
            for (let key of this.quesIdVsResponse.keys()) {
                let data = this.quesIdVsResponse.get(key);
                if (this.showAllQuesOnLoad) {
                    if (this.questionList.some(e => e.ques.Id === key)) {
                        reponseList.push(data);
                    }
                } else {
                    this.mapData.forEach(item => {
                        if (item.value.some(e => e.ques.Id === key)) {
                            reponseList.push(data);
                        }
                    });
                }
            }
            submitSurveyResponse({
                response: JSON.stringify(reponseList),
                isCompleted: isCompleted,
                leadId: this.recordId
            }).then(result => {
                if (result === 'success') {
                    if (isCompleted && this.customerType == 'Deferred') {
                        this.readOnlyMode = true;
                    } else if (this.customerType != 'Hot') { // Making detail page refresh except Lead convert
                        eval("$A.get('e.force:refreshView').fire();");
                    }
                    let successStr = isCompleted ? 'Your survey has been submitted successfully !' : 'Your survey has been save successfully !';
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Thank you for your valuable time',
                            message: successStr,
                            variant: 'success'
                        })
                    );
                    if (isCompleted) {
                        // Navigate to the Contact object's Recent list view.
                        this[NavigationMixin.Navigate]({
                            type: 'standard__objectPage',
                            attributes: {
                                objectApiName: 'Lead',
                                actionName: 'list'
                            },
                            state: {
                                // 'filterName' is a property on the page 'state'
                                // and identifies the target list view.
                                // It may also be an 18 character list view id.
                                filterName: 'Recent' // or by 18 char '00BT0000002TONQMA4'
                            }
                        });
                    }
                } else if (result === 'error') {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'Please contact to System Admin!',
                            variant: 'error'
                        })
                    );
                } else {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: result,
                            variant: 'error'
                        })
                    );
                }

                this.isLoading = false;
            }).catch(error => {
                this.isLoading = false;
                console.log('== error ', error);
            })
        } else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Review the errors on this page.',
                    variant: 'error'
                })
            );
        }
    }
    handleWorkshopLink(event) {
        this.isModalOpen = true;
        this.dealerQuestionId = event.currentTarget.dataset.id;
    }
    closeForCodeModal(event) {
        this.isModalOpen = false;
        this.dealerQuestionId = '';
    }
    selectDealerHandler(event) {
        const dealer = event.detail;
        try {
            if (!this.quesIdVsResponse.has(this.dealerQuestionId)) {
                let responseObj = {};
                responseObj.Response__c = dealer.Id;
                responseObj.Survey_Question__c = this.dealerQuestionId;
                responseObj.Lead__c = this.recordId;
                responseObj.Unique_ID__c = this.recordId + '_-_Enquiry_Dealership__c';
                this.quesIdVsResponse.set(this.dealerQuestionId, responseObj);
            } else {
                let responseObj = this.quesIdVsResponse.get(this.dealerQuestionId);
                responseObj.Response__c = dealer.Id;
                this.quesIdVsResponse.set(this.dealerQuestionId, responseObj);
            }
            let questionIndex = this.template.querySelector('[data-id=' + this.dealerQuestionId + ']').getAttribute("data-key");
            questionIndex = questionIndex != '' ? parseInt(questionIndex) : 0;
            if (questionIndex > 0 && this.questionList.length > questionIndex)
                this.questionList[questionIndex].selectedValue = dealer.Name;
            this.dealerName = dealer.Name;
            this.dealerCity = 'Name' in dealer.For_Code__r ? dealer.For_Code__r.Name : '';
            // Changing content
            if (this.lookupDynamicContainerNumber && this.questionList.length > this.lookupDynamicContainerNumber) {
                this.questionList[this.lookupDynamicContainerNumber].ques.Post_Question_Script__c = this.questionList[this.lookupDynamicContainerNumber].ques.Post_Question_Script__c.replace(/<span class=Enquiry_Dealership__r.Name>[\s\S]*?<\/span>/, '<span class=Enquiry_Dealership__r.Name>' + this.dealerName + '<\/span>');
                this.questionList[this.lookupDynamicContainerNumber].ques.Post_Question_Script__c = this.questionList[this.lookupDynamicContainerNumber].ques.Post_Question_Script__c.replace(/<span class=Enquiry_Dealership__r.Name1>[\s\S]*?<\/span>/, '<span class=Enquiry_Dealership__r.Name1>' + this.dealerName + '<\/span>');
                this.questionList[this.lookupDynamicContainerNumber].ques.Post_Question_Script__c = this.questionList[this.lookupDynamicContainerNumber].ques.Post_Question_Script__c.replace(/<span class=Enquiry_Dealer_City__r.Name>[\s\S]*?<\/span>/, '<span class=Enquiry_Dealer_City__r.Name>' + this.dealerCity + '<\/span>');
            }
        } catch (e) {
            console.error(e);
            console.error('e.name => ' + e.name);
            console.error('e.message => ' + e.message);
            console.error('e.stack => ' + e.stack);
        }
        this.isModalOpen = false;
    }
}