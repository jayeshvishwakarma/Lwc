/* eslint-disable no-alert */
import { LightningElement, track, wire, api} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import findVIN from '@salesforce/apex/TestDriveFunctionality.findVIN';
import findVariant from '@salesforce/apex/TestDriveFunctionality.findVariants';
import getTestDriveSlot from '@salesforce/apexContinuation/MSILMuleSoftIntegration.getTestDriveSlot';
import bookTDSlot from '@salesforce/apexContinuation/MSILMuleSoftIntegration.createOrUpdateOrCancelBooking';
import createTestDriveSF from '@salesforce/apex/TestDriveFunctionality.createTestDriveSF';
import saveSignatureMethod from '@salesforce/apex/SaveSignature.saveSignatureMethod'; 
import getOrgId from '@salesforce/schema/Organization.Id';
import {getRecord} from 'lightning/uiRecordApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import CURRENTUSERID from '@salesforce/user/Id';
//import model from '@salesforce/schema/Opportunity.Exchange_Model__c';
import testDriveLocations from '@salesforce/schema/Test_Drive__c.Location__c';
import vehicleFuleList from '@salesforce/schema/Product2.Fuel_Type__c';
import modelofInterest from '@salesforce/schema/Opportunity.Model_of_Interest__c';

/******** Error messagess ***********/
import UI_Error_Message from '@salesforce/label/c.UI_Error_Message';
import noVehicleFound from '@salesforce/label/c.Error_Message_No_Vehicle_Found';
import mspinMissing from '@salesforce/label/c.Error_Message_Missing_MSPIN';
import missingFieldnSignature from '@salesforce/label/c.Error_Message_Missing_Field_and_Signature';

const DELAY = 300;
export default class TestDriveScheduling extends NavigationMixin(LightningElement) {
    @track showPage1=true;
    @track showPage2=false;
    @track searchKey = '';
    @track searchVar='';
    @track searchVin='';
    @track noRecordsFlag = false;  
    @track showoptions = true;
    @track showoptionsProductCode = true;    
    @track selectedName;  
    @track selectedVariant; //This field is used for storing selected model
    @track vin;
    @track vins;
    @api selectedSlot=[];
    @track VINOptions=[];
    @track dateOptions=[];
    @track startTimeOptions=[]; //Used for Start Time slot drop down
    @track endTimeOptions=[];   //Used for end Time slot drop down
    @track selectedStartTime;
    @track selectedEndTime;
    @track selectedDate;
    @track bookTDSlotData;
    @track SlotOptions=[];
    @track showoptionsVIN=true;
    @track today;
    @track durationVal='15'; //This variable is used for Duration dropdown
    @track timeSlotResponse;
    @track key;
    @track sKey;
    @track loc='Showroom';
    @track selectedCheckBox=[]; //This veriable is used to store selected checkbox
    @track newDate;
    @track checkBoxLoopVal;
    @track loadSpinner=false;
    @track multiSelectRequired=true;
    @track slotsMap;
    @track testDriveCreateShow=false; // This variable is used to check which fields should visiable to user
    @track locationList=[]; // This variable is used to store location list from picklist of test drive object
    @track fuleList=[];     // This variable is used to store fuel list from fule type picklist of Product2 object
    @track selectedFuelType=''; // This variable is used to store selected fuel on test drive scheduling screen.
    @track modelofInterest=[]; // This variable is used to store model of interest picklist
    @track testDriveTitle='Schedule Test Drive'; // This variable is used for title of different test drive
    @track feedBackAnswerSelected; // This variable is used to store selected feedback answer.
    @track feedback; // This variable is used to store feedback given by customer.
    @track todayDate; // This variable is used to store today date
    @track variants=[];
    @track variant; // This variable is used to store selected variant
    @track testDriveId;
    @track kmDriven; // This variable is used to store KM Driven
    @track SelectedVin; //
    testDriveData;
    /***********Booking test drive slot veriables *******/
    @track assetsId;
    @track enquiryId;
    @track bookingId;
    @track bookingDate;
    @track startTime;
    @track endTime;
/***************************************************/
    variantSelected; //This variable is used to store variant of selected vehicle
    //satisfication; // This variable is used to store customer is satisfied or not
    // API properties  
    @api selectedsobject;  
    @api recordlimit;  
    @api label;  
    @api record;
    @api recordId;
    @api testDriveType; // This variable is used to check which component is called(Create/Schedule)
   
    /* eslint-disable no-console */
    userDetail; // This variable  is used to store current user's detail
    dateTimeDiff; // This variable is used to store time difference in min

