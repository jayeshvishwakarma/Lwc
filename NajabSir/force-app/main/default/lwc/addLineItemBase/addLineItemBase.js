/* eslint-disable no-console */
import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import model from './model';

export default class AddLineItemBase extends LightningElement {
    @api deviceFormFactor;

    @track state = model.state;

    @track isLoading = false;
    @track error;

    get browserFormFactor(){
        return this.deviceFormFactor==='DESKTOP' ? true : false;
    }

    setData(data) {
        model.state = data;
        this.state = {};
        this.state = model.state;
    }

    setSavePoint(){
        model.savePoint = true;
        return this;
    }
    commit(){
        model.commit = true;
        return this;
    }
    revert(){
        model.commit = false;
        return this;
    }
    resetState(){
       model.reset();
       return this;
    }

    validateInputs(query) {
        return Array.from(this.template.querySelectorAll(query)).filter(input => !input.reportValidity()).length === 0;
    }

    executeAction(action, params) {
        this.isLoading = true;
        return action(params).then((data) => {
            this.isLoading = false;
            return data;
        }).catch(error => {
            this.isLoading = false;
            this.error = error;
            //this.showToast({ message: 'Insufficient privileges. Please contact your administration.' });
            this.showToast({ message: this.error });
            console.log('Server Error', error);
        });
    }

    dispatchEvent(name, params){
        super.dispatchEvent(new CustomEvent(name, { detail: params }));
    }

    showToast({ message, mode = '', variant = 'error' }) {
        super.dispatchEvent(new ShowToastEvent({ message, mode, variant }));
    }

    closeModal() {
        //window.location.reload();
        this.dispatchEvent(new CustomEvent('CloseCmp'));
    }

    toJSON(data){
        return JSON.stringify(data);
    }

    clone(data){
        return JSON.parse(this.toJSON(data));
    }
}