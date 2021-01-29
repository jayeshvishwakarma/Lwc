import { LightningElement } from "lwc";

export default class LookupBase extends LightningElement {
  static instances = [];
  constructor() {
    super();
    LookupBase.instances.push(this);
  }
  static get container() {
    return LookupBase.instances.find(item => item.type === "CONTAINER");
  }
  disconnectedCallback() {
    let ind = LookupBase.instances.indexOf(this);
    if (ind >= 0) {
      LookupBase.instances.splice(ind, 1);
    }
  }
}