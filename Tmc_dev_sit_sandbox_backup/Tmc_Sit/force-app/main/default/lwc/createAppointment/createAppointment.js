/* eslint-disable @lwc/lwc/no-async-operation */
/* eslint-disable no-console */
import {
  LightningElement,
  track,
  wire,
  api
} from "lwc";
import {
  ShowToastEvent
} from "lightning/platformShowToastEvent";
import {
  NavigationMixin
} from "lightning/navigation";
import {
  getPicklistValues
} from "lightning/uiObjectInfoApi";
import pubsub from 'c/pubsub';
import WO_STATUS from "@salesforce/schema/WorkOrder.Status";
import WO_SERVICE_TYPE from "@salesforce/schema/WorkOrder.Service_Type__c";
import WO_APPOINTMENT_TYPE from "@salesforce/schema/WorkOrder.Appointment_Type__c";
import Server_Error from "@salesforce/label/c.UI_Error_Message";
import canncelApp from "@salesforce/label/c.Cancel_Appointment";
import getMMSVehicle from "@salesforce/apex/CreateAppointment.getMMSVehicle";
import fetchAppointmentData from "@salesforce/apex/CreateAppointment.fetchAppointmentData";
import fetchPickupLoc from "@salesforce/apex/CreateAppointment.fetchPickupLoc";
import fetchDriverList from "@salesforce/apex/CreateAppointment.fetchDriverList";
import saveAppointment from "@salesforce/apex/CreateAppointment.saveAppointment";
import apiCall from "@salesforce/apexContinuation/JITMuleSoftIntegration.genericJITCall";
import getAssets from "@salesforce/apex/CreateAppointment.getCustomerAssets";
import storeAppointment from "@salesforce/apex/CreateAppointment.storeAppointment";

import fetchCityandAssestInfo from "@salesforce/apex/ServiceCalculator.fetchCityandAssestInfo";

