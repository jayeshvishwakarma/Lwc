import { LightningElement,api,track } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
export default class FetchMIPolicyDetails extends LightningElement {
    @api policynumber;
    @track isModalOpen = false;
    @track ifpolicynumber = false;
    @track createCase = false;
    @track closePolicyPage = true;
    showPolicyDetails=false;
    showPolicyClaimDetails=false;
    policyDetails = {
        "policyNumber" : ""
    }
    

    handlePolicyNumberChange(event){
        this.policynumber = event.target.value;
    }
    closeCaseModel(event){
        console.log('Hi');
        this.isModalOpen = false;
    }
    handleSearch(event){
        console.log(event.target.name);
        
        if(this.policynumber){
            if(event.target.name==='c-indt-Insurance-Summary'){
                this.showPolicyDetails=true;
                //this.showPolicyClaimDetails=false;
    
            }
            else if(event.target.name==='c-claim-details'){
                this.showPolicyClaimDetails=true;
                //this.showPolicyDetails=false;
            }
            this.template.querySelector(event.target.name).handleFetchData(this.policynumber);   
        }
        else{
            this.showToastMessage('Something is wrong','Policy number is missing','error');
        }
        
        
    }

    handleCreateCase(event){
        this.isModalOpen = true;
        this.closePolicyPage = false;
        this.policyDetails.policyNumber = this.policynumber;
        console.log('case creation number',this.policyDetails.policyNumber);
       // this.template.querySelector("c-create-Inbound-Case-L-W-C").openModal();
    }
    policyDetailReceived(event){
        console.log('Inside policyDetailReceived');
        console.log(event);
        console.log(event.detail);
        this.ifpolicynumber = event.detail;
        console.log(this.ifpolicynumber);
    }
    closeModal(event) {
        this.isModalOpen = false;
    }
    showToastMessage(title,message,variant) {
      this.dispatchEvent(
        new ShowToastEvent({
          title: title,
          message: message,
          variant: variant
        })
      );
    }
   
}