    @wire(getRecord, { recordId: CURRENTUSERID, fields: ['User.Dealer_Employee_Code__c'] })
    currentUser({ error, data }) {
        console.log('Inside currentUser');
        console.log(data);
        if (data) {
            this.userDetail = data;
            
        }
        else{
            console.log(error);
        }
    }
    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: testDriveLocations})
    typePicklistValuesLocations({error, data}){
        if (data) {
            this.locationList=data;
        } else if(error){
            console.log('Inside error');
        }
    }
    
    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: vehicleFuleList})
    typePicklistValuesFuleList({error, data}){
        if (data) {
           // console.log('===>>'+JSON.stringify(data));
            this.fuleList=data;
        } else if(error){
            console.log('Inside error');
        }
    }
    
    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: modelofInterest})
    typePicklistValuesModelofInterest({error, data}){
        if (data) {
            console.log('Inside typePicklistValuesModelofInterest');
            this.modelofInterestList=data;
        } else if(error){
            console.log('Inside error');
        }
    }
    @wire(getRecord, { recordId: '$recordId', fields: ['Opportunity.Customer__r.PersonContactId','Opportunity.DSE_MSPIN__c','Opportunity.Dealership__c','Opportunity.DMS_Enquiry_Name__c','Opportunity.Customer__c','Opportunity.Line_Of_Business__c'] })
    wiredOpportunity({ error, data }) {
        console.log('Inside wiredOpportunity');
        console.log(data);
        if (data) {
            this.record = data;
            let key=this.modelofInterestList.controllerValues[this.record.fields.Line_Of_Business__c.value];
            this.modelofInterest = this.modelofInterestList.values.filter(opt => opt.validFor.includes(key));
            this.selectedVariant=this.modelofInterest[0].value;
            this.selectedName=this.modelofInterest[0].value;
            if(this.testDriveType!=='C')
            {
                this.findVINs();
            }
            else{
                this.findVariants();
            }
            
        }
        else{
            console.log(error);
        }
    }
    @wire(getOrgId)
    orgId;
   

connectedCallback(){
    console.log('inside connectedCallback');
    let tDate = new Date();
    let month=tDate.getMonth()+1;
    month=month>9?month:'0'+month;
    let curDate=tDate.getDate()>9?tDate.getDate():'0'+tDate.getDate();
    this.todayDate=tDate.getFullYear()+'-'+month+'-'+curDate;
    if(this.testDriveType==='C')
    {
        this.testDriveCreateShow=true;
        this.testDriveTitle='Create Test Drive';
    }
    this.template.addEventListener('click', this.handleTemplateClick.bind(this));   
}
/*** This function is used to get varients(Used when test drive vehicle is not available) ***/
findVariants()
{
    findVariant({searchVar:this.selectedVariant})
    .then(result => {
        console.log('Inside findVariant');
        console.log(result);
        this.variants=[];
        if(result.dataList.length>0)
                    {
                        result.dataList.forEach(element=>{
                            this.variants.push({label:element.Name, value:element.ProductCode});
                            //this.variants = [...this.variants, {label:element.Name, value:element.ProductCode}];
                        })
                    }
    })
    .catch(error => {
        this.error = error;
        //this.loadSpinner=false;
        this.tostMessage(UI_Error_Message,0,'Error','');
    });

}

handleTemplateClick(event){
    console.log('Inside handleTemplateClick');
    if(this.showPage2)
    {   
        this.template.querySelector('c-multi-select-cmp').handleClick(event);
    }   
}

get feedBackOptions() {
    return [
        { label: 'Yes', value: 'Yes' },
        { label: 'No', value: 'No' },
    ];
}

/******************This function will close the lwc **************************************/
cancel()
{
    console.log('cancel');
    this[NavigationMixin.Navigate]({
        type: 'standard__recordPage',
        attributes: {
            recordId: this.recordId,
            objectApiName: 'Opportunity', // objectApiName is optional
            actionName: 'view'
        }
    });
}
/******************This function will close the lwc and redirct to other page **************************************/
redirct(id)
{
    this[NavigationMixin.Navigate]({
        type: 'standard__recordPage',
        attributes: {
            recordId: id,
           // objectApiName: 'Opportunity', // objectApiName is optional
            actionName: 'view'
        }
    });
}
/*****************************************************************************************/

/************************This method is used to handle back functionality ******************/
back()
{
    this.selectedDate='';
    this.selectedSlot='';
    this.showPage1=true;
    this.showPage2=false;
}
/*****************************************************************************************/

