import { LightningElement, track, wire, api } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord } from 'lightning/uiRecordApi';
import CURRENT_USER_ID from '@salesforce/user/Id';
import getMDTListData from '@salesforce/apex/rfcApprovalCtrl.getMDTListData';
import getUserListData from '@salesforce/apex/rfcApprovalCtrl.getOwnerDetails';
import getAccContRelationValidataion from '@salesforce/apex/rfcApprovalCtrl.getAccContRelationValidataion';
import getLookupData from '@salesforce/apex/rfcApprovalCtrl.getLookupData';
import ENQUIRY_ID from '@salesforce/schema/RFC__c.Enquiry__c';
import RFC_STATUS from '@salesforce/schema/RFC__c.RFC_Status__c';
import RFC_TOTAL_AMT from '@salesforce/schema/RFC__c.Total_Amount__c';
import RFC_AMT_RECIEVED from '@salesforce/schema/RFC__c.Amount_Received__c';
import RFC_BUYING_PRICE from '@salesforce/schema/RFC__c.Buying_Price__c';
import RFC_LOAN_AMOUNT from '@salesforce/schema/RFC__c.Loan_Amount__c';
import ENQUIRY_FIRST_NAME from '@salesforce/schema/RFC__c.Enquiry__r.First_Name__c';
import ENQUIRY_MIDDLE_NAME from '@salesforce/schema/RFC__c.Enquiry__r.Middle_Name__c';
import ENQUIRY_LAST_NAME from '@salesforce/schema/RFC__c.Enquiry__r.Last_Name__c';
import ENQUIRY_OWNER_ID from '@salesforce/schema/RFC__c.Enquiry__r.Owner.Id';
import ENQUIRY_OWNER_PHONE from '@salesforce/schema/RFC__c.Enquiry__r.Owner.MobilePhone';
export default class RfcApproval extends LightningElement {


    @api recordId;
    @api approvalType;

    @track approvalTitle;
    @track opportunityId;
    @track enquiryOwnerId;
    @track rfcFields = [];
    @track readOnlyMode = false;
    @track editOnlyMode = false;
    @track enquiryName;
    @track notAuthUser;
    @track authUser;
    @track totalAmount;
    @track amountRecieved;

    detailsVisible = false;
    detailsVisible2 = false;
    detailsVisible3 = false;
    oppFieldSearchKey = 'OPP_READ_ONLY';
    rfcStatus = '';
    wiredACRAuthData;
    loanAmount;
    buyingPrice;
	
	showOwnerField = false;
	enquiryOwnerPhone;
	
    get lookupInputField() {
        return this.template.querySelector("c-lookup-input-field");
    }
    get isACMApproval() {
        return (this.approvalType === 'ACM') ? true : false;
    }
    get pendingAmount() {
        return this.totalAmount - (Number(this.amountRecieved) + Number(this.loanAmount) + Number(this.buyingPrice));
    }
    get isSMApproval() {
        return (this.approvalType === 'SM') ? true : false;
    }


    handleTotalAMTChange(event) {
        this.totalAmount = event.detail.value;
    }
    handleAMTRecievedChange(event) {
        this.amountRecieved = event.detail.value;
    }

    handleValueChange(event) {
        this.selectedFinancial = event.detail.value;
    }

    handleCustomSearch(event) {

        console.log(event.detail.customKey);
        getLookupData({
            searchKey: event.detail.searchTerm
        })
            .then(result => {
                this.records = result;
                let formatedResult = [];
                if (result) {
                    for (let data of result) {
                        if (data) {
                            let obj = { id: data.Id, title: data.Name };
                            formatedResult.push(obj);
                        }
                    }
                }
                if (formatedResult) {
                    this.lookupInputField.updateSearchResults(formatedResult);
                }
            })
            .catch(error => {
                console.log('== == ON Custom Search 3 Error ', error);
            })
    }

    connectedCallback() {
        this.approvalTitle = this.approvalType + ' Approval: RFC Detail';
    }

    handleLoad(event) {
        this.detailsVisible=true;
    }
    handleLoad2(event) {
        this.detailsVisible2=true;
    }
    handleLoad3(event) {
        this.detailsVisible3=true;
    }

    @wire(getAccContRelationValidataion, { BtnClickStr: '$approvalType', sobjectId: '$recordId' })
    wiredIsAuthorize(value) {
        // Hold on to the provisioned value so we can refresh it later.
        this.wiredACRAuthData = value;
        // destructure the provisioned value
        const { data, error } = value;
        if (data) {
            console.log(data);
            if (data === 'Not Authorized') {
                this.notAuthUser = true;
                this.dispatchEvent(
                    new ShowToastEvent({
                        message: 'You are not an authorized user',
                        variant: 'error'
                    })
                );
                this.closeQuickAction();

            } else if (data === 'Authorized') {
                this.authUser = true;
            }
        }
        else if (error) {
        }

    }

    @wire(getMDTListData, { fieldType: '$oppFieldSearchKey' })
    opportunityReadOnlyMDT;
	
