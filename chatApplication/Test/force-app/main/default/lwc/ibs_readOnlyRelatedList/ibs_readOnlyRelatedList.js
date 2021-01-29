import { LightningElement, track, api, wire } from 'lwc';
import getRecordsFromSF from '@salesforce/apex/IBSReadOnlyRelatedListController.getSobjectData';
import getFieldsFromSF from '@salesforce/apex/IBSReadOnlyRelatedListController.getFlds';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { registerListener, unregisterAllListeners } from 'c/pubSub';
export default class Ibs_readOnlyRelatedList extends LightningElement {

    @api objectName = '';
    @api fieldsApiName = '';
    @api relatedListTitle = '';
    @api iconName = '';
    @api recordId;
    @api whichFieldNeedToTotal = '';
    @api labelOfTotalField = '';
    @api design = 'Lightning theme';
    @api paretnFieldApiName;
    @api parentType;
    @api whereClause;
    @api orderBy;
    @api fieldsForEdit;
    @api firstColumnClickable = false;
    @api withinSF = false;
    @api urlRedirect = '';
    @api formualFld1;
    @api formualFld2;
    @api notAlginRigthValue = false;
    @api hideTableHeader = false;
    @api tableHeight = '';
    @api isSortable = false;
    @track fieldToshow;
    @track totalAmount;
    @track records;
    @track colspan = 0;
    @track index = 0;
    @track showSpinner = false;
    @track sortAsc;
    isFromEvent = 'false';
    connectedCallback() {
        console.log('apiobject', this.objectName);
        console.log('recordsId', this.recordId);
        console.log('paretnFieldApiName', this.paretnFieldApiName);
        registerListener('selectedAccountUpdate'
            , this.handleAccountChange,
            this);

    }
    @wire(getObjectInfo, { 'objectApiName': '$objectName' })
    getObjectInfo({ error, data }) {
        if (data) {
            this.showSpinner = true;
            console.log('fieldData', data);
            data = JSON.parse(JSON.stringify(data));
            let f1Arr = '';
            let f2Arr = '';
            let editableFlds = '';
            if (this.formualFld1) {
                f1Arr = this.formualFld1.split(',');
            }
            if (this.formualFld2) {
                f2Arr = this.formualFld2.split(',');
            }
            if (this.fieldsForEdit) {
                editableFlds = this.fieldsForEdit.replace(/\s/g, '').split(',');
            }
            //this.allFields = data.fields;
            if (this.fieldsApiName) {
                let fieldsApiNameArr = this.fieldsApiName.split(',');
                // if(fieldsApiNameArr.length() > 0){
                this.fieldToshow = []
                fieldsApiNameArr.forEach(ele => {
                    //console.log('fld', data.fields[ele.trim()]);
                    console.log('fl', f1Arr);
                    console.log('dat', data.fields[ele.trim()]);
                    if ((f1Arr[1] == data.fields[ele.trim()].apiName || f2Arr[1] == data.fields[ele.trim()].apiName) && data.fields[ele.trim()].calculated == true) {
                        return;
                    }
                    if (editableFlds && editableFlds.includes(data.fields[ele.trim()].apiName)) {
                        data.fields[ele.trim()].editable = true;
                    }
                    this.fieldToshow.push(data.fields[ele.trim()]);
                });

            }
            // }
            // let listViewData = [];
            // for (let indx of data.lists) {
            //     listViewData.push({
            //         value: indx.apiName,
            //         label: indx.label,
            //         id: indx.id,
            //         isSelected: false,
            //     });
            // }
            // this.listViewOptions = [...listViewData];
            // this.currentSelectedListView = this.listViewOptions[0].label;
            // this.listViewOptions[0].isSelected = true;
            // this.listViewId = this.listViewOptions[0].id;
            // console.log(' this.listViewId', this.listViewId);
            // console.log(this.listViewOptions);
            // this.showSpinner = false;
            this.getRecords();
        } else if (error) {
            this.showSpinner = false;
            if (this.objectName == 'Attachment') {
                this.getFields();
                // this.fieldToshow = [];
                // this.fieldToshow.push({ apiName: "Name", calculated: false, dataType: 'String', label: 'Name' });
                // this.getRecords();
            } else {
                console.log('err->', error);
            }
            // this.showSpinner = false;
        }

    }
    getFields() {
        console.log('this.fieldsApiName', this.fieldsApiName);
        getFieldsFromSF({ objectName: this.objectName, flds: this.fieldsApiName })
            .then(result => {
                console.log('Field from SF', JSON.parse(result));
                this.fieldToshow = [];
                this.fieldToshow = JSON.parse(result);
                this.getRecords();
            }).catch(error => {
                console.log('Error While getting field from SF', error);
            });
    }
    getRecords() {
        if (this.whereClause && this.whereClause.toLowerCase().includes('where')) {
            this.whereClause = this.whereClause.toLowerCase().replace('where', '').trim();
            console.log('this.whereClause', this.whereClause);
        }
        if (this.orderBy && this.orderBy.toLowerCase().includes('order by')) {
            this.orderBy = this.orderBy.toLowerCase().replace('order by', '');//.trim();
        }
        // if (this.objectName == 'Attachment') {
        //     this.objectName = 'ContentDocument';
        // }    

        getRecordsFromSF({
            objectApiName: this.objectName,
            fieldNames: this.fieldsApiName,
            recordId: this.recordId,
            parentFieldApiName: this.paretnFieldApiName,
            parentType: this.parentType,
            whereClause: this.whereClause,
            orderBy: this.orderBy,
            isFromEvent: this.isFromEvent
        })
            .then(result => {
                console.log('result', result);
                console.log('table');
                this.records = [];
                if (result != null) {
                    this.records = result;
                    console.log('this.fieldToshow', this.fieldToshow);
                    this.getTotalAmount();
                    console.log('this.tableHeight ->', this.tableHeight);
                    if (this.template.querySelector('.custom-billing-detail') && this.tableHeight) {
                        this.template.querySelector('.custom-billing-detail').style.height = this.tableHeight;
                    }
                } else {
                    this.records = null;
                }
                this.showSpinner = false;
            }).catch(error => {
                this.showSpinner = false;
                console.log('error', error);
            });
    }

