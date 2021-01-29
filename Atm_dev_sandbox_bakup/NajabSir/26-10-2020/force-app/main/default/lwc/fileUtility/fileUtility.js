import { LightningElement } from 'lwc';

//import fetchHistory from '@salesforce/fetchHistoryClass.fetchHistory';

export default class FileUtility extends LightningElement {

    activeIcon = 'utility:chevronright';
    activeIcon2 = 'utility:chevronright';

    activeIcon1 = 'utility:chevronright'; 


    checkBtn(){
        alert('Sample');
    }


    handleToggleSection() {
        let secObj = this.template.querySelector('[data-id="detail-section"]');
        if (secObj.classList.contains('slds-is-open')) {
            secObj.classList.remove('slds-is-open');
            this.activeIcon = 'utility:chevronright';
        } else {
            secObj.classList.add('slds-is-open');
            this.activeIcon = 'utility:chevrondown'; 
        }
    }

    handleToggleSection1() {
        let secObj = this.template.querySelector('[data-id="detail-section1"]');
        if (secObj.classList.contains('slds-is-open')) {
            secObj.classList.remove('slds-is-open');
            this.activeIcon1 = 'utility:chevronright';
        } else {
            secObj.classList.add('slds-is-open');
            this.activeIcon1 = 'utility:chevrondown'; 
        }
    }

    handleToggleSection2() {
        let secObj = this.template.querySelector('[data-id="detail-section2"]');
        if (secObj.classList.contains('slds-is-open')) {
            secObj.classList.remove('slds-is-open');
            this.activeIcon2 = 'utility:chevronright';
        } else {
            secObj.classList.add('slds-is-open');
            this.activeIcon2 = 'utility:chevrondown'; 
        }
    }

 
}