/********************* This function is used to show check box options ***********************/
get checkboxOptions() {
    return [
        { label: 'Create Without Confirmed Slot', value: 'selected' },
        
    ];
}
/**** This fuction is used to create date and time slot for Create Without Confirmed Slot ****/
createDateNSlot()
{
    const allValid = [...this.template.querySelectorAll('lightning-input')]
                .reduce((validSoFar, inputCmp) => {
                            inputCmp.reportValidity();
                            return validSoFar && inputCmp.checkValidity();
                }, true);
    const allValid1 = [...this.template.querySelectorAll('lightning-combobox')]
                .reduce((validSoFar, inputCmp) => {
                            inputCmp.reportValidity();
                            return validSoFar && inputCmp.checkValidity();
                }, true);
        this.dateOptions=[];        
    if(allValid && allValid1 && this.selectedCheckBox.length>0 && this.durationVal!==undefined && this.vin!==undefined)
        {
            
            this.today = new Date();
            
            // eslint-disable-next-line radix
            if(parseInt(this.durationVal)===15)
            {
                
                for(this.checkBoxLoopVal=1;this.checkBoxLoopVal<=15;this.checkBoxLoopVal++)
                {
                    
                    this.newdate=new Date();
                    this.newdate.setDate(this.today.getDate()+this.checkBoxLoopVal);
                    let month=this.newdate.getMonth()+1;
                    let curMonth=month>9?month:'0'+month;
                    let curDate=this.newdate.getDate()>9?this.newdate.getDate():'0'+this.newdate.getDate();
                    this.dateOptions=[...this.dateOptions,{label:curDate+'/'+curMonth+'/'+this.newdate.getFullYear(), value:this.newdate.getFullYear()+'-'+curMonth+'-'+curDate}];
                    //this.dateOptions=[...this.dateOptions,{label:this.newdate.getFullYear()+'-'+month+'-'+this.newdate.getDate(), value:this.newdate.getFullYear()+'-'+month+'-'+this.newdate.getDate()}];
                }
                
            }
            // eslint-disable-next-line radix
            else if(parseInt(this.durationVal)===30)
            {
                for(this.checkBoxLoopVal=1;this.checkBoxLoopVal<=30;this.checkBoxLoopVal++)
                {
                    
                    this.newdate=new Date();
                    this.newdate.setDate(this.today.getDate()+this.checkBoxLoopVal);
                    let month=this.newdate.getMonth()+1;
                    this.dateOptions=[...this.dateOptions,{label:this.newdate.getFullYear()+'-'+month+'-'+this.newdate.getDate(), value:this.newdate.getFullYear()+'-'+month+'-'+this.newdate.getDate()}];
                }
                
            }
            this.SlotOptions=[
                { Id: '09:00 to 09:30', Name:'09:00 to 09:30'},
                { Id: '09:30 to 10:00', Name:'09:30 to 10:00'},
                { Id: '10:00 to 10:30', Name:'10:00 to 10:30'},
                { Id: '10:30 to 11:00', Name:'10:30 to 11:00'},
                { Id: '11:00 to 11:30', Name:'11:00 to 11:30'},
                { Id: '11:30 to 12:00', Name:'11:30 to 12:00'},
                { Id: '12:00 to 12:30', Name:'12:00 to 12:30'},
                { Id: '12:30 to 13:00', Name:'12:30 to 13:00'},
                { Id: '13:00 to 13:30', Name:'13:00 to 13:30'},
                { Id: '13:30 to 14:00', Name:'13:30 to 14:00'},
                { Id: '14:00 to 14:30', Name:'14:00 to 14:30'},
                { Id: '14:30 to 15:00', Name:'14:30 to 15:00'},
                { Id: '15:00 to 15:30', Name:'15:00 to 15:30'},
                { Id: '15:30 to 16:00', Name:'15:30 to 16:00'},
                { Id: '16:00 to 16:30', Name:'16:00 to 16:30'},
                { Id: '16:30 to 17:00', Name:'16:30 to 17:00'},
                { Id: '17:00 to 17:30', Name:'17:00 to 17:30'},
                { Id: '17:30 to 18:00', Name:'17:30 to 18:00'},
                { Id: '18:00 to 18:30', Name:'18:00 to 18:30'},
                { Id: '18:30 to 19:00', Name:'18:30 to 19:00'},
                { Id: '19:00 to 19:30', Name:'19:00 to 19:30'},
                { Id: '19:30 to 20:00', Name:'19:30 to 20:00'},
                { Id: '20:00 to 20:30', Name:'20:00 to 20:30'},
                { Id: '20:30 to 21:00', Name:'20:30 to 21:00'},
            ];
            this.showPage1=false;
            this.showPage2=true;
        }
}

handleCheckBoxChange(event)
    {
        
        this.selectedCheckBox=event.detail.value;
        this.createDateNSlot();
        

    }
