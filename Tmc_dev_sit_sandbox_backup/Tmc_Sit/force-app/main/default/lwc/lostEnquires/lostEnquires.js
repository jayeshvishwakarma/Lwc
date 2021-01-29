/*eslint-disable no-alert*/
/*eslint-disable no-console*/
import { LightningElement, wire, track, api  } from 'lwc';
import getLostEnquires from '@salesforce/apex/LostEnquiresController.fetchLostEnquires';
import ApprovalAllEnquiryRecordSF from '@salesforce/apex/LostEnquiresController.ApprovalAllEnquiryRecordSF';
import changeEnquiryOwner from '@salesforce/apex/LostEnquiresController.changeEnquiryOwner';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import userList from '@salesforce/apex/ChangeOwnerFunctionality.getUserList';
import getValidUser from '@salesforce/apex/LostEnquiresController.getValidUser';
const columns = [
    { label: 'Name', fieldName: 'Name' },
    { label: 'Enq Stage', fieldName: 'StageName'},
    { label: 'Variant', fieldName: 'Variant__r.Name'},
    { label: 'DMS Enquiry Number', fieldName: 'DMS_Enquiry_Name__c'},
];
export default class LostEnquires extends LightningElement {
    @track listOfLostEnquires = [];
    @track columns = columns;
    @track isValid = false;
    @track showLoadingSpinner;
    selectedEnquiryMap = new Map();
    @track isAcceptAllEnqModal = false;
    @track isRejectAllEnqModal = false;
    @track isChangeEnquiryOwnerModal = false;
    @wire(getLostEnquires) LostEnquiresRecords;
    @track partnerUser;
    @track showList;
    @track selectedRecord;
    @track loadSpinner;
    @track mobileSelectAllCheckBox = true;
    //@api recordId;

    record;
    iconname = "standard:user";
    searchfield = 'Name';
    dealerAccount;
    // This is for refresh data Table
    refreshTable;

    @wire(getLostEnquires)
    wiredData({ data, error }) {
        this.showLoadingSpinner = true;
        if (data) {
            //this.hideComponent = data.hideComponent;
            //alert(JSON.stringify(data.fetchDetailsList));
            //console.log('Resultssss--------------');
            console.log('@@@## ', data.length);
            if (data !== undefined && data.length > 0) {
                //console.log('@@## data' + JSON.stringify(data));
                //this.listOfLostEnquires = data;
                let newTempLostEnquires = JSON.parse(JSON.stringify(data))
                console.log('@@## newTempLostEnquires.length' + newTempLostEnquires.length);
                for (let i = 0; i < newTempLostEnquires.length; i++) {
                    this.listOfLostEnquires.push(newTempLostEnquires[i]);
                    this.dealerAccount = newTempLostEnquires[i].dealerId;
                }
                this.refreshTable = data;
                //this.isValid = data.isValid;
            }
            this.isValidUser();
            this.showLoadingSpinner = false;
            console.log('@@## dealerAccount' + this.dealerAccount);
        }
        else if (error)
            console.log('LostEnquires error is ------' + JSON.stringify(error));
    }

    isValidUser(){
        getValidUser()
            .then(result => {
                console.log('@@ res ',JSON.stringify(result));
                //this.isValid = JSON.stringify(result);
                this.isValid = result;
                console.log('@@ isValid ',this.isValid);
            })
    }

    // This method is use to select all Checkbox value.
    selectAllCheckboxes(event) {
        let checkboxes = this.template.querySelectorAll('.checkVal');
        //console.log(checkboxes.length);
        for (let i = 0; i < checkboxes.length; i++) {
            checkboxes[i].checked = event.target.checked;
            console.log(event.target.checked);
            this.selectedEnquiryMap.set(i.toString(), event.target.checked);
            this.listOfLostEnquires[i].isSelected = event.target.checked;
            console.log(this.listOfLostEnquires[i].isSelected);
        }
        //console.log(this.changeValueMap);
    }

