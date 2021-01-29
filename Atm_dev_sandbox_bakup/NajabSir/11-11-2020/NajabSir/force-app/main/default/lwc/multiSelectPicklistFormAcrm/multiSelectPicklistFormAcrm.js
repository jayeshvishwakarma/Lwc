import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class MultiSelectPicklistFormAcrm extends LightningElement {
    // Undefined type variables
    @api indexKey;
    @api name;
    @api optionsList;
    @api selectedValues;
    @api disabled;

    // Integer type variables
    @api maxLimit = 5;

    // Boolean type variables
    @api showButton = false;
    showPicklist = false;

    // Array type variables
    @track filterOptions = [];
    @track currentSelectedValue = [];

    // String type variables
    inputValue = '';

    renderedCallback() {
        if (this.disabled) {
            let allPills = this.template.querySelectorAll('[data-id="pillblock"]');
            for (let i = 0; i < allPills.length; i++) {
                allPills[i].classList.add("remove");
            }
        } else {
            let allPills = this.template.querySelectorAll('[data-id="pillblock"]');
            for (let i = 0; i < allPills.length; i++) {
                allPills[i].classList.remove("remove");
            }
        }
    }

    connectedCallback() {
        if (this.selectedValues) {
            let allSelectedOptions = JSON.parse(JSON.stringify(this.selectedValues));
            if (allSelectedOptions) {
                this.currentSelectedValue = [];
                for (let i = 0; i < allSelectedOptions.length; i++) {
                    this.currentSelectedValue.push(allSelectedOptions[i]);
                }
            }
        } else {
            console.log('== Nothing come');
        }
    }

    handleOnClick(event) {
        this.filterOptions = [];
        this.showPicklist = true;
        let searchKey = event.target.value;
        this.inputValue = searchKey;
        if (searchKey && searchKey.length > 0) {
            let allOptions = JSON.parse(JSON.stringify(this.optionsList));
            for (let i = 0; i < allOptions.length; i++) {
                let option = allOptions[i];
                let optionLabel = JSON.parse(JSON.stringify(option.label)) + '';
                if (optionLabel) {
                    try {
                        if (String(optionLabel.toUpperCase()).indexOf(searchKey.toUpperCase()) !== -1
                            && !this.currentSelectedValue.includes(optionLabel)) {
                            this.filterOptions.push(option);
                        }
                    } catch (err) {
                        console.log('== Error ', err.message);
                    }
                }
            }
        } else {
            let allOptions = JSON.parse(JSON.stringify(this.optionsList));
            for (let i = 0; i < allOptions.length; i++) {
                let objInfo = {};
                objInfo.label = allOptions[i].label;
                objInfo.value = allOptions[i].value;
                if (!this.currentSelectedValue.includes(objInfo.label)) {
                    this.filterOptions.push(objInfo);
                }
            }
        }
        if (this.filterOptions.length < 1) {
            this.showPicklist = false;
        }

    }
    selectRecord(event) {
        let selectedVal = event.currentTarget.getAttribute("data-value");
        if (this.currentSelectedValue.length === this.maxLimit) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: '',
                    message: 'You can only select ' + this.maxLimit + ' options !',
                    variant: 'error'
                })
            );
        } else if (this.currentSelectedValue.length < this.maxLimit) {
            if (selectedVal) {
                this.currentSelectedValue.push(selectedVal);
            }
        }
        this.dispatchEvent(new CustomEvent('select', { detail: this.currentSelectedValue }));
        this.inputValue = '';
        this.showPicklist = false;
        this.filterOptions = [];
    }

    handleOnBlur(event) {
        this.showPicklist = false;
        this.filterOptions = [];
    }

    handleOnClear(event) {
        let selectedRemoveVal = event.target.name;
        if (this.currentSelectedValue) {
            let currentAllValue = JSON.parse(JSON.stringify(this.currentSelectedValue));
            this.currentSelectedValue = [];

            for (let i = 0; i < currentAllValue.length; i++) {
                let labeldata = currentAllValue[i];
                if (labeldata != selectedRemoveVal) {
                    this.currentSelectedValue.push(currentAllValue[i]);
                }
            }
            this.dispatchEvent(new CustomEvent('select', { detail: this.currentSelectedValue }));
        }

    }
    applyMultiselectChange(event) {
        this.dispatchEvent(new CustomEvent('savechange', { detail: { selectedQuesData: this.currentSelectedValue, indexKey: this.indexKey } }));
    }

}