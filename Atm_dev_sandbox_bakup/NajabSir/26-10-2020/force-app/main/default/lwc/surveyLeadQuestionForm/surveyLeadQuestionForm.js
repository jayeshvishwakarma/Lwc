import { LightningElement, track, wire, api } from 'lwc';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getDetails from '@salesforce/apex/FetchLeadSurveyDetail.getDetails';
import submitSurveyResponse from '@salesforce/apex/FetchLeadSurveyDetail.submitSurveyResponse';
import retriveLookupResult from '@salesforce/apex/FetchLeadSurveyDetail.retriveLookupResult';

export default class SurveyLeadQuestionForm extends LightningElement {
    @api recordId;
    header = '';
    subHeader = '';

    @track questionList = [];
    isFormFinished = false;
    readOnlyMode = false;
    CompleteMsg = '';
    isResponseExist = false;

    quesIdWIthAnwsersMap = new Map();
    survey;
    allQuestionList = [];
    isStartQuestionList = [];
    quesIdVsResponse = new Map();
    quesNameVsQuesId = new Map();
    isLoading = true;
    isAccordianLoading = false;

    secNameVsQuesList = new Map();

    showAllQuesOnLoad = true;

    mapData = [];
    quesIdAnwsersListMap = [];
    selectedLanguage = 'English';
    allAvailableLanguage = [];

    lookupValueMap;
    isCEI = false;

    // New Edition 21.10.2020
    selectedModel;
    selectedVariant;
    isMsga = false;

