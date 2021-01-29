import { LightningElement, track, wire, api } from 'lwc';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getDetails from '@salesforce/apex/FetchSurveyDetail.getDetails';
import submitSurveyResponse from '@salesforce/apex/FetchSurveyDetail.submitSurveyResponse';

export default class SurveyTakerQuestionForm extends LightningElement {
    @api recordId;
    header = '';
    subHeader = '';

    @track questionList = [];
    isFormFinished = false;
    readOnlyMode = false;
    CompleteMsg = 'Thank you for your response.';
    isResponseExist = false;

    quesIdWIthAnwsersMap = new Map();
    survey;
    allQuestionList = [];
    isStartQuestionList = [];
    quesIdVsResponse = new Map();
    quesNameVsQuesId = new Map();
    quesSequenceVsQuesId = new Map();
    isLoading = true;
    //showForm = false;
    isAccordianLoading = false;

    secNameVsQuesList = new Map();

    showAllQuesOnLoad = true;

    mapData = [];
    quesIdAnwsersListMap = [];
    selectedLanguage = 'English';
    allAvailableLanguage = [];

    isCEI = false;
    showAll = false;

    newNextquestionList = [];


    @wire(getDetails, { surveyTakerId: '$recordId', SelectedLang: '$selectedLanguage' })
    wiredUserList({ data, error }) {
        if (data) {
            console.log('== On load this.questionList ', this.questionList);
            console.log('== User data ', data);
            this.survey = data.survey;
            this.isCEI = (this.survey && this.survey.Type === 'CEI') ? true : false;
            this.allQuestionList = data.quesIdWIthQuestionObjectList;
            console.log("responseList@@", data.responseList);
            console.log("quesIdWIthAnwsersMap@@", data.quesIdWIthAnwsersMap);
            console.log("quesIdWIthQuestionObjectList@@", data.quesIdWIthQuestionObjectList);

            for (var key in data.quesIdWIthAnwsersMap) {
                this.quesIdAnwsersListMap.push({ key: key, value: data.quesIdWIthAnwsersMap[key] });
            }
            console.log('== this.quesIdAnwsersListMap ', this.quesIdAnwsersListMap);


            if (data.LanguageTypeList) {
                this.allAvailableLanguage = data.LanguageTypeList;
            }

            if (this.survey && this.survey.Question_type__c) {
                this.showAllQuesOnLoad = (this.survey.Question_type__c === 'Incremental') ? true : false;
            }

            console.log('== this.survey.Question_type__c ', this.survey.Question_type__c);
            console.log('== this.showAllQuesOnLoad ', this.showAllQuesOnLoad);

            for (let i = 0; i < data.responseList.length; i++) {
                let responseObj = data.responseList[i];
                let item = {};
                item.Response__c = responseObj.Response__c;
                item.Survey_Question__c = responseObj.Survey_Question__c;
                item.Survey_Taker__c = responseObj.Survey_Taker__c;
                item.Unique_ID__c = responseObj.Unique_ID__c;
                item.Answer_Type__c = responseObj.Survey_Question__r.Answer_Type__c;
                this.quesIdVsResponse.set(responseObj.Survey_Question__c, item);
                this.isResponseExist = true;
            }

            console.log('this.quesIdVsResponse===', this.quesIdVsResponse);

            if (data.surveyTaker && data.surveyTaker.Is_Completed__c) {
                this.readOnlyMode = data.surveyTaker.Is_Completed__c;
            }

            if (data.quesIdWIthAnwsersMap && data.quesIdWIthQuestionObjectList) {
                let increment = 1;
                for (var value of data.quesIdWIthQuestionObjectList) {
                    let ques = value;
                    let answerData = {};
                    let optionValue = [];
                    let secName;
                    this.quesNameVsQuesId.set(ques.Name, ques.Id);
                    this.quesSequenceVsQuesId.set(ques.Sequence_Number__c, ques.Id);
                    let ansList = this.quesIdAnwsersListMap.find((item) => item.key === ques.Id);
                    //console.log("== ansList@@", ansList);

                    if (ques.isStart__c) {
                        this.isStartQuestionList.push(ques);
                    }
                    if (ques.Is_Applicable_Question__c) {
                        this.applicableCEIQuesId = ques.Id;
                    }

                    if (ques && ques.Answer_Type__c === 'Radio Button' || ques.Answer_Type__c === 'Picklist (DropDown)' || ques.Answer_Type__c === 'Date' || ques.Answer_Type__c === 'Multi Select') {
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
                    answerData.isText = ques.Answer_Type__c === 'Text Area' ? true : false;
                    answerData.isRadio = ques.Answer_Type__c === 'Radio Button' ? true : false;
                    answerData.isPicklist = ques.Answer_Type__c === 'Picklist (DropDown)' ? true : false;
                    answerData.isDate = ques.Answer_Type__c === 'Date' ? true : false;
                    answerData.isMultiPicklist = ques.Answer_Type__c === 'Multi Select' ? true : false;
                    answerData.isAddress = ques.Answer_Type__c === 'Address' ? true : false;
                    answerData.multiselectMaxLimit = ques.MultiSelect_Limit__c;



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

                        console.log('this.secNameVsQuesList===', this.secNameVsQuesList);
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
                console.log('== this.isStartQuestionList ', this.isStartQuestionList);
                console.log('== this.isStartQuestionList.length ', this.isStartQuestionList.length);

                for (let i = 0; i < this.isStartQuestionList.length; i++) {
                    let currentItem = this.isStartQuestionList[i];
                    console.log('== currentItem.Id ===' + currentItem.Id);

                    if (this.isResponseExist && this.quesIdVsResponse.has(this.applicableCEIQuesId)) {
                        let responseObj = this.quesIdVsResponse.get(this.applicableCEIQuesId);
                        this.applicableCEIValue = responseObj.Response__c;
                    }
                    this.addQuestions(currentItem, count);
                    count++;
                }
            }


            this.header = this.survey.Name;
            this.subHeader = this.survey.Sub_Header__c;

            console.log('== Final questionList', this.questionList);

            console.log('this.mapData===', this.mapData);

            this.isLoading = false;
        } else if (error) {
            this.isLoading = false;
            console.log('== User error ', error);
        }
    }

    addQuestions(quesObj, srNum) {

        console.log('== CEI quesObj ', quesObj);

        let objectName = {};
        let responseValue;
        console.log('== this.quesIdVsResponse ', this.quesIdVsResponse);
        let responseObj;
        let resposeData;
        if (this.quesIdVsResponse.has(quesObj.Id)) {
            responseObj = this.quesIdVsResponse.get(quesObj.Id);
            console.log('== responseObj ', responseObj);
            if (responseObj.Response__c && responseObj.Answer_Type__c === 'Multi Select') {
                resposeData = responseObj.Response__c.split(',');
            } else if (responseObj.Response__c && responseObj.Answer_Type__c === 'Address') {

                let quesAddressObj = { 'sobjectType': 'Survey_Question_CTI__c' };
                quesAddressObj.Address_Line_1__c = quesObj.Address_Line_1__c ? quesObj.Address_Line_1__c : '';
                quesAddressObj.Address_Line_2__c = quesObj.Address_Line_2__c ? quesObj.Address_Line_2__c : '';
                quesAddressObj.Address_Line_3__c = quesObj.Address_Line_3__c ? quesObj.Address_Line_3__c : '';
                quesAddressObj.Pincode__c = quesObj.Pincode__c ? quesObj.Pincode__c : '';
                quesAddressObj.City__c = quesObj.City__c ? quesObj.City__c : '';
                quesAddressObj.State__c = quesObj.State__c ? quesObj.State__c : '';
                console.log('===quesAddressObj ', quesAddressObj);
                resposeData = Object.assign(quesAddressObj);

                //resposeData = responseObj.Response__c ? JSON.parse(responseObj.Response__c) : {};
            } else {
                resposeData = responseObj.Response__c;
            }

        } else if (quesObj.Answer_Type__c === 'Address') {
            let quesAddressObj = { 'sobjectType': 'Survey_Question_CTI__c' };
            quesAddressObj.Address_Line_1__c = quesObj.Address_Line_1__c ? quesObj.Address_Line_1__c : '';
            quesAddressObj.Address_Line_2__c = quesObj.Address_Line_2__c ? quesObj.Address_Line_2__c : '';
            quesAddressObj.Address_Line_3__c = quesObj.Address_Line_3__c ? quesObj.Address_Line_3__c : '';
            quesAddressObj.Pincode__c = quesObj.Pincode__c ? quesObj.Pincode__c : '';
            quesAddressObj.City__c = quesObj.City__c ? quesObj.City__c : '';
            quesAddressObj.State__c = quesObj.State__c ? quesObj.State__c : '';
            console.log('===quesAddressObj ', quesAddressObj);
            resposeData = Object.assign(quesAddressObj);
        }
        console.log('===resposeData ', resposeData);
        responseValue = resposeData;
        console.log('===responseValue ', responseValue);

        if (this.allQuestionList) {
            objectName.srNum = srNum;
            /* if (quesObj.Survey_Questions__r) {
                let langQues = quesObj.Survey_Questions__r[0];

            } */
            let ques = {};
            ques.Id = quesObj.Id;
            ques.Section__c = quesObj.Survey_Questions__r && quesObj.Survey_Questions__r[0].Section__c ? quesObj.Survey_Questions__r[0].Section__c : quesObj.Section__c;
            ques.isSection = (ques.Section__c) ? true : false;
            ques.Default_Help_Text = quesObj.Default_Help_Text__c ? quesObj.Default_Help_Text__c : 'Please enter here...';
            ques.Pre_Question_Script__c = quesObj.Survey_Questions__r && quesObj.Survey_Questions__r[0].Pre_Question_Script__c ? quesObj.Survey_Questions__r[0].Pre_Question_Script__c : quesObj.Pre_Question_Script__c;
            ques.Question_Name__c = quesObj.Survey_Questions__r ? quesObj.Survey_Questions__r[0].Question_Name__c : quesObj.Question_Name__c;
            ques.isQues = (ques.Question_Name__c) ? true : false;
            ques.Post_Question_Script__c = quesObj.Survey_Questions__r && quesObj.Survey_Questions__r[0].Post_Question_Script__c ? quesObj.Survey_Questions__r[0].Post_Question_Script__c : quesObj.Post_Question_Script__c;

            objectName.ques = ques;
            if (this.quesIdWIthAnwsersMap) {
                let answerDetails = this.quesIdWIthAnwsersMap.get(quesObj.Id);
                //console.log('== answerDetails ', answerDetails);
                if (answerDetails) {
                    objectName.isText = answerDetails.isText;
                    objectName.isRadio = answerDetails.isRadio;
                    objectName.isPicklist = answerDetails.isPicklist;
                    objectName.isDate = answerDetails.isDate;
                    objectName.isMultiPicklist = answerDetails.isMultiPicklist;
                    objectName.isAddress = answerDetails.isAddress;
                    objectName.answerOptions = answerDetails.options;
                    objectName.selectedValue = responseValue;
                    objectName.multiselectMaxLimit = answerDetails.multiselectMaxLimit;
                }

            }
            console.log('== start In Add Ques questionList ', this.questionList);

            this.questionList.push(objectName);

            console.log('== In Add Ques questionList ', this.questionList);

            if (this.showAllQuesOnLoad === false) {
                // console.log('== IN return Call');
                return objectName;
            }

            if (this.isResponseExist && responseObj && this.showAllQuesOnLoad) {
                if (this.quesIdVsResponse.has(this.applicableCEIQuesId)) {
                    let applicableQues = this.quesIdVsResponse.get(this.applicableCEIQuesId);
                    this.applicableCEIValue = applicableQues.Response__c;
                }
                this.addNextQues(responseObj.Survey_Question__c, responseValue);
            }

        }
        return null;
    }

    addNextQues(quesId, selectedValue) {

        let currentQuestion = this.allQuestionList.find((item) => item.Id === quesId);
        console.log('== currentQuestion ', currentQuestion);
        let nextQuestionId;
        let nextQuestionList;
        let selectedValueList;

        let ansList = this.quesIdAnwsersListMap.find((item) => item.key === quesId);
        console.log("== ansList@@", ansList);
        if (selectedValue && currentQuestion.Answer_Type__c === 'Multi Select') {
            selectedValueList = selectedValue;
        }
        console.log("== selectedValueList@@", selectedValueList);
        if (ansList) {
            for (var ans of ansList.value) {
                if (currentQuestion.Answer_Type__c === 'Text Area' || currentQuestion.Answer_Type__c === 'Date' || currentQuestion.Answer_Type__c === 'Address') {
                    nextQuestionId = ans.Next_Question__c;
                    break;
                } else if (currentQuestion.Answer_Type__c === 'Multi Select') {
                    //console.log('selectedValueList.indexOf(ans.Next_Question__c)===', selectedValueList.indexOf(ans.Actual_Value__c));
                    if (selectedValueList && selectedValueList.indexOf(ans.Actual_Value__c) !== -1) {
                        nextQuestionId = nextQuestionId ? nextQuestionId : '';
                        nextQuestionId = ans.Next_Question__c ? (nextQuestionId ? nextQuestionId + ',' + ans.Next_Question__c : ans.Next_Question__c) : nextQuestionId;
                    }
                } else if (ans.Actual_Value__c === selectedValue) {
                    nextQuestionId = ans.Next_Question__c;
                    break;
                }
            }
        }
        console.log('== nextQuestionId ', nextQuestionId);

        if (nextQuestionId) {

            nextQuestionList = nextQuestionId.split(',');

            let minSeqNum;
            let minques;

            for (let i = 0; i < nextQuestionList.length; i++) {
                let nextque = nextQuestionList[i];
                let nextQId = this.quesNameVsQuesId.get(nextque);

                console.log('== nextQId ', nextQId);
                let nextQuestion = this.allQuestionList.find((item) => item.Id === nextQId);
                console.log('== nextQuestion ', nextQuestion);
                /* if (currentQuestion.Answer_Type__c === 'Multi Select') {
                    if (minSeqNum == null || (minSeqNum && minSeqNum > nextQuestion.Sequence_Number__c)) {
                        minSeqNum = nextQuestion.Sequence_Number__c;
                        minques = nextQuestion;
                    }
                } */

                let nextapplicableQues;
                //if (currentQuestion.Answer_Type__c != 'Multi Select') {
                if (this.isCEI) {
                    nextapplicableQues = this.ceiNextApplicableQues(nextQuestion);

                    console.log('== nextapplicableQues From Start ', nextapplicableQues);
                } else {
                    nextapplicableQues = nextQuestion;
                }
                /* } else if (currentQuestion.Answer_Type__c === 'Multi Select' && (i === nextQuestionList.length - 1)) {
                    nextapplicableQues = minques;
                } */
                this.newNextquestionList.push(nextapplicableQues.Sequence_Number__c);

                /* if (nextapplicableQues) {
                    this.isFormFinished = false;
                    this.addQuestions(nextapplicableQues, (this.questionList.length + 1));
                } */
            }
            console.log('this.newNextquestionList=== ', this.newNextquestionList);
            let filteredQuesList = [];
            let currentQuesNum = currentQuestion.Sequence_Number__c;
            if (this.newNextquestionList) {
                this.isFormFinished = false;
                for (let i = 0; i < this.newNextquestionList.length; i++) {
                    let currentNum = this.newNextquestionList[i];
                    if (currentNum > currentQuesNum) {
                        filteredQuesList.push(currentNum);
                    }
                }
                console.log('this.filteredQuesList=== ', filteredQuesList);

                let renderQuesNum = filteredQuesList.reduce((a, b) => Math.min(a, b));
                console.log('this.renderQuesNum=== ', renderQuesNum);
                let renderQuesId = this.quesSequenceVsQuesId.get(renderQuesNum);
                let renderQues = this.allQuestionList.find((item) => item.Id === renderQuesId);
                console.log('this.renderQues=== ', renderQues);
                this.addQuestions(renderQues, (this.questionList.length + 1));
            }
        }
        else if (currentQuestion.Is_End__c) {
            this.isFormFinished = true;
        } else {
            this.dispatchEvent(
                new ShowToastEvent({
                    message: 'Please contact your System Administrator for the next question',
                    variant: 'error'
                })
            );
        }

        //console.log('== this.questionList ', this.questionList);
        this.isLoading = false;
    }

    ceiNextApplicableQues(currentQuestion) {

        let nextQuesApplicableValues = currentQuestion.Applicability_of_Scnerios__c ? currentQuestion.Applicability_of_Scnerios__c.split(';') : '';
        //console.log('== nextQuesApplicableValues ', nextQuesApplicableValues);
        //console.log('== this.applicableCEIValue ', this.applicableCEIValue);

        if (!nextQuesApplicableValues || nextQuesApplicableValues.includes(this.applicableCEIValue)) {
            //console.log('== return currentQuestion ', currentQuestion);
            return currentQuestion;
        } else if (currentQuestion.Not_Applicable_Next_Question__c) {
            let nextApplicableques = this.allQuestionList.find((item) => item.Id === currentQuestion.Not_Applicable_Next_Question__c);
            currentQuestion = nextApplicableques;
            //console.log('== nextApplicableques from sender ', currentQuestion);

            return this.ceiNextApplicableQues(currentQuestion);
        } else {
            return null;
        }

    }

    handleLanguageChange(event) {
        console.log('== IN lang CHange ', event.target.value);
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


        console.log('== In this.questionList ', this.questionList);
        console.log('== selected Language ', this.selectedLanguage);
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

        let currentQuestion = this.allQuestionList.find((item) => item.Id === quesId);
        let selectedIndx = event.currentTarget.getAttribute("data-key");

        if (currentQuestion && currentQuestion.Answer_Type__c === 'Multi Select' && event.detail) {
            console.log('== From Multi Sel Child ', event.detail);
            selectedValue = event.detail.selectedQuesData;
            selectedIndx = event.detail.indexKey;

        }

        if (this.isCEI) {
            this.applicableCEIValue = (this.applicableCEIQuesId === quesId) ? selectedValue : this.applicableCEIValue;
        }
        console.log('== applicableCEIValue ', this.applicableCEIValue);


        console.log('== quesId ', quesId);
        console.log('== selectedValue ', selectedValue);
        console.log('== typeof selectedValue ', typeof selectedValue);
        console.log('== selectedIndx ', selectedIndx);
        console.log('== this.quesIdVsResponse', this.quesIdVsResponse);
        console.log('== this.quesIdVsResponse.has(quesId) ', this.quesIdVsResponse.has(quesId));

        if (selectedValue && typeof selectedValue === 'object') {
            let actualValue = '';
            let selectedData = JSON.stringify(selectedValue);
            actualValue = JSON.parse(selectedData).join();
            selectedValue = actualValue;
            console.log('== selectedData ', selectedValue);
        }

        if (!this.quesIdVsResponse.has(quesId)) {
            let responseObj = {};
            responseObj.Response__c = selectedValue;
            responseObj.Survey_Question__c = quesId;
            responseObj.Survey_Taker__c = this.recordId;
            responseObj.Unique_ID__c = this.recordId + quesId;
            this.quesIdVsResponse.set(quesId, responseObj);
            console.log('== quesIdVsResponse ', this.quesIdVsResponse);

        } else if (!(currentQuestion.isStart__c && (selectedIndx != (this.isStartQuestionList.length - 1)))) {
            let responseObj = this.quesIdVsResponse.get(quesId);
            responseObj.Response__c = selectedValue;
            this.quesIdVsResponse.set(quesId, responseObj);
            console.log('== quesIdVsResponse@ ', this.quesIdVsResponse);
            let removedElement = parseInt(this.questionList.length) - (parseInt(selectedIndx) + parseInt(1));
            console.log('== removedElement@ ', removedElement);
            let queslength = parseInt(this.questionList.length);

            for (let i = 0; i < removedElement; i++) {
                let removeInd = parseInt(queslength) - (parseInt(i) + parseInt(1));
                let mapkey = this.questionList[removeInd].ques.Id;
                this.quesIdVsResponse.delete(mapkey);
                let poppedQues = this.allQuestionList[this.questionList.length - 1];
                let ansList = this.quesIdAnwsersListMap.find((item) => item.key === poppedQues.Id);
                if (ansList) {
                    for (var ans of ansList.value) {
                        if (ans.Next_Question__c) {
                            this.newNextquestionList.pop();
                        }
                    }
                }
                this.questionList.pop();
            }


            console.log('== After remove Ques Map ', this.newNextquestionList);
            console.log('== this.questionList ', this.questionList);
        }

        if (this.showAllQuesOnLoad) {
            this.addNextQues(quesId, selectedValue);
        }
        this.isLoading = false;
    }

    onBlurTextArea(event) {
        console.log('blur');
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

        console.log('== quesId ', quesId);
        console.log('== selectedValue ', selectedValue);
        console.log('== selectedIndx ', selectedIndx);

        if (!this.quesIdVsResponse.has(quesId)) {
            let responseObj = {};
            responseObj.Response__c = selectedValue;
            responseObj.Survey_Question__c = quesId;
            responseObj.Survey_Taker__c = this.recordId;
            responseObj.Unique_ID__c = this.recordId + quesId;
            this.quesIdVsResponse.set(quesId, responseObj);
            console.log('== quesIdVsResponse ', this.quesIdVsResponse);

            let currentQuestion = this.allQuestionList.find((item) => item.Id === quesId);
            console.log('== currentQuestion ', currentQuestion);


            let nextQuestionId;

            let ansList = this.quesIdAnwsersListMap.find((item) => item.key === quesId);
            console.log("== ansList@@", ansList);
            if (ansList) {
                for (var ans of ansList.value) {
                    nextQuestionId = nextQuestionId ? nextQuestionId : ans.Next_Question__c;
                }
            }
            console.log('== nextQuestionId ', nextQuestionId);

            let nextQuestionList;
            if (nextQuestionId) {
                nextQuestionList = nextQuestionId.split(',');
                for (var nextque of nextQuestionList) {
                    let nextQId = this.quesNameVsQuesId.get(nextque);
                    let nextQuestion = this.allQuestionList.find((item) => item.Id === nextQId);
                    let nextapplicableQues;
                    if (this.isCEI) {
                        nextapplicableQues = this.ceiNextApplicableQues(nextQuestion);
                        console.log('== nextapplicableQues ', nextapplicableQues);
                    } else {
                        nextapplicableQues = nextQuestion;
                    }
                    this.newNextquestionList.push(nextapplicableQues.Sequence_Number__c);

                    /* if (nextapplicableQues) {
                        this.isFormFinished = false;
                        this.addQuestions(nextapplicableQues, (this.questionList.length + 1));
                    } */
                }
                console.log('this.newNextquestionList=== ', this.newNextquestionList);
                let filteredQuesList = [];
                let currentQuesNum = currentQuestion.Sequence_Number__c;
                if (this.newNextquestionList) {
                    this.isFormFinished = false;
                    for (let i = 0; i < this.newNextquestionList.length; i++) {
                        let currentNum = this.newNextquestionList[i];
                        if (currentNum > currentQuesNum) {
                            filteredQuesList.push(currentNum);
                        }
                    }
                    console.log('this.filteredQuesList=== ', filteredQuesList);

                    let renderQuesNum = filteredQuesList.reduce((a, b) => Math.min(a, b));
                    console.log('this.renderQuesNum=== ', renderQuesNum);
                    let renderQuesId = this.quesSequenceVsQuesId.get(renderQuesNum);
                    let renderQues = this.allQuestionList.find((item) => item.Id === renderQuesId);
                    console.log('this.renderQues=== ', renderQues);
                    this.addQuestions(renderQues, (this.questionList.length + 1));
                }
            } else if (currentQuestion.Is_End__c) {
                this.isFormFinished = true;
            } else {
                this.dispatchEvent(
                    new ShowToastEvent({
                        message: 'Please contact your System Administrator for the next question',
                        variant: 'error'
                    })
                );
            }

        } else {
            let responseObj = this.quesIdVsResponse.get(quesId);
            responseObj.Response__c = selectedValue;
            this.quesIdVsResponse.set(quesId, responseObj);
            console.log('== quesIdVsResponse@ ', this.quesIdVsResponse);
        }
        this.isLoading = false;

    }

    handleAccordianChange(event) {
        this.isAccordianLoading = true;

        let selectedIndx = event.currentTarget.getAttribute("data-key");
        console.log('== selectedIndx ', selectedIndx);

        let singleObj = this.mapData[selectedIndx];
        singleObj.showData = !singleObj.showData;
        this.mapData[selectedIndx] = singleObj;

        console.log('== this.mapData ', this.mapData);
        this.isAccordianLoading = false;
    }

    handleExpendCollapseAll(event) {
        this.ExpendCollapseAll();
    }

    delay(delayInms) {
        return new Promise(resolve => {
            setTimeout(() => {
                resolve(2);
            }, delayInms);
        });
    }

    async ExpendCollapseAll() {
        this.isLoading = true;
        let response = await this.delay(1000);
        this.showAll = !this.showAll;
        this.mapData.forEach(item => {
            if (item.name !== 'blank' && item.name !== 'IsStart' && item.name !== 'IsEnd') {
                item.showData = this.showAll
            }
        });
        this.isLoading = false;
    }

    saveSurvey() {
        this.handleSurveyResponse(false);
    }

    submitSurvey() {
        this.handleSurveyResponse(true);
    }

    handleSurveyResponse(isCompleted) {

        this.isLoading = true;
        console.log('== this.quesIdVsResponse ', this.quesIdVsResponse);
        console.log('== this.questionList ', this.questionList);

        let reponseList = [];
        for (let key of this.quesIdVsResponse.keys()) {
            let data = this.quesIdVsResponse.get(key);
            if (this.showAllQuesOnLoad) {
                if (this.questionList.some(e => e.ques.Id === key)) {
                    reponseList.push(data);
                }
            } else {
                console.log('== this.secNameVsQuesList ', this.secNameVsQuesList.values());

                this.mapData.forEach(item => {
                    if (item.value.some(e => e.ques.Id === key)) {
                        reponseList.push(data);
                    }
                });
            }
        }

        let addressQuesData = { 'sobjectType': 'Survey_Question_CTI__c' };
        let addressTakerData = { 'sobjectType': 'Survey_Taker_CTI__c', 'Id': this.recordId };
        console.log('== reponseList ', reponseList);
        for (let i = 0; i < reponseList.length; i++) {
            let ques = reponseList[i];
            console.log('ques====', ques);
            if (ques.Answer_Type__c === "Address") {
                let data = ques.Response__c;
                console.log('data====', data);
                if (data) {
                    let parseResult = JSON.parse(data);
                    console.log('parseResult====', parseResult);
                    addressQuesData.Id = ques.Survey_Question__c;
                    addressQuesData.Address_Line_1__c = parseResult.Address_Line_1__c ? parseResult.Address_Line_1__c : '';
                    addressQuesData.Address_Line_2__c = parseResult.Address_Line_2__c ? parseResult.Address_Line_2__c : '';
                    addressQuesData.Address_Line_3__c = parseResult.Address_Line_3__c ? parseResult.Address_Line_3__c : '';
                    addressQuesData.City__c = parseResult.City__c ? parseResult.City__c : '';
                    addressQuesData.State__c = parseResult.State__c ? parseResult.State__c : '';
                    addressQuesData.Pincode__c = parseResult.Pincode__c ? parseResult.Pincode__c : '';

                    //addressTakerData.Id = this.recordId;
                    addressTakerData.New_Address_Line_1__c = parseResult.Address_Line_1__c ? parseResult.Address_Line_1__c : '';
                    addressTakerData.New_Address_Line_2__c = parseResult.Address_Line_2__c ? parseResult.Address_Line_2__c : '';
                    addressTakerData.New_Address_Line_3__c = parseResult.Address_Line_3__c ? parseResult.Address_Line_3__c : '';
                    addressTakerData.New_City__c = parseResult.City__c ? parseResult.City__c : '';
                    addressTakerData.New_State__c = parseResult.State__c ? parseResult.State__c : '';
                    addressTakerData.New_Pincode__c = parseResult.Pincode__c ? parseResult.Pincode__c : '';
                }
            }
        }
        if (this.isCEI) {
            addressTakerData.CEI_Scenario_Type__c = this.applicableCEIValue;
        }
        console.log('== addressQuesData ', addressQuesData);
        console.log('== addressTakerData ', addressTakerData);

        submitSurveyResponse({
            response: JSON.stringify(reponseList),
            isCompleted: isCompleted,
            addressQuesData: addressQuesData,
            addressTakerData: addressTakerData
        }).then(result => {
            console.log('== result ', result);
            if (isCompleted) {
                this.readOnlyMode = true;
            }
            if (result === 'success') {
                let successStr = isCompleted ? 'Your survey has been submitted successfully !' : 'Your survey has been save successfully !';
                //if (isCompleted) {
                //eval("$A.get('e.force:refreshView').fire();");
                window.location.reload();

                //}

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Thank you for your valuable time',
                        message: successStr,
                        variant: 'success'
                    })
                );
            } else if (result === 'error') {
                this.isLoading = false;

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Please contact to System Admin!',
                        variant: 'error'
                    })
                );
            }

        }).catch(error => {
            this.isLoading = false;
            console.log('== error ', error);
        })
    }

    validateAddress(event) {

        //console.log('== event ', event.target);
        //console.log('== event.dataset ', event.target.dataset);
        let addressCls = this.template.querySelectorAll('.validate-address');
        //console.log('addressCls==== ', addressCls[0]);
        //console.log('addressCls====name ', addressCls[0].name);
        //console.log('addressCls====id ', addressCls[0].dataset.id);
        //let selectedIndx = event.target.dataset.id;
        let selectedIndx = addressCls[0].dataset.id;
        console.log('== selectedIndx ', selectedIndx);

        //let quesData = JSON.parse(JSON.stringify(this.questionList[selectedIndx]));
        //console.log('== quesData ', quesData);
        //let quesId = quesData.ques.Id;
        //let quesId = event.target.name;
        let quesId = addressCls[0].name;
        console.log('== quesId ', quesId);
        let currentQuestion = this.allQuestionList.find((item) => item.Id === quesId);

        let validclick = this.template.querySelector("[data-id='content']").validate().then(result => {
            console.log('result==== ', JSON.stringify(result));
            let selectedValue;

            if (result.isValid) {
                selectedValue = Object.assign(result.record);
                if (selectedValue) {
                    let addressObj = {};
                    addressObj.Address_Line_1__c = selectedValue.Address_Line_1__c ? selectedValue.Address_Line_1__c : currentQuestion.Address_Line_1__c;
                    addressObj.Address_Line_2__c = selectedValue.Address_Line_2__c ? selectedValue.Address_Line_2__c : currentQuestion.Address_Line_2__c;
                    addressObj.Address_Line_3__c = selectedValue.Address_Line_3__c ? selectedValue.Address_Line_3__c : currentQuestion.Address_Line_3__c;
                    addressObj.Pincode__c = selectedValue.Pincode__c ? selectedValue.Pincode__c : currentQuestion.Pincode__c;
                    addressObj.City__c = selectedValue.City__c ? selectedValue.City__c : currentQuestion.City__c;
                    addressObj.State__c = selectedValue.State__c ? selectedValue.State__c : currentQuestion.State__c;
                    this.onBlurANDBtnClick(quesId, addressObj, selectedIndx, currentQuestion);
                }
            } else {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: result.errorMessage,
                        variant: 'error'
                    })
                );
            }
            return result.isValid;
        });

    }

    onBlurANDBtnClick(quesId, selectedValue, selectedIndx, currentQuestion) {


        console.log('== quesId ', quesId);
        console.log('== selectedValue ', selectedValue);
        console.log('== selectedIndx ', selectedIndx);

        if (!this.quesIdVsResponse.has(quesId)) {
            let responseObj = {};
            responseObj.Response__c = JSON.stringify(selectedValue);
            responseObj.Survey_Question__c = quesId;
            responseObj.Survey_Taker__c = this.recordId;
            responseObj.Unique_ID__c = this.recordId + quesId;
            this.quesIdVsResponse.set(quesId, responseObj);
            console.log('== quesIdVsResponse ', this.quesIdVsResponse);
            if (this.showAllQuesOnLoad) {
                this.addNextQues(quesId, selectedValue);
            }

        } else if (!(currentQuestion.isStart__c && (selectedIndx != (this.isStartQuestionList.length - 1)))) {
            let responseObj = this.quesIdVsResponse.get(quesId);
            responseObj.Response__c = JSON.stringify(selectedValue);
            this.quesIdVsResponse.set(quesId, responseObj);
            console.log('== quesIdVsResponse@ ', this.quesIdVsResponse);
        }


        this.isLoading = false;
    }



}