/*****************************************************************************************/
    kmDrivenChangeHandler(event)
    {
        this.kmDriven=event.detail.value;
    }
    handleSatisficationChange(event)
    {
        console.log(event.detail.value);
        this.feedBackAnswerSelected=event.detail.value;
    }
    handleFeedbackChange(event)
    {
        this.feedback=event.detail.value;
    }
   handleLocationChange(event)
    {
        
        this.loc=event.detail.value;
        
    }

   startTimeChangeHandler(event)
   {
    console.log(event.detail.value);
    this.startTime=event.detail.value;
   } 
   endTimeChangeHandler(event)
   {
    this.endTime=event.detail.value;
   } 

   /******** This function is used to create test drive on sfdc  ********/
   createTestDrive()
   {
    console.log('Inside createTestDrive');
    createTestDriveSF({data:JSON.stringify(this.testDriveData)})
        .then(result1 =>{
            console.log('Inside result');
            if(result1.code===200)
            {

                this.testDriveId=result1.createdId;
                if(this.testDriveType==='C')
                {
                    this.save();
                }
                this.loadSpinner=false;
                this.tostMessage(result1.message,result1.code,result1.status,result1.createdId);
            }
            else{
                this.loadSpinner=false;
                this.tostMessage(UI_Error_Message,result1.code,result1.status,this.recordId);
            }
            
        })
        .catch(error => {
            this.loadSpinner=false;
            this.error = error;
            this.tostMessage(UI_Error_Message,0,'Error','');
        });
   }
    
   /********************************* This function is used to book test drive slot*************************** */
    bookTestDriveSlot()
    {
        this.loadSpinner=true;
        const allValid = [...this.template.querySelectorAll('lightning-combobox')]
        .reduce((validSoFar, inputCmp) => {
                    inputCmp.reportValidity();
                    return validSoFar && inputCmp.checkValidity();
        }, true);
        let dealerEmpId='';
        if(this.userDetail.fields.Dealer_Employee_Code__c.value!==null && this.userDetail.fields.Dealer_Employee_Code__c.value!==undefined && this.userDetail.fields.Dealer_Employee_Code__c.value.includes('_'))
        {
            dealerEmpId=this.userDetail.fields.Dealer_Employee_Code__c.value.split('_')[1];
        }
        if(this.testDriveType==='S')
        {
            console.log(this.loadSpinner);
            console.log(allValid);
            if(this.selectedSlot===undefined || this.selectedSlot.length===0 || this.selectedSlot==='')
            {
                this.template.querySelector('c-multi-select-cmp').setPickListName(this.selectedSlot);
                this.loadSpinner=false;
            }
            else if(this.selectedDate!==undefined && this.selectedDate!=='' && allValid){
                console.log('Inside Else if');
                //this.loadSpinner=true;
                this.bookingDate=this.selectedDate;
                if(this.selectedSlot.length===1)
                {
                    this.startTime=this.selectedSlot[0].Name.split(' to ')[0];
                    this.endTime=this.selectedSlot[0].Name.split(' to ')[1];
                }
                else if(this.selectedSlot.length>1)
                {
                    this.startTime=this.selectedSlot[0].Name.split(' to ')[0];
                    this.endTime=this.selectedSlot[this.selectedSlot.length-1].Name.split(' to ')[1];
                }
                
                let tdrd={
                    "optType" : this.testDriveType,
                    "mspin": this.record.fields.DSE_MSPIN__c.value,
                    "model": this.selectedVariant, 
                    "variant": this.variantSelected,
                    "location": this.loc,
                    "status":this.testDriveType==='C'?"COMPLETED":"RESERVED", //"RESERVED",
                    "owner": "1",
                    "enquiryId": this.record.fields.DMS_Enquiry_Name__c.value, //"19000050",
                    "salesPersonId": dealerEmpId,//"EMP2096",
                    "scheduleStartTime": this.bookingDate+'T'+this.startTime+':00.090Z',
                    "scheduleEndTime": this.bookingDate+'T'+this.endTime+':00.090Z' ,
                    "duration":0,
                    "drivenKM" : this.testDriveType==='C'?this.kmDriven:0,
                    "signature": false,
                    "vin": this.vin,
                    "orgId": 1,
                    "salesforceId": ""  
                  };
                  console.log(tdrd);
                this.callBookTestDriveAPI(tdrd);
            }
            else{
                //console.log('Inside else');
                this.loadSpinner=false;
            }
            
        }
        else{
            const allValidCreate = [...this.template.querySelectorAll('lightning-input')]
        .reduce((validSoFar, inputCmp) => {
                    inputCmp.reportValidity();
                    return validSoFar && inputCmp.checkValidity();
        }, true);
        const allValidCreateSatisfied = [...this.template.querySelectorAll('lightning-radio-group')]
        .reduce((validSoFar, inputCmp) => {
                    inputCmp.reportValidity();
                    return validSoFar && inputCmp.checkValidity();
        }, true);
        const checkTextAreaFeedBack = [...this.template.querySelectorAll('lightning-textarea')]
        .reduce((validSoFar, inputCmp) => {
                    inputCmp.reportValidity();
                    return validSoFar && inputCmp.checkValidity();
        }, true);
            console.log(this.todayDate);
            console.log(this.sTime);
            console.log(this.eTime);
            if(allValidCreate && this.padTOuched===true && allValidCreateSatisfied && checkTextAreaFeedBack)
            {
                let dateSplit=this.todayDate.split('-');
                let startTimeSplit=this.startTime.split(':');
                let endTimeSplit=this.endTime.split(':');
                this.dateTimeDiff=Math.abs(new Date(dateSplit[0], dateSplit[1], dateSplit[2], endTimeSplit[0], endTimeSplit[1], '00', '00')- new Date(dateSplit[0], dateSplit[1], dateSplit[2], startTimeSplit[0], startTimeSplit[1], '00', '00'));
                this.dateTimeDiff=Math.floor((this.dateTimeDiff/1000)/60);
                let tdrd={
                    "optType" : this.testDriveType,
                    "mspin": this.record.fields.DSE_MSPIN__c.value,
                    "model": this.selectedVariant, 
                    "variant": this.variantSelected,
                    "location": this.loc,
                    "status":this.testDriveType==='C'?"COMPLETED":"RESERVED", //"RESERVED",
                    "owner": "1",
                    "enquiryId": this.record.fields.DMS_Enquiry_Name__c.value, //"19000050",
                    "salesPersonId": dealerEmpId,
                    "scheduleStartTime": this.todayDate+'T'+this.startTime+'Z',
                    "scheduleEndTime": this.todayDate+'T'+this.endTime+'Z' ,
                    "duration": this.dateTimeDiff,
                    "drivenKM" : this.kmDriven,
                    "signature": false,
                    
                    "orgId": 1,
                    "salesforceId": ""  
                  };
                this.callBookTestDriveAPI(tdrd);
            }
            else{
                this.tostMessage(missingFieldnSignature,0,'Error','');
                this.loadSpinner=false;
            }
            
        }
        //this.loadSpinner=false;
        
    }

    callBookTestDriveAPI(testDriveRawData)
    {
        console.log('Inside callBookTestDriveAPI');
        console.log(testDriveRawData);
        if(this.record.fields.DSE_MSPIN__c.value!==null && this.record.fields.DSE_MSPIN__c.value!==''&& this.record.fields.DMS_Enquiry_Name__c.value!==null && this.record.fields.DMS_Enquiry_Name__c.value!=='')
            {
                bookTDSlot({apiType:'Create Booking',methodType:'POST',testDriveRawData:JSON.stringify(testDriveRawData),bookinId:''})
                .then(result => {
                    this.bookTDSlotData=JSON.parse(result);
                    if(this.testDriveType==='S')
                    {
                        console.log('Inside if when S');
                        if(this.bookTDSlotData.status==='Success' && this.record.fields.Customer__c.value!==null && this.record.fields.Customer__c.value!=='')
                        {
                            this.testDriveData={contactId:this.record.fields.Customer__r.value.fields.PersonContactId.value,assetId:this.assetsId,fuelType:this.selectedFuelType ,enquiryId:this.recordId,bookingId:'',bookingDate:this.bookingDate,startTime:this.startTime,endTime:this.endTime,location:this.loc,svocCustomer:this.record.fields.Customer__c.value,status:'RESERVED'};
                            this.createTestDrive();
                        }
                        else{
                            this.loadSpinner=false;
                            this.tostMessage(UI_Error_Message,0,'Failed','');
                        }
                        
                    }
                    else{
                        console.log('Inside else when C');
                        if(this.bookTDSlotData.status==='Success' && this.record.fields.Customer__c.value!==null && this.record.fields.Customer__c.value!=='')
                        {
                            
                            //this.bookingId=this.bookTDSlotData.bookingId;
                            console.log('Inside if of else');
                            console.log(this.todayDate+'T'+this.startTime+'Z');
                            this.testDriveData={contactId:this.record.fields.Customer__r.value.fields.PersonContactId.value,fuelType:this.selectedFuelType ,enquiryId:this.recordId,bookingId:this.bookTDSlotData.bookingId,bookingDate:this.todayDate,startTime:this.startTime,endTime:this.endTime,location:this.loc,svocCustomer:this.record.fields.Customer__c.value,status:'COMPLETED',kmDriven:this.kmDriven,satisfied:this.feedBackAnswerSelected,feedback:this.feedback,duration:this.dateTimeDiff};
                            console.log(this.testDriveData);
                            this.createTestDrive();
        
        
                        }
                        else{
                            console.log('Inside else of else');
                            this.loadSpinner=false;
                            this.tostMessage(UI_Error_Message,0,'Error','');
                        }
                    }
                    
                    
                })
                .catch(error => {
                    this.error = error;
                    this.loadSpinner=false;
                    this.tostMessage(UI_Error_Message,0,'Error','');
                });
            }
        else{
                console.log('Inside else');
                this.loadSpinner=false;
                this.tostMessage(mspinMissing,1,'Error',0);
            }
    }
    tostMessage(message,code,status,id)
    {
        const showSuccess = new ShowToastEvent({
            title: status,
            message: message,
            variant: status,
        });
        this.dispatchEvent(showSuccess);
        if(code===200)
        {
            console.log('Inside if');
            this.redirct(id);
        }
        
    }

    handleDateChange(event)
    {
        
        this.selectedDate=event.detail.value;
        if(this.selectedCheckBox.length===0)
        {
            this.SlotOptions=[];
            this.SlotOptions=this.slotsMap.get(this.selectedDate);
        }
        
    }
    handleTimeSlot(event)
    {
        
        this.selectedSlot=event.detail.value;
    }
