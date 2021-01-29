import Base from "c/lookupBase";
import { track } from "lwc";

export default class LookupContainer extends Base {
  type = "CONTAINER";

  @track showScreen = false;

  get contentClass() {
    return this.showScreen ? "slds-hide" : "";
  }
  get containerInputField() {
    return this.template.querySelector("c-lookup-input-field");
  }

  renderedCallback() {
    if (this.showScreen) {
      this.containerInputField.setFocus();
      this.containerInputField.setData(this.parentInputField.getData(), true);
    }
  }
  showLookupScreen(inputField) {
    this.parentInputField = inputField;
    this.showScreen = true;
  }
  handleCustomSearch(event) {
    this.parentInputField.handleSearch(event);
  }
  updateSearchResults(searchResults) {
    this.containerInputField.updateSearchResults(searchResults);
  }
  handleChange() {
    this.parentInputField.setData(this.containerInputField.getData());
    this.showScreen = false;
  }
  handleCancel() {
    this.showScreen = false;
  }
}