import { LightningElement,api,track,wire } from 'lwc';
import fetchCityandAssestInfo from "@salesforce/apex/ServiceCalculator.fetchCityandAssestInfo";
import getServiceCalculatorData from "@salesforce/apexContinuation/JITMuleSoftIntegration.genericJITCall";
import createWorkOrderRecord from "@salesforce/apex/CreateAppointment.createWorkOrderRecord";
import {NavigationMixin} from "lightning/navigation";
import {ShowToastEvent} from "lightning/platformShowToastEvent";
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import WORK_ORDER from '@salesforce/schema/WorkOrder';
import SERVICE_TYPE from "@salesforce/schema/WorkOrder.Service_Type__c";
import APPOINTMENT_TYPE from '@salesforce/schema/WorkOrder.Appointment_Type__c';
import PICKUP_TYPE from '@salesforce/schema/WorkOrder.Pickup_Type__c';



export default class FetchAppointmentLwc extends NavigationMixin(LightningElement) {
    @api recordId;
    registrationNumberValues = [];
    registrationNumber;
    appointmentNumber;
    @track loading = false; // This varibale is used to control the visibility of spinner
    @track errorMessage;
    parentGroup;
    dealerMapCode;
    locationCode;
    workshopOptions = [];
    forCodeAPIReq;
    workshopList = [];
    @track isVisible = false;
    columns;
    obj;
    data = [];
    decoy;
    showCreateWorkOrder = false;
    wrkShopId;
    @track showDetailsProperty = true;
    serviceTypeArray = [];
    serviceType;
    appointmentTypeArray =[];
    appointmentType;
    pickupTypeArray =[];
    pickupType;
    //monthList={"jan":1,"feb":2,"mar":3,"apr":4,"may":5,"jun":6,"jul":7,"aug":8,"sep":9,"oct":10,"nov":11,"dec":12};

