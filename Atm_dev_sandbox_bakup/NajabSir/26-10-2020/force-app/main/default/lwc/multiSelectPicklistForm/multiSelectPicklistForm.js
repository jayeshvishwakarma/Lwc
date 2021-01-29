import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class MultiSelectPicklistForm extends LightningElement {

    @api indexKey;
    @api name;
    @api optionsList;
    @api selectedValues;
    @api disabled;

    @track filterOptions = [];

    showPicklist = false;

    @track currentSelectedValue = [];

    inputValue = '';

    renderedCallback() {
        if (this.disabled) {
            let allPills = this.template.querySelectorAll('[data-id="pillblock"]');
            console.log('== allPills ', allPills.length);
            for (let i = 0; i < allPills.length; i++) {
                allPills[i].classList.add("remove");
            }
        } else {
            let allPills = this.template.querySelectorAll('[data-id="pillblock"]');
            console.log('== allPills ', allPills.length);
            for (let i = 0; i < allPills.length; i++) {
                allPills[i].classList.remove("remove");
            }
        }
    }

    connectedCallback() {
        if (this.selectedValues) {
            let allSelectedOptions = JSON.parse(JSON.stringify(this.selectedValues));
            console.log('== On child Load ', allSelectedOptions);
            if (allSelectedOptions) {
                this.currentSelectedValue = [];

                for (let i = 0; i < allSelectedOptions.length; i++) {
                    this.currentSelectedValue.push(allSelectedOptions[i]);
                }
            }
        } else {
            console.log('== Nothing come');
        }

        /* data-id="pillblock"
        this.template.querySelectorAll('[data-id="pillblock"]').className='remove'; */

    }

    handleOnClick(event) {
        this.filterOptions = [];
        this.showPicklist = true;
        let searchKey = event.target.value;
        this.inputValue = searchKey;
        console.log('==== searchKey ', searchKey);
        //console.log('==== this.optionsList 11 ', this.optionsList);
        console.log('==== this.optionsList.length@@@ ', this.optionsList.length);

        if (searchKey && searchKey.length > 0) {
            let allOptions = JSON.parse(JSON.stringify(this.optionsList));
            console.log('== currentSelectedValue ', this.currentSelectedValue);
            for (let i = 0; i < allOptions.length; i++) {
                let option = allOptions[i];
                let optionLabel = JSON.parse(JSON.stringify(option.label)) + '';
                console.log('== optionLabel ', optionLabel);
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
            console.log('===this.filterOptions 111', this.filterOptions);
        } else /* if (this.currentSelectedValue.length === 0) */ {
            console.log('===this.optionsList 22 ', this.optionsList);
            let allOptions = JSON.parse(JSON.stringify(this.optionsList));
            console.log('== allOptions ', allOptions);
            for (let i = 0; i < allOptions.length; i++) {
                let objInfo = {};
                objInfo.label = allOptions[i].label;
                objInfo.value = allOptions[i].value;
                if (!this.currentSelectedValue.includes(objInfo.label)) {
                    this.filterOptions.push(objInfo);
                }
            }
            console.log('===this.filterOptions22 ', this.filterOptions);
        }

        if (this.filterOptions.length < 1) {
            this.showPicklist = false;
        }

    }
    selectRecord(event) {
        console.log('== Current Child Index ', this.indexKey);

        let selectedVal = event.currentTarget.getAttribute("data-value");
        console.log('== selectedVal ', selectedVal);
        if (this.currentSelectedValue.length === 5) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: '',
                    message: 'You can only select 5 options !',
                    variant: 'error'
                })
            );
        } else if (this.currentSelectedValue.length < 5) {
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
        console.log('=== on blur ');
        this.showPicklist = false;
        this.filterOptions = [];
    }

    handleOnClear(event) {
        let selectedRemoveVal = event.target.name;
        console.log('== selectedRemoveVal ', selectedRemoveVal);
        if (this.currentSelectedValue) {
            let currentAllValue = JSON.parse(JSON.stringify(this.currentSelectedValue));
            console.log('== Before currentAllValue ', currentAllValue);
            this.currentSelectedValue = [];
            console.log('== After currentAllValue ', currentAllValue);

            for (let i = 0; i < currentAllValue.length; i++) {
                let labeldata = currentAllValue[i];
                if (labeldata != selectedRemoveVal) {
                    this.currentSelectedValue.push(currentAllValue[i]);
                }
            }
            this.dispatchEvent(new CustomEvent('select', { detail: this.currentSelectedValue }));
        }

    }
}