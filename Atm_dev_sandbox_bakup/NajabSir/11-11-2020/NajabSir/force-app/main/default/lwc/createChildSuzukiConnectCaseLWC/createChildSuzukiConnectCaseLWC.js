import {
    LightningElement,
    api
} from 'lwc';
import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';
import {
    NavigationMixin
} from 'lightning/navigation';
import SuzukiConnectChildCaseDetails from "@salesforce/apex/SuzukiConnectChildCaseDetails.getCaseData";
import Error_Suzuki_Connect from "@salesforce/label/c.Error_Suzuki_Connect";



export default class CreateChildSuzukiConnectCaseLWC extends NavigationMixin(LightningElement) {


    @api recordId;
    message;
    showSpinner = true;
    callConnected = false;
    sObjectName = 'Case';
    valuesObj = {};
    dealerQuery;
    selectedDealer;
    selectedDealerName;
    selectedDealerId;
    isMobileDevice = false;
    dealerRecordTypeName = 'Dealer';
    dealerSelectionMatrices;
    caseJson = {};

    connectedCallback() {
        console.log('Inside connectedCallback');
        this.checkForMobileDevice();
        SuzukiConnectChildCaseDetails({
            recordId: this.recordId
        }).then(result => {
            if (result) {
                if (result.dealerSelectionMatrices) {
                    this.dealerSelectionMatrices = result.dealerSelectionMatrices;
                }
                this.caseJson = result.parentCaseData ? result.parentCaseData : null;
                if (result.parentCaseData && result.parentCaseData.Case_Type__c === 'Complaint' && (result.parentCaseData.Job_Status__c === 'Pending for Device Inspection' || result.parentCaseData.Job_Status__c === 'Resolved by Stakeholder Replacement') &&
                    result.parentCaseData.Primary_Category__c === 'Suzuki Connect Product Complaint' && result.parentCaseData.RecordType.DeveloperName === 'Suzuki_Connect' && result.parentCaseData.Status === 'Open') {
                    console.log('Inisde if');
                    if (result.taskData && result.taskData.length > 0) {
                        if (result.taskData.Disposition_Detail__c) { //Call Not connected scenario
                            this.saveCase();
                        } else if (result.taskData.Wrap_Up_Code__c) { //Call Connected scenario
                            this.updateDealerQuery('onload');
                            this.callConnected = true;
                        }
                    } else {
                        this.updateDealerQuery('onload');
                        this.callConnected = true;
                    }

                } else {
                    console.log('inside else');
                    this.message = Error_Suzuki_Connect;
                    this.handleMessage('Error', Error_Suzuki_Connect, 'error');
                }
            }
            console.log('result------->', result);
        }).catch(error => {
            console.log('result------->', error);
        })
        this.showSpinner = false;
    }

