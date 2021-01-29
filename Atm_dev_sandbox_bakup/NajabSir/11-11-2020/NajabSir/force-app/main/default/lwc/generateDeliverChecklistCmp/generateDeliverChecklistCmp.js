/* eslint-disable no-console */
/* eslint-disable radix */
/*eslint-disable no-alert*/
import { LightningElement, track, api } from 'lwc';
import deliveryCheckListQuestions from '@salesforce/apex/GenerateDeliveryChecklistController.deliveryCheckListQuestions';
import saveSurveyResponse from '@salesforce/apex/GenerateDeliveryChecklistController.saveSurveyResponse';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';	
import Generate_Delivery_Checklist from '@salesforce/label/c.Generate_Delivery_Checklist';

export default class GenerateDeliverChecklistCmp extends LightningElement {
 
    @track fetchSurveyQuestions = []; 
    @track dataList = []; 
    runOnce = true;
    @api formFactor;
    @api enquiryId;
    @track showSpinner = false;
    @track isValidCmp = true;
    @track erroMessage = Generate_Delivery_Checklist;
    
    
    //Method to get called on load of the component
    connectedCallback(){
        this.handleLoad();        
    }

    //Map the result from server side to a javascript variable.
    handleLoad() {
        this.showSpinner = true;
        deliveryCheckListQuestions({
            enquiryId : this.enquiryId
        })
        .then(result => {
            console.log('== fetchSurveyQuestions ', JSON.stringify(result));
            //let tempResult = JSON.parse(result);
            let tempFetchSurveyList = [];
            for(let i=0; i< result.length; i++){
                let singleRec = result[i];
                if(singleRec.surveyResponseId === ''){
                    singleRec.dateDisable = true;
                    singleRec.dateRequired = false;
                }else{
                    if(singleRec.answer && singleRec.answer === 'No'){
                        singleRec.dateDisable = false;
                        singleRec.dateRequired = true;
                    }else if(singleRec.answer && singleRec.answer === 'Yes'){
                        singleRec.dateDisable = true;
                        singleRec.dateRequired = false;
                    }
                }
                tempFetchSurveyList.push(singleRec);
            }
            console.log('== updated List ', tempFetchSurveyList);
            this.fetchSurveyQuestions = tempFetchSurveyList;

            this.checkArrayLength();
            this.showSpinner = false;
            this.tempRenderedCallback();
        }) 
        .catch(error => {
            this.showSpinner = false;
            this.error = error;
        });
    } 

    //Rendered callback method to create a new array object for altering the values of the wrapper
    //created at server side
    
    tempRenderedCallback(){
        console.log('== Is running');
        let objAray = Array.from(this.fetchSurveyQuestions);
            let tempArray =[];
            objAray.forEach(function(record){
                let newObj = Object.assign({},record);
                tempArray.push(newObj);
        });
        this.dataList = tempArray;
    }
    

    //Map the remarks with the remarks attribute iin the wrapper
    trackAnswers(event){  
        let key = event.target.dataset.key;
        let objArray = Array.from(this.fetchSurveyQuestions); 
        objArray.forEach(function(record){
            if(record.srno===parseInt(key)){
                record.remarks = event.target.value;
            }
        });
        
    }

    //Map date values with the date variable in the wrapper
    trackDateAnswers(event){
        let key = event.target.dataset.did;
        console.log('== Selected Key ', key);

        let objArray = Array.from(this.fetchSurveyQuestions);
        if(!this.validateDateFieldValue(event)){
            objArray.forEach(function(record){
                if(record.srno===parseInt(key)){
                    record.dateExpected = null;
                }
            });
        }else{
            objArray.forEach(function(record){
                if(record.srno===parseInt(key)){
                    record.dateExpected = event.target.value;
                }
            });
        }
        this.fetchSurveyQuestions = objArray;
    }

    // To check selected Date must be future Date only.
    validateDateFieldValue(event){
        let selectedDate = new Date(event.target.value);
        let todayValue = new Date();
        let validData = true;

        let selectedDateEle = this.template.querySelector('[data-dtid="'+event.target.dataset.dtid+'"]');
        selectedDateEle.setCustomValidity("");
        if (selectedDate < todayValue) {
            validData = false;
            selectedDateEle.setCustomValidity("Please select future date only!");
        }
        selectedDateEle.reportValidity();

        return validData;
    }

