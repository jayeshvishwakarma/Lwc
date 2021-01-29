import { LightningElement, api, track } from 'lwc';

export default class SurveyTakerAnswerForm extends LightningElement { 
    @track question;
    @api 
    set surveyQuestion(value){
        console.log('== In child Value ', value);
        this.question = value;
    }
    
    get surveyQuestion(){
        return this.question;
    }

    connectedCallback(){
        console.log('== In child Question Data ', this.question);
    }

}