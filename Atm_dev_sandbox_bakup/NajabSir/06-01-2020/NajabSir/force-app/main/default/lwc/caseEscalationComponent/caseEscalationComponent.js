import { LightningElement,api,wire,track } from 'lwc';
import getEscalationNew from '@salesforce/apex/CaseActionEscalationTimeCtrl.getEscalationNew';
import getDetails from '@salesforce/apex/CaseActionEscalationTimeCtrl.getDetails';
export default class CaseEscalationComponent extends LightningElement {
    @api recordId;
    escalationList = [];
    error;
    showList = false;
    details;
    showNote = false;
    
    connectedCallback() {
        this.callgetDetails();
        setInterval(() => { 
                    this.callGetEscalationNew();

                     }, 10000); 
    }

    callgetDetails() {
        getDetails({recordId :this.recordId}).then(result=>{
            if(result){
                this.details = result;
                if(result.length > 0) {
                    this.showNote = true;   
                }
                else {
                    this.showNote = false;     
                }
            }
        }).catch(error=>{
            if(error){
                
            }
        })
    }

    callGetEscalationNew(){
        getEscalationNew({recordId :this.recordId}).then(result=>{
            if(result){
                this.escalationList = [];
                this.escalationList = result;
                this.error = undefined;
                if(result.length > 0) {
                    this.showList = true;   
                }
                else {
                    this.showList = false;     
                }
            }
        }).catch(error=>{
            if(error){
                this.error = error;
                this.escalationList = undefined;
                this.showList = false;
            }
        })
   }
}