    //Map the answer with answer variable in the wrapper
    trackChange(event){
        event.target.checked = true; 
        let selVal = event.target.value;
        let selqid = event.target.dataset.qstnid;
        console.log('== Selected Ques ', selqid);
        let objid = selqid+this.changeValue(selVal);

        console.log('== selVal ', selVal);

        let obj = this.template.querySelector('[data-id="'+objid+'"]');
        obj.checked = false;
        
        let objArray = Array.from(this.fetchSurveyQuestions); 
        objArray.forEach(function(record){
            if(record.questionId===selqid){
                record.answer = event.target.value;
                console.log('== Change in record ', record);
                if(record.answer === 'No'){
                    record.dateDisable = false;
                    record.dateRequired = true;
                }else{
                    record.dateExpected = null;
                    record.dateDisable = true;
                    record.dateRequired = false;
                }
            }
        });
        this.fetchSurveyQuestions = objArray;
        console.log('== fetchSurveyQuestions ', this.fetchSurveyQuestions);
    }
    
    //Set the value of selected yes or no. 
    changeValue(selectedText){
        return selectedText.includes('Yes') ? 'No' : 'Yes';
    }
    
    //Get the device type (DESKTOP, PHONE, IPAD)
    get deviceType(){
        return this.formFactor!=='DESKTOP' ? 'slds-col slds-size_1-of-1' : 'slds-col slds-size_1-of-2';
    }

    //Check if Array has values
    checkArrayLength(){
        this.isValidCmp = this.fetchSurveyQuestions.length>0 ? true : false;
    }

    //For DSE User, Hide the button
    get saveButtonVisibility(){
        let retVal = true;
        if(this.isValidCmp===true){
            let objArray = Array.from(this.fetchSurveyQuestions); 
            objArray.forEach(function(record){
                if(record.isDisabled===true){
                    retVal = false;
                }
            });
        }
        return retVal;
    }
    //Save Method to save the delivery checklist
    saveSurvey(event){
        let btnLabel = event.target.dataset.id;
        this.showSpinner = true;
        let message = btnLabel==='save' ? 'Delivery Checklist has been generated successfully' : 'Delivery Checklist has been sent successfully';
        if(this.validateAllRecord()){
            console.log('== Is Valid');
            if(this.toCheckInputField()){
                saveSurveyResponse({
                        enquiryId : this.enquiryId,
                        data : JSON.stringify(this.fetchSurveyQuestions),
                        btnLabel : btnLabel
                    })
                    .then(result => { 
                        if(result.includes('SUCCESS')){
                            const evt = new ShowToastEvent({
                                title: 'Record Created',
                                message: message,
                                variant: 'success',
                                mode: 'dismissable'
                            }); 
                            this.dispatchEvent(evt);
                            this.closequickAction();
                        }else{
                            this.isValidCmp = false;
                            this.erroMessage = result;
                            this.showSpinner = false;
                        }

                    })
                    .catch(error => {
                        this.error = error;
                        this.showSpinner = false;
                    });
                }else{
                    this.showSpinner = false;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: '',
                            message: 'Please check all the inputs!',
                            variant: 'error'
                        })
                    );
                }
        }else{
            this.showSpinner = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: '',
                    message: 'Please answer all the questions',
                    variant: 'error'
                })
            );
        }
    }

    validateAllRecord(){
        let validData = true;
        let allRecords = this.fetchSurveyQuestions;
        for(let i=0; i< allRecords.length; i++){
            let singlerec = allRecords[i];
            console.log('== singlerec ', singlerec);
            let recordKeys = Object.keys(singlerec);
            console.log('== recordKeys ', recordKeys);
            if(recordKeys.includes('answer') && (singlerec.answer === '' || singlerec.answer === null) ){
                validData = false;
            }
        }
        console.log('== validData ', validData);
        /*
        if(!validData){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: '',
                    message: 'Please answer all the questions',
                    variant: 'error'
                })
            );
        }
        */
        return validData;
    }

    toCheckInputField(){
        const allValid2 = [...this.template.querySelectorAll('lightning-input')]
            .reduce((validSoFar, inputCmp) => {
                        inputCmp.reportValidity();
                        return validSoFar && inputCmp.checkValidity();
            }, true);
        return allValid2;
    }

    //Method to close the quick action
    closequickAction(){ 
        // Fire the custom event
        this.dispatchEvent(new CustomEvent('closequickacion'));
    }
}