    getTotalAmount() {
        if (this.whichFieldNeedToTotal) {
            this.totalAmount = 0;
            this.records.forEach(ele => {
                this.totalAmount += parseFloat(ele[this.whichFieldNeedToTotal]);
            });
            this.colspan = this.fieldToshow.length;
        }
    }

    get designToken() {
        if (this.design == 'Lightning theme') {
            return 'slds-table slds-table_cell-buffer slds-table_bordered';
        } else if (this.design == 'Grey theme') {
            return 'slds-table slds-table_cell-buffer slds-no-row-hover  grey-theme';
        }
    }
    get thDesignToken() {
        let designCls = '';
        if (this.design == 'Grey theme') {
            designCls = 'grey-theme';
        }
        if (this.fieldToshow && this.fieldToshow.length >= this.index) {
            //console.log('this.fieldToshow[this.index].dataType.toLowerCase()',this.fieldToshow[this.index].dataType.toLowerCase());
            if (this.fieldToshow[this.index] && this.fieldToshow[this.index].dataType.toLowerCase() == 'currency' && this.notAlginRigthValue == false) {
                designCls += ' slds-float_right';
            }

        }
        designCls += ' slds-is-sortable';
        this.index = this.index + 1;
        return designCls;
    }

    get detailDivDesign() {
        if (this.design == 'Lightning theme') {
            return 'slds-col slds-size_1-of-1 custom-billing-detail';
        } else if (this.design == 'Grey theme') {
            return 'slds-col slds-size_1-of-1 custom-billing-detail grey-theme';
        }
    }

    handleAccountChange(value) {
        console.log('changed value ', value);
        this.recordId = value;
        this.isFromEvent = 'true';
        this.getRecords();
    }

    @api refershList() {
        this.records = [];
        this.showSpinner = true;
        this.getRecords();
    }

    handleSort(event) {
        if (this.isSortable) {
            [].forEach.call(this.template.querySelectorAll('.slds-is-sortable'), function (el) {
                el.classList.remove('slds-is-sorted');
                el.querySelector('.icon-area').classList.add('hide');
            });
            let column = event.target;
            if (column.tagName != 'TH')
                column = column.closest('th');

            let sortby = column.dataset.sortby;
            column.classList.add("slds-is-sorted");
            let icon = column.querySelector('.icon-area');
            icon.classList.remove('hide');

            //sort(this.contacts, sortby);

            let data = this.records;
            //let btnProp = event.target;
            let targetName = column.dataset.sortby;
            //event.target.iconName = event.target.iconName == 'utility:arrowdown' ? 'utility:arrowup' : 'utility:arrowdown';
            let sortOrder = this.sortAsc === true ? 1 : -1;
            console.log('sortOrder', sortOrder);
            console.log('targetName', targetName);
            if(this.sortAsc){               
                this.sortAsc = false;
            }else{
                this.sortAsc = true;
            }
            this.records = JSON.parse(JSON.stringify(data.sort(this.sortBy(targetName, sortOrder))));
            console.log('this.tableRecords ,', this.records);
        }

    }
    sortBy(field, reverse, primer) {
        var key = primer ?
            function (x) { return primer(x[field]) } :
            function (x) { return x[field] };
        return function (a, b) {
            return a = key(a) ? key(a) : '', b = key(b) ? key(b) : '', reverse * ((a > b) - (b > a));
        }
    }
    get isAsc() {
        return this.sortAsc === true ? true : false;
    }

    get isDesc() {
        return this.sortAsc === false ? true : false;
    }
}