/*Custom Label*/
import mmsVehicleError from "@salesforce/label/c.MMS_Vehicle";
import mmsWorkshop from "@salesforce/label/c.MMS_Workshop";
import SAProfileId from "@salesforce/label/c.Service_Advisor_Profile_Id";
import {
  retrieveObjectArrayFromCache,
} from "c/cacheServiceLayerCMP";
import {
  getRecord
} from "lightning/uiRecordApi";
import currentUserId from "@salesforce/user/Id";
import dealerId from "@salesforce/schema/User.AccountId";
import Manager_Id from "@salesforce/schema/User.ManagerId";
import profileId from "@salesforce/schema/User.ProfileId";
import dealerEmpCode from "@salesforce/schema/User.Dealer_Employee_Code__c";
export default class CreateAppointment extends NavigationMixin(
  LightningElement
) {
  //@api recordId = "0010T000003qtScQAI";
  @api recordId;
  @api componentName = "Create Appointment";
  @track woRecordTypeId;
  @track workOrder;
  @track showPickupDropSection = false;
  @track statusOptions;
  @track serviceTypeOptions;
  @track appointmentTypeOptions;
  @track assetOptions;
  @track workshopOptions;
  @track locationOptions;
  @track driverOptions;
  @track loading = false;
  @track assetSearchResultList = []; //This field is used to store asset search result
  @track asset = false;
  @track assetWorkShop = false; //
  selectedSA = false;
  SaName;
  slotCode;
  selectedWorkshop;
  readOnly = true;
  isVisible = true;
  workshopVisible = false;
  picLocVisible = true;
  dropLocVisible = true;
  cmpVisible = false;
  assetData = false;
  account;
  assetList;
  mmsVehicleError;
  succesContent;
  mmsRecVisible = false;
  dealerRecId;
  workshopList; //Added
  isDropAddSameAsPickup;
  currentDatetime;
  errorMessage;
  successMessage = false;;
  driverList; //New Var
  locationList;
  Driver__cSearchResults = [];
  Pickup_Location__cSearchResults = [];
  Drop_Location__cSearchResults = [];
  MMS_Vehicle__cSearchResults = [];
  cce_ManagerId;
  mmsVehicleOpt = [];
  userProfileId; //This field is used to store loggedin user's profile Id
  userDealerEmpCode; //This field is used to store loggedin user's DealerEmpCode
  isModalOpen = false;
  forCodeList = [];
  partnerUser = true;
  internaldealerdata = {};
  fieldVisible = false;
  isPartnerUser = true;
  showCommunityWorkshopField = true;
  fixedInternalUservalue;
  showAssetForSelection= true;
  autoAssetName;
  autoAppointmentType = 'Incoming Telephone Calls';
  get loaded() {
    return !this.errorMessage && !this.loading;
  }
  get today() {
    return new Date();
  }
  get tomorrow() {
    return this.getNextDay(this.today);
  }
  get minAppointmentDate() {
    return this.toMinDatetimeString(this.tomorrow);
  }
  get minPickupDate() {
    return this.toMinDatetimeString(this.workOrder.Appointment_Datetime__c);
  }
  get currentDate() {
    if (this.componentName.includes("Create Appointment")) {
      return this.toCurrentDatetimeString(this.tomorrow);
    } else {
      return null;
    }
  }
  get maxAppointmentDays() {
    return this.maxAppDays(this.today);
  }
  maxAppDays(dt) {
    dt = new Date(dt);
    dt.setDate(dt.getDate() + 60);
    return dt.toISOString();
  }
  toCurrentDatetimeString(dt) {
    dt = new Date(dt);
    dt.setHours(0, 0, 0);
    return dt.toISOString();
  }
  get minDropDate() {
    return this.toMinDatetimeString(
      //this.getNextDay(this.workOrder.Appointment_Datetime__c)
      this.workOrder.Pickup_Datetime__c
    );
  }
  get isPickupAppType() {
    return this.workOrder.Pickup_Type__c === "PU";
  }
  get isDropAppType() {
    return this.workOrder.Pickup_Type__c === "DR";
  }
  get isPickupDropAppType() {
    return this.workOrder.Pickup_Type__c === "PUD";
  }
  get isMMSAppType() {
    return this.workOrder.Pickup_Type__c === "MMS";
  }
  get showPickupInput() {
    return this.isPickupAppType || this.isPickupDropAppType;
  }
  get showDropInput() {
    return this.isDropAppType || this.isPickupDropAppType;
  }
  get showPickupDropInput() {
    return this.showPickupInput || this.showDropInput;
  }
  get disableDropAddressInput() {
    return this.isPickupDropAppType && this.isDropAddSameAsPickup;
  }
  get selectedAsset() {
    if (
      !this._selectedAsset ||
      this._selectedAsset.Id !== this.workOrder.AssetId
    ) {
      this._selectedAsset = this.assetList.find(
        asset => asset.Id === this.workOrder.AssetId
      );
    }
    return this._selectedAsset;
  }
  get pickupBtnCls() {
    return (
      "slds-button " +
      (this.isPickupAppType ? "slds-button_brand" : "slds-button_neutral")
    );
  }
  get dropBtnCls() {
    return (
      "slds-button " +
      (this.isDropAppType ? "slds-button_brand" : "slds-button_neutral")
    );
  }
  get pickupDropBtnCls() {
    return (
      "slds-button " +
      (this.isPickupDropAppType ? "slds-button_brand" : "slds-button_neutral")
    );
  }
  get mmsBtnCls() {
    return (
      "slds-button " +
      (this.isMMSAppType ? "slds-button_brand" : "slds-button_neutral")
    );
  }
  // This method is used to fetch Manager Logged in User
  @wire(getRecord, {
    recordId: currentUserId,
    fields: [Manager_Id, dealerId, profileId, dealerEmpCode]
  })
  currentUser({
    error,
    data
  }) {
    if (data) {
      this.cce_ManagerId = data.fields.ManagerId.value;
      this.userProfileId = data.fields.ProfileId.value;
      this.userDealerEmpCode = data.fields.Dealer_Employee_Code__c.value;
      if (data.fields.AccountId && data.fields.AccountId.value) {
        this.dealerRecId = data.fields.AccountId.value;
      }
    }
  }
  @wire(getPicklistValues, {
    recordTypeId: "$woRecordTypeId",
    fieldApiName: WO_STATUS
  })
  statusOptions;
  @wire(getPicklistValues, {
    recordTypeId: "$woRecordTypeId",
    fieldApiName: WO_SERVICE_TYPE
  })
  serviceTypeOptions;
  @wire(getPicklistValues, {
    recordTypeId: "$woRecordTypeId",
    fieldApiName: WO_APPOINTMENT_TYPE
  })
  appointmentTypeOptions;

  connectedCallback() {
    this.loading = true;
    //this.mmsVehicleError = mmsVehicleError;
    //this.mmsWorkshop = mmsWorkshop;
    ///////////////////////////////////////////////////////////////////////////////////////////////
    fetchCityandAssestInfo({
      recordId: this.recordId,
    })
      .then(result => {
        if (result && result.registrationNumberList && result.registrationNumberList.length > 0 &&
          result.userData.IsPortalEnabled === false && result.forCodeList && result.forCodeList.length > 0 
          && (result.userData.Profile.Name === 'ATM - Corporate Call Centre Agent' || result.userData.Profile.Name === 'ATM - Corporate Call Centre TL/ Manager')){
            console.log('coming in fetchCityandAssestInfo----------')
            console.log('-------------------result',result);
          this.partnerUser = false;
          this.showCommunityWorkshopField = false;
          this.forCodeList = [];
          this.forCodeList = result.forCodeList;
          this.internaldealerdata = '';
          if(this.recordId.includes('02i',0)){
            this.showAssetForSelection = false;
          }
        }
        this.fetchAppointmentDataMethod();
      })
      .catch(error => {
        console.log('error--------------->', error);
      })
    ///////////////////////////////////////////////////////////////////////////////////////////////   
    
  }
   
  fetchAppointmentDataMethod(){
    fetchAppointmentData({
      recordId: this.recordId
    })
      .then(this.parseResponse)
      .then(response => this.setAppointmentData(response))
      .catch(error => this.handleServerError(error))
      .finally(() => (this.loading = false));
  }

  renderedCallback() {
    if (this.workOrder) {
      // fetch today's date and format in YYYY-MM-DD 
      let today = new Date(); // Today's Date
      var dd = today.getDate();
      var mm = today.getMonth() + 1;
      var yyyy = today.getFullYear();
      if (dd < 10) {
        dd = '0' + dd;
      }
      if (mm < 10) {
        mm = '0' + mm;
      }
      today = yyyy + '-' + mm + '-' + dd;
      // Appointment Date
      var appDate = (this.workOrder.Appointment_Datetime__c).split("T");
      var todaysDate = new Date(today);
      var appointmentDate = new Date(appDate[0]);
      if (this.workOrder.Status !== 'Canceled') {
        //if (appointmentDate >= todaysDate) {
        if (!this.workOrder.Status && this.statusOptions.data) {
          this.workOrder.Status = this.statusOptions.data.values[0].value;
        }
        if (this.workOrder.Id) {
          this.readOnly = false;
        }
        if (this.workOrderDataLoaded) {
          this.updateLookupData("MMS_Vehicle__c", "");
          this.workOrderDataLoaded = false;
        }
        /*} else {
          this.showMessage("Something is wrong", "Past Appoinment cannot be changed", "error");
          this.closeModal();
        }*/
      } else {
        this.showMessage("Something is wrong", canncelApp, "error");
        this.closeModal();
      }
    }
  }
  parseResult(response) {
    return JSON.parse(JSON.stringify(response));
  }
  setAppointmentData(data) {
    console.log('datat------------------------',data);
    this.cmpVisible = true;
    this.account = data.account;
    this.assetList = data.assetList;

    this.workOrder = Object.assign({}, data.workOrder);
    console.log('this.workOrder:- ', this.workOrder);
    console.log('ProfileId:- ' + this.userProfileId);
    console.log('currentUserId:- ' + currentUserId);
    console.log('this.workOrder:- ' + this.workOrder);
    if (this.workOrder.OwnerId && SAProfileId === this.userProfileId.substring(0, 15) && currentUserId !== this.workOrder.OwnerId) {

      this.showMessage("Something is wrong", 'You are not allowed to reschedule this appointment', "error");
      this.closeModal();
    }
    this.workshopList = data.workshopList; //AddedworkshopOptions
    console.log('this.workshopList--------------',this.workshopList);
      this.driverList = data.workshopDriverList;

    //To make Workshop and Asset read only while Rescheduling Appointment
    if (this.componentName.includes("Update")) {
      this.workshopVisible = true;
      this.assetData = true;
    }
    
    this.workshopOptions = data.workshopList.map(workShpOpt => {
      if (!this.workOrder.Id && workShpOpt.Id === this.dealerRecId) {
        this.workOrder.Workshop__c = this.dealerRecId;
        this.fetchDriverList(this.workOrder.Workshop__c);
        this.fetchLocations(this.workOrder.Workshop__c);
        this.picLocVisible = false;
        this.dropLocVisible = false;
      }
      return {
        label: workShpOpt.Name,
        value: workShpOpt.Id
      };
    });

    this.woRecordTypeId = data.workOrder.RecordTypeId;
    this.asset = data.assetList.find(item => item.Id === data.workOrder.AssetId);
    if (!this.workOrder.AccountId) {
      this.workOrder.AccountId = this.account.Id;
    }

    if (this.workOrder.Id) {
      this.showPickupDropSection = this.workOrder.Pickup_Type__c ? true : false;
      this.fetchDriverList(this.workOrder.Workshop__c);
      if (this.workOrder.Pickup_Driver__c && this.workOrder.Pickup_Driver__r.Dealer_Employee_Code__c) {
        this.workOrder.empCode = this.workOrder.Pickup_Driver__r.Dealer_Employee_Code__c;
      }
      if (this.workOrder.Drop_Driver__c && this.workOrder.Drop_Driver__r.Dealer_Employee_Code__c) {
        this.workOrder.dropEmpCode = this.workOrder.Drop_Driver__r.Dealer_Employee_Code__c;
      }
      if (this.workOrder.MMS_Vehicle__c && this.fetchMMSVehRecord()) {
        this.workOrder.MMS_Vehicle__c = this.workOrder.MMS_Vehicle__c && this.mmsVehicleOpt.length > 0 ? this.workOrder.MMS_Vehicle__c : '';
      }

      //Added on 30th March to Show Slot code and SA name on component load
      if (this.workOrder.Workshop__c && this.workOrder.SA_Id__r) {
        this.selectedSA = true;
        this.SaName = this.workOrder.SA_Id__r.Name;
        this.slotCode = this.workOrder.Slot_Time__c;
      }
      //Added to show Pickup/Drop Locations
      this.fetchLocations(this.workOrder.Workshop__c);
      if (this.workOrder.Pickup_Location__c && !this.workOrder.Drop_Location__c) {
        this.picLocVisible = false;
        this.dropLocVisible = true;
      }
      if (!this.workOrder.Pickup_Location__c && this.workOrder.Drop_Location__c) {
        this.picLocVisible = true;
        this.dropLocVisible = false;
      }
      if (this.workOrder.Pickup_Location__c && this.workOrder.Drop_Location__c) {
        this.picLocVisible = false;
        this.dropLocVisible = false;
      }
    } else {
      this.showPickupDropSection = true;
      // Prepopulate Data
      if(this.partnerUser === false){
        this.workOrder.Appointment_Type__c = 'TEL';
      }else{
      this.workOrder.Appointment_Type__c = 'SRL';
    }
      
      let response = retrieveObjectArrayFromCache(); //// Prepopulate Data on the basis of cache
      if (response && response.Veh_Service_Due_Dt__c && response.Contact_ID__c && this.recordId === response.Contact_ID__c) {
        this.workOrder.Due_Date__c = response.Veh_Service_Due_Dt__c;
      }
      if (response && response.Service_Type__c && response.Contact_ID__c && this.recordId === response.Contact_ID__c) {
        if (response.Service_Type__c === 'First Free Service') {
          this.workOrder.Service_Type__c = 'FR1';
        } else if (response.Service_Type__c === 'Second Free Service') {
          this.workOrder.Service_Type__c = 'FR2';
        } else if (response.Service_Type__c === 'Third Free Service') {
          this.workOrder.Service_Type__c = 'FR3';
        } else if (response.Service_Type__c === 'Paid Service') {
          this.workOrder.Service_Type__c = 'PMS';
        }
      }
      if (response && response.Asset__c && response.Contact_ID__c && this.recordId === response.Contact_ID__c) {
        this.asset = response.Asset__r;
        this.workOrder.AssetId = response.Asset__c;
      }
      // To call SA availability cmp when Asset, Workshop & Appointment date is filled
      if (this.workOrder.AssetId && this.workOrder.Workshop__c) {
        this.checkSaAvailability();
      }
      if (this.account.BillingAddress) {
        this.workOrder.Pickup_Address__c = this.toAddressString(
          this.account.BillingAddress
        );

        this.workOrder.Drop_Address__c = this.workOrder.Pickup_Address__c;
        this.workOrder.Address__c = this.toAddressString(
          this.account.BillingAddress
        );
        this.isDropAddSameAsPickup = true;
      }
    }
    if (!this.workOrder.Pickup_Type__c) {
      this.workOrder.Pickup_Type__c = "PU";
    }
    if (this.workOrder.Appointment_Datetime__c) {
      this.workOrder.Appointment_Datetime__c = this.toDatetimeString(
        this.workOrder.Appointment_Datetime__c
      );
    } else {
      this.workOrder.Appointment_Datetime__c = this.toDatetimeString(
        this.tomorrow
      );
    }
    if (this.workOrder.Due_Date__c) {
      this.workOrder.Due_Date__c = this.toDateString(
        this.workOrder.Due_Date__c
      );
    } else {
      this.workOrder.Due_Date__c = this.toDateString(
        this.workOrder.Appointment_Datetime__c
      );
    }
    if (this.workOrder.Pickup_Datetime__c) {
      this.workOrder.Pickup_Datetime__c = this.toDatetimeString(
        this.workOrder.Pickup_Datetime__c
      );
    } else {
      this.workOrder.Pickup_Datetime__c = this.getPickupDatetimeString();
    }
    if (this.workOrder.Drop_Datetime__c) {
      this.workOrder.Drop_Datetime__c = this.toDatetimeString(
        this.workOrder.Drop_Datetime__c
      );
    } else {
      this.workOrder.Drop_Datetime__c = this.getDropDatetimeString();
    }

    if (this.workshopOptions.length === 0  && this.partnerUser === true) {
     this.errorMessage = "There is no Workshop record";
      this.showErrorMessage(this.errorMessage);
    }
    if (!this.assetList.length) {
      this.errorMessage =
        "There is no Asset related to Customer " + data.account.Name;
      this.showErrorMessage(this.errorMessage);
    }
    this.workOrderDataLoaded = true;


    //for auto assign of Asset name when cmp call from Asset directly
    if(this.recordId.includes('02i',0)){
      this.asset = this.assetList.find(item => item.Id === this.recordId);
      console.log('aseett----------------',this.asset);
      this.checkSaAvailability();
      this.autoAssetName = this.asset.Name;
      this.workOrder.AssetId = this.asset.Id;
      this.workOrder.Subject = this.account.Name + (this.asset ? " - " + this.asset.Name : "");
    }
    
  }

  handleWorkshopLink(event) {
    this.isModalOpen = true;
  }
  closeForCodeModal(event) {
    this.isModalOpen = false;
  }

  handleInternalDealerIDChange(event) {
    this.internaldealerdata = event.detail;
    console.log('this.internaldealerdata -------',this.internaldealerdata);
    this.isModalOpen = false;
    this.fieldVisible = true;
    this.isPartnerUser = false;
    this.partnerUser = true;
    this.parentGroup = this.internaldealerdata.Parent_Group__c;
    this.dealerMapCode = this.internaldealerdata.Dealer_Map_Code__c;
    this.locationCode = this.internaldealerdata.Dealer_Location__c;
    this.forCodeAPIReq = this.internaldealerdata.For_Code__r.For_Code__c;
    console.log('this.internaldealerdata-------->' + JSON.stringify(this.internaldealerdata));
    this.workshopList = [];
    this.workshopList.push(this.internaldealerdata);
    console.log('this.workshopList-----------------------',JSON.stringify(this.workshopList));


    ////////////////////////////////////////////////////////////
    console.log('valyue on this --------',this.internaldealerdata.Id);
    this.partnerUser === true;
    this.assetWorkShop = false;
    this.selectedSA = false; // This part will hide the SA Name and slot code part
    this.workOrder.Workshop__c = this.internaldealerdata.Id;
    this.driverOptions = null;
    this.locationOptions = null;
    this.workOrder.empCode = null; // To remove the Pickup Driver Employee code when the Workshop is Changed
    this.workOrder.dropEmpCode = null; // To remove the Drop Driver Employee code when the Workshop is Changed
    this.workOrder.Pickup_Driver__c = null; // To remove the Pickup Driver when the Workshop is Changed
    this.workOrder.Drop_Driver__c = null; // To remove the Drop Driver when the Workshop is Changed
    this.triggerSAavailabilityCmp();

    if (this.workOrder.Workshop__c && this.workOrder.Pickup_Type__c === "MMS") {
      this.fetchMMSVehRecord();
    }
    this.checkSaAvailability();
    this.fetchLocations(this.workOrder.Workshop__c);
    this.fetchDriverList(this.workOrder.Workshop__c);
    
    try {
      this.template.querySelector("c-sa-Allocation").fetchAvailableSlots();
    } catch (err) {

    }
    
    ////////////////////////////////////////////////////////////
  }

  handlePickupSelect() {
    this.workOrder.Pickup_Type__c = "PU";
    this.picLocVisible = false;
    this.dropLocVisible = true;
    this.workOrder.Drop_Driver__c = '';
    this.workOrder.Drop_Location__c = '';
    this.workOrder.dropEmpCode = '';
  }
  handleDropSelect() {
    this.workOrder.Pickup_Type__c = "DR";
    this.picLocVisible = true;
    this.dropLocVisible = false;
    this.workOrder.Pickup_Location__c = '';
    this.workOrder.Pickup_Driver__c = '';
    this.workOrder.empCode = '';
  }
  handlePickupDropSelect() {
    this.workOrder.Pickup_Type__c = "PUD";
    this.picLocVisible = false;
    this.dropLocVisible = false;
    this.workOrder.Drop_Driver__c = '';
    this.workOrder.Drop_Location__c = '';
    this.workOrder.Pickup_Location__c = '';
    this.workOrder.Pickup_Driver__c = '';
    this.workOrder.empCode = '';
    this.workOrder.dropEmpCode = '';
  }
  handleMMSSelect() {
    this.workOrder.Pickup_Type__c = "MMS";
    this.workOrder.Pickup_Location__c = '';
    this.workOrder.Drop_Location__c = '';
    this.workOrder.Pickup_Driver__c = '';
    this.workOrder.Drop_Driver__c = '';
    this.workOrder.empCode = '';
    this.workOrder.dropEmpCode = '';
    this.workOrder.dropLocCode = '';
    this.workOrder.pickupLocCode = '';
    this.picLocVisible = true;
    this.dropLocVisible = true;
    this.fetchMMSVehRecord();
  }

  fetchMMSVehRecord() {
    if (this.workOrder.Workshop__c && this.workOrder.Pickup_Type__c === "MMS") {
      getMMSVehicle({
        workshopId: this.workOrder.Workshop__c
      }).then(result => {
        if (result && result.length > 0) {
          this.mmsVehicleOpt = [];
          for (let i = 0; i < result.length; i++) {
            this.mmsVehicleOpt.push({
              label: result[i].Name,
              value: result[i].Id
            });
          }
          console.log(' this.mmsVehicleOpt------>' + this.mmsVehicleOpt);
        } else {
          this.mmsVehicleError = mmsVehicleError;
          this.showErrorMessage(mmsVehicleError);
        }
      }).catch(error => this.handleServerError(error));
    } else {
      this.mmsVehicleError = mmsWorkshop;
      this.showErrorMessage(mmsWorkshop);
    }
  }

  /*handleCustomSearch(event) {
    let fname = event.target.dataset.name;
    let params = Object.assign({}, event.detail, {
      codeFieldName: event.target.dataset.codeFieldName,
      workshopId: this.workOrder.Workshop__c
    });

    getSearchResults(params).then(searchResults => {

      if (searchResults.length > 0 && this.workOrder.Workshop__c) {
        this.mmsRecVisible = false;
        this[fname + "SearchResults"] = searchResults;
        this.template
          .querySelector("[data-name='" + fname + "']")
          .updateSearchResults(searchResults);
      } else {
        this.mmsRecVisible = true;
      }
    });
  }*/

  handleFieldUpdate(event) {

    let fieldName = event.target.name || event.target.dataset.name;
    this.workOrder[fieldName] = event.target.value || event.detail.value;

    if (event.target.reportValidity()) {
      switch (fieldName) {
        case "Pickup_Address__c":
          this.updatePickupAddressDependents();
          break;
        case "Appointment_Datetime__c":
          //this.triggerSAavailabilityCmp(); //New Added 
          this.updateAppointmentDateDependents();
          //this.checkSaAvailability(); //New Added
          if (this.asset && this.workOrder.AssetId && this.workOrder.Workshop__c) {
            this.triggerSAavailabilityCmp(); //New Added
            this.checkSaAvailability();
            if (this.componentName.includes("Update")) {
              setTimeout(this.callChildComponent.bind(this), 1000);
            }
            if (!this.componentName.includes("Update")) {
              this.template.querySelector("c-sa-allocation").fetchAvailableSlots();
            }
          }

          break;
        default:
      }
    }
  }

  get readOnlyValue() {
    console.log('this asset read only value', this.asset)
    return (!this.asset) ? true : false;
  }

  callChildComponent() {
    this.template.querySelector("c-sa-allocation").fetchAvailableSlots();
  }




  //copy the pickup address to drop address
  handleDropAddSameAsPickupChange(event) {
    this.isDropAddSameAsPickup = event.target.checked;
    this.updatePickupAddressDependents();
  }
  handleShowPickupDropSectionChange(event) {
    this.showPickupDropSection = event.target.checked ? true : false;
    if (event.target.checked && this.workOrder.Pickup_Type__c === "PU") {
      this.picLocVisible = false;
      this.dropLocVisible = true;
    } else if (!event.target.checked) {
      this.picLocVisible = true;
      this.dropLocVisible = true;
    }
  }
  handleSASelection(event) {
    this.workOrder.SA_Code__c = event.detail.selectedSA.code;
    this.workOrder.Slot_Time__c = event.detail.selectedSlot.slot;
    this.workOrder.Slot_Code__c = event.detail.selectedSlot.slotCode;
  }
  //save method to create appointment
  handleSave() {
    var element = this.template.querySelector('[data-id="isBlank"]');
    this.loading = true; // Added to show the spinner
    this.classList.add("disabled");
    if (this.validateInputs() && this.asset !== undefined && (this.partnerUser === true || (this.partnerUser === false && element))) {
      this.cmpVisible = false
      //To populate CCE Manager Id
      if (this.cce_ManagerId) {
        this.workOrder.Executive_Manager__c = this.cce_ManagerId;
      }
      if (!this.showPickupDropSection) {
        this.workOrder.Pickup_Type__c = null;
      }
      if (!this.showPickupInput) {
        this.workOrder.Pickup_Datetime__c = null;
        this.workOrder.Pickup_Address__c = null;
        this.workOrder.Pickup_Location__c = null;
        this.workOrder.Pickup_Driver__c = null;
        this.workOrder.empCode = null;
      }
      if (!this.showDropInput) {
        this.workOrder.Drop_Datetime__c = null;
        this.workOrder.Drop_Address__c = null;
        this.workOrder.Drop_Location__c = null;
        this.workOrder.Drop_Driver__c = null;
        this.workOrder.dropEmpCode = null;
      }
      if (!this.isMMSAppType) {
        this.workOrder.Address__c = null;
        this.workOrder.MMS_Vehicle__c = null;
      }
      let params = {
        workOrderJSONString: JSON.stringify(this.workOrder)
      };
      console.log('this.workshopList below--------------',JSON.stringify(this.workshopList));
      console.log('== this.workOrder.Workshop__c ', this.workOrder.Workshop__c);
      if (this.workOrder.Workshop__c) {
        this.selectedWorkshop = this.workshopList.find(item => item.Id === this.workOrder.Workshop__c);
      }
      console.log('this.selectedWorkshop below--------------',JSON.stringify(this.selectedWorkshop));
      

      if (this.workOrder.Pickup_Driver__c) {
        var pickEmpCode = (this.driverList.find(item => item.Id === this.workOrder.Pickup_Driver__c).Dealer_Employee_Code__c).split('_');
        params.empCode = pickEmpCode[1] ? pickEmpCode[1] : '';
      }
      if (this.workOrder.Drop_Driver__c) {
        var drpEmpCode = (this.driverList.find(item => item.Id === this.workOrder.Drop_Driver__c).Dealer_Employee_Code__c).split('_');
        params.dropEmpCode = drpEmpCode[1] ? drpEmpCode[1] : '';
      }
      if (this.workOrder.Pickup_Location__c) {
        params.pickupLocCode = this.locationList.find(item => item.Id === this.workOrder.Pickup_Location__c).Location_Code__c;
      }
      if (this.workOrder.Drop_Location__c) {
        params.dropLocCode = this.locationList.find(item => item.Id === this.workOrder.Drop_Location__c).Location_Code__c;
      }
      if (this.selectedWorkshop) {
        params.workshopRecord = this.selectedWorkshop;
      }
      console.log('== params.workOrderJSONString ',params.workOrderJSONString);
      console.log('== params.empCode ',params.empCode);
      console.log('== params.dropEmpCode ',params.dropEmpCode);
      console.log('== params.pickupLocCode ',params.pickupLocCode);
      console.log('== params.dropLocCode ',params.dropLocCode);
      console.log('== params.workshopRecord ',params.workshopRecord);
        var scrollOptions = {
          left: 0,
          top: 0,
          behavior: 'smooth'
      }
      window.scrollTo(scrollOptions);
      saveAppointment(params)
        .then(result => this.handleSaveResponse(result))
        .catch(error => this.handleServerError(error))
        .finally(() => this.classList.remove("disabled"));
    } else {
      this.loading = false;
      this.classList.remove("disabled");
      this.showErrorMessage("Check your inputs and try again.");
    }
  }
  updateLookupData(field, codeField) {
    let id = this.workOrder[field];
    if (id) {
      let record = this.workOrder[field.replace("__c", "__r")];
      this[field + "SearchResults"].push({
        id: id,
        code: record[codeField]
      });
      let lookupInput = this.getLookupInputField(field);
      if (lookupInput) {
        lookupInput.updateSelection(id, record.Name);
      }
    }
  }
  getSelectedCode(key) {
    let list = this[key + "SearchResults"] || [];
    let value = this.workOrder[key];
    return list.find(item => item.id === value).code;
  }
  handleSaveResponse(result = {
    message: "Server Error"
  }) {

    console.log('== result.bodyData ', result.bodyData);
    console.log('== result.apiName ', result.apiName);

    if (result.bodyData) {
      apiCall({
        jitName: result.apiName,
        jsonBody: result.bodyData,
        urlParam: '',
        urlPart: result.urlPart
      })
        .then(response => {
            console.log('== response ', response);
          if (response.code === 200) {
            storeAppointment({
              workOrderJSONString: result.workOrder,
              DPSAppointmentNo: JSON.parse(response.data).appointmentNum
            })
              .then(finalResponse => {
                if (finalResponse.code === 200) {
                  this.showSuccessMessage(
                    "Appointment " + (this.workOrder.Id ? "Updated" : "Created & Service Number is:- " + JSON.parse(response.data).appointmentNum)
                  );
                  pubsub.fire('appointmentBooked', JSON.parse(response.data).appointmentNum);
                  if (this.workOrder.Id) {
                    this.closeModal();
                  }

                  this.successMessage = this.workOrder.Id ? false : true;
                  this.succesContent = "Appointment " + (this.workOrder.Id ? "Updated" : "Created & Service Number is:- " + JSON.parse(response.data).appointmentNum);
                } else {

                  this.showErrorMessage(finalResponse.message);
                  this.errorMessage = finalResponse.message;
                }
              })
          } else if (response.code !== 200) {
            this.showErrorMessage(response.message + '- Please reach out to support team.');
            this.cmpVisible = true; // To display the existing field on cmp
            //this.errorMessage = response.message+'- Please reach out to support team.';
            //setTimeout(this.closeModal.bind(this), 2000);

          }
          this.loading = false;
        })
        .catch(error => {
          console.log('== response error ', error);
          this.loading = false;
        })
    } else {
      this.loading = false;
      throw result;
    }
  }
  handleServerError(error) {

    this.loading = false;
    this.errorMessage = Server_Error;
    var concatErrMessage = error.message + '. ' + Server_Error;

    this.showErrorMessage(concatErrMessage);
    console.error('eror sis ---------------------',error);
    console.error('eror sis ---------------------',error.message);
  }
  updatePickupAddressDependents() {
    if (this.isDropAddSameAsPickup) {
      this.workOrder.Drop_Address__c = this.workOrder.Pickup_Address__c;
    }
  }
  updateAppointmentDateDependents() {
    if (this.workOrder.Appointment_Datetime__c) {
      this.workOrder.Pickup_Datetime__c = this.getPickupDatetimeString();
      this.workOrder.Drop_Datetime__c = this.getDropDatetimeString();
    }
  }
  // This method is used for removal of selected Asset
  handleRemove(event) {
    event.preventDefault();
    this.asset = undefined;
    this.assetSearchResultList = undefined;
    this.checkSaAvailability();
  }
  /*****  This method is used for asset search *****/
  handleAssetSearch(event) {

    this.assetSearchResultList = [];
    // let tempList=[];
    getAssets({
      customerId: this.account.Id,
      searchKey: event.detail.value
    })
      .then(result => {

        this.assetSearchResultList = result
      })
      .catch(error => this.handleServerError(error));

  }
  handleSelect(event) {

    const selectedRecordId = event.detail;
    this.asset = this.assetList.find(item => item.Id === selectedRecordId);
    this.checkSaAvailability();
    this.workOrder.AssetId = this.asset.Id;
    this.workOrder.Subject =
      this.account.Name + (this.asset ? " - " + this.asset.Name : "");

  }
  //This method will be called when Asset, Workshop and Appointment date and time gets changed
  triggerSAavailabilityCmp() {

    if (this.workOrder.Workshop__c) {
      this.workOrder.SA_Id__r = null;
      this.workOrder.Slot_Time__c = null;
    }
  }

  fetchWorkShopId(event) {
    console.log('valyue on this --------',event.target.value);
    this.partnerUser === true;
    this.assetWorkShop = false;
    this.selectedSA = false; // This part will hide the SA Name and slot code part
    this.workOrder.Workshop__c = event.target.value;
    this.driverOptions = null;
    this.locationOptions = null;
    this.workOrder.empCode = null; // To remove the Pickup Driver Employee code when the Workshop is Changed
    this.workOrder.dropEmpCode = null; // To remove the Drop Driver Employee code when the Workshop is Changed
    this.workOrder.Pickup_Driver__c = null; // To remove the Pickup Driver when the Workshop is Changed
    this.workOrder.Drop_Driver__c = null; // To remove the Drop Driver when the Workshop is Changed
    this.triggerSAavailabilityCmp();

    if (this.workOrder.Workshop__c && this.workOrder.Pickup_Type__c === "MMS") {
      this.fetchMMSVehRecord();
    }

    this.fetchLocations(this.workOrder.Workshop__c);
    this.fetchDriverList(this.workOrder.Workshop__c);
    try {

      this.template.querySelector("c-sa-Allocation").fetchAvailableSlots();
    } catch (err) {

    }
    this.checkSaAvailability();
  }
  checkSaAvailability() {
    if (this.asset && this.workOrder.Workshop__c) {
      this.assetWorkShop = true;
    } else {
      this.assetWorkShop = false;
    }
    console.log('== this.asset ', this.asset);
    console.log('== this.workOrder.Workshop__c ', this.workOrder.Workshop__c);
    console.log('== this.assetWorkShop ', this.assetWorkShop);
  }
  handlePickUpLOcUpdate(event) {

    if (event.target.name === "pickupLoc") {
      this.workOrder.Pickup_Location__c = event.target.value;

    }
    if (event.target.name === "DropLoc") {
      this.workOrder.Drop_Location__c = event.target.value;
    }
  }
  //Method added to Fetch Pickup and Drop Locations on the basis of WorkshopId
  fetchLocations(wrkShopRecId) {
    if (this.showPickupInput && !this.showDropInput) {
      this.picLocVisible = false;
      this.dropLocVisible = true;
    } else if (!this.showPickupInput && this.showDropInput) {
      this.picLocVisible = true;
      this.dropLocVisible = false;
    } else if (this.showPickupInput && this.showDropInput) {
      this.picLocVisible = false;
      this.dropLocVisible = false;
    }
    fetchPickupLoc({
      workshopId: wrkShopRecId
    })
      .then(result => {
        if (result && result.length > 0) {
          this.locationList = result;
          this.locationOptions = result.map(locOpt => {
            return {
              label: locOpt.Name,
              value: locOpt.Id
            };
          });
        } else {
          if (this.showPickupDropSection) {
            this.dispatchEvent(
              new ShowToastEvent({
                title: "Something is wrong",
                message: "There is no Pickup/Drop Location available for the selected Workshop",
                variant: "error"
              })
            );
          }
        }
      })
      .catch(error => this.handleServerError(error))
  }
  fetchDriverList(wrkShopId) {
    this.isVisible = false;
    // Method to fetch the List of Drivers from the selected Workshop
    fetchDriverList({
      workshopId: wrkShopId
    })
      .then(result => {
        if (result && result.length > 0) {

          this.driverList = result;
          this.driverOptions = result.map(driverOpt => {
            return {
              label: driverOpt.Name,
              value: driverOpt.Dealer_Employee_Code__c
            };
          });
        } else {
          //this.assetWorkShop=false;
          this.driverOptions = null;
          this.workOrder.Pickup_Driver__c = '';
          this.workOrder.Drop_Driver__c = '';
          this.workOrder.empCode = '';
          this.workOrder.dropEmpCode = ''; // Drop Driver Change
          if (this.showPickupDropSection) {
            this.dispatchEvent(
              new ShowToastEvent({
                title: "Something is wrong",
                message: "There is no Driver for the selected Workshop",
                variant: "error"
              })
            );
          }
        }
      })
      .catch(error => this.handleServerError(error))
      .finally(() => (this.loading = false));
  }
  handleDriverUpdate(event) {
    //Pickup Driver
    if (event.target.name === "Driver") {
      this.workOrder.Pickup_Driver__c = this.driverList.find(item => item.Dealer_Employee_Code__c === event.target.value).Id;
      this.workOrder.empCode = event.target.value;
    }
    //Drop Driver 
    else if (event.target.name === "DropDriver") {
      this.workOrder.Drop_Driver__c = this.driverList.find(item => item.Dealer_Employee_Code__c === event.target.value).Id;
      this.workOrder.dropEmpCode = event.target.value;
    }
  }
  //to handle the data validation
  validateInputs() {
    let inps = [].concat(
      this.queryAll("lightning-input"),
      this.queryAll("lightning-combobox"),
      this.queryAll("lightning-textarea"),
      this.queryAll("c-lookup-input-field"),
      this.queryAll("c-sa-allocation")
    );
    return inps.filter(inp => !inp.reportValidity()).length === 0;
  }
  getPickupDatetimeString() {
    let dt = new Date(this.workOrder.Appointment_Datetime__c);
    dt.setHours(dt.getHours() - 2);
    return this.toDatetimeString(dt);
  }
  getDropDatetimeString() {
    return this.toDatetimeString(
      this.getNextDay(this.workOrder.Appointment_Datetime__c)
    );
  }
  getNextDay(dt) {
    dt = new Date(dt);
    dt.setDate(dt.getDate() + 1);
    return dt;
  }
  toDatetimeString(dt) {
    return new Date(dt).toISOString();
  }
  toDateString(dt) {
    return this.toDatetimeString(dt).substring(0, 10);
  }
  toMinDatetimeString(dt) {
    dt = new Date(dt);
    dt.setHours(0);
    dt.setMinutes(0);
    dt.setSeconds(0);
    return dt.toISOString();
  }
  toAddressString(address) {
    let values = [
      address.street || "",
      address.city || "",
      address.country || "",
      address.province || "",
      address.postalCode || ""
    ];
    return values.filter(Boolean).join(" ");
  }
  getLookupInputField(name) {
    return this.template.querySelector("[data-name=" + name + "]");
  }
  queryAll(query) {
    return Array.from(this.template.querySelectorAll(query));
  }
  //redirect to work order detail page
  navigateToWorkOrder(woId) {
    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: woId,
        objectApiName: "WorkOrder",
        actionName: "view"
      }
    });
  }
  //method to show success toast message
  showSuccessMessage(message) {
    this.showMessage("Success", message, "success");
  }
  //method to show error toast message
  showErrorMessage(error) {
    this.showMessage("Something is wrong", error, "error");
  }
  showMessage(title, message, variant) {
    this.dispatchEvent(
      new ShowToastEvent({
        title: title,
        message: message,
        variant: variant
      })
    );
  }
  //method to close the quick action
  closeModal() {
    //fire the custom event to be handled by parent aura component
    this.dispatchEvent(new CustomEvent("finish"));
  }
}