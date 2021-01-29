import Base from "c/lookupBase";
import { api, track, wire } from "lwc";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import { getRecord } from "lightning/uiRecordApi";
import search from "@salesforce/apex/LookupInputFieldCtrl.search";

const MINIMAL_SEARCH_TERM_LENGTH = 2; // Min number of chars required to search

export default class LookupInputField extends Base {
  @api label;
  @api value;
  @api objectName;
  @api recordType;
  @api variant;
  @api required = false;
  @api scrollAfterNItems = 5;
  @api minLength = MINIMAL_SEARCH_TERM_LENGTH;
  @api customKey;
  @api isMobile = false;
  @api isCustomSearch = false;
  @api customPlaceholder;
  //New
  @api firstvalue;

  @track objectInfo = {};
  @track selection = [];
  @track errors = [];
  @track fields = [];

  get placeholder() {
    if (this.customPlaceholder) {
      return this.customPlaceholder;
    }
    return (
      "Search" +
      (this.objectInfo.labelPlural ? " " + this.objectInfo.labelPlural : "") +
      "..."
    );

  }
  get lookupInput() {
    return this.template.querySelector("c-lookup-input");
  }
  get selectedValue() {
    let selection = this.lookupInput.getSelection() || [];
    let selectedItem = selection[0] || {};
    return selectedItem.id;
  }

  // @wire(getObjectInfo, { objectApiName: "$objectName" })
  // wiredObjectInfo({ data }) {
  //   if (data) {
  //     this.objectInfo = data;
  //   }
  // }
  @wire(getObjectInfo, { objectApiName: "$objectName" })
  wiredObjectInfo({ data }) {
    if (data) {
      this.objectInfo = data;
      console.log('== check this.objectInfo ', this.firstvalue);
      if (this.firstvalue && this.firstvalue.length > 0 && this.firstvalue[0].id) {
        this.selection = [
          {
            id: this.firstvalue[0].id,
            title: this.firstvalue[0].title,
            themeInfo: this.objectInfo.themeInfo
          }
        ];
        console.log('== on selctionValue this.selection', this.selection);
      }
    }
  }

  //New Secition
  @api setSelection(data) {
    console.log('data', data);
    this.selection = data;
  }
  @wire(getRecord, { recordId: "$value", fields: "$fields" })
  wiredRecord({ data }) {
    if (data) {
      this.selection = [
        {
          id: this.value,
          title: data.fields.Name.value,
          themeInfo: this.objectInfo.themeInfo
        }
      ];
    }
  }
  connectedCallback() {
    this.fields.push(this.objectName + ".Name");
  }
  @api setFocus() {
    this.lookupInput.setFocus();
  }
  @api getData() {
    return {
      searchTerm: this.lookupInput.getKeyword(),
      selection: this.lookupInput.getSelection()
    };
  }
  @api setData(data, skipFireEvent) {
    console.log('data', data);
    this.errors = [];
    this.selection = data.selection;
    this.lookupInput.setKeyword(data.searchTerm);
    if (!skipFireEvent) {
      // eslint-disable-next-line @lwc/lwc/no-async-operation
      setTimeout(() => {
        this.handleSelectionChange();
      });
    }
  }
  @api updateSelection(id, name) {
    this.errors = [];
    this.selection = [
      {
        id: id,
        title: name,
        themeInfo: this.objectInfo.themeInfo
      }
    ];
  }
  @api reportValidity() {
    this.errors = [];
    if (this.required && !this.selectedValue) {
      this.errors.push({ message: "Complete this field." });
    }
    return this.errors.length === 0;
  }
  handleInput(event) {
    if (this.isMobile) {
      this.searchTerm = event.target.value;
      Base.container.showLookupScreen(this, event);
    }
  }
  @api handleSearch(event) {
    let params = {
      objectName: this.objectName,
      searchTerm: event.detail.searchTerm,
      recordType: this.recordType,
      customKey: this.customKey
    };
    if (this.isCustomSearch) {
      this.fireEvent("customsearch", params);
    } else {
      search(params).then(searchResults => {
        this.updateSearchResults(searchResults);
      });
    }
  }
  @api updateSearchResults(searchResults) {
    if (this.isCustomSearch && this.isMobile) {
      Base.container.updateSearchResults(searchResults);
    } else {
      searchResults = this.clone(searchResults);
      searchResults.forEach(
        item => (item.themeInfo = this.objectInfo.themeInfo)
      );
      this.lookupInput.setSearchResults(searchResults);
    }
  }
  handleSelectionChange() {
    console.log('selection', this.selection);
    this.fireEvent("change", { value: this.selectedValue });
    this.reportValidity();
  }
  fireEvent(name, detail) {
    this.dispatchEvent(new CustomEvent(name, { detail }));
  }
  clone(data) {
    return JSON.parse(JSON.stringify(data));
  }
}