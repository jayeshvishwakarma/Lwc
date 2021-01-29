import { LightningElement, wire,track } from 'lwc';
import fetchDetails from '@salesforce/apex/ChangeMSGAEnquiryOwner.fetchDetails';
import userList from '@salesforce/apex/ChangeMSGAEnquiryOwner.getUserList';
import updateEnqOwner from '@salesforce/apex/ChangeMSGAEnquiryOwner.updateEnqOwner';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

const columns = [
    {label: 'Enquiry Name', fieldName: 'Name'},
    {label: 'Created Date', fieldName: 'CreatedDate'},
    {label: 'DMS Enquiry Number', fieldName: 'DMS_Enquiry_Name__c'},
    {label: 'Close Date', fieldName:'CloseDate'}
];
const DELAY = 300;

export default class ChangeMSGAEnquiryOwner extends LightningElement {
    showModal = false;
    showRecordsList;
    changeValueMap = new Map();
    columns = columns;
    dealerAccount;
    partnerUser;
    selectedRecord;
    showSpinner = false;
    iconname = "standard:user";
    searchfield = 'Id';    
    msgaEnquiry = [];
    loadMoreStatus;
    hideComponent = false;
    fetchEnquiries = 0;

    //lazy load
    initialRows = 10;
    totalNumberOfRows = 0;
    currentCount = 10;
    loadOffset = 1;
    //---------------------------Wired data---------------------//
    wiredResults;
    @wire(fetchDetails)
    wiredData(result) {
        this.wiredResults = result;
        if (result.data) {            
            if(result.data.userInfo.Designation__c == 'ACM'){
                this.hideComponent = false;
                if (result.data.enquiryList !== undefined && result.data.enquiryList.length <= 0)
                this.msgaEnquiry = null;
            
                if (result.data.enquiryList !== undefined && result.data.enquiryList.length > 0) {               
                    this.msgaEnquiry = result.data.enquiryList;
                    this.dealerAccount = result.data.userInfo.Contact.AccountId; 
                    this.totalNumberOfRows = result.data.enquiryList.length;            
                    console.log('total rows '+ this.totalNumberOfRows);
                } 
            } else{
                this.hideComponent = true;
            }                      
                       
        }
        else if (result.error)
            console.log('the error is ------' , JSON.stringify(result.error));
    }
    
 
    openModal(){
        let localEnqList = this.msgaEnquiry;
        let arr2 = [];
        for(let i = 0; i<localEnqList.length; i++){
            //console.log('1 '+arr[i].Id);
            //console.log('2 '+arr[i].Name);
            //console.log('3 '+this.changeValueMap.get(localEnqList[i].Id) );
            if(this.changeValueMap.get(localEnqList[i].Id) == localEnqList[i].Name){
                arr2.push(localEnqList[i].Id);
            }
        }
        //console.log('size '+ arr2.length);
        if(arr2.length > 0){
            this.showModal = true;
        }else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please select atleast one enquiry before assign to DSE',
                    variant: 'error'
                })
            )

        }                
    }
    closeModal(event){
        this.showModal = false;
        event.preventDefault();
        this.selectedRecord = undefined;
        this.records = undefined;
        this.error = undefined;
        /* fire the event with the value of undefined for the Selected RecordId */
        const selectedRecordEvent = new CustomEvent(
            "selectedrec",
            {
                detail: { recordId: undefined, index: this.index, relationshipfield: this.relationshipfield }
            }
        );
        this.dispatchEvent(selectedRecordEvent);
    }


    getSelectedEnq(event){
        //console.log('## '+ event.target.checked);
        const selectedRows = event.detail.selectedRows;
        //console.log('##! '+ JSON.stringify(selectedRows));
        if(selectedRows.length > 0){
            for (let i = 0; i < selectedRows.length; i++){
                //console.log("You selected: " + selectedRows[i].Name);           
                this.changeValueMap.set(selectedRows[i].Id, selectedRows[i].Name);
            } 
        }else {
            this.changeValueMap.clear();
        }        
              
    }

    handleOnChange(event){
        this.showRecordsList = false;        
        //console.log('this.dealeraccount '+ this.dealerAccount);
        userList({dealerId:this.dealerAccount, name:event.detail.value})
            .then(result =>{
                console.log(result);
                this.partnerUser=result.dataList;
            })
            .catch(error => {
                this.loadSpinner=false;
                this.error = error;
                this.tostMessage(UI_Error_Message,0,'Error','');
            });
        
        //console.log(event.detail.value);
    }
    handleSelect(event)
    {
        const selectedRecordId = event.detail;
        //console.log('## '+ selectedRecordId);
        this.showRecordsList=true;
        this.selectedRecord = this.partnerUser.find( record => record.Id === selectedRecordId);
        console.log(this.selectedRecord);
    }
   
    //--------------------------------------------For removal selected User---------------------------------------------------//
    handleRemove(event) {
        event.preventDefault();
        this.selectedRecord = undefined;
        this.records = undefined;
        this.error = undefined;
        /* fire the event with the value of undefined for the Selected RecordId */
        const selectedRecordEvent = new CustomEvent(
            "selectedrec",
            {
                detail: { recordId: undefined, index: this.index, relationshipfield: this.relationshipfield }
            }
        );
        this.dispatchEvent(selectedRecordEvent);
    }

    changeOwner() {
        let localEnqList = this.msgaEnquiry;
        let arr2 = [];
        for(let i = 0; i<localEnqList.length; i++){            
            //console.log('3 '+this.changeValueMap.get(localEnqList[i].Id) );
            if(this.changeValueMap.get(localEnqList[i].Id) == localEnqList[i].Name){
                arr2.push(localEnqList[i].Id);
            }
        }
        //console.log('size '+ arr2.length);
        //console.log('JSON.stringify', JSON.stringify(arr2));
        //console.log('owner Id', this.selectedRecord.Id);
        if (arr2.length > 0) {
            this.showSpinner = true;
            updateEnqOwner({
                stringData: JSON.stringify(arr2),
                ownerId: this.selectedRecord.Id
            })
                .then(result => {
                    this.showSpinner = false;
                    this.showModal = false;
                    this.message = result;
                    //this.error = undefined;
                    if (this.message === 'SUCCESS') {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'SUCCESS',
                                message: 'Owner changed successfully',
                                variant: 'SUCCESS'
                            })
                        );
                        //location.reload();                        
                    } else {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error on save',
                                message: error.message.body,
                                variant: 'error'
                            })
                        )
                    }                   
                    return refreshApex(this.wiredResults);                                       
                })
                .catch(error => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error on save',
                            message: error.message.body,
                            variant: 'error'
                        })
                    )
                })
        }
    }
}