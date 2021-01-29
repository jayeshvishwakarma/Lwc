import { LightningElement } from 'lwc';
import getZipCodeFromSF from '@salesforce/apex/ZipCodeLwcController.getZipCode';
import sendEmilFromSF from '@salesforce/apex/EmailUtility.sendEmail';
import toEmail from '@salesforce/label/c.ZipCodeCheckToEmail';
export default class ZipCodeCheckCmp extends LightningElement {

    portfolio = '';
    supplierData;
    showTable = false;
    showSpinner = false;
    showError = false;
    errorMsg = '';
    validateForm(event) {
        console.log('event', event.target.name);
        let { name } = event.target;
        this.portfolio = name == 'ZakelijkPremium' ? 'Business' : 'SMB';
        const allValid = [...this.template.querySelectorAll('.req')]
            .reduce((validSoFar, inputCmp) => {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);
        if (allValid) {

            // let params = {
            //     accountId: null,
            //     portfolio: this.portfolio,
            //     zipcode: this.template.querySelector('.postcode').value,
            //     houseNr: this.template.querySelector('.houseNr').value,
            //     hourseNrExtension: this.template.querySelector('.hourseNrExtension').value,
            // };
            // console.log('params', params);
            this.executeZipCode();
        }
    }
    executeZipCode() {
        this.showSpinner = true;
        this.showTable = true;
        this.showError = false;
        getZipCodeFromSF({
            accountId: null,
            portfolio: this.portfolio,
            zipcode: this.template.querySelector('.postcode').value,
            houseNr: this.template.querySelector('.houseNr').value,
            hourseNrExtension: this.template.querySelector('.hourseNrExtension').value,
        })
            .then(result => {
                console.log('result', result);
                if (result.length > 0) {
                    this.supplierData = result;
                    if(this.template.querySelector('.telephone').value != 0){
                        this.sendEmailToSupport();
                    }                
                }
                this.showSpinner = false;            
            }).catch(error => {
                console.log('error', error);
                let { body: { message } } = error;
                console.log('message', message);
                this.errorMsg = message;
                this.showSpinner = false;
                this.showError = true;
            })
    }
    sendEmailToSupport() {
        let body = 'Hello Support,';
        body += '<br/>Here is the recent zipcode check done';
        body += '<br/>Portfolio     : ' + this.portfolio;
        body += '<br/>ZipCode       : ' + this.template.querySelector('.postcode').value;
        body += '<br/>HouseNr       : ' + this.template.querySelector('.houseNr').value;
        body += '<br/>Husinummer    : ' + this.template.querySelector('.hourseNrExtension').value;
        body += '<br/>Telefoonnummer: ' + this.template.querySelector('.telephone').value;
        body += '<br/><br/>Please contact';
        body += '<br/><br/>Thanks<br/>Admin';
        console.log('body', body);       
        sendEmilFromSF({
            to : toEmail,
            cc : null,
            subject : 'ZipCodeCheck Activity',
            htmlBody : body,
            orgwideAddress:null,
        }).then(result => {
            console.log('result',result);
        }).catch(error => {
            console.log('error',error);
        })
    }
}