/***************************This part is for Duration dropdown values******************/
    get options() {
        return [
            
            { label: '15 Days', value: '15' },
            { label: '30 Days', value: '30' },
        ];
    }
/************************ Dropdown values for timeSlots**************/
/*get TimeSlotOptions(){
    return[
        { label: '9:00 am to 9:30 am', value:'9930'},
        { label: '10:00 am to 10:30 am', value:'101030'},
        { label: '11:30 am to 12:00 pm', value:'113012'},
        { label: '5:00 pm to 5:30 pm', value:'5530'},
        { label: '6:30 pm to 7:00 am', value:'6307'},
    ];
}*/

get VINOptions()
{
    return [];
}
handleDurationChange(event) {
    console.log(event.detail.value);
        this.durationVal= event.detail.value;
        this.createDateNSlot();
    }

handleVINChange(event)
{
    console.log(this.VINOptions);
    console.log(event.detail.value);
    console.log(event.target.value);
    console.log(this.vin);
    this.SelectedVin=event.detail.value;
   let selectedVehicle=this.vins.find(vin => vin.Id=== event.target.value);
   console.log(selectedVehicle);
    //this.variantSelected=this.vins.find(vin => vin.Id=== event.target.value).Product2.ProductCode;
    this.variantSelected=selectedVehicle.Product2.ProductCode;
    this.vin=selectedVehicle.VIN__c;
    this.assetsId=selectedVehicle.Id;
    console.log(this.vin);
    console.log(this.variantSelected);
}
/**************************************************************************************/
    handleKeyChange(event) {
        // Debouncing this method: Do not update the reactive property as long as this function is
        // being called within a delay of DELAY. This is to avoid a very large number of Apex method calls.
        this.showoptions=true;
        window.clearTimeout(this.delayTimeout);
        const searchKey = event.target.value;
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.delayTimeout = setTimeout(() => {
            this.searchKey = searchKey;
        }, DELAY);
    }
    handleSearchVariant(event)
    {
        /* eslint-disable no-console */
        console.log('Inside handleSearchVariant');
        this.variantSelected=event.target.value;
        /*this.showoptionsProductCode=true;
        const searchVar=event.target.value;
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.delayTimeout = setTimeout(() => {
            this.searchVar=searchVar;
        }, DELAY);
        console.log(this.searchVar);*/
    }

    handleSearchVIN(event)
    {
         const searchVin = event.target.value;
         // eslint-disable-next-line @lwc/lwc/no-async-operation
         this.delayTimeout = setTimeout(() => {
             this.searchVin=searchVin;
         }, DELAY);
    }
        // This method handles the selection of lookup value  
        // eslint-disable-next-line no-unused-vars
    handleLookupSelect(event) {  
          this.selectedName = event.detail.Family;  
          this.showoptions=false;
          
        }  