    @wire(getObjectInfo, { objectApiName: WORK_ORDER })
    objectInfo;
    
    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: SERVICE_TYPE})
    ServTypePicklistValues({error,data}){
      if(error){
        console.log('coming in error',error);
      }
      if(data){
        console.log('data is-----',data);
        this.serviceTypeArray = data.values;
      }
    };
    
    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: APPOINTMENT_TYPE})
    AppTypePicklistValues({error,data}){
      if(error){
        console.log('coming in error',error);
      }
      if(data){
        console.log('data is-----',data);
        this.appointmentTypeArray = data.values;
      }
    };

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: PICKUP_TYPE})
    PickTypePicklistValues({error,data}){
      if(error){
        console.log('coming in error',error);
      }
      if(data){
        console.log('data is-----',data);
        this.pickupTypeArray = data.values;
      }
    };

    connectedCallback(){
        fetchCityandAssestInfo({
            recordId: this.recordId,
          })
          .then(result=>{
            if(result && result.registrationNumberList && result.registrationNumberList.length > 0 && result.workShopList && result.workShopList.length > 0){
                this.registrationNumberValues = [];
                for (let i = 0; i < result.registrationNumberList.length; i++){
                    this.registrationNumberValues.push({
                        label :  result.registrationNumberList[i].Name,
                        value :  result.registrationNumberList[i].Registration_Number__c
                    })
                }

                this.workshopOptions = [];
                this.workshopList = result.workShopList;
                for (let i = 0; i < result.workShopList.length; i++) {
                    this.workshopOptions.push({
                        label: result.workShopList[i].Name,
                        value: result.workShopList[i].Id
                      });
                }

            }else{
                // To hide the Spinner
                this.loading = false;
                // To throw an error message if Registration Number is not present
                this.dispatchEvent(
                  new ShowToastEvent({
                    title: "Something is wrong",
                    message: 'Asset details are missing',
                    variant: "error"
                  })
                );
                this.cancel();
              }
            })
          .catch(error=>{
            this.error = error;
            this.dispatchEvent(
              new ShowToastEvent({
                title: "Something is wrong",
                message: "Please try again later!",
                variant: "error"
              })
            );
            this.cancel();
          })
    }

      // This method is used to close the LWC and navigate to record page
      cancel() {
        this.loading = true;
        this[NavigationMixin.Navigate]({
          type: "standard__recordPage",
          attributes: {
            recordId: this.recordId,
            objectApiName: "Account", // objectApiName is optional
            actionName: "view"
          }
        });
        this.loading = false;
      }

      handlechange(event){
        if(event.target.name === "RegistrationNumber"){
            this.registrationNumber = event.target.value;
        }else if (event.target.name === "WorkShopName") {
            this.wrkShopId = event.target.value;
            this.fetchDealerDetails(this.wrkShopId);
        }else{
            this.appointmentNumber = event.target.value;
        }
    }

    fetchDealerDetails(workshopId){
        let selectedWorkshop=this.workshopList.find(workshop=>workshop.Id===workshopId);
        this.parentGroup=selectedWorkshop.Parent_Group__c;
        this.dealerMapCode=selectedWorkshop.Dealer_Map_Code__c;
        this.locationCode=selectedWorkshop.Dealer_Location__c;
    }

    get loaded() {
        return !this.errorMessage && !this.loading;
    }

    showDetails(event){
          // To Handle the data validation for lightning-input field
          var vl = this.template.querySelector("lightning-input");
          var registrationValidation = this.template.querySelector('[data-id="registrationCheck"]')
          var workShopValidation = this.template.querySelector('[data-id="workShopCheckValidation"]')
          if (workShopValidation.value!== undefined && (registrationValidation.value !== undefined || (vl.value !== "" && vl.value !== null))){
            this.loading = true;
            let params = {
                jitName: "Fetch_Appointment",
                jsonBody: " ",
                urlParam : JSON.stringify({
                    regNumber: this.registrationNumber,
                    parentGroup : this.parentGroup,
                    dealerMapCode : this.dealerMapCode,
                    locationCode : this.locationCode,
                    appointmentNumber : this.appointmentNumber
                })
            }
            console.log('paramter is--------',params);
            if((this.registrationNumber || this.appointmentNumber ) && this.parentGroup && this.dealerMapCode && this.locationCode){
            getServiceCalculatorData(params)
            .then(result=>{
                if (result && result.code === 200) {
                    this.obj = JSON.parse(result.data);
                    console.log(this.obj);
                    this.serviceType = this.obj.serviceType;
                    if(this.obj.serviceType){
                       let tempServiceType = this.serviceTypeArray.find(item=>item.value === this.obj.serviceType);
                      if(tempServiceType){
                        this.serviceType = tempServiceType.label
                      }
                    }
                    this.appointmentType = this.obj.appointmentType;
                    if(this.obj.appointmentType){
                      let tempAppointmentType = this.appointmentTypeArray.find(item=>item.value === this.obj.appointmentType);
                      if(tempAppointmentType){
                        this.appointmentType = tempAppointmentType.label;
                      }
                    }
                    this.pickupType = this.obj.pickUpType;
                    if(this.obj.pickUpType){
                      let tempPickupType = this.pickupTypeArray.find(item=>item.value === this.obj.pickUpType);
                      if(tempPickupType){
                        this.pickupType = tempPickupType.label;
                      }
                    }
                    console.log('this.serviceType-------',this.serviceType);

                    this.showDetailsProperty = false;
                    this.showCreateWorkOrder = true;
                    this.columns = [{
                        label : "Key",
                        fieldName : "Key",
                        type : "text"
                    },
                    {
                        label: "value",
                        fieldName : "value",
                        type : "text"
                    }]

                    const data =[];
                    data.push(
                    {
                        Key : "Vehicle Number",
                        value : String(this.obj.vehicleRegNo)
                    },
                    {
                        Key : "Odometer",
                        value : String(this.obj.odometer)
                    },
                    {
                        Key : "Service Type",
                        value : String(this.obj.serviceType)
                    },
                    {
                        Key : "Appointment Type",
                        value : String(this.obj.appointmentType)
                    },
                    {
                        Key : "Appointment Date",
                        value : String(this.obj.appointmentDateTime)
                    },
                    {
                        Key : "Slot Code",
                        value : String(this.obj.slotCD)
                    },
                    {
                        Key : "Slot Time",
                        value : String(this.obj.slotTime)
                    },
                    {
                        Key : "Pickup Type",
                        value : String(this.obj.pickUpType)
                    },
                    {
                        Key : "Pickup Time",
                        value : String(this.obj.pickUpTime)
                    },
                    {
                        Key : "Pickup Address",
                        value : String(this.obj.pickUpAddress)
                    },
                    {
                        Key : "Drop Time",
                        value : String(this.obj.dropTime)
                    },
                    {
                        Key : "Drop Address",
                        value : String(this.obj.dropAddress)
                    },
                    {
                        Key : "Pickup Remarks",
                        value : String(this.obj.pickUpRemarks)
                    });
                    
                    this.data = data;
              this.isVisible = true;
              this.loading = false;
              this.dispatchEvent(
                new ShowToastEvent({
                  title: "Success",
                  message: "Data has been retrieved successfully!",
                  variant: "success"
                })
              );
            } else {
                // To hide the Spinner
                this.loading = false;
                // To throw an error message if Registration Number is not present
                this.dispatchEvent(
                  new ShowToastEvent({
                    title: "Error",
                    message: result.message,
                    variant: "Warning"
                  })
                );
              }
            })
            .catch(error=>{
                this.error = error;
                this.dispatchEvent(
                    new ShowToastEvent({
                    title: "Something is wrong",
                    message: "Please try again later!",
                    variant: "error"
                    })
                );
                this.loading = false;
                this.cancel();
            })
        }
        }else {
            // To popup error message when required fields are missing message.
            vl.reportValidity();
            this.dispatchEvent(
            new ShowToastEvent({
                title: "Something is wrong",
                message: "Required fields are missing / Data entered is not correct",
                variant: "error"
            })
            );
        }
    }

      // To Handle the data validation for lightning-combobox fields
      validationCheckMethod() {
        const allValid1 = [...this.template.querySelectorAll("lightning-combobox")]
        .reduce((validSoFar, inputCmp) => {
          inputCmp.reportValidity();
          return validSoFar && inputCmp.checkValidity();
        }, true);
        return allValid1;
      }

      createWorkOrder(){
        console.log('inside createWorkOrder');
        try{
        this.loading = true;
        if(this.obj.appointmentDateTime!==null && this.obj.appointmentDateTime!==undefined && this.obj.appointmentDateTime!==''){
          let apointmentDate=this.obj.appointmentDateTime.split('/');
          this.obj.appointmentDateTime=apointmentDate[2].split(' ')[0]+'-'+apointmentDate[1]+'-'+apointmentDate[0]+'T'+apointmentDate[2].split(' ')[1];
        }
        if(this.obj.dropTime!==null && this.obj.dropTime!==undefined && this.obj.dropTime!==''){
          let dropDate=this.obj.dropTime.split('/');
          this.obj.dropTime=dropDate[2].split(' ')[0]+'-'+dropDate[1]+'-'+dropDate[0]+'T'+dropDate[2].split(' ')[1];
        }
        if(this.obj.pickUpTime!==null && this.obj.pickUpTime!==undefined && this.obj.pickUpTime!==''){
          let pickupDate=this.obj.pickUpTime.split('/');
          this.obj.pickUpTime=pickupDate[2].split(' ')[0]+'-'+pickupDate[1]+'-'+pickupDate[0]+'T'+pickupDate[2].split(' ')[1];
        }
        
        console.log(this.obj);
      }
      catch(err){
        console.log(err);
      }
        createWorkOrderRecord({
          recievedJSONData : JSON.stringify(this.obj)
        })
        .then(result=>{
          this.loading = false;
          this.message = result
          console.log('this.message---------',this.message)
          if(this.message.includes('Id')){
            this.dispatchEvent(
              new ShowToastEvent({
                title: "Success",
                message: "Record created successfully",
                variant: "Success"
              })
            );
            this[NavigationMixin.Navigate]({
              type: 'standard__recordPage',
              attributes: {
                  recordId: this.message.split('Id')[1],
                  objectApiName: 'WorkOrder',
                  actionName: 'view'
              }
          });
          }else if(this.message.includes('Error is ')){
            this.loading=false;
            this.dispatchEvent(
              new ShowToastEvent({
                title: "Error",
                message: this.message,
                variant: "error"
              })
            );
            this.cancel();
          }
        })
        .catch(error=>{
          this.loading=false;
          this.error = error;
            this.dispatchEvent(
              new ShowToastEvent({
                title: "Error",
                message: this.error,
                variant: "error"
              })
            );
            this.cancel();
        })
      }
}