    checkForMobileDevice() {
        // Mobile device check
        let mobileCheck = function () {
            let check = false;
            (function (a) {
                if (/(android|bb\d+|meego).+mobile|avantgo|bada\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|iris|kindle|lge |maemo|midp|mmp|mobile.+firefox|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\.(browser|link)|vodafone|wap|windows ce|xda|xiino/i.test(a) || /1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\-(n|u)|c55\/|capi|ccwa|cdm\-|cell|chtm|cldc|cmd\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\-s|devi|dica|dmob|do(c|p)o|ds(12|\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\-|_)|g1 u|g560|gene|gf\-5|g\-mo|go(\.w|od)|gr(ad|un)|haie|hcit|hd\-(m|p|t)|hei\-|hi(pt|ta)|hp( i|ip)|hs\-c|ht(c(\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\-(20|go|ma)|i230|iac( |\-|\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\/)|klon|kpt |kwc\-|kyo(c|k)|le(no|xi)|lg( g|\/(k|l|u)|50|54|\-[a-w])|libw|lynx|m1\-w|m3ga|m50\/|ma(te|ui|xo)|mc(01|21|ca)|m\-cr|me(rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\-2|po(ck|rt|se)|prox|psio|pt\-g|qa\-a|qc(07|12|21|32|60|\-[2-7]|i\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\-|oo|p\-)|sdk\/|se(c(\-|0|1)|47|mc|nd|ri)|sgh\-|shar|sie(\-|m)|sk\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\-|v\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\-|tdg\-|tel(i|m)|tim\-|t\-mo|to(pl|sh)|ts(70|m\-|m3|m5)|tx\-9|up(\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|yas\-|your|zeto|zte\-/i.test(a.substr(0, 4))) check = true;
            })(navigator.userAgent || navigator.vendor || window.opera);
            return check;
        };
        this.isMobileDevice = mobileCheck();
    }

    handleFieldChange(event) {
        try {
            let fieldName = event.target.name;
            let fieldValue = event.detail.value;
            console.log('fieldName------>', fieldName);
            console.log('fieldValue------>', fieldValue);
            if (fieldName == 'For_Code__c') {
                if (fieldValue && fieldValue !== '') {
                    this.valuesObj.cityValue = Object.values(fieldValue)[0];
                } else {
                    this.valuesObj.cityValue = undefined;
                }
            } else if (fieldName == 'Outlet_Type__c') {
                if (fieldValue && fieldValue !== '') {
                    this.valuesObj.outletTypeValue = fieldValue;
                } else {
                    this.valuesObj.outletTypeValue = undefined;
                }
            }
            this.updateDealerQuery(fieldName);

        } catch (error) {
            console.log('error---------->', error);
        }
    }

    /* Dealer related functions */
    updateDealerQuery(fieldName) {

        // For Dealer Reset
        if (fieldName === 'onload' || fieldName === 'Outlet_Type__c' || fieldName === 'For_Code__c') {
            if (fieldName !== 'onload') {
                this.resetDealer();
            }
            this.dealerQuery = undefined;
            this.dealerQuery = 'SELECT Name,Type,Dealer_Code__c,Region_Code__c,City__c,Dealer_Type__c,BillingStreet,BillingCity,BillingCountry,BillingState,BillingPostalCode,Zone__c FROM Account';
            this.dealerQuery += ' WHERE RecordType.Name =' + "'" + this.dealerRecordTypeName + "'";

            if (this.valuesObj.cityValue && this.valuesObj.outletTypeValue) {
                this.dealerQuery += ' AND For_Code__c =' + "'" + this.valuesObj.cityValue + "'";
                let whereClause = this.getDealerFilterQuery();
                if (whereClause && whereClause !== '') {
                    this.dealerQuery += whereClause;
                }
            } else {
                this.dealerQuery = undefined;
            }
        }
    }

    resetDealer() {
        console.log('reset dealer called')
        this.selectedDealer = undefined;
        //this.isDealerFieldShow = false;
        this.valuesObj.dealerType = '';
        this.valuesObj.dealerCode = '';
        this.selectedDealerId = undefined;
        this.valuesObj.dealerBillingStreet = '';
        this.valuesObj.dealerBillingCity = '';
        this.valuesObj.dealerBillingCountry = '';
        this.valuesObj.dealerBillingState = '';
        this.valuesObj.dealerBillingPostalCode = '';

        this.valuesObj.dealerZone = '';
        setTimeout(f => {
            //  this.isDealerFieldShow = true;
        }, 0);

    }

    getDealerFilterQuery() {
        let whereClause = '';
        const selectedMatrix = this.dealerSelectionMatrices.find(dealerSelectionMatrix => dealerSelectionMatrix.Outlet_Type__c === this.valuesObj.outletTypeValue);
        let getFilterValue = (name, value) => {
            let returnValue;
            let valuesOptions = value.split(",");
            returnValue = valuesOptions.length > 1 ? '(' : '';
            valuesOptions.forEach((value, index) => {
                returnValue = index === 0 ? returnValue += name + '=' + "'" + value + "'" : returnValue += ' OR ' + name + ' =' + "'" + value + "'";
            });
            returnValue += valuesOptions.length > 1 ? ')' : '';
            return returnValue;
        };
        if (selectedMatrix) {
            if (selectedMatrix.Dealer_Channel__c) {
                whereClause += ' AND ' + getFilterValue('Channel__c', selectedMatrix.Dealer_Channel__c);
            }
            if (selectedMatrix.Dealer_Category__c) {
                whereClause += ' AND ' + getFilterValue('Dealer_Category__c', selectedMatrix.Dealer_Category__c);
            }
            if (selectedMatrix.Dealer_Type__c) {
                whereClause += ' AND ' + getFilterValue('Dealer_Type__c', selectedMatrix.Dealer_Type__c);
            }
        }
        return whereClause;
    }

    handleLookupChange(event) {
        try {
            let txt = JSON.stringify(event.detail);
            // console.log(txt);
            this.selectedDealer = JSON.parse(txt);
            console.log('this.selectedDealer----------->' + this.selectedDealer);
            this.valuesObj.dealerCode = '';
            this.valuesObj.dealerType = '';
            this.valuesObj.regionCodeValue = '';
            this.valuesObj.dealerZone = '';
            this.valuesObj.dealerBillingStreet = '';
            this.valuesObj.dealerBillingCity = '';
            this.valuesObj.dealerBillingCountry = '';
            this.valuesObj.dealerBillingState = '';
            this.valuesObj.dealerBillingPostalCode = '';
            this.selectedDealerId = undefined;
            let address = '';
            if (this.selectedDealer && this.selectedDealer.Id) {
                this.selectedDealerId = this.selectedDealer.Id;
                if (this.selectedDealer.Dealer_Code__c) {
                    this.valuesObj.dealerCode = this.selectedDealer.Dealer_Code__c;
                }
                if (this.selectedDealer.Dealer_Type__c) {
                    this.valuesObj.dealerType = this.selectedDealer.Dealer_Type__c;
                }
                if (this.selectedDealer.Region_Code__c) {
                    this.valuesObj.regionCodeValue = this.selectedDealer.Region_Code__c;
                }
                if (this.selectedDealer.Zone__c) {
                    this.valuesObj.dealerZone = this.selectedDealer.Zone__c;
                }

                this.valuesObj.dealerBillingStreet = this.selectedDealer.BillingStreet;
                this.valuesObj.dealerBillingCity = this.selectedDealer.BillingCity;
                this.valuesObj.dealerBillingCountry = this.selectedDealer.BillingCountry;
                this.valuesObj.dealerBillingState = this.selectedDealer.BillingState;
                this.valuesObj.dealerBillingPostalCode = this.selectedDealer.BillingPostalCode;
                if (this.selectedDealer.BillingStreet) {
                    address += this.selectedDealer.BillingStreet;
                }
                if (this.selectedDealer.BillingStreet) {
                    address += ', ' + this.selectedDealer.BillingCity;
                }
                if (this.selectedDealer.BillingStreet) {
                    address += ', ' + this.selectedDealer.BillingState;
                }
                if (this.selectedDealer.BillingStreet) {
                    address += ', ' + this.selectedDealer.BillingCountry;
                }
                if (this.selectedDealer.BillingStreet) {
                    address += ', ' + this.selectedDealer.BillingPostalCode;
                }
            }
            this.valuesObj.dealerAddress = address;
        } catch (e) {
            console.log(e.message);
        }
    }

    saveCase() {
        console.log('This Button');
        console.log('this.caseJson------------>', this.caseJson);

    }

    // This method is used to close the LWC and navigate to record page
    cancel() {
        this.showSpinner = true;
        this[NavigationMixin.Navigate]({
            type: "standard__recordPage",
            attributes: {
                recordId: this.recordId,
                objectApiName: "Case", // objectApiName is optional
                actionName: "view"
            }
        });
        this.showSpinner = false;
    }

    /* submit functions */
    handleSubmit(event) {
        event.preventDefault();

    }

    //Handle Success & Error Messages
    handleMessage(title, message, response) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: response
            })
        );
    }

}