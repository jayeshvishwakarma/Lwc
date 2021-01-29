import { LightningElement ,api,wire,track} from 'lwc';
import getEscalation from '@salesforce/apex/CaseActionEscalationTimeCtrl.getEscalation';
export default class CaseEscalationCmp extends LightningElement {
    @api recordId;
    escalationsList = [];
    error;
    

    connectedCallback() {
        
        setInterval(() => { 
                    this.callGetEscalation();

                     }, 5000); 
    }
   callGetEscalation(){
        getEscalation({recordId :this.recordId}).then(result=>{
            if(result){
                this.escalationsList = [];
                this.escalationsList = result;
                this.error = undefined;
                console.log('----result-->',result);
            }
        }).catch(error=>{
            if(error){
                this.error = error;
                this.escalationsList = undefined;
                console.log('-------->',error);
            }
        })
   
    }
    
}