    @wire(getRecord, { recordId: '$recordId', fields: [ENQUIRY_ID, ENQUIRY_OWNER_ID, ENQUIRY_OWNER_PHONE, RFC_STATUS, ENQUIRY_FIRST_NAME, ENQUIRY_MIDDLE_NAME, ENQUIRY_LAST_NAME, RFC_TOTAL_AMT, RFC_AMT_RECIEVED, RFC_LOAN_AMOUNT, RFC_BUYING_PRICE] })
    wiredRFC({ error, data }) {
        if (data) {
			console.log('== ENQUIRY_OWNER_PHONE ', getFieldValue(data, ENQUIRY_OWNER_PHONE));
			
			if(getFieldValue(data, ENQUIRY_OWNER_PHONE)){
				this.showOwnerField = false;
			}else{
				this.showOwnerField = true;
			}
			
            this.opportunityId = getFieldValue(data, ENQUIRY_ID);
            this.enquiryOwnerId = getFieldValue(data, ENQUIRY_OWNER_ID);
			console.log('== enquiryOwnerId ', this.enquiryOwnerId);
            this.rfcStatus = getFieldValue(data, RFC_STATUS);
            if (getFieldValue(data, ENQUIRY_FIRST_NAME)) {
                this.enquiryName = getFieldValue(data, ENQUIRY_FIRST_NAME);
            }
            if (getFieldValue(data, ENQUIRY_MIDDLE_NAME)) {
                this.enquiryName = this.enquiryName + ' ' + getFieldValue(data, ENQUIRY_MIDDLE_NAME);
            }
            if (getFieldValue(data, ENQUIRY_LAST_NAME)) {
                this.enquiryName = this.enquiryName + ' ' + getFieldValue(data, ENQUIRY_LAST_NAME);
            }
            if (this.isACMApproval) {
                this.totalAmount = getFieldValue(data, RFC_TOTAL_AMT);
                this.amountRecieved = getFieldValue(data, RFC_AMT_RECIEVED);
                this.loanAmount = getFieldValue(data, RFC_LOAN_AMOUNT);
                this.buyingPrice = getFieldValue(data, RFC_BUYING_PRICE);
            }

            //this.enquiryName = getFieldValue(data, ENQUIRY_FIRST_NAME) + ' ' + getFieldValue(data, ENQUIRY_MIDDLE_NAME) + ' ' + getFieldValue(data, ENQUIRY_LAST_NAME);
            console.log(this.enquiryName);
            if ((this.rfcStatus != 'Pending with FM' && this.approvalType === 'FM') ||
                (this.rfcStatus != 'Pending with TVM' && this.approvalType === 'TVM') ||
                (this.rfcStatus != 'Pending with ACM' && this.approvalType === 'ACM') ||
                (this.rfcStatus != 'Pending with SM' && this.approvalType === 'SM')) {
                this.readOnlyMode = true;
            } else {
                this.editOnlyMode = true;
            }
			if(this.approvalType === 'SM'){
				this.readOnlyMode = false;
				this.editOnlyMode = true;
			}
        }
        else {
            console.log(error);
        }
    }
	@wire(getUserListData, {userId : '$enquiryOwnerId'})
	wiredUserList({data, error}){
		if(data){
			console.log('== User data ', data);
			this.enquiryOwnerPhone = data[0].MobilePhone;
		}else if(error){
			console.log('== User error ', error);
		}
	}
	
    @wire(getMDTListData, { fieldType: '$approvalType' })
    rfcApprovalTypeMDT;


