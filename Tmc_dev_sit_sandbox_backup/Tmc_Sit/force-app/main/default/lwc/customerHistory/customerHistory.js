/* eslint-disable no-console */

import { LightningElement, api, track, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";

import ACCOUNT_SVOC_ID_FIELD from "@salesforce/schema/Account.SVOC_ID__c";
import fetchData from "@salesforce/apexContinuation/FetchSVOCDetails.fetchSelectedSVOCDetails";

import Server_Error from "@salesforce/label/c.UI_Error_Message";
import Missing_Field_Error_Message from "@salesforce/label/c.SVOC_Detail_Missing_Fields";

export default class CustomerHistory extends LightningElement {
  @api recordId;
  @api svocsection = "Loyalty";

  @track expand = false;
  @track loading = false;
  @track errorMessage;

  @track data = [];
  @track columns = [];

  @wire(getRecord, { recordId: "$recordId", fields: [ACCOUNT_SVOC_ID_FIELD] })
  record;

  get loaded() {
    return !this.errorMessage && !this.loading;
  }
  get svocId() {
    return getFieldValue(this.record.data, ACCOUNT_SVOC_ID_FIELD);
  }
  get sectionCls() {
    return (
      "slds-section slds-p-around_xx-small " +
      (this.expand ? "slds-is-open" : "")
    );
  }

  //Function called when clicked on expand/collapse section
  handleToggleSection() {
    this.expand = !this.expand;
    if (this.expand) {
      if (this.svocId) {
        this.fetchData();
      } else {
        this.handleError({ msg: Missing_Field_Error_Message });
      }
    }
  }
  //Call server method to get the API response and show it in table
  fetchData() {
    this.loading = true;
    let params = {
      svocDetail: this.svocsection,
      svocId: this.svocId
    };
    fetchData(params)
      .then(response => this.handleResponse(response))
      .catch(error => this.handleError(error))
      .finally(() => (this.loading = false));
  }
  handleResponse(result) {
    console.log(result.data);
    if (!result.data) {
      throw result;
    }
    let data = result.data;
    let types = {
      boolean: new Set(),
      date: new Set()
    };
    console.log(data);
    this.data = data.fieldValueWrapList.map((item, ind1) => {
      return item.svocFieldValue.reduce(
        (row, value, ind2) => {
          let col = data.keys[ind2];
          row[col] = this.parseValue(col, value, types);
          return row;
        },
        { id: ind1 }
      );
    });
    this.columns = data.svocFielLabelList.map((item, ind) => {
      console.log(item);
      console.log(ind);
      let col = data.keys[ind];
      console.log('Col:-'+col);
      console.log(types.boolean.has(col));
      return {
        label: item,
        fieldName: col,
        wrapText: col.includes('MINumber')? false:true,
        type: types.boolean.has(col)
          ? "boolean"
          : types.date.has(col)
          ? "date"
          : "text"
      };
    });
    this.recordsCount = String(
      this.data.length > 25 ? "25+" : this.data.length
    );
    if (!this.data.length) {
      this.errorMessage = "No data found";
    }
    console.log('FInal data');
    console.log(this.data);
    console.log(this.columns);
  }
  parseValue(key, value, types) {
    console.log('key:- '+key);
    console.log('value:- '+value);
    console.log('types:- '+types);
    if (value) {
      switch (key) {
        case "StartDate":
          types.date.add(key);
          break;
        case "EndDate":
          if (new Date(value) > new Date()) {
            value = "";
          }
          types.date.add(key);
          break;
        default:
      }
      switch (value) {
        case "true":
        case "false":
          value = value === "true";
          types.boolean.add(key);
          break;
        default:
      }
    }
    return value;
  }
  handleError(error) {
    this.errorMessage = error.msg || Server_Error;
    const toastEvent = new ShowToastEvent({
      title: status,
      message: this.errorMessage,
      variant: "error"
    });
    this.dispatchEvent(toastEvent);
    console.error(error);
  }
}