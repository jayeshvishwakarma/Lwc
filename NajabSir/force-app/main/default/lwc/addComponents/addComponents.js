/*eslint-disable no-console*/
import Base from 'c/addLineItemBase';
import { api, track, wire } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';

import MCP_Package_FIELD from '@salesforce/schema/OpportunityLineItem.MCP_Package__c';
import MCP_Validity_FIELD from '@salesforce/schema/OpportunityLineItem.MCP_Validity__c';
import Extended_Warranty_Validity_FIELD from '@salesforce/schema/OpportunityLineItem.Extended_Warranty_Validity__c';
import getMCPAmount from '@salesforce/apex/AddLineItemCtrlHelper.fetchMCPAmount';

export default class AddComponents extends Base {
    @api variant;

    @track variantJSObj = {};
    @track extendedWarrentyItems = [];
    @track extendedWarrentyValidityData = [];
    @track selectedExtendedWarrantyValue = '';
    @track packagePickList = [];
    @track validityPicklist = [];
    @track selectedPackage = '';
    @track selectedValidity = '';
    @track selectedAddons = [];
    @track selection;
    @track dataPackageOptions = [];

    @track datalist1 = [
        { label: 'Extended Warranty', value: '', isChecked: false, isExchangedWarrenty: false, showLabel: false, isDisabled: true, year: '', showCheckBox: false },
        { label: 'Loyalty', value: '', isChecked: false, showLabel: true, isDisabled: true, showCheckBox: true },
        { label: 'Insurance', value: '', isChecked: false, showLabel: true, isDisabled: false, showCheckBox: true },
        { label: 'Municipal Charges', value: '', isChecked: false, showLabel: true, isDisabled: false, showCheckBox: true },
        { label: 'FASTag charges', value: '', isChecked: false, showLabel: true, isDisabled: false, showCheckBox: true },
        { label: 'Road Tax', value: '', isChecked: false, showLabel: true, isDisabled: false, showCheckBox: true },
        { label: 'MCP', value: '', isChecked: false, isMCP: false, showLabel: false, isDisabled: true, packageValue: '', validityValue: '', showCheckBox: false, amount: 0 },
    ]

    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: MCP_Package_FIELD })
    packagePicklistValues({ error, data }) {
        if (data) {
            this.packagePickList = data.values;
        }
        if(error){
            console.log('== Error ', error);
        }
    }
    get packageOptions() {
        let data = [];
        data.push({ value: '', label: '---NONE---' });
        for (let i = 0; i < this.packagePickList.length; i++) {
            data.push({ value: String(this.packagePickList[i].value), label: String(this.packagePickList[i].label) });
        }
        return data;
    }

    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: MCP_Validity_FIELD })
    validityPicklistValues({ error, data }) {
        if (data) {
            this.validityPicklist = data.values;
        }
        if(error){
            console.log('== Error ', error);
        }
    }
    get validityOptions() {
        let data = [];
        data.push({ value: '', label: '---NONE---' });
        for (let i = 0; i < this.validityPicklist.length; i++) {
            data.push({ value: String(this.validityPicklist[i].value), label: String(this.validityPicklist[i].label) });
        }
        return data;
    }

    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: Extended_Warranty_Validity_FIELD })
    extendedWarrentyValidityPicklist({ error, data }) {
        if (data) {
            this.extendedWarrentyValidityData = data;
        }
        if(error){
            console.log('== Error ', error);
        }
    }

    connectedCallback() {
        this.setSavePoint();

        this.datalist1 = this.state.addComponent ? this.clone(this.state.addComponent) : null;
        this.variant = this.state.selectedVariant;

        if (this.variant !== '' && this.variant != null) {
            let variantObj = '';
            if (typeof this.variant === 'string')
                variantObj = JSON.parse(this.variant);
            else
                variantObj = this.variant;

            this.variantJSObj = variantObj;
            let keys = Object.keys(variantObj);
            this.extendedWarrentyItems.push({ label: '---NONE---', value: '' });
            for (let i = 0; i < keys.length; i++) {
                if (keys[i].search('Extended_Warranty') > -1) {
                    let keyLabel = keys[i].replace('__c', '').replace(/_/g, ' ');
                    this.extendedWarrentyItems.push({ value: (String(variantObj[keys[i]]) + '#' + keyLabel).trim(), label: (keys[i].replace('__c', '')).replace(/_/g, ' ') });
                }
            }
            if (this.datalist1 !== null) {
                for (let i = 0; i < this.datalist1.length; i++) {
                    if (this.datalist1[i].label === 'Loyalty') {
                        this.datalist1[i].value = this.variantJSObj.Loyalty_Amount__c;
                    }
                    //popuate validity and package
                    if (this.datalist1[i].label === 'MCP') {
                        if (this.datalist1[i].packageValue !== '' && this.datalist1[i].validityValue !== '') {
                            this.selectedPackage = this.datalist1[i].packageValue;
                            this.selectedValidity = this.datalist1[i].validityValue;
                        }
                    }
                    //POPULATE EXTENDED WARRENTY
                    if (this.datalist1[i].label === 'Extended Warranty') {
                        if (this.datalist1[i].value !== '') {
                            this.selectedExtendedWarrantyValue = this.datalist1[i].value + '#Extended Warranty ' + this.datalist1[i].year;
                        }
                    }
                }


            } else {
                this.datalist1 = [
                    { label: 'Extended Warranty', value: '', isChecked: false, isExchangedWarrenty: true, showLabel: false, isDisabled: true, year: '', showCheckBox: false },
                    { label: 'Loyalty', value: this.variantJSObj.Loyalty_Amount__c, isChecked: false, showLabel: true, isDisabled: true, showCheckBox: true },
                    { label: 'Insurance', value: '', isChecked: false, showLabel: true, isDisabled: false, showCheckBox: true },
                    { label: 'Municipal Charges', value: '', isChecked: false, showLabel: true, isDisabled: false, showCheckBox: true },
                    { label: 'FASTag charges', value: '', isChecked: false, showLabel: true, isDisabled: false, showCheckBox: true },
                    { label: 'Road Tax', value: '', isChecked: false, showLabel: true, isDisabled: false, showCheckBox: true },
                    { label: 'MCP', value: '', isChecked: false, isMCP: true, showLabel: false, isDisabled: true, packageValue: '', validityValue: '', showCheckBox: false, amount: 0 },
                ]
            }

        }
    }

    handleAddOnCheck(event) {
        for (let i = 0; i < this.datalist1.length; i++) {
            if (this.datalist1[i].label === event.target.label) {
                this.datalist1[i].isChecked = event.target.checked;
            }
        }
    }

    handleExtendedWarranty(event) {
        this.selectedExtendedWarrantyValue = event.detail.value;
        if (this.selectedExtendedWarrantyValue !== '' && this.selectedExtendedWarrantyValue !== null) {
            for (let i = 0; i < this.datalist1.length; i++) {
                if (this.datalist1[i].label === 'Extended Warranty') {
                    this.datalist1[i].value = (this.selectedExtendedWarrantyValue).split('#')[0] && (this.selectedExtendedWarrantyValue).split('#')[0] !== 'null' ? (this.selectedExtendedWarrantyValue).split('#')[0] : 0;
                    this.datalist1[i].year = (((this.selectedExtendedWarrantyValue).split('#')[1]).replace('Extended Warranty', '')).trim();
                    if (this.selectedExtendedWarrantyValue !== '')
                        this.datalist1[i].isChecked = true;
                    else
                        this.datalist1[i].isChecked = false;
                }
            }
        }else{
            for (let i = 0; i < this.datalist1.length; i++) {
                if (this.datalist1[i].label === 'Extended Warranty') {
                    if (this.selectedExtendedWarrantyValue === '' || this.selectedExtendedWarrantyValue === null || (this.selectedExtendedWarrantyValue).split('#')[0] === 'null'){
                        this.datalist1[i].isChecked = false;
                        this.datalist1[i].value = 0;
                    }
                }
            }
        }
    }

    handlePackageChange(event) {
        this.selectedPackage = event.detail.value;
    }

    handleValidityChange(event) {
        this.selectedValidity = event.detail.value;
    }

    handleSave() {
        let isMCPValid = true;
        for (let i = 0; i < this.datalist1.length; i++) {
            if (this.datalist1[i].label === 'MCP') {
                this.datalist1[i].packageValue = this.selectedPackage;
                this.datalist1[i].validityValue = this.selectedValidity;
            }
        }

        if (this.selectedPackage !== '' && this.selectedValidity !== '') {
            for (let i = 0; i < this.datalist1.length; i++) {
                if (this.datalist1[i].label === 'MCP') {
                    this.datalist1[i].isChecked = true;
                }
            }
        } else {
            for (let i = 0; i < this.datalist1.length; i++) {
                if (this.datalist1[i].label === 'MCP') {
                    this.datalist1[i].isChecked = false;
                }
            }
        }

        if ((this.selectedPackage === '' && this.selectedValidity !== '') || (this.selectedPackage !== '' && this.selectedValidity === '')) {
            isMCPValid = false;
        }

        if (isMCPValid) {
            let fueltype = this.variant.Fuel_Type__c;
            this.executeAction(getMCPAmount, {
                selectedPackage: this.selectedPackage,
                selectedValidity: this.selectedValidity,
                varientId: fueltype
            }).then(result => {
                for (let i = 0; i < this.datalist1.length; i++) {
                    if (this.datalist1[i].label === 'MCP') {
                        this.datalist1[i].value = result;
                    }
                }
                this.setData({
                    addComponent: this.datalist1
                });
                this.commit().dispatchEvent('components');
            })
        } else {
            this.showToast({ message: 'Please select MCP Package/Validity' });
        }
    }

    handleAmountChange(event) {
        for (let i = 0; i < this.datalist1.length; i++) {
            if (this.datalist1[i].label === event.target.label) {
                this.datalist1[i].value = event.target.value;
            }
        }

    }

    handleCancel() {
        this.revert().dispatchEvent('components');
    }
}