/****** This function is used to populate vehicle on basic of selected Variant/Model******/
    handleVariantSelect(event)
        {
            console.log('handleVariantSelect');
            this.vin='';
            if(event.target.dataset.type==='model')
            {
                this.selectedName=event.detail.value;
                this.selectedVariant=event.detail.value;
            }
            else{
                this.selectedFuelType=event.detail.value;
            }
            if(this.testDriveType!=='C')
            {
                this.findVINs();
            }
            else{
                this.findVariants();
            }
            
            console.log('this.event.detail.value-->'+event.detail.value);
            console.log('this.selectedName-->'+this.selectedName);

              
        }
/*****************************************************************************************/

findVINs()
{
    this.VINOptions=[];
        findVIN({selectedName:this.selectedName,dealerAccount:this.record.fields.Dealership__c.value,fuleType:this.selectedFuelType})
        .then(result => {
                console.log('Inside Find VIN');
                console.log(result);
                this.showoptionsProductCode=false;
                this.vins=result;
                if(result.length>0)
                {
                    this.vins.forEach(element=>{
                        this.VINOptions = [...this.VINOptions, {label:element.Name, value:element.Id}];

                    })
                }
                else{
                    this.tostMessage(noVehicleFound,1,'error',0);
                }
                
            })
            .catch(error => {
                this.error = error;
                this.tostMessage(UI_Error_Message,1,'error',0);
            });  
}

