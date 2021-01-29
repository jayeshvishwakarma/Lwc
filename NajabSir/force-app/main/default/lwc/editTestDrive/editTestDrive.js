/* eslint-disable no-alert */
/* eslint-disable no-console */
import { LightningElement,api,track,wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getTestDrive from '@salesforce/apex/TestDriveFunctionality.getTestDrive';
import getTestDriveSlot from '@salesforce/apexContinuation/MSILMuleSoftIntegration.getTestDriveSlot';
import updateOrCancelBooking from '@salesforce/apexContinuation/MSILMuleSoftIntegration.createOrUpdateOrCancelBooking';
import updateTestDrive from '@salesforce/apex/TestDriveFunctionality.updateTestDrive';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import Test_Drive_Status_FIELD from '@salesforce/schema/Test_Drive__c.Status__c';
import testDriveLocations from '@salesforce/schema/Test_Drive__c.Location__c';
import {getRecord} from 'lightning/uiRecordApi';
import CURRENTUSERID from '@salesforce/user/Id';
//import saveSignatureMethod from '@salesforce/apex/SaveSignature.saveSignatureMethod'; 

/******** Error messagess ***********/
import UI_Error_Message from '@salesforce/label/c.UI_Error_Message';
import mspinMissing from '@salesforce/label/c.Error_Message_Missing_MSPIN';
import testDriveUpdationError from '@salesforce/label/c.Error_Message_Test_Drive_Updation';
import missingFieldnSignature from '@salesforce/label/c.Error_Message_Missing_Field_and_Signature';
import noFurtherAction from '@salesforce/label/c.Error_Message_No_Further_Action';

export default class EditTestDrive extends NavigationMixin(LightningElement) {
    @api recordId;
    @api updateType;
    @api cancelType;
    @api completeType;
   
    @track testDriveData;
    @track timeSlotResponse; // Used to store API responce of getTestDriveSlot
    @track dateOptions=[]; // Used to store date options getting from API responce of getTestDriveSlot
    @track SlotOptions=[]; // Used to store SlotOptions getting from API responce of getTestDriveSlot
    @track selectedDate; // Used to store slected date from dropdown
    @track selectedSlot; // Used to store select slot from dropdown
    @track selectedSlotApi=[]; //Used to store/send selected slot to multiselect picklist component
    @track slotsMap;
    @track multiSelectRequired=true;
    @track testDriveStatusPickList;
    @track locationOptions=[]; //This is used to store location from picklist
    @track loadSpinner=false;
    @track todayDate; // This variable is used to store today date
    @track actualStartTime; // This variable is used to store actual start time
    @track actualEndTime; // This variable is used to store actual end time
    @track kmDriven; // This variable is used to store actual KM driven for that test drive
    @track titleLabel; // This variable is used to set label dynamically for Reschedule/Complete testdrive
    @track selectedCheckBox=[]; //This veriable is used to store selected checkbox
    signatureCollected=false;
    durationVal=15; // This variable is used when custom date slot is getting created
    dmsDates=[];
    dmsSlots=[];
    userDetail; // This field is used to store current user's detail



     





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
    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: Test_Drive_Status_FIELD})
    typePicklistValues({error, data}){
        if (data) {
            this.testDriveStatusPickList=data;
        } else if(error){
            console.log('Inside error');
        }
    }
    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: testDriveLocations})
    typePicklistValuesLocations({error, data}){
        if (data) {
            this.locationOptions=data;
            //console.log(this.locationOptions);
        } else if(error){
            console.log('Inside error');
        }
    }
    // This function is used to do things on load of LWC
    connectedCallback() {
        //console.log(this.completeType);
        this.titleLabel="Reschedule Test Drive"
        if(this.completeType==='True')
        {
            this.titleLabel="Complete Test Drive";
            let tDate = new Date();
            let month=tDate.getMonth()+1;
            month=month>9?month:'0'+month;
            let curDate=tDate.getDate()>9?tDate.getDate():'0'+tDate.getDate();
            this.todayDate=tDate.getFullYear()+'-'+month+'-'+curDate;
            this.updateType=true;
            
        }
        
        this.template.addEventListener('click', this.handleTemplateClick.bind(this));
         getTestDrive({id:this.recordId})
            .then(result => {
                this.testDriveData = Object.assign({}, result);
                console.log('Hello');
                console.log(result);
                if(this.testDriveData.Status__c!=='COMPLETED' && this.testDriveData.Status__c!=='CANCELLED')
                {
                     if(this.testDriveData.Scheduled_Start__c!== undefined)
                    {
                        let bookingDateSplit=this.testDriveData.Scheduled_Start__c.split('T')[0].split('-');
                        this.selectedDate=this.testDriveData.Scheduled_Start__c.split('T')[0];
                        this.testDriveData.selectedDate=this.testDriveData.Scheduled_Start__c.split('T')[0];
                        let startDate=new Date(this.testDriveData.Scheduled_Start__c);
                        this.dateOptions.push({label:bookingDateSplit[2]+'/'+bookingDateSplit[1]+'/'+bookingDateSplit[0], value:this.selectedDate});
                        if(this.testDriveData.Scheduled_End__c!==undefined)
                        {
                            let endDate=new Date(this.testDriveData.Scheduled_End__c);
                            this.selectedSlot=this.testDriveData.Scheduled_Start__c.split('T')[1].split(':')[0]+':'+this.testDriveData.Scheduled_Start__c.split('T')[1].split(':')[1]+' to '+this.testDriveData.Scheduled_End__c.split('T')[1].split(':')[0]+':'+this.testDriveData.Scheduled_End__c.split('T')[1].split(':')[1];
                            
                            let selectedSlot=this.selectedSlot.split(' to ');
                            let startSlot=selectedSlot[0];
                            let endSlot=selectedSlot[1];
                            for(let i=0;i<((endDate.getTime() - startDate.getTime())/(1000*3600))*2;i++)
                            {
                                let startSlotSpllit=startSlot.split(':');
                                if(parseInt(startSlotSpllit[1],10)+30===60)
                                {
                                    endSlot=parseInt(startSlotSpllit[0],10)+1;
                                    if(endSlot<10)
                                    {
                                        endSlot='0'+endSlot.toString()+':00';
                                    }
                                    else{
                                        endSlot=endSlot.toString()+':00';
                                    }
                                    
                                }
                                else{
                                    endSlot=startSlotSpllit[0]+':30';
                                }
                                let sSlot=startSlot.replace('.00',':00');
                                let eSlot=endSlot.replace('//.',':');
                                this.selectedSlotApi.push({"Id":sSlot+" to "+eSlot,"Name":sSlot+" to "+eSlot});
                                startSlot=endSlot;
                            }
                        }
                    }
                    //console.log('Hi');
                    //console.log(this.testDriveData);
                    getTestDriveSlot({apiType:'Test Drive Slots',vin:this.testDriveData.Test_Drive_Vehicle__r.VIN__c,dateRange:30,enquiryId:this.testDriveData.Enquiry__r.DMS_Enquiry_Name__c,mspin:this.testDriveData.Enquiry__r.DSE_MSPIN__c,orgId:1})
                    .then(slotResult => { 
                        this.timeSlotResponse = JSON.parse(slotResult);
                        this.slotsMap=new Map();
                        this.timeSlotResponse.availableslots.forEach(element => {
                            let bookingDateSplit=element.bookingDate.split('-');
                            console.log(this.dateOptions.find(selectedDate=>selectedDate.value !==element.bookingDate));
                           /* if(this.dateOptions.find(selectedDate=>selectedDate.value !==element.bookingDate))
                            {
                                console.log(element.bookingDate);
                                this.dateOptions = [...this.dateOptions, {label:bookingDateSplit[2]+'/'+bookingDateSplit[1]+'/'+bookingDateSplit[0], value:element.bookingDate}];
                                this.SlotOptions=[];
                                this.dmsDates=this.dateOptions;
                                element.timeSlots.forEach(slots=>{
                                    this.SlotOptions = [...this.SlotOptions, {Id:slots.fromTime+' to '+slots.toTime, Name:slots.fromTime+' to '+slots.toTime}];
                                });
                                this.slotsMap.set(element.bookingDate,this.SlotOptions);
                                //console.log(this.SlotOptions);
                            }
                            else if(this.dateOptions.find(selectedDate=>selectedDate.value ===element.bookingDate))
                            {
                                element.timeSlots.forEach(slots=>{
                                    this.SlotOptions = [...this.SlotOptions, {Id:slots.fromTime+' to '+slots.toTime, Name:slots.fromTime+' to '+slots.toTime}];
                                });
                                this.slotsMap.set(element.bookingDate,this.SlotOptions);
                            }*/
                            
                            if(this.dateOptions.find(selectedDate=>selectedDate.value ===element.bookingDate))
                            {
                                this.SlotOptions=[];
                                element.timeSlots.forEach(slots=>{
                                    this.SlotOptions = [...this.SlotOptions, {Id:slots.fromTime+' to '+slots.toTime, Name:slots.fromTime+' to '+slots.toTime}];
                                });
                                this.slotsMap.set(element.bookingDate,this.SlotOptions);
                            }
                            else
                            {
                                console.log(element.bookingDate);
                                this.dateOptions = [...this.dateOptions, {label:bookingDateSplit[2]+'/'+bookingDateSplit[1]+'/'+bookingDateSplit[0], value:element.bookingDate}];
                                this.SlotOptions=[];
                                this.dmsDates=this.dateOptions;
                                element.timeSlots.forEach(slots=>{
                                    this.SlotOptions = [...this.SlotOptions, {Id:slots.fromTime+' to '+slots.toTime, Name:slots.fromTime+' to '+slots.toTime}];
                                });
                                this.slotsMap.set(element.bookingDate,this.SlotOptions);
                                //console.log(this.SlotOptions);
                            }
                            this.dmsSlots=this.SlotOptions;
                            
                        });
                        this.SlotOptions=this.slotsMap.get(this.testDriveData.selectedDate);
                    // console.log(this.dateOptions);
                    })
                    .catch(error => {
                        this.error = error;
                    });
                }
                else{
                     
                    let message=testDriveUpdationError+' '+this.testDriveData.Status__c+' .'+noFurtherAction;
                    if(this.cancelType==='True')
                    {
                        this.tostMessage(message,0,'Error');
                        this.cancel();
                    }
                    else{
                        this.tostMessage(message,0,'Warning');
                        this.cancel();
                    }
                    
                    
                }
               
                
            })
            .catch(error => {
                this.error = error;
            });
    }

    /*** This function is used to set feedback options ***/
    get feedBackOptions() {
        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' },
        ];
    }
    handleSatisficationChange(event)
    {
        this.feedBackAnswerSelected=event.detail.value;
    }
    handleFeedbackChange(event)
    {
        this.feedback=event.detail.value;
    }
    handleTemplateClick(event){
        if(this.cancelType!=='True' && this.completeType!=='True')
        {
            this.template.querySelector('c-multi-select-cmp').handleClick(event);  
        }
        
    }
    handleCheckBoxChange(event)
    {
        console.log('Inside handleCheckBoxChange');
        this.selectedDate='';
        this.selectedSlot='';
        this.dateOptions=[];
        //this.SlotOptions=[];
        this.selectedSlotApi=[];
        this.selectedCheckBox=event.detail.value;
        
        if(this.selectedCheckBox.length>0)
        {
            console.log('Inside If of handleCheckBoxChange');
            this.createDateNSlot();
            console.log(this.SlotOptions);
        }
        else{
            this.dateOptions=this.dmsDates;
            this.SlotOptions=this.dmsSlots;
        }
        
        console.log(this.selectedCheckBox);

    }
    /********************* This function is used to show check box options ***********************/
    get checkboxOptions() {
        return [
            { label: 'Create Without Confirmed Slot', value: 'selected' },
            
        ];
    }