    //------------------------------------------- for single or multiple checkbox select----------------------------//
    chnageCheckboxValue(event) {
        let singleChange;
        this.selectedEnquiryMap.set(event.target.getAttribute("data-row-index"), event.target.checked);
        //console.log(this.selectedEnquiryMap);
        if (this.mobileSelectAllCheckBox)
            singleChange = this.template.querySelector('[data-id="mobSingleCheck"]')
        else
            singleChange = this.template.querySelector('[data-id="singleCheck"]')
        let checkboxes = this.template.querySelectorAll('.checkVal');
        if (event.target.checked) {
            let flag = 1;
            for (let i = 0; i < checkboxes.length; i++) {
                if (!checkboxes[i].checked) {
                    flag = 0;
                }
            }
            if (flag === 0)
                singleChange.checked = false;
            else if (flag === 1)
                singleChange.checked = true;
        }
        else
            singleChange.checked = false;

        //console.log(event.target.dataset.id);
        this.listOfLostEnquires[event.target.dataset.id].isSelected = event.target.checked;
        console.log(this.listOfLostEnquires[event.target.dataset.id].isSelected);
    }

    //------------------------------------------ Accept all Enquiry modal -----------------------------------//
    AcceptAllEnqModal(event) {
        let arr = this.listOfLostEnquires;
        let arr2 = [];
        for (let i = 0; i < arr.length; i++) {
            if (this.selectedEnquiryMap.get(i.toString()) === true) {
                arr2.push(arr[i].objOpp.Id);
            }
        }
        if (arr2.length > 0){
            this.isAcceptAllEnqModal = true;
            //document.body.setAttribute('style', 'overflow: hidden;');  
        }

        if (arr2.length <= 0) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please Select Atleast One Enquiry Before Accepting.',
                    variant: 'error'
                })
            )
        }
    }

    // This method is use for Accept all Enquiry record.
    acceptAllEnquiryRecord() {
        this.showLoadingSpinner = true;
        // prevending default type sumbit of record edit form
        //event.preventDefault();
        let newTempEnquiryRecord = [];
        for (let i = 0; i < this.listOfLostEnquires.length; i++) {
            newTempEnquiryRecord.push(this.listOfLostEnquires[i]);
        }
        //window.console.log('update Record ====>'+ JSON.stringify(newTempEnquiryRecord));
        window.console.log('update Record ====>');
        ApprovalAllEnquiryRecordSF({ listOfLEWrapper : JSON.stringify(this.listOfLostEnquires), isApproveReject : true })
            .then(result => {
                window.console.log('update Record After Apex ====>');
                //this.listOfLostEnquires = result;
                this.isAcceptAllEnqModal = false;
                this.newTempEnquiryRecord = [];  
                this.showLoadingSpinner = false;

                // showing success message
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success!!',
                    message: 'Selected All Enquiries Accepted Successfully!!.',
                    variant: 'success'
                }));

                // refreshing table data using refresh apex
                this.listOfLostEnquires = [];
                refreshApex(this.listOfLostEnquires);  
                refreshApex(this.LostEnquiresRecords); 
                return refreshApex(this.listOfLostEnquires);
            })
            .catch(error => {
                this.showLoadingSpinner = false;
                window.console.log('Error ====> ' + error);
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error!!',
                    message: error.message,
                    variant: 'error'
                }));
            }
        );
    }

    //------------------------------------------ Reject All Enquiry modal -----------------------------------//
    RejectAllEnqModal(event) {
        let arr = this.listOfLostEnquires;
        let arr2 = [];
        for (let i = 0; i < arr.length; i++) {
            if (this.selectedEnquiryMap.get(i.toString()) === true) {
                arr2.push(arr[i].objOpp.Id);
            }
        }
        if (arr2.length > 0){
            this.isRejectAllEnqModal = true;
            //document.body.setAttribute('style', 'position: fixed;'); 
        }

        if (arr2.length <= 0) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please Select Atleast One Enquiry Before Rejecting.',
                    variant: 'error'
                })
            )
        }
    }

    // This method is use for Reject all Enquiry record.
    rejectAllEnquiryRecord() {
        this.showLoadingSpinner = true;
        // prevending default type sumbit of record edit form
        //event.preventDefault();
        let newTempEnquiryRecord = [];
        for (let i = 0; i < this.listOfLostEnquires.length; i++) {
            newTempEnquiryRecord.push(this.listOfLostEnquires[i]);
        }
        //window.console.log('update Record ====>'+ JSON.stringify(newTempEnquiryRecord));
        window.console.log('update Record ====>');
        ApprovalAllEnquiryRecordSF({ listOfLEWrapper : JSON.stringify(this.listOfLostEnquires), isApproveReject : false })
            .then(result => {
                window.console.log('update Record After Apex ====>');
                //this.listOfLostEnquires = result;
                this.isRejectAllEnqModal = false;
                this.newTempEnquiryRecord = [];  
                this.showLoadingSpinner = false;

                // showing success message
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success!!',
                    message: 'Selected All Enquiries Rejected Successfully!!.',
                    variant: 'success'
                }));

                // refreshing table data using refresh apex
                this.listOfLostEnquires = [];
                refreshApex(this.listOfLostEnquires);  
                refreshApex(this.LostEnquiresRecords); 
                return refreshApex(this.listOfLostEnquires);
            })
            .catch(error => {
                this.showLoadingSpinner = false;
                window.console.log('Error ====> ' + error);
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error!!',
                    message: error.message,
                    variant: 'error'
                }));
            }
        );
    }

    //------------------------------------------ Change Enquiry Owner Modal -----------------------------------//
    ChangeEnquiryOwnerModal(event) {
        let arr = this.listOfLostEnquires;
        let arr2 = [];
        for (let i = 0; i < arr.length; i++) {
            if (this.selectedEnquiryMap.get(i.toString()) === true) {
                arr2.push(arr[i].objOpp.Id);
            }
        }
        if (arr2.length > 0){
            this.isChangeEnquiryOwnerModal = true;
            //document.body.setAttribute('style', 'position: fixed;');  
        }
        if (arr2.length <= 0) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please Select Atleast One Enquiry Before Changing Owner.',
                    variant: 'error'
                })
            )
        }
    }

    changeOwner() {
        this.showLoadingSpinner = true;
        console.log('@@## Selected ',this.selectedRecord.Id);
        changeEnquiryOwner({ listOfLEWrapper : JSON.stringify(this.listOfLostEnquires), ownerId : this.selectedRecord.Id })
            .then(result => {
                //this.listOfLostEnquires = result;
                this.isChangeEnquiryOwnerModal = false;
                this.newTempEnquiryRecord = [];  
                this.showLoadingSpinner = false;

                // showing success message
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success!!',
                    message: 'Selected Enquiries Owner Changed Successfully!!.',
                    variant: 'success'
                }));

                // refreshing table data using refresh apex
                refreshApex(this.listOfLostEnquires);  
                return refreshApex(this.refreshTable);
            })
            .catch(error => {
                this.showLoadingSpinner = false;
                //window.console.log('Error ====> ' + JSON.stringify(error));
                var err = JSON.stringify(error);
                window.console.log('Error Json ====> ' + err);
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error!!',
                    message: JSON.stringify(error.message),
                    variant: 'error'
                }));
            }
        );
    }

    handleOnchange(event)    {
        console.log('@@## showLoadingSpinner '+this.showLoadingSpinner);
        console.log('@@## event.detail.value '+event.detail.value);
        //this.showLoadingSpinner = true;
        this.showList = false;
        if(event.detail.value != ''){
            userList({dealerId:this.dealerAccount, name:event.detail.value})
            .then(result =>{
                //console.log('@@## result.dataList '+result.dataList.length);
                if(result.dataList.length > 0){
                    this.partnerUser = result.dataList;
                }else{
                    this.partnerUser = undefined;   
                }
                //this.showLoadingSpinner = false;
            })
            .catch(error => {
                this.loadSpinner=false;
                this.error = error;
                this.tostMessage(UI_Error_Message,0,'Error','');
            });        
            //console.log(event.detail.value);
        }else{
            this.partnerUser = undefined;  
        }        
    }

    handleSelect(event)    {
        const selectedRecordId = event.detail;
        this.showList = true;
        this.selectedRecord = this.partnerUser.find( record => record.Id === selectedRecordId);
        console.log('@@## Selected ',this.selectedRecord.Id);
    }
    
    handleRemove(){        
        this.selectedRecord = undefined; 
        this.partnerUser = undefined;    
        this.showList = undefined;
    }

    // This method is use for close Accept All Enquiry Modal.
    closeAcceptAllEnqModal() {
        this.isAcceptAllEnqModal = false;
        document.body.setAttribute('style', 'position: unset;'); 
    }
    // This method is use for close Reject All Enquiry Modal.
    closeRejectAllEnqModal() {
        this.isRejectAllEnqModal = false;
        document.body.setAttribute('style', 'position: unset;'); 
    }
    // This method is use for close Change Enquiry Owner Modal.
    closeChangeEnquiryOwnerModal() {
        this.isChangeEnquiryOwnerModal = false;
        this.handleRemove();
        document.body.setAttribute('style', 'position: unset;'); 
    }

}