    @wire(getDetails, { surveyTakerId: '$recordId', SelectedLang: '$selectedLanguage' })
    wiredUserList({ data, error }) {
        if (data && data.survey) {
            this.readOnlyMode = false;

            //console.log('== On load this.questionList ', this.questionList);
            //this.showForm = true;
            console.log('== User data ', data);
            this.CompleteMsg = '<br/><br/>Thank you Sir/Ma’am for your time and information, you were speaking with '+data.userName+', have a nice day.';
            this.survey = data.survey;

            this.isCEI = (this.survey && this.survey.Type === 'CEI') ? true : false;

            //this.quesIdWIthAnwsersMap = data.quesIdWIthAnwsersMap;
            this.allQuestionList = data.quesIdWIthQuestionObjectList;
            //this.quesIdVsResponse = JSON.parse(JSON.stringify(data.quesIdWIthRespon));
            // console.log("responseList@@", data.responseList);
            // console.log("quesIdWIthAnwsersMap@@", data.quesIdWIthAnwsersMap);
            // console.log("quesIdWIthQuestionObjectList@@", data.quesIdWIthQuestionObjectList);
            this.lookupValueMap = data.lookupJson !== undefined ? data.lookupJson : {};
            //console.log('this.lookupValueMap : ',this.lookupValueMap);
            //this.quesIdAnwsersListMap = JSON.parse(data.quesIdWIthAnwsersMap);

            for (var key in data.quesIdWIthAnwsersMap) {
                this.quesIdAnwsersListMap.push({ key: key, value: data.quesIdWIthAnwsersMap[key] });
            }
            //console.log('== this.quesIdAnwsersListMap ', this.quesIdAnwsersListMap);


            if (data.LanguageTypeList) {
                this.allAvailableLanguage = data.LanguageTypeList;
            }

            if (this.survey && this.survey.Question_type__c) {
                this.showAllQuesOnLoad = (this.survey.Question_type__c === 'Incremental') ? true : false;
            }
            //console.log('== this.survey.Question_type__c ', this.survey.Question_type__c);
            //console.log('== this.showAllQuesOnLoad ', this.showAllQuesOnLoad);
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
                this.isResponseExist = true;
            }

            // console.log('this.quesIdVsResponse===', this.quesIdVsResponse);
            // console.log('data.surveyTaker', data.surveyTaker);

            if (data.surveyTaker && data.surveyTaker.Is_Completed__c) {
                this.readOnlyMode = data.surveyTaker.Is_Completed__c;
            }
            if (data.surveyTaker && data.surveyTaker.Upsell_Cross_Sell_Tele_Caller__c && data.surveyTaker.Upsell_Cross_Sell_Tele_Caller__c.includes("MSGA")) {
                this.isMsga = true;
            }

            if (data.quesIdWIthAnwsersMap && data.quesIdWIthQuestionObjectList) {
                let increment = 1;
                for (var value of data.quesIdWIthQuestionObjectList) {
                    let ques = value;
                    //console.log('== each ques ', ques);
                    let answerData = {};
                    let optionValue = [];
                    let secName;
                    this.quesNameVsQuesId.set(ques.Name, ques.Id);
                    let ansList = this.quesIdAnwsersListMap.find((item) => item.key === ques.Id);
                    //console.log("== ansList@@", ansList);

                    if (ques.isStart__c) {
                        this.isStartQuestionList.push(ques);
                    }

                    if (ques && ques.Answer_Type__c === 'Radio Button' || ques.Answer_Type__c === 'Picklist (DropDown)' || ques.Answer_Type__c === 'Multi Select') {
                        for (var ans of ansList.value) {
                            //console.log("ans@@", ans);

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

                        //console.log('this.secNameVsQuesList===', this.secNameVsQuesList);
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
                // console.log('== this.isStartQuestionList ', this.isStartQuestionList);
                // console.log('== this.isStartQuestionList.length ', this.isStartQuestionList.length);

                for (let i = 0; i < this.isStartQuestionList.length; i++) {
                    let currentItem = this.isStartQuestionList[i];
                    //console.log('== currentItem.Id ===' + currentItem.Id);

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

            // console.log('== Final questionList', this.questionList);
            // console.log('this.mapData===', this.mapData);

            this.isLoading = false;
        } else if (error) {
            this.isLoading = false;
            console.log('== User error ', error);
        }else{
            this.isLoading = false;
            //this.readOnlyMode = true;
        }
    }

    addQuestions(quesObj, srNum) {

        let objectName = {};
        let responseValue;
        //console.log('== this.quesIdVsResponse ', this.quesIdVsResponse);
        let responseObj;
        let resposeData;
        if (this.quesIdVsResponse.has(quesObj.Id)) {
            responseObj = this.quesIdVsResponse.get(quesObj.Id);
            //responseObj.Unique_ID__c = quesObj.Target_Field__c;
            //this.quesIdVsResponse.set(quesObj.Id, responseObj);
            //console.log('== responseObj ', responseObj);
            if (responseObj.Response__c && (responseObj.Answer_Type__c === 'Multi Select' || responseObj.Response__c.includes(','))) {
                resposeData = responseObj.Response__c.split(',');
            } else if(responseObj.Response__c && responseObj.Answer_Type__c === 'Lookup' && responseObj.Lookup_Object_Name__c){
                // console.log('responseObj.Lookup_Object_Name__c',responseObj.Lookup_Object_Name__c);
                // console.log('responseObj.Response__c',responseObj.Response__c);
                if(responseObj.Response__c in this.lookupValueMap ){
                    resposeData = JSON.parse(this.lookupValueMap[responseObj.Response__c]);
                }
                //console.log('responseObj.Response__c',resposeData);
            }else {
                resposeData = responseObj.Response__c;
            }
        }
        responseValue = resposeData;
        // console.log('===resposeData ', resposeData);
        // console.log('===responseValue ', responseValue);

        if (this.allQuestionList) {
            objectName.srNum = srNum;
            /* if (quesObj.Survey_Questions__r) {
                let langQues = quesObj.Survey_Questions__r[0];

            } */
            let ques = {};
            ques.Id = quesObj.Id;
            ques.Target_Field__c = quesObj.Target_Field__c ? quesObj.Target_Field__c : '';
            ques.Is_Required__c = quesObj.Is_Required__c;
            ques.Where_Clause__c = quesObj.Where_Clause__c;
            ques.Lookup_Object_Name__c = quesObj.Lookup_Object_Name__c;
            ques.Pre_Question_Script__c = quesObj.Survey_Questions__r && quesObj.Survey_Questions__r[0].Pre_Question_Script__c ? quesObj.Survey_Questions__r[0].Pre_Question_Script__c : quesObj.Pre_Question_Script__c;
            ques.Question_Name__c = quesObj.Survey_Questions__r ? quesObj.Survey_Questions__r[0].Question_Name__c : quesObj.Question_Name__c;
            ques.Post_Question_Script__c = quesObj.Survey_Questions__r && quesObj.Survey_Questions__r[0].Post_Question_Script__c ? quesObj.Survey_Questions__r[0].Post_Question_Script__c : quesObj.Post_Question_Script__c;

            objectName.ques = ques;
            if (this.quesIdWIthAnwsersMap) {
                let answerDetails = this.quesIdWIthAnwsersMap.get(quesObj.Id);
                //console.log('== answerDetails ', answerDetails);
                if (answerDetails) {
                    objectName.isTextarea = answerDetails.isTextarea;
                    objectName.isText = answerDetails.isText;
                    objectName.isDate = answerDetails.isDate;
                    objectName.isLookup = answerDetails.isLookup;
                    objectName.isRadio = answerDetails.isRadio;
                    objectName.isPicklist = answerDetails.isPicklist;
                    objectName.isMultiPicklist = answerDetails.isMultiPicklist;
                    objectName.answerOptions = answerDetails.options;
                    objectName.selectedValue = responseValue;
                }

            }
            //console.log('== start In Add Ques questionList ', this.questionList);

            this.questionList.push(objectName);

            //console.log('== In Add Ques questionList ', this.questionList);

            if (this.showAllQuesOnLoad === false) {
                // console.log('== IN return Call');
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

        //console.log('== currentQuestion ', currentQuestion);
        let nextQuestionId;
        let ansList = this.quesIdAnwsersListMap.find((item) => item.key === quesId);
        //console.log("== ansList@@", ansList);
        if (ansList) {
            for (var ans of ansList.value) {
                if (currentQuestion.Answer_Type__c === 'Text Area' || currentQuestion.Answer_Type__c === 'Text' || currentQuestion.Answer_Type__c === 'Date') {
                    nextQuestionId = ans.Next_Question__c;
                    break;
                } 
                else if (ans.Actual_Value__c === selectedValue) {
                    if(currentQuestion.Target_Field__c == 'Interested_in_TV__c' && ((selectedValue == 'No' && this.isMsga) || selectedValue == 'Yes')){
                        nextQuestionId = ans.Next_Question__c;
                        break;
                    } else if(currentQuestion.Target_Field__c != 'Interested_in_TV__c' ){
                        nextQuestionId = ans.Next_Question__c;
                        break;
                    } 
                }
            }
        }
        //console.log('== nextQuestionId ', nextQuestionId);
        let nextQuestionList;
        if (nextQuestionId) {
            nextQuestionList = nextQuestionId.split(',');

            for (var nextque of nextQuestionList) {
                let nextQId = this.quesNameVsQuesId.get(nextque);
                //console.log('== nextQId ', nextQId);
                let nextQuestion = this.allQuestionList.find((item) => item.Id === nextQId);
                //console.log('== nextQuestion ', nextQuestion);
                if (nextQuestion) {
                    this.isFormFinished = false;
                    this.addQuestions(nextQuestion, (this.questionList.length + 1));
                }
            }
        }
        else {
            this.isFormFinished = true;
        }

        //console.log('== this.questionList ', this.questionList);
        this.isLoading = false;
    }

    handleLanguageChange(event) {
        //console.log('== IN lang CHange ', event.target.value);
        this.isLoading = true;

        this.questionList = [];
        this.allQuestionList = [];
        this.isStartQuestionList = [];
        this.quesIdVsResponse = new Map();
        this.quesNameVsQuesId = new Map();
        this.allAvailableLanguage = [];
        this.secNameVsQuesList = new Map();
        this.mapData = [];
        this.quesIdAnwsersListMap = [];
        this.isFormFinished = false;


        // console.log('== In this.questionList ', this.questionList);
        // console.log('== selected Language ', this.selectedLanguage);
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
        //console.log('== applicableCEIValue ', this.applicableCEIValue);

        let selectedIndx = event.currentTarget.getAttribute("data-key");
        // console.log('== quesId ', quesId);
        // console.log('== selectedValue ', selectedValue);
        // console.log('== typeof selectedValue ', typeof selectedValue);
        // console.log('== selectedIndx ', selectedIndx);
        // console.log('== this.quesIdVsResponse', this.quesIdVsResponse);
        // console.log('== this.quesIdVsResponse.has(quesId) ', this.quesIdVsResponse.has(quesId));

        if (selectedValue && typeof selectedValue === 'object') {
            let actualValue = '';
            let selectedData = JSON.stringify(selectedValue);
            actualValue = JSON.parse(selectedData).join();
            selectedValue = actualValue;
            //console.log('== selectedData ', selectedValue);
        }
        let currentQuestion = this.allQuestionList.find((item) => item.Id === quesId);
        const targetFieldName = event.currentTarget.dataset.field;
        //console.log('targetFieldName', targetFieldName);
        
        if (!this.quesIdVsResponse.has(quesId)) {
            let responseObj = {};
            responseObj.Response__c = selectedValue;
            responseObj.Survey_Question__c = quesId;
            responseObj.Lead__c = this.recordId;
            responseObj.Unique_ID__c = this.recordId + (targetFieldName !== undefined && targetFieldName !== '' ? '_-_' + targetFieldName : '');
            this.quesIdVsResponse.set(quesId, responseObj);
            //console.log('== quesIdVsResponse ', this.quesIdVsResponse);


        } else if (!(currentQuestion.isStart__c && (selectedIndx != (this.isStartQuestionList.length - 1)))) {
            let responseObj = this.quesIdVsResponse.get(quesId);
            responseObj.Response__c = selectedValue;
            this.quesIdVsResponse.set(quesId, responseObj);
            //console.log('== quesIdVsResponse@ ', this.quesIdVsResponse);
            let removedElement = parseInt(this.questionList.length) - (parseInt(selectedIndx) + parseInt(1));
            //console.log('== removedElement@ ', removedElement);
            let queslength = parseInt(this.questionList.length);

            for (let i = 0; i < removedElement; i++) {
                let removeInd = parseInt(queslength) - (parseInt(i) + parseInt(1));
                let mapkey = this.questionList[removeInd].ques.Id;
                this.quesIdVsResponse.delete(mapkey);
                this.questionList.pop();
            }


            // console.log('== After remove Ques Map ', this.quesIdVsResponse);
            // console.log('== this.questionList ', this.questionList);
        }

        if (this.showAllQuesOnLoad) {
            if (this.isCEI && (!(currentQuestion.isStart__c && (selectedIndx != (this.isStartQuestionList.length - 1))))) {
                let selQues;
                let startIndex = parseInt(selectedIndx) + parseInt(1);
                //console.log("===startIndex ", startIndex);
                for (let i = startIndex; i < this.allQuestionList.length; i++) {
                    let tmpQues = this.allQuestionList[i];
                    //console.log("===tmpQues ", tmpQues);

                    let nextQuesApplicableValues = tmpQues.Applicability_of_Scnerios__c ? tmpQues.Applicability_of_Scnerios__c.split(';') : '';
                    // console.log("===nextQuesApplicableValues ", nextQuesApplicableValues);
                    // console.log("===nextQuesApplicableValues.includes ", nextQuesApplicableValues.includes(this.applicableCEIValue));
                    if (nextQuesApplicableValues.includes(this.applicableCEIValue)) {
                        let prevIndex = parseInt(i) - parseInt(1);
                        selQues = this.allQuestionList[prevIndex];
                        break;
                    }

                }
                if (selQues) {
                    //console.log('===selQues ', selQues);
                    this.addNextQues(selQues.Id, selectedValue);
                }
            } else {
                this.addNextQues(quesId, selectedValue);
            }
            //New Edition 24.10.2020
            // Variant and color should be empty if Enq_model get changed
            if(targetFieldName !== undefined && targetFieldName == 'Enq_Model__c'){
                setTimeout(() => {
                    this.selectedModel = selectedValue;
                    const variantIndx = parseInt(selectedIndx) + 1;
                    const colorIndex = variantIndx + 1; 
                    this.template.querySelector('[data-key="'+variantIndx+'"]').setSelection([]);
                    this.template.querySelector('[data-key="'+colorIndex+'"]').setSelection([]);
                },100);
            }
            // else if(targetFieldName == 'Purchase_Interest__c'){
            //     let customerType = '';
            //     if(selectedValue == '<= 1 month')
            //         customerType = 'Hot';
            //     else if(selectedValue == '1-2 months')
            //         customerType = 'Warm';
            //     else if(selectedValue == '2-3 months')
            //         customerType = 'Cold';
            //     else 
            //         customerType = 'Deferred';
            //     setTimeout(()=>{
            //         this.template.querySelector('.customer-type').innerHTML = 'customerType';

            //     },100);
            // }
        }
        this.isLoading = false;
    }

    onBlurHandler(event) {
        //console.log('blur');
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
        // console.log('== quesId ', quesId);
        // console.log('== selectedValue ', selectedValue);
        // console.log('== selectedIndx ', selectedIndx);
        const targetFieldName = event.currentTarget.dataset.field;
        if (!this.quesIdVsResponse.has(quesId)) {
            let responseObj = {};
            responseObj.Response__c = selectedValue;
            responseObj.Survey_Question__c = quesId;
            responseObj.Lead__c = this.recordId;
            responseObj.Unique_ID__c = this.recordId + (targetFieldName !== undefined && targetFieldName !== '' ? '_-_' + targetFieldName : '');
            this.quesIdVsResponse.set(quesId, responseObj);
            //console.log('== quesIdVsResponse ', this.quesIdVsResponse);

            let currentQuestion = this.allQuestionList.find((item) => item.Id === quesId);
            //console.log('== currentQuestion ', currentQuestion);
            let nextQuestionId;
            let ansList = this.quesIdAnwsersListMap.find((item) => item.key === quesId);
            //console.log("== ansList@@", ansList);
            if (ansList) {
                for (var ans of ansList.value) {
                    //if (ans.Display_Value__c === selectedValue) {
                    nextQuestionId = ans.Next_Question__c;
                    //break;
                    //}
                }
            }
            //console.log('== nextQuestionId ', nextQuestionId);
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
            // console.log('== quesIdVsResponse@ ', this.quesIdVsResponse);
            // console.log('responseObj : ',responseObj);
        }
        this.isLoading = false;
    }

    handleAccordianChange(event) {
        this.isAccordianLoading = true;

        let selectedIndx = event.currentTarget.getAttribute("data-key");
        //console.log('== selectedIndx ', selectedIndx);

        let singleObj = this.mapData[selectedIndx];
        singleObj.showData = !singleObj.showData;
        this.mapData[selectedIndx] = singleObj;

        //console.log('== this.mapData ', this.mapData);
        this.isAccordianLoading = false;
    }
    handleCustomSearch(event) {
        // console.log('== ON Custom Search 1 ', event.target.value);
        // console.log('== ON Custom Search 2', event.detail.value);
        // console.log('== ON Custom Search 3', event.detail.searchTerm);
        // console.log('== ON Custom Search 8 type', this.typeValue);
        // console.log('== 364 ON Custom Search 9 level', this.levelValue);
        
        // console.log('== 369 ON Custom typee', this.typeValue);
        const objectAPIName = event.currentTarget.dataset.objectname;

        //console.log('event.currentTarget.dataset.field',event.currentTarget.dataset.field);
        const targetFieldName = event.currentTarget.dataset.field;

        let query = event.currentTarget.dataset.query !== undefined ? event.currentTarget.dataset.query : '';
        
        //console.log('objectAPIName', objectAPIName);
        if(objectAPIName == 'Product2'){
            query += ' AND Model__c =\''+this.selectedModel+'\'';
        }else if(objectAPIName == 'Color_Variant_Master__c'){
            query += ' AND Variant__c =\''+this.selectedVariant+'\'';
        }
        retriveLookupResult({
            objectName: objectAPIName,
            fields: 'Name',
            name: event.detail.searchTerm,
            queryConditions: query
        })
            .then(result => {
                console.log('== == ON Custom Search 3 Result ', result);
                this.records = result;
                let formatedResult = [];
                if (result) {
                    for (let data of result) {
                        if (data) {
                            let obj = {
                                id: data.Id,
                                title: data.Name
                            };
                            formatedResult.push(obj);
                        }
                    }
                }
                //console.log('== formatedResult ', formatedResult);
                
                if (formatedResult) {
                    this.template.querySelector('[data-field="'+targetFieldName+'"]').updateSearchResults(formatedResult);
                }

            })
            .catch(error => {
                console.log('== == ON Custom Search 3 Error ', error);
                //console.log('== == ON Custom Search 3 Result ', result);
            })

    }

    handleLookup(event) {
        // console.log('== Search Product ', event.target.value);
        // console.log('== name Value ', event.currentTarget.name);
        // console.log('== Detail Search term ', event.detail.searchTerm);
        // console.log('== Detail handleLookup typeValue', this.typeValue);
        // console.log('== Detail handleLookup typeValue', this.levelValue);
        /*if(this.levelValue==='S'){
            this.typeValue=this.levelValue;
           console.log('== ON Custom Search 3 level', this.levelValue);
        }*/
        const targetFieldName = event.currentTarget.dataset.field;
        const questionId = event.currentTarget.name;
        if (event.detail.value) {
            const selectedRecordId = event.detail.value;
            
            //console.log('this.selectedVariant : ',selectedRecordId);
            //console.log('targetFieldName : ',targetFieldName);
            
            //console.log('querySelector : ',this.template.querySelector('[data-field="'+targetFieldName+'"]').offsetTop);
            // let offset = this.template.querySelector('[data-field="'+targetFieldName+'"]').offsetTop;
            // this.template.querySelector('[data-field="'+targetFieldName+'"]').scrollTop = offset;
            
            if(targetFieldName !== undefined && targetFieldName == 'Variant__c'){
                this.selectedVariant = selectedRecordId;
                //console.log('this.selectedVariant : ',this.selectedVariant);
            }
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
                if(targetFieldName !== undefined && targetFieldName == 'Variant__c'){
                    let selectedIndx = parseInt(event.currentTarget.getAttribute("data-key")) + 1;
                    this.questionList[selectedIndx].selectedValue = null;
                    let quesId = this.template.querySelector('[data-key="'+selectedIndx+'"]').getAttribute("data-questionid");
                    if (this.quesIdVsResponse.has(quesId)) {
                        this.quesIdVsResponse.delete(quesId);
                    }
                    this.template.querySelector('[data-key="'+selectedIndx+'"]').setSelection([]);
                }
            }
        }
        this.isLoading = false;
        //console.log('this.quesIdVsResponse->',this.quesIdVsResponse);
    }
    // handleRemove() {
    //     //this.selectedRecord = undefined;
    //     this.showOutletTypes = false;
    //     this.showDetails = false;
    //     this.showButton = false;
    //     this.records = undefined;
    //     this.error = undefined;
    //     this.showCheckStockButton = false;
    // }
    // get lookupInputField() {
    //     return this.template.querySelector("c-lookup-input-field");
    // }

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
        if(isValid){
            this.isLoading = true;
            //console.log('== this.quesIdVsResponse ', this.quesIdVsResponse);
            //console.log('== this.questionList ', this.questionList);

            let reponseList = [];
            for (let key of this.quesIdVsResponse.keys()) {
                let data = this.quesIdVsResponse.get(key);
                if (this.showAllQuesOnLoad) {
                    if (this.questionList.some(e => e.ques.Id === key)) {
                        reponseList.push(data);
                    }
                } else {
                    //console.log('== this.secNameVsQuesList ', this.secNameVsQuesList.values());
                    this.mapData.forEach(item => {
                        if (item.value.some(e => e.ques.Id === key)) {
                            reponseList.push(data);
                        }
                    });
                }
                //lastSequenceNo = data.Survey_Question__r.Sequence_Number__c;
            }
            //console.log('lastSequenceNo : ',lastSequenceNo);
            //console.log('== reponseList ', reponseList);
            submitSurveyResponse({
                response: JSON.stringify(reponseList),
                isCompleted: isCompleted,
                leadId : this.recordId
            }).then(result => {
                console.log('== the result ', result);
                
                if (result === 'success') {
                    if (isCompleted) {
                        this.readOnlyMode = true;
                    }
                    let successStr = isCompleted ? 'Your survey has been submitted successfully !' : 'Your survey has been save successfully !';
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Thank you for your valuable time',
                            message: successStr,
                            variant: 'success'
                        })
                    );
                } else if (result === 'error') {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'Please contact to System Admin!',
                            variant: 'error'
                        })
                    );
                }else {
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
        }
    }    
}