/*** This function is used to create date and slot when no date and slot is coming from DMS ***/
    createDateNSlot()
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
        console.log(this.SlotOptions);
    }
    // This function will handle any change in location field and store that
    handleLocationChange(event)
    {
        this.testDriveData.Location__c=event.detail.value;
    }
    // This function will handle any change in Status field and store that
    handleStatusChange(event)
    {
        this.testDriveData.Status__c=event.detail.value;
    }
    // This function will handle any change in Date field and store that
    handleDateChange(event)
    {
        console.log('Inside handleDateChange');
        //console.log(this.slotsMap);
        this.template.querySelector('c-multi-select-cmp').onRefreshClick();  
        this.testDriveData.selectedDate=event.detail.value;
        this.selectedDate=event.detail.value;
        this.selectedSlot='';
        this.selectedSlotApi=[];
        if(this.selectedCheckBox.length===0)
        {
            console.log('Inside If');
            this.SlotOptions=this.slotsMap.get(this.testDriveData.selectedDate);
        }
    }
    // This function will handle any change in Date field and store that
    handleSlotChange(event)
    {
        this.testDriveData.selectedSlot=event.detail.value;
    }
    startTimeChangeHandler(event)
    {
        this.actualStartTime=event.detail.value;
    } 
    endTimeChangeHandler(event)
    {
        this.actualEndTime=event.detail.value;
    } 
    kmDrivenChangeHandler(event)
    {
        this.kmDriven=event.detail.value;
    }
    handleSignature(event)
    {
        console.log(event.detail);
        this.signatureCollected=event.detail;
    }

    eraseHelper()
    {
        this.template.querySelector('c-signatur-capture').eraseHelper();
    }
    // This function is used to update test drive record
    updateTestDrive()
    {
        
        console.log('Inside updateTestDrive');
        console.log(this.testDriveData);
        if(this.testDriveData.Enquiry__r.DSE_MSPIN__c!==null && this.testDriveData.Enquiry__r.DSE_MSPIN__c!=='' && this.testDriveData.Enquiry__r.DSE_MSPIN__c!==undefined)
        {
            this.loadSpinner=true;
            console.log(this.loadSpinner);
            const allValid = [...this.template.querySelectorAll('lightning-combobox')]
            .reduce((validSoFar, inputCmp) => {
                        inputCmp.reportValidity();
                        return validSoFar && inputCmp.checkValidity();
            }, true);
            const allValidInput = [...this.template.querySelectorAll('lightning-input')]
            .reduce((validSoFar, inputCmp) => {
                        inputCmp.reportValidity();
                        return validSoFar && inputCmp.checkValidity();
            }, true);

            const allValidCreateSatisfied = [...this.template.querySelectorAll('lightning-radio-group')]
            .reduce((validSoFar, inputCmp) => {
                    inputCmp.reportValidity();
                    return validSoFar && inputCmp.checkValidity();
            }, true);

            const allValidtextareafield = [...this.template.querySelectorAll('lightning-textarea')]
            .reduce((validSoFar, inputCmp) => {
                    inputCmp.reportValidity();
                    return validSoFar && inputCmp.checkValidity();
            }, true);
            
            console.log(allValidInput);
            let currentDateTime=new Date();
            let month=currentDateTime.getMonth()+1;
            let curMonth=month>9?month:'0'+month;
            let curDate=currentDateTime.getDate()>9?currentDateTime.getDate():'0'+currentDateTime.getDate();
            let curHour=currentDateTime.getHours()>9?currentDateTime.getHours():'0'+currentDateTime.getHours();
            let minute=currentDateTime.getMinutes()>9?currentDateTime.getMinutes():'0'+currentDateTime.getMinutes();
            let curSec=currentDateTime.getSeconds()>9?currentDateTime.getSeconds():'0'+currentDateTime.getSeconds();
            
            let curFormatedDateTime=currentDateTime.getYear()+1900+'-'+curMonth+'-'+curDate+'T'+curHour+':'+minute+':'+curSec+'.090Z';
            let startTime;
            let endTime;
            let startDateSplit=this.testDriveData.Scheduled_Start__c.split('T');
            let endDateSplit=this.testDriveData.Scheduled_End__c.split('T');
            this.testDriveData.selectedDate=this.selectedDate;
            if(typeof this.selectedSlot=='string')
                {
                    startTime=this.selectedSlot.split(' to ')[0];
                    endTime=this.selectedSlot.split(' to ')[1];
                }
                else
                {
                    if(this.selectedSlot.length === 1)
                    {
                        //console.log('Inside if else Start');
                        startTime=this.selectedSlot[0].Name.split(' to ')[0];
                        endTime=this.selectedSlot[0].Name.split(' to ')[1];
                        //console.log('Inside if else end');
                    }
                    else if(this.selectedSlot.length>1)
                    {
                        startTime=this.selectedSlot[0].Name.split(' to ')[0];
                        endTime=this.selectedSlot[this.selectedSlot.length-1].Name.split(' to ')[1];
                    }
                }

            console.log(this.testDriveData.selectedDate);
            console.log(startTime);
            console.log(this.selectedSlot);
            console.log(this.todayDate);
            if(allValid && allValidInput && allValidCreateSatisfied && allValidtextareafield && startTime!==undefined)
            {
                let dealerEmpId='';
                if(this.userDetail.fields.Dealer_Employee_Code__c.value!==null && this.userDetail.fields.Dealer_Employee_Code__c.value!==undefined && this.userDetail.fields.Dealer_Employee_Code__c.value.includes('_'))
                {
                    dealerEmpId=this.userDetail.fields.Dealer_Employee_Code__c.value.split('_')[1];
                }
                //let dealerEmpId=this.userDetail.fields.Dealer_Employee_Code__c.value!==null?
                if(this.completeType==='True' && this.signatureCollected===false)
                {
                    this.tostMessage(missingFieldnSignature,0,'Error');
                }
                else{
                    
                    //console.log(dateTimeDiff);
                    //console.log(Math.floor((dateTimeDiff/1000)/60));
                    let dateTimeDiff;
                    let testDriveRawData={
                        "optType" : "u",
                        "mspin": this.testDriveData.Enquiry__r.DSE_MSPIN__c,
                        "model": this.testDriveData.Test_Drive_Vehicle__r.Product2.Model__c, //"DR",
                        "variant": this.testDriveData.Test_Drive_Vehicle__r.Product2.ProductCode,
                        "location": this.testDriveData.Location__c,
                        "status": "CANCELLED",
                        "owner": "1",
                        "enquiryId": this.testDriveData.Enquiry__r.DMS_Enquiry_Name__c,//,
                        "salesPersonId": dealerEmpId,//"EMP2096",
                        "scheduleStartTime":  this.testDriveData.selectedDate+'T'+startTime+':00.090Z',
                        "scheduleEndTime": this.testDriveData.selectedDate+'T'+endTime+':00.090Z',
                        "duration": 0,
                        "signature": false,
                        "vin": this.testDriveData.Test_Drive_Vehicle__r.VIN__c,
                        "orgId": 1,
                        "salesforceId": "",
                        "drivenKM": this.kmDriven,
                        "cancellationDateTime": curFormatedDateTime
                        }
                    
                        if(this.cancelType!=='True')
                        {
                            let dateSplit=this.completeType==='True'?this.todayDate.split('-'):'';
                            let startTimeSplit=this.completeType==='True'?this.actualStartTime.split(':'):'';
                            let endTimeSplit=this.completeType==='True'?this.actualEndTime.split(':'):'';
                            dateTimeDiff=this.completeType==='True'?Math.abs(new Date(dateSplit[0], dateSplit[1], dateSplit[2], endTimeSplit[0], endTimeSplit[1], '00', '00')- new Date(dateSplit[0], dateSplit[1], dateSplit[2], startTimeSplit[0], startTimeSplit[1], '00', '00')):0;
                            dateTimeDiff=Math.floor((dateTimeDiff/1000)/60);
                            testDriveRawData={
                                "optType" :this.completeType==='True'?"C":"u",
                            "mspin": this.testDriveData.Enquiry__r.DSE_MSPIN__c,
                            "model": this.testDriveData.Test_Drive_Vehicle__r.Product2.Model__c,//"DR",
                            "variant": this.testDriveData.Test_Drive_Vehicle__r.Product2.ProductCode,
                            "location": this.testDriveData.Location__c,
                            "status": this.testDriveData.Status__c,
                            "owner": "1",
                            "enquiryId": this.testDriveData.Enquiry__r.DMS_Enquiry_Name__c,//"19000050",
                            "salesPersonId": dealerEmpId,//"EMP2096",
                            "scheduleStartTime":  this.completeType==='True'?this.todayDate+'T'+this.actualStartTime+'Z':this.testDriveData.selectedDate+'T'+startTime+':00.090Z',
                            "scheduleEndTime": this.completeType==='True'?this.todayDate+'T'+this.actualEndTime+'Z':this.testDriveData.selectedDate+'T'+endTime+':00.090Z',
                            "rescheduleDateTime": curFormatedDateTime,
                            "duration": this.completeType==='True'?dateTimeDiff:0,//25,
                            "signature": false,
                            "vin": this.testDriveData.Test_Drive_Vehicle__r.VIN__c,
                            "orgId": 1,
                            "salesforceId": "",//"SF123",
                            "drivenKM": this.kmDriven
                            
                            }
                        }
                        console.log('Hello');
                        console.log(testDriveRawData);
                        
                        updateOrCancelBooking({apiType:this.completeType==='True'?'Create Booking':'Update or Cancel Booking',methodType:this.completeType==='True'?'POST':'PUT',testDriveRawData:JSON.stringify(testDriveRawData),bookingID:this.testDriveData.DMS_Booking_ID__c})
                    .then(result =>{
                        console.log(result);
                        this.updateOrCancelBooking=JSON.parse(result);
                        
                            if(this.updateOrCancelBooking.status==='Success')
                            {
                                console.log('Trest');
                                
                                if(this.cancelType==='True')
                                {
                                    this.tempVar={id:this.testDriveData.Id,status:'CANCELLED',location:this.testDriveData.Location__c,selectedDate:startDateSplit[0],startTime:startDateSplit[1].split(':')[0]+':'+startDateSplit[1].split(':')[1],endTime:endDateSplit[1].split(':')[0]+':'+endDateSplit[1].split(':')[1],oldStartDate:this.testDriveData.Scheduled_Start__c};
                                    //this.tempVar={id:this.testDriveData.Id,status:'CANCELLED',location:this.testDriveData.Location__c,selectedDate:startDateSplit[0],startTime:startDateSplit[1].split(':')[0]+'.'+startDateSplit[1].split(':')[1],endTime:endDateSplit[1].split(':')[0]+'.'+endDateSplit[1].split(':')[1],oldStartDate:this.testDriveData.Scheduled_Start__c};
                                }
                                else if(this.completeType==='True')
                                {
                                    
                                    console.log('Inside else if start');
                                    console.log(this.testDriveData);
                                    console.log(this.testDriveData.Enquiry__c);
                                    this.tempVar={id:this.testDriveData.Id,status:'COMPLETED',location:this.testDriveData.Location__c,selectedDate:this.todayDate,startTime:this.actualStartTime,endTime:this.actualEndTime,oldStartDate:this.testDriveData.Scheduled_Start__c,kmDriven:this.kmDriven,bookingId:this.updateOrCancelBooking.bookingId,satisfied:this.feedBackAnswerSelected,feedback:this.feedback,duration:dateTimeDiff,enquiryId:this.testDriveData.Enquiry__c};
                                }
                                else 
                                {
                                    console.log('Inside else start');
                                    this.tempVar={id:this.testDriveData.Id,status:this.testDriveData.Status__c,location:this.testDriveData.Location__c,selectedDate:this.testDriveData.selectedDate,startTime:startTime,endTime:endTime,oldStartDate:this.testDriveData.Scheduled_Start__c};
                                    
                                }
                                updateTestDrive({data:JSON.stringify(this.tempVar)})
                                .then(result1 =>{
                                    console.log(result1);
                                    if(result1.code===200)
                                    {
                                        this.tostMessage(result1.message,result1.code,result1.status);
                                        this.loadSpinner=false;
                                        if(this.completeType==='True')
                                        {
                                            this.template.querySelector("c-signatur-capture").save();
                                        }
                                    }
                                    else{
                                        this.tostMessage(result1.message,result1.code,result1.status);
                                        this.loadSpinner=false;
                                    }
                                
                                })
                                .catch(error => {
                                    console.log(error);
                                    this.error = error;
                                    this.tostMessage(UI_Error_Message,1,'error');
                                    this.loadSpinner=false;
                                });
                            }
                        })
                        .catch(error => {
                            console.log('Inside Error');
                            this.tostMessage(UI_Error_Message,'1','error');
                            this.error = error;
                            this.loadSpinner=false;
                        });
                }
                
            }
            else{
                this.loadSpinner=false;
            }
            //this.loadSpinner=false;
        }
        else{
            //this.loadSpinner=false;
            this.tostMessage(mspinMissing,'1','error');
            this.loadSpinner=false;
        }
        //console.log(this.testDriveData);
        
        
        
    }
    // This function will be used to close the model
    cancel()
    {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.testDriveData.Id,
                objectApiName: 'Test_Drive__c', // objectApiName is optional
                actionName: 'view'
            }
        });
    }
    valueSelected(event){
        //Assign the selected values to selectedSlot variable
        this.selectedSlot = event.detail;
    }
    tostMessage(message,code,status)
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
            this.cancel();
        }
        
    }
}