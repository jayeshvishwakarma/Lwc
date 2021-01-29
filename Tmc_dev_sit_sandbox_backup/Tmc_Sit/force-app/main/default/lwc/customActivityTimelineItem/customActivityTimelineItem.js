/* eslint-disable no-console */
import { LightningElement, api, track } from "lwc";

export default class CustomActivityTimelineItem extends LightningElement {
  @api task;
  @api isUpcoming = false;
  @track collapseSection = false;

  get iconName() {
    return "standard:" + this.iconClass;
  }
  get containerCls() {
    return (
      "slds-timeline__item_expandable " +
      (!this.collapseSection ? "slds-is-open" : "") +
      " " +
      this.typeCls
    );
  }
  get typeCls() {
    let cls = "";
    switch (this.task.Type) {
      case "E":
        cls = "slds-timeline__item_email";
        break;
      case "Call":
        cls = "slds-timeline__item_call";
        break;
      case "Whatsapp/Messaging":
        cls = "slds-timeline__item_sms";
        break;
      default:
        cls = "slds-timeline__item_task";
    }
    return cls;
  }
  get iconClass() {
    let cls = "";
    switch (this.task.Type) {
      case "E":
        cls = "email";
        break;
      case "Call":
        cls = "log_a_call";
        break;
      case "Whatsapp/Messaging":
        cls = "sms";
        break;
      default:
        cls = "task";
    }
    return cls;
  }
  get createdDate() {
    return new Date(this.task.ActivityDate);
  }
  get connectMessage() {
    return this.isUpcoming ? "has an upcoming task" : "had a task";
  }
  get collapse() {
    return this.collapseSection;
  }
  @api set collapse(collapse) {
    this.collapseSection = collapse;
  }

  connectedCallback() {
    this.collapseSection = true;
  }
  toogleSection() {
    this.collapseSection = !this.collapseSection;
  }
  handleView() {
    this.fireEvent("view");
  }
  handleEdit() {
    this.fireEvent("edit");
  }
  fireEvent(name) {
    this.dispatchEvent(
      new CustomEvent(name, { detail: { taskId: this.task.Id } })
    );
  }
}