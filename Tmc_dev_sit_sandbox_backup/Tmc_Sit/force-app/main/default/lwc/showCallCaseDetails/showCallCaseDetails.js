import { LightningElement, api, wire,track } from 'lwc';
import { retrieveObjectArrayFromCache} from "c/cacheServiceLayerCMP";
import errMessage from "@salesforce/label/c.CallDetails";

import formFactorPropertyName from '@salesforce/client/formFactor';
import VehModel_FIELD from '@salesforce/schema/Case.Vehicle_Model_Description__c';
import Vehfuel_FIELD from '@salesforce/schema/Case.Vehicle_Fuel__c';
import McpExp_FIELD from '@salesforce/schema/Case.MCP_Expiry_Date__c';
import EWExp_FIELD from '@salesforce/schema/Case.EW_Expiry_Date__c';
import ServDueDt_FIELD from '@salesforce/schema/Case.Service_Due_Date__c';
import MIExpDt_FIELD from '@salesforce/schema/Case.Expiry_Date__c';
import LastPSF_FIELD from '@salesforce/schema/Case.Last_PSF_Status__c';
import VehSalDt_FIELD from '@salesforce/schema/Case.Vehicle_Sale_Date__c';
import Chance_FIELD from '@salesforce/schema/Case.Chances__c';
import Critical_FIELD from '@salesforce/schema/Case.Critical_Customer__c';
import Type_FIELD from '@salesforce/schema/Case.Type';
import SubType_FIELD from '@salesforce/schema/Case.Call_Campaign_Subtype__c';
import VehOdo_FIELD from '@salesforce/schema/Case.Veh_Odometer__c';
import LastPkupDt_FIELD from '@salesforce/schema/Case.Last_Pickup_Date__c';
import LastPkupLoc_FIELD from '@salesforce/schema/Case.Last_Pickup_Location__c';
import LastDropDt_FIELD from '@salesforce/schema/Case.Last_Drop_Date__c';
import LastDropLoc_FIELD from '@salesforce/schema/Case.Last_Drop_Location__c';
import CompMode_FIELD from '@salesforce/schema/Case.Complaint_Mode__c';
import ConStatus_FIELD from '@salesforce/schema/Case.Contact_Status__c';
import LastServType_FIELD from '@salesforce/schema/Case.Last_Service_Type__c';
import LastServDt_FIELD from '@salesforce/schema/Case.Last_Service_Date__c';
import LastMile_FIELD from '@salesforce/schema/Case.Last_Service_Mileage__c';
import LastSchServ_FIELD from '@salesforce/schema/Case.Last_Sch_Service__c';
import LastSchServDt_FIELD from '@salesforce/schema/Case.Last_Sch_Service_Date__c';
import DealerName_FIELD from '@salesforce/schema/Case.Dealer_Name__r.Name';
import PrefSA_FIELD from '@salesforce/schema/Case.Preferred_SA__c';
import DMSCompNum_FIELD from '@salesforce/schema/Case.DMS_Complaint_Number__c';
import DMSCompStat_FIELD from '@salesforce/schema/Case.Complaint_Status__c';
import DMSCompDesc_FIELD from '@salesforce/schema/Case.Complaint_Description__c';
import LastFupRemarks_FIELD from '@salesforce/schema/Case.Last_Follow_Up_Remarks__c';
import DMSCompVOC_FIELD from '@salesforce/schema/Case.DMS_Customer_VOC__c';
import Appnt_FIELD from '@salesforce/schema/Case.Appointment__c';
import AppntNumber_FIELD from '@salesforce/schema/Case.Appointment_Service_Number__c';
import PickupDt_FIELD from '@salesforce/schema/Case.Appointment_Date__c';
import PrefWrkName_FIELD from '@salesforce/schema/Case.Preferred_Workshop_Name__c';
import PrefWrkCode_FIELD from '@salesforce/schema/Case.Preferred_Workshop_Code__c';
import LoyPoints_FIELD from '@salesforce/schema/Case.Loyalty_Points__c';
import LoyCardNum_FIELD from '@salesforce/schema/Case.Loyalty_Card_Number__c';
import BillNum_Field from '@salesforce/schema/Case.Bill_Number__c';
import WorkshopName_Field from '@salesforce/schema/Case.Workshop_Name__c';
import lastJCNum_field from '@salesforce/schema/Case.Last_JC_Number__c';
import lastJCDate_field from '@salesforce/schema/Case.Last_JC_Open_Date__c';
//new added as part of DE1866--Rohit
import lastJCBillDate_Field from '@salesforce/schema/Case.Last_JC_Bill_Date__c';
import VEHREGNO_FIELD from '@salesforce/schema/Case.Vehicle_Registration_Number__c';
import DMSVehicleOwnerName_FIELD from '@salesforce/schema/Case.DMS_Vehicl_Car_User_Name__c';

