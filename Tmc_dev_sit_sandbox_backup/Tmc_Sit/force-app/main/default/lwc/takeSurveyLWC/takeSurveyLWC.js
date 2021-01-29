import {
    LightningElement,
    api,
    track
} from 'lwc';
import fetchQuestions from "@salesforce/apex/TakeSurveyLWCController.fetchQuestions";
import saveSurvey from "@salesforce/apex/TakeSurveyLWCController.saveSurvey";
import {
    ShowToastEvent
} from "lightning/platformShowToastEvent";


export default class TakeSurveyLWC extends LightningElement {


    @api
    surveyId;
    @api
    caseId;
    @api
    enquiryId;
    @api
    contactId;

    showError = false;
    @track uiQuests = [];
    errorMessage = 'Error in constructing Script. Please contact your support team.';

    connectedCallback() {

        if (this.surveyId)

            fetchQuestions({
                surveyId: this.surveyId
            })
            .then(response => this.handleResponse(response))
            .catch(error => this.handleError(error))

    }

    handleResponse(response) {
        console.log(response);
        let orderNumber = 1;
        let serialNumber = 1
        if (response.length > 0) {
            this.showError = false;
            response.forEach(quest => {
                let uiQuest = {};
                uiQuest.name = quest.Name;
                uiQuest.id = quest.Id;
                uiQuest.question = 'Q' + serialNumber++ + '. ' + quest.Question__c;
                uiQuest.orderNumber = orderNumber++;
                uiQuest.type = quest.Question_Type__c;
                uiQuest.choices = quest.Choices__c;
                uiQuest.required = quest.Required__c;
                uiQuest.questionType = quest.Type__c;
                uiQuest.value = "";
                if (quest.Type__c === "Single Select--Vertical" || quest.Type__c === "Single Select--Horizontal") {
                    uiQuest.renderAsRadio = true;
                    if (quest.Choices__c != "") {
                        uiQuest.options = [];
                        let values = quest.Choices__c.split(/\r?\n/);
                        values.forEach(opt => {
                            uiQuest.options.push({
                                'label': opt,
                                'value': opt
                            });
                        });
                    }
                } else if (quest.Type__c === "Multi-Select--Vertical") {
                    uiQuest.renderAsCheckbox = true;
                    if (quest.Choices__c != "") {
                        uiQuest.options = [];
                        let values = quest.Choices__c.split(/\r?\n/);
                        values.forEach(opt => {
                            uiQuest.options.push({
                                'label': opt,
                                'value': opt
                            });
                        });
                    }
                } else if (quest.Type__c === "Free Text" || quest.Type__c === "Free Text - Single Row Visible") {
                    uiQuest.renderAsText = true;
                }
                this.uiQuests.push(uiQuest);
            });
            
        } else {
            this.showError = true;
            console.log('no response');
        }
    }

    handleError(error) {
        console.log('in error');
        console.log(error);
        this.showError = true;
    }

    handleClick(evt) {

        console.log(evt.target.label);
        console.log(this.uiQuests);
        let resQS = [];
        this.uiQuests.forEach(uiQ => {
            console.log("in UI Quests");
            let QS = {};
            QS.surveyId = this.surveyId;
            QS.qid = uiQ.id;
            QS.answer = JSON.stringify(uiQ.value);
            resQS.push(QS);
        });
        saveSurvey({
                allQS: resQS,
                surveyId: this.surveyId,
                caseId: this.caseId,
                enquiryId: this.enquiryId,
                contactId: this.contactId
            })
            .then(response => {
                console.log(response);
                if (response === "Success") {
                    const event = new ShowToastEvent({
                        "title": "Saved",
                        "message": "Survey has been saved successfully",
                        "variant": "Success"
                    });
                    this.dispatchEvent(event);
                    this.closeModal();
                }
            })
            .catch(error => {
                console.log(error);
                const event = new ShowToastEvent({
                    "title": "Error",
                    "message": "An error occurred saving the survey",
                    "variant": "Error"
                });
                this.dispatchEvent(event);

            })
    }

    handleChangeValue(evt) {

        console.log(evt.target.dataset.item);
        console.log(evt.detail.value);
        let objIndex = this.uiQuests.findIndex((obj => obj.id == evt.target.dataset.item));
        console.log("Before update: ", this.uiQuests[objIndex]);
        this.uiQuests[objIndex].value = evt.detail.value;
        //Log object to console again.
        console.log("After update: ", this.uiQuests[objIndex]);

    }

    // This event will be handled in scriptsDockerComposer
    closeModal() {
        //fire the custom event to be handled by parent aura component
        this.dispatchEvent(new CustomEvent("finish"));
    }

}