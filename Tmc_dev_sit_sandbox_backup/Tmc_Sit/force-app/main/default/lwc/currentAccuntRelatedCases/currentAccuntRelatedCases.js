import { LightningElement, api, track, wire } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import fetchData from "@salesforce/apex/CurrentAccuntRelatedCasesCtrl.fetchData";
import Server_Error from "@salesforce/label/c.UI_Error_Message";

const COLUMNS = [
  {
    label: "Policy Number",
    fieldName: "Policy_No__c",
    type: "text",
    sortable: true
  },
  {
    label: "Vehicle Registration Number",
    fieldName: "Vehicle_Registration_Number__c",
    type: "text",
    sortable: true
  },
  {
    label: "Expiry Date",
    fieldName: "Expiry_Date__c",
    type: "date",
    sortable: true
  },
  {
    label: "Case Number",
    fieldName: "nameUrl",
    type: "url",
    typeAttributes: { label: { fieldName: "CaseNumber" }, target: "_self" },
    sortable: true
  },
  {
    label: "Status",
    fieldName: "Status",
    type: "text",
    sortable: true
  },
  {
    label: "Created Date",
    fieldName: "CreatedDate",
    type: "date",
    sortable: true
  },
  {
    label: "Closed Date",
    fieldName: "ClosedDate",
    type: "date",
    sortable: true
  }
];

export default class CurrentAccuntRelatedCases extends NavigationMixin(
  LightningElement
) {
  @api recordId;

  @track columns = COLUMNS;
  @track loading = true;
  @track errorMessage;

  data = [];

  get loaded() {
    return !this.errorMessage && !this.loading;
  }

  @wire(fetchData, { recordId: "$recordId" })
  wiredfetchData(result) {
    const { data, error } = result;
    if (data) {
      let defers = data.map(row => this.generateUrl(row.Id));
      Promise.all(defers).then(urls => {
        this.data = data.map((row, ind) => ({ ...row, nameUrl: urls[ind] }));
        console.log('data type',typeof(this.data));
        console.log('data',this.data);
        this.loading = false;
      });
    }
    if (error) {
      this.handleServerError(error);
    }
  }
  generateUrl(recordId) {
    return this[NavigationMixin.GenerateUrl]({
      type: "standard__recordPage",
      attributes: {
        recordId,
        actionName: "view"
      }
    });
  }
  handleServerError(error) {
    this.errorMessage = Server_Error;
    this.dispatchEvent(
      new ShowToastEvent({
        title: "No related Cases found",
        message: this.errorMessage,
        variant: "error"
      })
    );
    // eslint-disable-next-line no-console
    console.error(error);
  }
}