import DMSVehiclCarOwnerMobile_FIELD from '@salesforce/schema/Case.DMS_Vehicle_Car_User_Mobile_No__c';






export default class ShowCallCaseDetails extends LightningElement {

    columnNumber = 1;
    @api recordId;
    @track caseRecordId;
    @track campaignType;
    @track fields;
    showForm = false;
    errorMessage = 'Please click Call Start on a task first to see data here.';

    //fields = [CAMPAIGN_FIELD, Type_FIELD, SERVDUE_FIELD, Asset_FIELD, VEHREGNO_FIELD, WORKSH_FIELD, CROSSSELL_FIELD];
//Vehicle_Model__c,Vehicle_Fuel__c,MCP_Expiry_Date__c,EW_Expiry_Date__c,Service_Due_Date__c,Expiry_Date__c,Last_PSF_Status__c,Vehicle_Sale_Date__c,Chances__c,Critical_Customer__c,Type,Veh_Odometer__c,Last_Pickup_Drop_Date__c,Last_Pickup_Drop_Location__c,Complaint_Mode__c,Contact_Status__c,Last_Service_Type__c,Last_Service_Date__c,Last_Service_Mileage__c,Last_Sch_Service__c,Last_Sch_Service_Date__c,Dealer_Name__r.name
//Vehicle_Model__c,Vehicle_Fuel__c,MCP_Expiry_Date__c,EW_Expiry_Date__c,Service_Due_Date__c,Expiry_Date__c,Last_PSF_Status__c,Vehicle_Sale_Date__c,Chances__c,
  /*  @wire(getCaseFields,{taskId: '', servType: 'First Free Service'})
    getCallCaseDetails({data,error}){
        if(data){
            console.log(data);
            this.fields = data.Fields__c;
            console.log(this.fields);
            console.log(data.Fields__c);
        }
        else {
            console.log('Error occurred ' + error);
        }
    }*/
    
