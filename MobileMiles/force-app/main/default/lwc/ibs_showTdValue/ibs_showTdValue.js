import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
export default class Ibs_showTdValue extends NavigationMixin(LightningElement) {
    @api row;
    @api column;
    @api type;
    @api columnIndex;
    @api firstColumnClickable = false;
    @api urlRedirect;
    @api objectName;
    @api formualFld1;
    @api formualFld2;
    @api notAlginRigthValue = false;
    @api withinSf = false;
    @api fieldEditable = false;
    @track fieldVal;
    @track showFormulaFld = false;
    @track formulaVal;
    @track recid;
    @track showModal = false;
    @api label;
    className;
    fullUrl = '';
    @track showAnchorTag = false;
    @track spinner = false;
    @track showCurrencyFld = false;
    @track showAlertButton = false;
    @track isSimsModalVisable = false;

    connectedCallback() {
        let fieldvalue = '';
        fieldvalue = this.row[this.column];
        this.recid = this.row['Id'];

        let fld1Arr;
        let fld2Arr;
        if (this.formualFld1) {
            fld1Arr = this.formualFld1.split(',');
            if (this.column == fld1Arr[0].trim()) {
                this.formulaVal = this.row[fld1Arr[1].trim()];
                this.showFormulaFld = true;
            }
        }
        if (this.formualFld2) {
            fld2Arr = this.formualFld2.split(',');
            if (this.column == fld2Arr[0].trim()) {
                this.formulaVal = this.row[fld2Arr[1].trim()];
                this.showFormulaFld = true;
            }
        }
        //console.log(this.type);
        if (this.type != undefined) {
            if (this.type.toLowerCase() == 'datetime') {
                if (fieldvalue != null && fieldvalue != undefined && fieldvalue != '' && fieldvalue != '-') {
                    fieldvalue = fieldvalue.substring(0, fieldvalue.length - 1);
                    if (fieldvalue != null && fieldvalue != undefined) {
                        let fieldValueArr = fieldvalue.split('T'); //removes T
                        if (fieldValueArr != undefined) {
                            fieldvalue = fieldValueArr[0] + ' ' + fieldValueArr[1].split('.')[0];
                            //this.fieldVal = fieldvalue;
                        }
                    }
                }
            }
            if (this.type.toLowerCase() == 'date') {
                fieldvalue = this.createDateFormat(new Date(fieldvalue));
            }
            if (this.type.toLowerCase() == 'phone') {
                let phnNumber = this.formatPhoneNumber(fieldvalue);
                if (fieldvalue != null) {
                    fieldvalue = phnNumber;
                }
            }
            if (this.type.toLowerCase() == 'currency') {
                //fieldvalue = fieldvalue != undefined ? '€ ' + fieldvalue : '€ ' + 0;
                this.showCurrencyFld = true;
            }
        }

        this.fieldVal = fieldvalue;
        if (this.firstColumnClickable == true && this.columnIndex == 0) {
            this.showAnchorTag = true;
            this.fullUrl = this.urlRedirect + this.recid;
            // if(this.objectName.toLowerCase() == 'attachment'){
            //     this.fullUrl = '/servlet/servlet.FileDownload?file='+this.recid;
            // }else if(this.objectName.toLowerCase() != 'attachment' && this.withinSf == true){
            //     this[NavigationMixin.GenerateUrl]({
            //         type: 'standard__recordPage',
            //         attributes: {
            //             recordId:  this.recid,
            //             actionName: 'view',
            //         },
            //     }).then(url => {
            //         this.fullUrl = url;                    
            //     });
            // }else{
            //     this.fullUrl = this.urlRedirect;
            // } 
        }

        if(this.objectName == 'Porteringen_mobiel__c' && this.column == 'X06_097_nummer__c'){
            this.showAlertButton = true;
        }
    }

    get customCls() {
        //console.log('this.type.toLowerCase()->' , this.type.toLowerCase());
        if (this.type.toLowerCase() == 'currency' && this.notAlginRigthValue == false) {
            //console.log('this.type.toLowerCase()->' , this.type.toLowerCase());            
            return 'custom-align show-edit-icon';
        }
        return 'show-edit-icon';
    }
    createDateFormat(currentDate) {
        let month = '' + (currentDate.getMonth() + 1);
        let day = '' + currentDate.getDate();
        let year = currentDate.getFullYear();

        if (month.length < 2)
            month = '0' + month;
        if (day.length < 2)
            day = '0' + day;

        return [day, month, year].join('-');
    }

    handleSubmit() {
        this.spinner = true;
    }
    toggleEditModal() {
        this.spinner = false;
        this.showModal = !this.showModal;
    }
    handleError(event) {
        console.log(event.detail.message);
        this.showSpinner = false;
    }
    setEvent() {
        this.showSpinner = false;
        this.showModal = !this.showModal;
        this.dispatchEvent(new CustomEvent('refershtable'));

    }

    showSimsModal(){
        this.isSimsModalVisable = !this.isSimsModalVisable;
    }
}