import { LightningElement, track, api } from "lwc";

const MINIMAL_SEARCH_TERM_LENGTH = 2; // Min number of chars required to search
const SEARCH_DELAY = 300; // Wait 300 ms after user stops typing then, peform search

export default class LookupInput extends LightningElement {
  @api label;
  @api selection = [];
  @api placeholder = "";
  @api isMultiEntry = false;
  @api errors = [];
  @api scrollAfterNItems;
  @api required;
  @api customKey;
  @api variant;
  @api minLength = MINIMAL_SEARCH_TERM_LENGTH;

  @track searchTerm = "";
  @track searchResults = [];
  @track hasFocus = false;

  cleanSearchTerm;
  blurTimeout;
  searchThrottlingTimeout;

  // EXPOSED FUNCTIONS

  @api
  setSearchResults(results) {
    this.searchResults = results.map(result => {
      if (
        typeof result.themeInfo === "undefined" &&
        typeof result.icon === "undefined"
      ) {
        result.icon = "standard:default";
      }
      return result;
    });
  }

  @api
  getSelection() {
    return this.selection;
  }

  @api
  getkey() {
    return this.customKey;
  }

  @api getKeyword() {
    return this.searchTerm;
  }

  @api setKeyword(searchTerm) {
    this.updateSearchTerm(searchTerm);
  }

  @api setFocus() {
    this.template.querySelector("input").focus();
  }

  @api reportValidity() {
    return !this.required || this.hasSelection();
  }

  // INTERNAL FUNCTIONS

  updateSearchTerm(newSearchTerm) {
    this.searchTerm = newSearchTerm;

    // Compare clean new search term with current one and abort if identical
    const newCleanSearchTerm = newSearchTerm
      .trim()
      .replace(/\*/g, "")
      .toLowerCase();
    if (this.cleanSearchTerm === newCleanSearchTerm) {
      return;
    }

    // Save clean search term
    this.cleanSearchTerm = newCleanSearchTerm;

    // Ignore search terms that are too small
    if (newCleanSearchTerm.length < this.minLength) {
      this.searchResults = [];
      return;
    }

    // Apply search throttling (prevents search if user is still typing)
    if (this.searchThrottlingTimeout) {
      clearTimeout(this.searchThrottlingTimeout);
    }
    // eslint-disable-next-line @lwc/lwc/no-async-operation
    this.searchThrottlingTimeout = setTimeout(() => {
      // Send search event if search term is long enougth
      if (this.cleanSearchTerm.length >= this.minLength) {
        const searchEvent = new CustomEvent("search", {
          detail: {
            searchTerm: this.cleanSearchTerm,
            selectedIds: this.selection.map(element => element.id)
          }
        });
        this.dispatchEvent(searchEvent);
      }
      this.searchThrottlingTimeout = null;
    }, SEARCH_DELAY);
  }

  renderedCallback() {
    let imgs = Array.from(this.template.querySelectorAll("img")).filter(
      img =>
        img.dataset.color &&
        "#" + img.dataset.color !== img.style.backgroundColor
    );
    if (imgs.length) {
      imgs.forEach(img => {
        img.style.backgroundColor = "#" + img.dataset.color;
      });
    }
  }

  isSelectionAllowed() {
    if (this.isMultiEntry) {
      return true;
    }
    return !this.hasSelection();
  }

  hasResults() {
    return this.searchResults.length > 0;
  }

  hasSelection() {
    return this.selection.length > 0;
  }

  // EVENT HANDLING

  handleInput(event) {
    // Prevent action if selection is not allowed
    if (!this.isSelectionAllowed()) {
      return;
    }
    this.updateSearchTerm(event.target.value);
  }

  handleResultClick(event) {
    const recordId = event.currentTarget.dataset.recordid;

    // Save selection
    let selectedItem = this.searchResults.filter(
      result => result.id === recordId
    );
    if (selectedItem.length === 0) {
      return;
    }
    selectedItem = selectedItem[0];
    const newSelection = [...this.selection];
    newSelection.push(selectedItem);
    this.selection = newSelection;

    // Reset search
    this.searchTerm = "";
    this.searchResults = [];

    // Notify parent components that selection has changed
    this.dispatchEvent(new CustomEvent("selectionchange"));
  }

