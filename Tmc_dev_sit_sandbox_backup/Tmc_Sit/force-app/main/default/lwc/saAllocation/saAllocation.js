/* eslint-disable no-console */
import { LightningElement, track, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import Server_Error from "@salesforce/label/c.UI_Error_Message";
import fetchAvailableSlots from "@salesforce/apex/CreateAppointment.fetchAvailableSlots";
import fetchApiResponse from "@salesforce/apexContinuation/JITMuleSoftIntegration.genericJITCall";

/*Custom Label*/
import SAProfileId from "@salesforce/label/c.Service_Advisor_Profile_Id";

export default class SAAllocation extends LightningElement {
  @api workOrder;
  @api asset;
  @api userProfilrId;
  @api userDealerEmpCode;

  @track selectedSA;
  @track selectedSlot;
  @track collapseSection = false;
  @track showUnavailableSlots = false;
  @track errorMessage = "";
  @track loading = false;
  //@track lastSA = false;
  @track lastSA = [];
  

  startDate;
  selectedSlotOption;

  slotOptions = [
    {
      value: "00:00-02:00",
      label: "00:00-02:00",
      start: 0,
      end: 2
    },
    {
      value: "02:00-05:00",
      label: "02:00-05:00",
      start: 2,
      end: 5
    },
    {
      value: "05:00-07:00",
      label: "05:00-07:00",
      start: 5,
      end: 7
    },
    {
      value: "07:00-09:00",
      label: "07:00-09:00",
      start: 7,
      end: 9
    },
    {
      value: "09:00-11:00",
      label: "09:00-11:00",
      start: 9,
      end: 11
    },
    {
      value: "11:00-13:00",
      label: "11:00-13:00",
      start: 11,
      end: 13
    },
    {
      value: "13:00-16:00",
      label: "13:00-16:00",
      start: 13,
      end: 16
    },
    {
      value: "16:00-19:00",
      label: "16:00-19:00",
      start: 16,
      end: 19
    },
    {
      value: "19:00-21:00",
      label: "19:00-21:00",
      start: 19,
      end: 21
    },
    {
      value: "21:00-23:59",
      label: "21:00-23:59",
      start: 21,
      end: 24
    }
  ];
  availableSlots = [];

  get sectionCls() {
    return (
      "slds-section " +
      (!this.collapseSection
        ? "slds-is-open"
        : !this.selectedSlot
          ? "slds-p-bottom_small"
          : "")
    );
  }
  get sectionIconName() {
    return this.collapseSection
      ? "utility:chevronright"
      : "utility:chevrondown";
  }

  connectedCallback() {

    console.log('workOrder=====>' + this.workOrder.Workshop__c);
    console.log('workOrder=====>', this.workOrder);
    if (this.workOrder.SA_Id__r) {
      this.selectedSA = {
        name: this.workOrder.SA_Id__r.Name,
        code: this.workOrder.SA_Code__c
      };
    }
    if (this.workOrder.Slot_Time__c) {
      this.selectedSlot = {
        slot: this.workOrder.Slot_Time__c,
        slotCode: this.workOrder.Slot_Code__c
      };
    }
    console.log('this.selectedSlot------->', this.selectedSlot);
    if (this.selectedSlot) {
      this.updateStartDate();
    } else {
      this.fetchAvailableSlots();
    }
    if (this.selectedSlot) {
      this.collapseSection = true;
    }
    if (!this.selectedSlotOption) {
      this.selectedSlotOption = this.slotOptions[0];
    }
  }
  updateStartDate(startDate) {
    if (!startDate) {
      startDate = this.workOrder.Appointment_Datetime__c;
    }
    startDate = new Date(startDate);
    //startDate = new Date(startDate).toLocaleString("en-US", {timeZone: "Asia/Kolkata"});
    if (startDate > new Date()) {
      console.log('startDate:- '+startDate)
      let currentHours = startDate.getHours();
      
      let year=startDate.getYear()+1900;
      console.log(year);
      let mon=startDate.getMonth()+1;
      let date=startDate.getDate()>9?startDate.getDate():'0'+startDate.getDate();
      let monDate=mon>9?mon+'-'+date:'0'+mon+'-'+date;
      this.startDate = year+'-'+monDate;
      //this.startDate = startDate.toISOString().substring(0, 10);
      console.log(this.startDate);
      this.selectedSlotOption = this.slotOptions.find(
        item => currentHours >= item.start && currentHours < item.end
      );
    } else {
      this.errorMessage = "Appointment Datetime must be greater than today";
    }
  }
  @api fetchAvailableSlots(startDate, skipNextDayTry) {
    console.log('startDate:- ' + startDate);
    console.log('skipNextDayTry:- ' + skipNextDayTry);
    this.updateStartDate(startDate);
    if (this.startDate) {
      console.log('Inside If of fetchAvailableSlots');
      if (this.selectedSlotOption) {
        console.log('Inside If of fetchAvailableSlots 1');
        this.fetchAvailableSlots2();
      } else if (!skipNextDayTry) {
        let nextDate = new Date(this.startDate);
        nextDate.setDate(nextDate.getDate() + 1);
        nextDate.setHours(7, 0, 0, 0);
        console.log('Inside If of fetchAvailableSlots 2');
        this.fetchAvailableSlots(nextDate, true);
      }
    }
  }
  fetchAvailableSlots2() {
    console.log('Inside fetchAvailableSlots2');
    this.selectedSA = null;
    this.selectedSlot = null;
    this.collapseSection = false;
    this.availableSlots = [];
    this.errorMessage = "";
    this.loading = true;
    let request = {
      fromDate: this.startDate,
      toDate: this.startDate,
      startTime:
        (this.selectedSlotOption.start > 9
          ? this.selectedSlotOption.start
          : "0" + this.selectedSlotOption.start) + ":00",
      endTime:
      (this.selectedSlotOption.end===24 ? '23:59':this.selectedSlotOption.end > 9
        ? this.selectedSlotOption.end+":00"
        : "0" + this.selectedSlotOption.end+":00"),
      /*endTime:
        (this.selectedSlotOption.end > 9
          ? this.selectedSlotOption.end
          : "0" + this.selectedSlotOption.end) + ":00",*/
      regNumber: this.asset.Registration_Number__c
    };
    console.log(this.startDate);
    fetchAvailableSlots({ request, workshopId: this.workOrder.Workshop__c })
      .then(result => {
        console.log('Inside fetchAvailableSlots');
        console.log(result);
        if (!result) {
          throw result;
        }
        fetchApiResponse({jitName:'Available_SA',jsonBody:'',urlParam:JSON.stringify(result)})
        .then(slotDetail=>{
          console.log(slotDetail);
          if (!slotDetail.data) {
            throw slotDetail;
          }
          let response = JSON.parse(slotDetail.data);
          this.availableSlots = response.serviceAdvisors;
          let finalavailableSlots=[];
        console.log('this.availableSlots----->', this.availableSlots);
        this.availableSlots.forEach(item => {
          console.log(this.availableSlots.indexOf(item));
          console.log('SAProfileId:- '+SAProfileId);
          console.log('userProfilrId:- '+this.userProfilrId);
          console.log('userDealerEmpCode:- '+this.userDealerEmpCode);
          console.log('item.code:- '+item.code);
          if(SAProfileId===this.userProfilrId.substring(0,15) && this.userDealerEmpCode.split('_')[1]===item.code){
            console.log('Inside if');
            finalavailableSlots.push(item);
            //this.availableSlots.splice(this.availableSlots.indexOf(item),1);
            console.log(this.availableSlots);
          }
         
              item.timeSlots.forEach(item2 => {
                let arr = Array.from(item2.slot);
                arr.splice(2, 0, ":");
                arr.splice(8, 0, ":");
                item2.slot = arr.join("");
              item2.available = item2.available === "Y";
            });
              
              if(item.lastServiceAdvisor === "Y"){
                item.lastServiceAdvisor=true;
              }else if(item.lastServiceAdvisor === "N"){
                item.lastServiceAdvisor=false;
              }
              console.log('item.lastServiceAdvisor------->'+item.lastServiceAdvisor);
          
          })
        
        //this.availableSlots[2].lastSA = true;
        this.filterUnavailableSlots(this.showUnavailableSlots);
        console.log('finalavailableSlots:- ',finalavailableSlots);
        if(SAProfileId===this.userProfilrId.substring(0,15)){
          console.log('inside finalavailableSlots');
          this.availableSlots=finalavailableSlots;
        }
        this.loading = false;
        })
        .catch(error => {
          console.log('error.messagefetch------->' + error.message);
          this.errorMessage = (error && error.message) || Server_Error;
          this.showErrorMessage(this.errorMessage);
          console.error(error);
          this.loading = false;
        })
        
      })
      .catch(error => {
        console.log('error.messagefetch------->' + error.message);
        this.errorMessage = (error && error.message) || Server_Error;
        this.showErrorMessage(this.errorMessage);
        console.error(error);
        this.loading = false;
      })
     // .finally(() => (this.loading = false));
  }
  @api reportValidity() {
    if (!this.selectedSlot) {
      this.errorMessage = "Please select a slot";
      return false;
    }
    return true;
  }
  handleInputClick(evt) {
    evt.stopPropagation();
  }
  toogleSection() {
    this.collapseSection = !this.collapseSection;
    if (!this.collapseSection && !this.availableSlots.length) {
      this.fetchAvailableSlots();
    }
  }
  toogleUnavailableSlots() {
    this.filterUnavailableSlots(!this.showUnavailableSlots);
    this.showUnavailableSlots = !this.showUnavailableSlots;
  }
  handleSlotSelect(evt) {
    if (!evt.currentTarget.firstChild.disabled) {
      this.errorMessage = "";
      this.selectedSA = this.availableSlots.find(
        item => item.name === evt.currentTarget.dataset.sa
      );
      this.selectedSlot = this.selectedSA.timeSlots.find(
        item => item.slot === evt.currentTarget.dataset.slot
      );
      let inps = Array.from(
        this.template.querySelectorAll(".slds-visual-picker")
      );
      inps.forEach(inp => {
        let inp2 = inp.firstChild;
        inp2.checked = false;
      });
      let target = evt.currentTarget.firstChild;
      target.checked = true;
      let selectedSAInput = this.template.querySelector(
        "[data-vp-key='" + this.selectedSA.name + "']"
      ).firstChild;
      selectedSAInput.checked = true;
      this.dispatchEvent(
        new CustomEvent("select", {
          detail: {
            selectedSA: this.selectedSA,
            selectedSlot: this.selectedSlot
          }
        })
      );
    }
  }
  filterUnavailableSlots(show) {
    this.availableSlots.forEach(item => {
      item.timeSlots.forEach(slot => {
        slot.show = show ? true : slot.available;
      });
    });
  }
  showErrorMessage(message) {
    this.dispatchEvent(
      new ShowToastEvent({
        title: "Something is wrong",
        message: message,
        variant: "error"
      })
    );
  }
}