/******** This function is used to get available test drive slots from DMS  **************/
        // eslint-disable-next-line no-unused-vars
    fetchScheduleInfo(event){
        console.log('Current value of the input: ');
        this.dateOptions=[];
        const allValid = [...this.template.querySelectorAll('lightning-input')]
            .reduce((validSoFar, inputCmp) => {
                        inputCmp.reportValidity();
                        return validSoFar && inputCmp.checkValidity();
            }, true);
        const allValidComboBox = [...this.template.querySelectorAll('lightning-combobox')]
            .reduce((validSoFar, inputCmp) => {
                        inputCmp.reportValidity();
                        return validSoFar && inputCmp.checkValidity();
            }, true);
        if (allValid && allValidComboBox && this.durationVal!==undefined && this.vin!==undefined) {
            this.loadSpinner=true;
            
            if(this.record.fields.DSE_MSPIN__c.value!==null && this.record.fields.DSE_MSPIN__c.value!=='' && this.record.fields.DMS_Enquiry_Name__c.value!==null && this.record.fields.DMS_Enquiry_Name__c.value!=='')
            {
                getTestDriveSlot({apiType:'Test Drive Slots',vin:this.vin,dateRange:this.durationVal,enquiryId:this.record.fields.DMS_Enquiry_Name__c.value,mspin:this.record.fields.DSE_MSPIN__c.value,orgId:1})
                .then(result => {
                    console.log(result);
                    this.timeSlotResponse = JSON.parse(result);
                    this.slotsMap=new Map();
                    this.timeSlotResponse.availableslots.forEach(element => {
                        // this.dateOptions = [...this.dateOptions, {label:element.bookingDate, value:element.bookingDate}];
                        let bookingDateSplit=element.bookingDate.split('-');
                        this.dateOptions = [...this.dateOptions, {label:bookingDateSplit[2]+'/'+bookingDateSplit[1]+'/'+bookingDateSplit[0], value:element.bookingDate}]; 
                        this.SlotOptions=[];
                        element.timeSlots.forEach(slots=>{
                            this.SlotOptions = [...this.SlotOptions, {Id:slots.fromTime+' to '+slots.toTime, Name:slots.fromTime+' to '+slots.toTime}];

                        });
                        this.slotsMap.set(element.bookingDate,this.SlotOptions);
                    });
                    this.loadSpinner=false;
                })
                .catch(error => {
                    this.error = error;
                });
                this.showPage1=false;
                this.showPage2=true;
            }
            else{
                this.loadSpinner=false;
                this.tostMessage(mspinMissing,1,'error',0);
            }
        } else {
            // eslint-disable-next-line no-alert
            //alert('Please update the invalid form entries and try again.');
        }
        
    }