  handleComboboxClick() {
    // Hide combobox immediatly
    if (this.blurTimeout) {
      window.clearTimeout(this.blurTimeout);
    }
    this.hasFocus = false;
  }

  handleFocus() {
    // Prevent action if selection is not allowed
    if (!this.isSelectionAllowed()) {
      return;
    }
    this.hasFocus = true;
  }

  handleBlur() {
    // Prevent action if selection is not allowed
    if (!this.isSelectionAllowed()) {
      return;
    }
    // Delay hiding combobox so that we can capture selected result
    // eslint-disable-next-line @lwc/lwc/no-async-operation
    this.blurTimeout = window.setTimeout(() => {
      this.hasFocus = false;
      this.blurTimeout = null;
    }, 300);
  }

  handleRemoveSelectedItem(event) {
    const recordId = event.currentTarget.name;
    this.selection = this.selection.filter(item => item.id !== recordId);
    // Notify parent components that selection has changed
    this.dispatchEvent(new CustomEvent("selectionchange"));
  }

  handleClearSelection() {
    this.selection = [];
    // Notify parent components that selection has changed
    this.dispatchEvent(new CustomEvent("selectionchange"));
  }

  // STYLE EXPRESSIONS

  get getContainerClass() {
    let css = "slds-combobox_container ";
    if (this.hasFocus && this.hasResults()) {
      css += "slds-has-input-focus ";
    }
    if (this.errors.length > 0) {
      css += "has-custom-error";
    }
    return css;
  }

  get getDropdownClass() {
    let css =
      "slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click ";
    if (this.hasFocus && this.hasResults()) {
      css += "slds-is-open";
    } else {
      css += "slds-combobox-lookup";
    }
    return css;
  }

  get getInputClass() {
    let css =
      "slds-input slds-combobox__input has-custom-height " +
      (this.errors.length === 0 ? "" : "has-custom-error ");
    if (!this.isMultiEntry) {
      css +=
        "slds-combobox__input-value " +
        (this.hasSelection() ? "has-custom-border" : "");
    }
    return css;
  }

  get getComboboxClass() {
    let css = "slds-combobox__form-element slds-input-has-icon ";
    if (this.isMultiEntry) {
      css += "slds-input-has-icon_right";
    } else {
      css += this.hasSelection()
        ? "slds-input-has-icon_left-right"
        : "slds-input-has-icon_right";
    }
    return css;
  }

  get getSearchIconClass() {
    let css = "slds-input__icon slds-input__icon_right ";
    if (!this.isMultiEntry) {
      css += this.hasSelection() ? "slds-hide" : "";
    }
    return css;
  }

  get getClearSelectionButtonClass() {
    return (
      "slds-button slds-button_icon slds-input__icon slds-input__icon_right " +
      (this.hasSelection() ? "" : "slds-hide")
    );
  }

  get getSelectIconName() {
    return this.hasSelection() ? this.selection[0].icon : "standard:default";
  }

  get getSelectedThemeInfo() {
    return this.hasSelection() ? this.selection[0].themeInfo || {} : {};
  }

  get getSelectIconClass() {
    return (
      "slds-combobox__input-entity-icon " +
      (this.hasSelection() ? "" : "slds-hide")
    );
  }

  get getInputValue() {
    if (this.isMultiEntry) {
      return this.searchTerm;
    }
    return this.hasSelection() ? this.selection[0].title : this.searchTerm;
  }

  get getListboxClass() {
    return (
      "slds-listbox slds-listbox_vertical slds-dropdown slds-dropdown_fluid " +
      (this.scrollAfterNItems
        ? "slds-dropdown_length-with-icon-" + this.scrollAfterNItems
        : "")
    );
  }

  get getStackedListboxClass() {
    return (
      "slds-listbox slds-listbox_vertical " +
      (this.scrollAfterNItems
        ? "slds-dropdown_length-with-icon-" + this.scrollAfterNItems
        : "")
    );
  }

  get isInputReadonly() {
    if (this.isMultiEntry) {
      return false;
    }
    return this.hasSelection();
  }

  get isExpanded() {
    return this.hasResults();
  }

  get isStacked() {
    return this.variant === "stacked";
  }
}