    handleApproveClick() {
        console.log('clickapprove');
        // Create the recordInput object
        /*  const allValid = [...this.template.querySelectorAll('lightning-input')]
             .reduce((validSoFar, inputFields) => {
                 inputFields.reportValidity();
                 return validSoFar && inputFields.checkValidity();
             }, true); */

        var validValue = true;
        if (this.isACMApproval) {

        } else {
            this.rfcApprovalTypeMDT.data.forEach(data => {
                var apiname = data.Field_API_Name__c;
                if (!data.Is_Lookup__c) {
                    var fieldvalue = this.template.querySelector('[data-field="' + apiname + '"]').value;
                    validValue = data.Is_Mandatory__c ? (fieldvalue ? validValue : false) : validValue;
                } else {
                    validValue = !(this.selectedFinancial) ? false : validValue;
                }
            });
        }

        if (validValue) {
            const fields = {};
            fields['Id'] = this.recordId;
            if (this.isACMApproval) {
                fields['Total_Amount__c'] = this.totalAmount;
                fields['Amount_Received__c'] = this.amountRecieved;
                fields['Pending_Amount__c'] = this.pendingAmount;
                fields['Accounts_Manager_Comments__c'] = this.template.querySelector('[data-field="Accounts_Manager_Comments__c"]').value;

            } else {

                this.rfcApprovalTypeMDT.data.forEach(data => {
                    var apiname = data.Field_API_Name__c;
                    //console.log(apiname);
                    if (!data.Is_Lookup__c) {
                        var fieldvalue = this.template.querySelector('[data-field="' + apiname + '"]').value;
                        fields[apiname] = fieldvalue;
                    }
                    if (data.Is_Lookup__c) {
                        fields["Financier_Name__c"] = this.selectedFinancial;
                    }
                });

                console.log('handlesave----' + this.selectedFinancial);


            }
            const recordInput = { fields };
            console.log(recordInput);
            var todayDate = new Date();
            if (this.approvalType === 'FM') {
                fields['FM_Approval_Status__c'] = 'Approved';
                fields['Finance_Approver__c'] = CURRENT_USER_ID;
                fields['Finance_Approval_Date__c'] = todayDate.toJSON();
            } else if (this.approvalType === 'TVM') {
                fields['True_Value_Approval_Status__c'] = 'Approved';
                fields['True_Value_Approver__c'] = CURRENT_USER_ID;
                fields['True_Value_Approval_Date__c'] = todayDate.toJSON();
            } else if (this.approvalType === 'ACM') {
                fields['Accounts_Approval_Status__c'] = 'Approved';
                fields['Accounts_Approver__c'] = CURRENT_USER_ID;
                fields['Accounts_Approval_Date__c'] = todayDate.toJSON();
            } else if (this.approvalType === 'SM') {
                fields['SM_Approval_Status__c'] = 'Approved';
                fields['SM_Approver__c'] = CURRENT_USER_ID;
                fields['SM_Approval_Date__c'] = todayDate.toJSON();
            }

            updateRecord(recordInput)
                .then(() => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'RFC approved',
                            variant: 'success'
                        })
                    );
                    //Close the form
                    this.closeQuickAction();
                })
                .catch(error => {
                    console.log(error);
                    var errormsg = '';
                    if (error.body.output.errors[0] && error.body.output.errors[0].message) {
                        //validation and trigger errror
                        errormsg = error.body.output.errors[0].message;
                    } else {
                        errormsg = error.body.message;
                    }
                    this.dispatchEvent(
                        new ShowToastEvent({
                            message: errormsg,
                            variant: 'error'
                        })
                    );
                });
        }
        else {
            // The form is not valid
            this.dispatchEvent(
                new ShowToastEvent({
                    message: 'Check your input and try again.',
                    variant: 'error'
                })
            );
        }

    }


    handleRejectClick() {
        const fields = {};
        fields['Id'] = this.recordId;
        if (this.isACMApproval) {
            fields['Total_Amount__c'] = this.totalAmount;
            fields['Amount_Received__c'] = this.amountRecieved;
            fields['Pending_Amount__c'] = this.pendingAmount;
            fields['Accounts_Manager_Comments__c'] = this.template.querySelector('[data-field="Accounts_Manager_Comments__c"]').value;
        } else {
            this.rfcApprovalTypeMDT.data.forEach(data => {
                var apiname = data.Field_API_Name__c;
                if (!data.Is_Lookup__c) {
                    var fieldvalue = this.template.querySelector('[data-field="' + apiname + '"]').value;
                    fields[apiname] = fieldvalue;
                }
                if (data.Is_Lookup__c) {
                    fields["Financier_Name__c"] = this.selectedFinancial;
                }
            });

        }
        const recordInput = { fields };
        var todayDate = new Date();
        if (this.approvalType === 'FM') {
            fields['FM_Approval_Status__c'] = 'Rejected';
            fields['Finance_Approver__c'] = CURRENT_USER_ID;
            fields['Finance_Approval_Date__c'] = todayDate.toJSON();
        } else if (this.approvalType === 'TVM') {
            fields['True_Value_Approval_Status__c'] = 'Rejected';
            fields['True_Value_Approver__c'] = CURRENT_USER_ID;
            fields['True_Value_Approval_Date__c'] = todayDate.toJSON();
        } else if (this.approvalType === 'ACM') {
            fields['Accounts_Approval_Status__c'] = 'Rejected';
            fields['Accounts_Approver__c'] = CURRENT_USER_ID;
            fields['Accounts_Approval_Date__c'] = todayDate.toJSON();
        } else if (this.approvalType === 'SM') {
            fields['SM_Approval_Status__c'] = 'Rejected';
            fields['SM_Approver__c'] = CURRENT_USER_ID;
            fields['SM_Approval_Date__c'] = todayDate.toJSON();
        }

        updateRecord(recordInput)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'RFC rejected',
                        variant: 'success'
                    })
                );
                //Close the form
                this.closeQuickAction();
            })
            .catch(error => {

                var errormsg = '';
                if (error.body.output.errors[0] && error.body.output.errors[0].message) {
                    //validation and trigger errror
                    errormsg = error.body.output.errors[0].message;
                } else {
                    errormsg = error.body.message;
                }
                this.dispatchEvent(
                    new ShowToastEvent({
                        message: errormsg,
                        variant: 'error'
                    })
                );
            });
    }


    closeQuickAction() {
        const closeQA = new CustomEvent('close');
        this.dispatchEvent(closeQA);
    }
}