import { LightningElement,api } from 'lwc';

export default class LoanStatusItem extends LightningElement {
      @api recordId;
      @api enquiryNumber;
      @api dealerCode;
      @api dealerForCode;
      @api loanStatus;
      @api load;
      @api isEnquiryBlank;
	  @api actionTime;
}