    connectedCallback(){
        console.log(formFactorPropertyName);
        console.log(this.recordId);
        let formSize = formFactorPropertyName;
        console.log('form factor is ' + formSize);
        if (formSize === 'Large'){
            console.log('entered Large');
            this.columnNumber = 3;
        }

        let response = retrieveObjectArrayFromCache();
        if (response) {
            console.log('>>>', response);
            if(this.recordId == response.Contact_ID__c ){
                this.caseRecordId = response.Case__c;
                this.campaignType = response.Service_Type__c;
                //this.campaignType = 'Welcome Call';
                this.showForm = true;
            }
            else {
                this.showForm = false;
                this.errorMessage = errMessage;
                //temporary hardcode
              //  this.recordId = '5000T000000pvHZQAY';
              console.log('wrong recordId');
              console.log(this.showForm);
                   
            }
        }
        else {
            this.showForm = false;
            this.errorMessage = errMessage;
            //temporary hardcode
          //  this.recordId = '5000T000000pvHZQAY';
          console.log('no recordId');
          console.log(this.showForm);
        }

        /*let csId = localStorage.getItem("CallCaseId");
        console.log(csId);
        let csCampaignType = localStorage.getItem("CallCampaignType");
        if (csId){
            this.recordId = csId;
            this.showForm = true;
        }
        else {
            this.showForm = false;
            //temporary hardcode
          //  this.recordId = '5000T000000pvHZQAY';
          console.log('no recordId');
          console.log(this.showForm);
        }
        if (csCampaignType){
            this.campaignType = csCampaignType;
        }
        else{
            //temporary hardcode
          //  this.campaignType = 'SMR';
          console.log('no campaign type');
        } */
        if (this.campaignType === 'First Free Service' || this.campaignType === 'Second Free Service' || this.campaignType === 'Third Free Service' || this.campaignType === 'Paid Service'){
            this.fields = [DMSVehicleOwnerName_FIELD, DMSVehiclCarOwnerMobile_FIELD,VEHREGNO_FIELD,VehModel_FIELD,Vehfuel_FIELD,McpExp_FIELD,EWExp_FIELD,ServDueDt_FIELD,MIExpDt_FIELD,LastPSF_FIELD,VehSalDt_FIELD,Chance_FIELD,Critical_FIELD,Type_FIELD,SubType_FIELD,LoyPoints_FIELD,LoyCardNum_FIELD,LastPkupDt_FIELD,LastPkupLoc_FIELD,LastDropDt_FIELD,LastDropLoc_FIELD,CompMode_FIELD,ConStatus_FIELD,VehOdo_FIELD,LastServType_FIELD,lastJCDate_field,LastMile_FIELD,LastSchServ_FIELD,LastSchServDt_FIELD,WorkshopName_Field];
        }
        else if (this.campaignType === 'BPO Post Service Feedback' || this.campaignType === 'Dealer Post Service Feedback' || this.campaignType === 'Post Service Feedback'){
            this.fields = [DMSVehicleOwnerName_FIELD, DMSVehiclCarOwnerMobile_FIELD,VEHREGNO_FIELD,VehModel_FIELD,Vehfuel_FIELD,McpExp_FIELD,EWExp_FIELD,ServDueDt_FIELD,MIExpDt_FIELD,LastPSF_FIELD,VehSalDt_FIELD,Chance_FIELD,lastJCNum_field, lastJCDate_field,BillNum_Field,WorkshopName_Field,PrefSA_FIELD,Type_FIELD,SubType_FIELD,VehOdo_FIELD, LastServType_FIELD, LastSchServ_FIELD, CompMode_FIELD, DMSCompNum_FIELD, DMSCompStat_FIELD, DMSCompDesc_FIELD, LastFupRemarks_FIELD, DMSCompVOC_FIELD, lastJCBillDate_Field];
        }
        else if (this.campaignType === 'BPO Post Sales Feedback' || this.campaignType === 'Dealer Post Sales Feedback' || this.campaignType === 'Post Sales Feedback'){
            this.fields = [DMSVehicleOwnerName_FIELD, DMSVehiclCarOwnerMobile_FIELD,VehModel_FIELD,Vehfuel_FIELD,VehSalDt_FIELD,WorkshopName_Field,Type_FIELD,SubType_FIELD];
        }        
        else if (this.campaignType === 'Appointment Reminder' || this.campaignType === 'Appointment Confirmation'){
            this.fields = [DMSVehicleOwnerName_FIELD, DMSVehiclCarOwnerMobile_FIELD,VEHREGNO_FIELD,VehModel_FIELD,Vehfuel_FIELD,McpExp_FIELD,EWExp_FIELD,ServDueDt_FIELD,MIExpDt_FIELD,LastPSF_FIELD,VehSalDt_FIELD,Chance_FIELD,AppntNumber_FIELD,PickupDt_FIELD,PrefSA_FIELD,Type_FIELD,SubType_FIELD,VehOdo_FIELD];
        }
        else if (this.campaignType === 'Welcome Call'){
            this.fields = [VEHREGNO_FIELD,VehModel_FIELD,Vehfuel_FIELD,McpExp_FIELD,EWExp_FIELD,ServDueDt_FIELD,MIExpDt_FIELD,LastPSF_FIELD,VehSalDt_FIELD,Chance_FIELD,PrefWrkName_FIELD,PrefWrkCode_FIELD,PrefSA_FIELD];
        }
        else {
            this.fields = [VEHREGNO_FIELD,VehModel_FIELD,Vehfuel_FIELD,McpExp_FIELD,EWExp_FIELD,ServDueDt_FIELD,MIExpDt_FIELD,LastPSF_FIELD,VehSalDt_FIELD,Chance_FIELD,Critical_FIELD,Type_FIELD,SubType_FIELD,LastPkupDt_FIELD,LastPkupLoc_FIELD,LastDropDt_FIELD,LastDropLoc_FIELD,CompMode_FIELD,ConStatus_FIELD,VehOdo_FIELD,LastServType_FIELD,lastJCDate_field,LastMile_FIELD,LastSchServ_FIELD,LastSchServDt_FIELD,WorkshopName_Field];            
        }
        
    }

    setCaseId(event){
        this.caseRecordId = event.target.value;
    }

    setCampType(event){
        this.campaignType = event.target.value;
    }

    setLocalStorageValues(){
        console.log('in button click');
        console.log('set local storage values');
        console.log(this.caseRecordId);
        console.log(this.campaignType);
        localStorage.setItem("CallCampaignType",this.campaignType);
        localStorage.setItem("CallCaseId",this.caseRecordId);
        console.log('set local storage values');
    }

}