/*****************************************************************************************/
        //Handler
        valueSelected(event){
            //Assign the selected values to selectedSlot variable
            this.selectedSlot = event.detail;
        }
        // Used to close dropdown of multiselect





 /**************** Signature Part ****************************/

 @api closeModal = false;
 @api testDriveId;
 @track showspinner = false
 canvas = false
 ctx = false
 flag = false
 prevX = 0
 currX = 0
 prevY = 0
 currY = 0
 dot_flag = false;
 x = "black";
 y = 2;
 w;
 h;
 ratio;
 padTOuched = false;


 //Method to run on every rendered callback of component
 renderedCallback() {
     if(this.testDriveType==='C')
     {
        this.canvas = this.template.querySelector('[data-id="can"]');
        this.ratio = Math.max(window.devicePixelRatio || 1, 1);
        this.w = this.canvas.width * this.ratio;
        this.h = this.canvas.height * this.ratio;
   
        //For desktop mouse move events
        this.canvas.addEventListener('mousemove', this.handlemouseMove.bind(this));
        this.canvas.addEventListener('mousedown', this.handlemousedown.bind(this));
        this.canvas.addEventListener('mouseup', this.handlemouseup.bind(this));
        this.canvas.addEventListener('mouseout', this.handlemouseout.bind(this));
   
        // Set up touch events for mobile, etc
        this.canvas.addEventListener('touchstart', this.handletouchstart.bind(this));
        this.canvas.addEventListener('touchend', this.handletouchend.bind(this));
        this.canvas.addEventListener('touchmove', this.handletouchmove.bind(this));
     }
    
 }


 //Method to move the pointer in the Canvas and perform draw event
 handlemouseMove(e) {
     const rect = this.canvas.getBoundingClientRect();
     if (this.flag) {
         this.prevX = this.currX;
         this.prevY = this.currY;
         this.currX = e.clientX - rect.left;
         this.currY = e.clientY - rect.top;
         this.draw(this.template, this.ctx);
     }
 }

 //Method to calculate the x, y coordinates of the mouse in canvas when button is clicked
 handlemousedown(e) {
     this.ctx = this.canvas.getContext("2d");
     const rect = this.canvas.getBoundingClientRect();
     this.prevX = this.currX;
     this.prevY = this.currY;
     this.currX = e.clientX - rect.left;
     this.currY = e.clientY - rect.top;

     this.flag = true;
     this.dot_flag = true;
     if (this.dot_flag) {
         this.ctx.beginPath();
         this.ctx.fillRect(this.currX, this.currY, 2, 2);
         this.ctx.closePath();
         this.dot_flag = false;
     }
 }

 handlemouseup() {
     this.flag = false;
 }

 //method to check if the pointer is inside the canvas or not
 handlemouseout() {
     this.flag = false;
 }

 // Set up touch events for mobile, etc
 handletouchstart(e) {
     var touch = e.touches[0];
     var mouseEvent = new MouseEvent("mousedown", {
         clientX: touch.clientX,
         clientY: touch.clientY
     })
     this.canvas.dispatchEvent(mouseEvent);
     e.preventDefault();
 }

 // Set up touch events for mobile, etc     
 handletouchend() {
     var mouseEvent = new MouseEvent("mouseup", {});
     this.canvas.dispatchEvent(mouseEvent);
 }

 // Set up touch events for mobile, etc
 handletouchmove(e) {
     var touch = e.touches[0];
     var mouseEvent = new MouseEvent("mousemove", {
         clientX: touch.clientX,
         clientY: touch.clientY
     });
     this.canvas.dispatchEvent(mouseEvent);
     e.preventDefault();
 }

 //method to draw on canvas
 draw() {
     this.padTOuched = true;
     this.ctx.beginPath();
     this.ctx.moveTo(this.prevX, this.prevY);
     this.ctx.lineTo(this.currX, this.currY);
     this.ctx.stroke();
     this.ctx.closePath();
 }


 //Erase signature
 eraseHelper() {
     if (confirm('Are you sure?')) {
         this.padTOuched = false;
         let canvas = this.template.querySelector('[data-id = "can"]');
         let ctx = canvas.getContext("2d");
         let w = canvas.width;
         let h = canvas.height;
         ctx.clearRect(0, 0, w, h);
     }
 }

 //Method to save the signature under the related record
 //Calls the server side controller passing 
 save() { 
     console.log('Inside Save');
     console.log(this.testDriveId);
     if(this.padTOuched===true){
         this.showspinner = true;
         let pad = this.template.querySelector('[data-id="can"]');
         let dataURL = pad.toDataURL();
         let strDataURI = dataURL.replace(/^data:image\/(png|jpg);base64,/, "");
         console.log('Inside Save 1');
         console.log(strDataURI);
         console.log(this.testDriveId);
         //Calling server side action and passing base64 of signature and parent record Id to the server side method
         saveSignatureMethod({
             signatureBody: strDataURI,
             recordId: this.testDriveId
         })
         //Show toast message 
         .then(() => {
             this.showspinner = false;
             this.dispatchEvent(
                 new ShowToastEvent({
                     title: 'SUCCESS',
                     message: 'Signature registered successfully',
                     variant: 'SUCCESS'
                 })
             )
         })
         //after show toast message close quick action
         
         .then(() => {
                 this.dispatchEvent(new CustomEvent('close'));
                 this.showspinner = false;
             
         })
         
         //Catch error 
         .catch(error => {
             this.dispatchEvent(
                 new ShowToastEvent({
                     title: 'Error on signature save',
                     message: error.message.body,
                     variant: 'error'
                 })
             )
         })
     }else{
         this.dispatchEvent(
             new ShowToastEvent({
                 title: 'Error:',
                 message: 'Please add signature',
                 variant: 'error'
             })
         )
     }
 }
        
}