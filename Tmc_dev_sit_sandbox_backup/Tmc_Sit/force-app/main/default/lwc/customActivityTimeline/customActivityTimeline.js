/* eslint-disable no-console */
import { LightningElement, track, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import Server_Error from "@salesforce/label/c.Server_Error";
import fetchTasks from "@salesforce/apex/CustomActivityTimelineCtrl.fetchTasks";

export default class CustomActivityTimeline extends NavigationMixin(
  LightningElement
) {
  @api recordId;

  @track collapseUpcomingSection = false;
  @track collapsePastSection = false;
  @track showCollapseAll = false;
  @track loading = false;
  @track errorMessage;

  upcomingTasks;
  pastTasks;

  get loaded() {
    return !this.errorMessage && !this.loading;
  }
  get upcomingSectionCls() {
    return (
      "slds-section " + (!this.collapseUpcomingSection ? "slds-is-open" : "")
    );
  }
  get pastSectionCls() {
    return "slds-section " + (!this.collapsePastSection ? "slds-is-open" : "");
  }

  connectedCallback() {
    this.loading = true;
    this.upcomingTasks = [];
    this.pastTasks = [];
    //fetch all activities(tasks) of a customer
    fetchTasks({ recordId: this.recordId })
      .then(response => this.handleResponse(response))
      .catch(error => this.handleError(error))
      .finally(() => (this.loading = false));
  }
  handleResponse(tasks) {
    console.log(tasks);
    //let today = new Date().getTime();
    tasks.forEach(task => {
      if (task.Status==='Open') {
        this.upcomingTasks.push(task);
      } else {
        this.pastTasks.push(task);
      }
    });
  }
  handleView(event) {
    this.navigate(event.detail.taskId, "view");
  }
  handleEdit(event) {
    this.navigate(event.detail.taskId, "edit");
  }
  toogleUpcomingSection() {
    this.collapseUpcomingSection = !this.collapseUpcomingSection;
  }
  tooglePastSection() {
    this.collapsePastSection = !this.collapsePastSection;
  }
  handleRefresh() {
    this.connectedCallback();
  }
  handleCollapseAll() {
    this.getTimelineItems().forEach(item => (item.collapse = true));
    this.showCollapseAll = false;
  }
  handleExpandAll() {
    this.getTimelineItems().forEach(item => (item.collapse = false));
    this.showCollapseAll = true;
  }
  getTimelineItems() {
    return this.queryAll("c-custom-activity-timeline-item");
  }
  queryAll(query) {
    return Array.from(this.template.querySelectorAll(query));
  }
  navigate(taskId, actionName) {
    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: taskId,
        objectApiName: "Task",
        actionName: actionName
      }
    });
  }
  handleError(error) {
    this.errorMessage = Server_Error;
    this.dispatchEvent(
      new ShowToastEvent({
        title: "Something is wrong",
        message: this.errorMessage,
        variant: "error"
      })
    );
    console.error(error);
  }
}