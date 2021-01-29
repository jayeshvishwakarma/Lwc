/* eslint-disable no-console */
import {
  LightningElement,
  track,
  api,
  wire
} from "lwc";
import {
  ShowToastEvent
} from "lightning/platformShowToastEvent";
import {
  NavigationMixin
} from "lightning/navigation";
import {
  getRecord
} from "lightning/uiRecordApi";
import currentUserId from "@salesforce/user/Id";
import {
  retrieveObjectArrayFromCache
} from "c/cacheServiceLayerCMP";
//Server methods
import fetchCityandAssestInfo from "@salesforce/apex/ServiceCalculator.fetchCityandAssestInfo";
import getServiceCalculatorData from "@salesforce/apexContinuation/JITMuleSoftIntegration.genericJITCall";

// To use the Service Type Custom Label
import serviceType from "@salesforce/label/c.serviceType";
// This is used to display content under the Service Calculations
import serviceCalContent from "@salesforce/label/c.serviceCalContent";
import dealerId from "@salesforce/schema/User.AccountId";
import userChannel from "@salesforce/schema/User.Channel__c";


export default class ServiceCalculator extends NavigationMixin(
  LightningElement
) {
  @api recordId; // This variable is used to store Record ID of Account Object

  @track isVisible = false;
  @track cityoptions; // This variable is used to store the City Picklist values

  @track loading = false; // This varibale is used to control the visibility of spinner
  @track errorMessage;
  @track showVehicle = false;
  @track showPMSJobs = false;

  city; // This variable is used to store City data.
  serviceType; // This variable is used to store Service Type data
  workshopPrf; // This variable is used to store WorkShop prefrence data
  kilometre; // This variable is used to store Kilometre data
  registrationNumber; // This variable is used to store Registration Number data
  obj; // This variable is used to store JSON result
  DealerforCode; //This variable is used to store forCode from Dealer Account
  //cityRecordId; // This variable is used to store the City Record ID for Logged in user Dealer

  serviceTypevalues; // This variable is used to store Picklist values Free and Periodic
  staticContent; // This varibale is used to store the content that is displayed under Estimated cost of Services ex: Tax not included
  columns; // This variable is used to store the Lightning datatable columns data
  registrationNumberValues; // This variable is used to Store the Registration Number of Customer Cars from Assest object
  columnsDescription; //This variable is used to Store Description
  dataDescription = [];
  loggedInUserDealerId;
  workshopOptions = [];
  forCodeAPIReq;
  onDemandJobData = []; // This variable is used to store all ondemand jobs data
  showOndemanJobs = false;
  showVehicleOndemandJob = false;
  workshopList = []; //This field is used to store all workshops related to logged in user
  selectedWorkshopId = ''; // This field is used to store selected workshop id
  parentGroup = ''; // This is used to store selected workshop's parent group 
  dealerMapCode = ''; // This is used to store selected workshop's dealer map code
  locationCode = ''; // This is used to store selected workshop's location code
  workParticularTotalCost = 0;
  totalCost = 0;
  forCodeData = false;
  partnerUser = true;
  isModalOpen = false;
  forCodeList = [];
  forCodeFilteredList = [];
  forCodeRecordId;
  internaldealerdata = {};
  internalWorkshopType = 'Select Workshop';
  isPartnerUser = true;
  showCommunityWorkshopField = true;
  fieldVisible = false;
  showRegisterNumberField = true;
  registrationNumName;
  get loaded() {
    return !this.errorMessage && !this.loading;
  }

  // This method is used to fetch Channel of Logged in User and Pass it Workshop Prefrence for Service Calculation
  @wire(getRecord, {
    recordId: currentUserId,
    fields: [userChannel, dealerId]
  })
  currentUser({
    error,
    data
  }) {
    if (data) {
      //this.workshopPrf = data.fields.Channel__c.value ? data.fields.Channel__c.value : '';
      this.loggedInUserDealerId = data.fields.AccountId.value ? data.fields.AccountId.value : '';
    } else {

    }
  }

  handleWorkshopLink(event) {
    this.isModalOpen = true;
  }
  closeForCodeModal(event) {
    this.isModalOpen = false;
  }

  //connectedCallbackfetchDatafromServer
  connectedCallback() {
    // To show the Spinner
    this.loading = true;
    // Method to Pass recordId and it will return the City and Assest related to Customer
    fetchCityandAssestInfo({
        recordId: this.recordId,
      })
      .then(result => {
        console.log('data is---------',result.userData.Profile.Name);
        let response = retrieveObjectArrayFromCache();
        if (response) {
          this.registrationNumber = response.Vehicle_Registration_Number__c;
        }
        console.log('Server data------>', result);
        console.log('result.userData.IsPortalEnabled data------>', result.userData.IsPortalEnabled);
        if (result && result.registrationNumberList && result.registrationNumberList.length > 0 && result.userData.IsPortalEnabled === true) {
          // ************************  For Community users ************************ ************************ ************************ 
          if (result.workShopList && result.workShopList.length > 0) {
            // To hide the Spinner

            this.loading = false;
            this.registrationNumberValues = [];
            for (let i = 0; i < result.registrationNumberList.length; i++) {
              this.registrationNumberValues.push({
                label: result.registrationNumberList[i].Name,
                value: result.registrationNumberList[i].Registration_Number__c
              });
            }

            this.workshopOptions = [];
            this.workshopList = result.workShopList;
            for (let i = 0; i < result.workShopList.length; i++) {
              this.workshopOptions.push({
                label: result.workShopList[i].Name,
                value: result.workShopList[i].Id + '-' + result.workShopList[i].For_Code__r.For_Code__c
              });
              if (this.loggedInUserDealerId && this.loggedInUserDealerId === result.workShopList[i].Id) {
                this.DealerforCode = result.workShopList[i].Id + '-' + result.workShopList[i].For_Code__r.For_Code__c;
                var forCd = (this.DealerforCode).split('-');
                this.selectedWorkshopId = result.workShopList[i].Id;
                this.forCodeAPIReq = forCd[1];
                this.fetchDealerDetails(this.selectedWorkshopId);
              }
            }

            // This part is covered to fetch and display the Picklist values for Service type
            this.serviceTypeValues = [];
            if (serviceType !== "" && serviceType !== null) {
              let reslt = serviceType.split(";");
              for (let i = 0; i < reslt.length; i++) {
                this.serviceTypeValues.push({
                  label: reslt[i],
                  value: reslt[i]
                });
              }
            }

            // This is used to display the Content under the Estimated cost of Services
            this.staticContent = [];
            if (serviceCalContent !== "" && serviceCalContent !== null) {
              this.staticContent = serviceCalContent.split(";");
            }
          } else {
            // To hide the Spinner
            this.loading = false;
            // To throw an error message if Registration Number is not present
            this.dispatchEvent(
              new ShowToastEvent({
                title: "Something is wrong",
                message: "Asset details are missing",
                variant: "error"
              })
            );
            this.cancel();
          }
        } else if (result && result.registrationNumberList && result.registrationNumberList.length > 0 &&
          result.userData.IsPortalEnabled === false && result.forCodeList && result.forCodeList.length > 0 
          && (result.userData.Profile.Name === 'ATM - Corporate Call Centre Agent' || result.userData.Profile.Name === 'ATM - Corporate Call Centre TL/ Manager')) {
          // ************************  For Internal Users *************************************************
          this.loading = false;
          this.partnerUser = false;
          this.registrationNumberValues = [];
          this.forCodeList = [];
          this.forCodeList = result.forCodeList;
          this.internaldealerdata = '';
          this.showCommunityWorkshopField = false;
          if(this.recordId.includes('02i',0)){
            this.showRegisterNumberField = false;
          }

          //Asset List data
          for (let i = 0; i < result.registrationNumberList.length; i++) {
            this.registrationNumberValues.push({
              label: result.registrationNumberList[i].Name,
              value: result.registrationNumberList[i].Registration_Number__c
            });
            //for auto assigning of registration number when internal user use component in Asset obj
            if(this.showRegisterNumberField === false && result.registrationNumberList[i].Id === this.recordId){
              this.registrationNumber = result.registrationNumberList[i].Name;
            }
          }

          // This part is covered to fetch and display the Picklist values for Service type
          this.serviceTypeValues = [];
          if (serviceType !== "" && serviceType !== null) {
            let reslt = serviceType.split(";");
            for (let i = 0; i < reslt.length; i++) {
              this.serviceTypeValues.push({
                label: reslt[i],
                value: reslt[i]
              });
            }
          }

          // This is used to display the Content under the Estimated cost of Services
          this.staticContent = [];
          if (serviceCalContent !== "" && serviceCalContent !== null) {
            this.staticContent = serviceCalContent.split(";");
          }


        } else {
          this.dispatchEvent(
            new ShowToastEvent({
              title: "Something is wrong",
              message: "Please try again later!",
              variant: "error"
            })
          );
          this.loading = false;
          this.cancel();
        }

      })
      .catch(error => {
        console.log(error);
        this.error = error;
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Something is wrong",
            message: "Please try again later!",
            variant: "error"
          })
        );
        this.cancel();
      });
  }


  openModalInternalUser() {
    try {
      this.isModalOpen = true;
    } catch (error) {
      console.log('ID-----error----->', error);
    }

  }

  handleInternalDealerIDChange(event) {
    this.internaldealerdata = event.detail;
    console.log('this.internaldealerdata-------------',this.internaldealerdata);
    this.isModalOpen = false;
    this.fieldVisible = true;
    this.isPartnerUser = false;
    this.partnerUser = true;
    if(this.internaldealerdata.Channel__c === 'EXC'){
      this.workshopPrf = 'Nexa';
    }
    else if(this.internaldealerdata.Channel__c === 'NRM' && this.internaldealerdata.Dealer_Category__c !== 'DDT'){
      this.workshopPrf = 'Arena';
    }
    else{
      this.workshopPrf = 'Nexa';
    }
    this.parentGroup = this.internaldealerdata.Parent_Group__c;
    this.dealerMapCode = this.internaldealerdata.Dealer_Map_Code__c;
    this.locationCode = this.internaldealerdata.Dealer_Location__c;
    this.forCodeAPIReq = this.internaldealerdata.For_Code__r.For_Code__c;
    console.log('this.DealerforCode----->' + this.DealerforCode);
    console.log('this.internaldealerdata-------->' + JSON.stringify(this.internaldealerdata));
  }



  // This method is used to fetch selected workshops details(Dealer map code,Parentgroup & Location code)
  fetchDealerDetails(workshopId) {
    let selectedWorkshop = this.workshopList.find(workshop => workshop.Id === workshopId);
    this.parentGroup = selectedWorkshop.Parent_Group__c;
    this.dealerMapCode = selectedWorkshop.Dealer_Map_Code__c;
    this.locationCode = selectedWorkshop.Dealer_Location__c;
  }
  onchangeHandler(event) {
    this.totalCost = this.workParticularTotalCost;
    for (var selectedRow in event.detail.selectedRows) {
      if (event.detail.selectedRows[selectedRow].name != 'Total Cost') {
        this.totalCost = this.totalCost + event.detail.selectedRows[selectedRow].cost;
      }
    }
  }
  // This method will be called on onchange event
  handlechange(event) {
    if (event.target.name === "RegistrationNumber") {
      this.registrationNumber = event.detail.value;
    } else if (event.target.name === "ServiceType") {
      this.serviceType = event.detail.value;
    } else if (event.target.name === "Kilometre") {
      this.kilometre = event.detail.value;
    } else if (event.target.name === "WorkShopName" && this.partnerUser === true) {
      var forCodeVal = event.detail.value;
      var codeRec = forCodeVal.split('-');
      this.selectedWorkshopId = codeRec[0];
      this.forCodeAPIReq = codeRec[1];
      this.fetchDealerDetails(this.selectedWorkshopId);
    }
  }


  // This function is created to accept only numbers
  isDecimal(event) {
    var charCode = event.which ? event.which : event.keyCode;
    if (charCode < 48 || charCode > 57) {
      event.preventDefault();
    }
    return true;
  }

  // This method is created to restrict Copy and Paste
  handlePaste(event) {
    event.preventDefault();
  }

  // This method will be called when user clicks on Calculate button
  calculateAmount() {

    // To Handle the data validation for lightning-input field
    //var vl = this.template.querySelector("lightning-input"); //&& vl.value <= 500000
    if (this.validateInputs()) {
      console.log('this.partnerUser------->' + this.partnerUser);
      console.log('this.internaldealerdata------->', this.internaldealerdata);
      if (!this.partnerUser && !this.internaldealerdata) {
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Something is wrong",
            message: "Dealer Workshop is not selected",
            variant: "error"
          })
        );
        this.loading = false;
      } else {
        // To show the spinner
        this.loading = true;
        // To hide Accordin
        this.showVehicle = false;
        this.showPMSJobs = false;
        this.showVehicleOndemandJob = false;
        this.showOndemanJobs = false;
        this.dataDescription = '';

        let params = {
          jitName: "Service_Calculator",
          jsonBody: " ",
          urlParam: JSON.stringify({
            cityCode: this.forCodeAPIReq,
            serviceType: this.serviceType,
            workshopType: this.workshopPrf,
            //workshopType: 'Nexa',
            odometer: this.kilometre,
            regNumber: this.registrationNumber,
            parentGroup: this.parentGroup,
            dealerMapCode: this.dealerMapCode,
            locationCode: this.locationCode
          })
        };
        console.log('API Request----->', params);
        //Method which will pass the data from LWC to Apex and then we will make a call out to get the Service Calculator data
        getServiceCalculatorData(params)
          .then(result => {
            this.isVisible = false;
            if (result && result.code === 200) {
              // This is used to convert JSON to Object
              this.obj = JSON.parse(result.data);
              console.log(this.obj.serverCostDetails);
              this.onDemandJobData = this.obj.serverCostDetails.onDemandRepairs;
              this.workParticularTotalCost = this.obj.serverCostDetails.totalAmount;
              this.totalCost = this.workParticularTotalCost;

              this.columns = [{
                  label: "Work Particulars",
                  fieldName: "WorkParticular",
                  type: "text"
                },
                {
                  label: "Amount",
                  fieldName: "Amount",
                  type: "text"
                }
              ];

              this.columnsDescription = [{
                //label: "PMS Jobs",
                fieldName: "pmsJobs",
                type: "text"
              }];
              this.ondemandJobColumns = [{
                  label: "Name",
                  fieldName: "name",
                  type: "text"
                },
                {
                  label: "Amount",
                  fieldName: "cost",
                  type: "text"
                }
              ];

              if (this.obj.serverCostDetails.services && this.obj.serverCostDetails.services.length !== 0) {
                let reslt = this.obj.serverCostDetails.services;
                const dataDescription = [];
                for (let i = 0; i < reslt.length; i++) {
                  //var descArray = [];
                  if (reslt[i].desc) {
                    dataDescription.push({
                      pmsJobs: reslt[i].desc
                    });
                  }
                }
                this.dataDescription = dataDescription;

              }

              this.partsCost = this.obj.serverCostDetails.parts;
              this.labourCost = this.obj.serverCostDetails.labour;
              this.consumableCost = this.obj.serverCostDetails.consumables;

              const dataDescription = [];
              //this.dataDescription=dataDescription;

              const data = [];
              data.push({
                WorkParticular: "Cost of Labour",
                Amount: String(this.labourCost)
              });
              data.push({
                WorkParticular: "Cost of Parts",
                Amount: String(this.partsCost)
              });
              data.push({
                WorkParticular: "Cost of Consumables",
                Amount: String(this.consumableCost)
              });
              data.push({
                WorkParticular: "Estimated cost of Services",
                Amount: String(this.obj.serverCostDetails.totalAmount)
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
              this.loading = false;

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
          .catch(error => {
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
          });
      }
    } else {
      // To popup error message when required fields are missing message.
      //vl.reportValidity();
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Something is wrong",
          message: "Required fields are missing / Data entered is not correct",
          variant: "error"
        })
      );
    }
  }

  queryAll(query) {
    return Array.from(this.template.querySelectorAll(query));
  }

  //to handle the data validation
  validateInputs() {
    let inps = [].concat(
      this.queryAll("lightning-combobox"),
      this.queryAll("lightning-input"),
    );
    console.log('inps00000000>',inps);
    return inps.filter(inp => !inp.reportValidity()).length === 0;
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

  showHideVehicleSection() {
    this.showVehicle = !this.showVehicle;
    if (this.dataDescription && this.showVehicle) {
      this.showPMSJobs = true;
    } else {
      this.showPMSJobs = false;
    }
  }
  showHideOndemandJobSection() {
    this.showVehicleOndemandJob = !this.showVehicleOndemandJob;
    if (this.dataDescription && this.showVehicleOndemandJob) {
      this.showOndemanJobs = true;
    } else {
      this.showOndemanJobs = false;
    }
  }

  // To Handle the data validation for lightning-combobox fields
  validationCheckMethod() {
    const allValid1 = [
      ...this.template.querySelectorAll("lightning-combobox")
    ].reduce((validSoFar, inputCmp) => {
      inputCmp.reportValidity();
      return validSoFar && inputCmp.checkValidity();
    }, true);
    return allValid1;
  }
}