/* eslint-disable no-console */
import {
    LightningElement,
    track,
    api,
    wire
} from 'lwc';
import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';

import retriveModelList from '@salesforce/apex/StockCheckCtrl.retrieveModelPicklist';

import retriveModelVarient from '@salesforce/apex/StockCheckCtrl.retriveModelVarient';
import retriveColorVarient from '@salesforce/apex/StockCheckCtrl.retriveColorVarient';
import retriveOutletAndForCodeInfo from '@salesforce/apex/StockCheckCtrl.retriveOutletAndForCodeInfo';
import retriveOutletAndForCodeFromAccount from '@salesforce/apex/StockCheckCtrl.retriveOutletAndForCodeFromAccount';
import findVariant from '@salesforce/apex/TestDriveFunctionality.findVariants';
import findVariantsForStockCheck from '@salesforce/apex/TestDriveFunctionality.findVariantsForStockCheck';
import getAccountList from '@salesforce/apex/StockCheckCtrl.getAccounts';
import getDealerList from '@salesforce/apex/StockCheckCtrl.getDealers';
//import retriveCOnsigneeCode from '@salesforce/apex/StockCheckCtrl.retriveConsigneeCode';
//import { getPicklistValues } from 'lightning/uiObjectInfoApi';
// Added as part of R1.2 Parts Development By Anuj
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import retrieveParts from '@salesforce/apex/StockCheckCtrl.retrieveParts';
//import model from '@salesforce/schema/Opportunity.Model_Code__c';
import stateList from '@salesforce/schema/Opportunity.ShipTo_State__c';


// import getResponse from '@salesforce/apex/StockCheckCtrl.getResponse';
import getProductStockList from '@salesforce/apexContinuation/MSILMuleSoftIntegration.getProductStockList';
import UI_Error_Message from '@salesforce/label/c.UI_Error_Message';
import checkUserDesignation from '@salesforce/apex/StockCheckCtrl.checkUserDesignation';
import retriveDelaerDataWhenParentSelected from '@salesforce/apex/StockCheckCtrl.retriveDelaerDataWhenParentSelected';
import { getRecord } from 'lightning/uiRecordApi';
import CURRENTUSERID from '@salesforce/user/Id';
import Category_FIELD from '@salesforce/schema/Product2.Part_Category__c';

export default class StockCheck extends LightningElement {

    // Before Search Component Data
    @track isLoading = false;
    @track records;
    @track error;
    @track selectedRecord;
    @api index;
    @api relationshipfield;
    @api iconname = "standard:product";
    @api objectName = 'Product2';
    @api searchfield = 'Name';
    @track colorOptions = [];
    @track modelList = [];
    @track selectedModel; // This variable is used to store selected Model
    @track hideComponent = false;
    @track showAccountSearchUI = false;
    @track variants = [];
    @track responseResult = [];
    @track selectedVariant;
    @track dealerAccountOptions = [];
    @track accessoriesResultData = [];
    @track accessoriesResultColumn = [];
    @track colorVarientsRecords;
    @track showNoDataError = false;
    @track selectedColorVarientRecords;
    @track selectedOutletType;
    @track accountList;
    @track selectedAccount;
    @track variantCode = '';
    @track colorCode = '';
    @track dealerMapCode = '';
    @track locationCode = '';
    @track parentCode = '';

    @track placeHolder = 'Enter Variant Name e.g. Spresso vxi , Baleno Delta';


    @track showButton = false;
    @track showDetails = false;
    @track showOutletTypes = false;
    @track tempShowOutletTypes = false;

    @track typeValue; // This variable is used to store selected type
    @track levelValue = 'O'; // This variable is used to store the labelValue
    @track showVehicleStateLevel = false;

    @track showModelVariant = false; // This variable is used to show/hide model variant search box
    @track showUserSpecific;
    @track tempVar;
    // This variable is used to show/hide model variant search box
    //@track showTypeCombobox=true; // This variable is used to show/hide type combobox
    @track modelSearchBoxLabel = ''; // This variable is used to pass modelSearchBoxLabel on basis of type selection
    @track accessoriesTypeSelected = false; // This variable is used to show/hide accessories type selected or not

    @api deviceFormFactor;
    showAccountSearch = false;
    consingneeCode = ''; // This variable is used to store Consingnee Code of selected dealer Account
    userType = 'E'; // This variable is used to account type Internal/External

    @track typeOptions = [];
	
	@track stateList=[];
    @track cityList=[];
    @track selectedState;
    @track selectedCity;
    @track dealerList;
    @track isATM;
    @track showTypeOptions;
	
	@wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: stateList })
    stateListValues({ data }) {
        if (data) {
            this.stateList = data.values;
        }
    }

    isParts = false;
    isMSILParts = false;
    selecetdProductType = '';
    productTypeOptions;
    showPartTypeSelect = false;
    showCheckStockButton = false;
    dealerCEOProfile = false;
    showDealerCEOParts = false;
	

    // GET Category__c Product PICKIST VALUES
    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: Category_FIELD })
    wiredCategoryValue({ error, data }) {
        if (data) {
            let allTypeOptions = [];
            allTypeOptions.push({ label: 'Accessories', value: 'Accessories' });

            for (var value of data.values) {
                allTypeOptions.push(value);
            }

            this.productTypeOptions = allTypeOptions;
            console.log('== productTypeOptions Data ', this.productTypeOptions);
        } else if (error) {
            console.log('== productTypeOptions Error ', error);
        }
    }

    @wire(getRecord, { recordId: CURRENTUSERID, fields: ['User.Profile.Name', 'User.Channel__c'] })
    currentUser({ error, data }) {
        if (data) {
            console.log('== Channel__c ', data);
            let userChennel = data.fields.Channel__c.value;
            this.typeOptions = [];
			this.showTypeOptions=true
            if (userChennel && userChennel === 'Commercial') {
                this.typeOptions.push({ label: 'Vehicle', value: 'C' });
            } else {
                this.typeOptions.push({ label: 'Car', value: 'C' });
            }
            this.typeOptions.push({ label: 'Accessories', value: 'A' });

            if (userChennel && userChennel === 'Parts') {
                this.isParts = true;
                this.typeOptions = [];
                this.typeOptions.push({ label: 'Parts and Accessories', value: 'A' });

                this.modelSearchBoxLabel = 'Part Name';
                this.placeHolder = 'Enter Part/Accessories Description or Code';
            }
            let profileName = data.fields.Profile.value.fields.Name.value;
            console.log('== profileName ', profileName);

            if(userChennel && userChennel === 'Maruti' && profileName && profileName === 'Maruti Parts/Accessories'){
                this.isParts = true;
                this.isMSILParts = true;
                console.log('== For Parts MSIL Only');
            }

            if(profileName && profileName === 'Dealer CEO/Owner' && this.productTypeOptions){
                this.dealerCEOProfile = true;
                for (var value of this.productTypeOptions) {
                    console.log('== productTypeOptions Values ', value);
                    if (value.value !== 'Accessories') {
                        this.typeOptions.push(value);
                    }
                }
                console.log('== this.typeOptions ', this.typeOptions);
            }
            console.log('== this.typeOptions ', this.typeOptions);
        }
        if (error) {
            console.log('== this.typeOptions error ', error);
        }
    }

    carsColumns = [
        // { label: 'Model', fieldName: 'ModelDescription' },
        {
            label: 'Colour',
            fieldName: 'ColorDescription'
        },
        { label: 'Variant', fieldName: 'Variant', initialWidth: 80 },
        {
            label: 'Available',
            fieldName: 'Available',
            type: 'number',
            cellAttributes: {
                alignment: 'left'
            }
        },
        {
            label: 'Allotted',
            fieldName: 'Allotted',
            type: 'number',
            cellAttributes: {
                alignment: 'left'
            }
        },
        {
            label: 'InTransit',
            fieldName: 'InTransit',
            type: 'number',
            cellAttributes: {
                alignment: 'left'
            }
        }
    ];
    carsColumns2 = [
        // { label: 'Model', fieldName: 'ModelDescription' },
        {
            label: 'Colour',
            fieldName: 'ColorDescription',
            initialWidth: 80
        },
        { label: 'Variant', fieldName: 'Variant', initialWidth: 80 },
        {
            label: 'Available',
            fieldName: 'AvailableCount',
            type: 'number',
            cellAttributes: {
                alignment: 'left'
            },
            initialWidth: 100
        },
        {
            label: 'Allotted',
            fieldName: 'AllottedCount',
            type: 'number',
            cellAttributes: {
                alignment: 'left'
            },
            initialWidth: 95
        },
        {
            label: 'InTransit',
            fieldName: 'TransitCount',
            type: 'number',
            cellAttributes: {
                alignment: 'left'
            },
            initialWidth: 95
        },
        {
            label: 'ParenGroup',
            fieldName: 'ParentGroup',
            type: 'String',
            cellAttributes: {
                alignment: 'left'
            },
            initialWidth: 110
        },
        {
            label: 'DealerMap',
            fieldName: 'DealerMapCode',
            type: 'number',
            cellAttributes: {
                alignment: 'left'
            },
            initialWidth: 110
        },
        {
            label: 'Location',
            fieldName: 'LocationCode',
            type: 'String',
            cellAttributes: {
                alignment: 'left'
            },
            initialWidth: 90
        },
        {
            label: 'StateCode',
            fieldName: 'StateCode',
            type: 'String',
            cellAttributes: {
                alignment: 'left'
            },
            initialWidth: 100
        }
    ];

    accessoriesColumns = [{
        label: 'Part Name',
        fieldName: 'PartDescription'
    },
    {
        label: 'Part Number',
        fieldName: 'PartNumber'
    },
    {
        label: 'Available Stock',
        fieldName: 'Quantity',
        type: 'number',
        cellAttributes: {
            alignment: 'left'
        }
    }
    ];

    /*
    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: model})
    typePicklistValuesModel({error, data}){
        if (data) {
            this.modelList=data;
        } else if(error){
            console.log('Error Occurred!!');
        }
    }
    */

    @wire(retriveOutletAndForCodeInfo)
    wiredCodeValue({
        data,
        error
    }) {
        if (data) {
            console.log('== Data retriveOutletAndForCodeInfo ', data);
            this.hideComponent = data.hideComponent;
            this.showAccountSearch = data.showAccountSearch;
            this.dealerMapCode = data.dealerMapCode;
            this.locationCode = data.locationCode;
            this.parentCode = data.parentCode;
            this.isATM=data.isATM;
            if(this.isATM){
                this.showTypeOptions=false;   
           }
            if (data.accountList !== undefined && data.accountList.length > 0) {
                this.tempShowOutletTypes = true;
                for (let i = 0; i < data.accountList.length; i++) {
                    let objInfo = {};
                    objInfo.value = data.accountList[i].Id;
                    let objLabel = data.accountList[i].Name +
                        (data.accountList[i].Dealer_Location__c ? (' - ' + data.accountList[i].Dealer_Location__c) : '') +
                        (data.accountList[i].BillingCity ? (' - ' + data.accountList[i].BillingCity) : '');
                    objInfo.label = objLabel;
                    this.dealerAccountOptions.push(objInfo);
                }
                /*eslint-disable  no-console*/
                console.log('== dealerAccountOptions ', this.dealerAccountOptions);
            }

        } else if (error) {
            /*eslint-disable  no-console*/
            console.log('== Code Error ', error);
        }
    }

    // @wire(retriveDelaerDataWhenParentSelected)
    /* wiredDealerValue({
         data,
         error
     }) {
         if (data) {
             console.log('== Code Dealer '+ data);
             this.dealerMapCode = data.dealerMapCode;
             this.locationCode = data.locationCode;
             this.parentCode = data.parentCode;
             this.tempShowOutletTypes = true;
         } else if (error) {
             /*eslint-disable  no-console*/
    // console.log('== Code Error ', error);
    // }
    //}*/

    connectedCallback() {
        this.setModelPicklist();
        /*Should be visible only to specific User*/
        checkUserDesignation()
            .then(result => {
                this.showUserSpecific = result;
                this.error = undefined;
            })
            .catch(error => {
                this.error = error;
                this.showUserSpecific = undefined;
            });

    }

    // Added as part of R1.2 Parts Development By Anuj

    handlePartTypeChange(event) {
        console.log('== Show Parts Search');
        this.showPartTypeSelect = true;
        this.selecetdProductType = event.target.value;
        this.handleRemove();
        this.showButton = false;
        this.showCheckStockButton = false;
    }

    handlePartCustomSearch(event) {
        console.log('== selecetdProductType ', this.selecetdProductType);
        console.log('== event.detail.searchTerm ', event.detail.searchTerm);

        retrieveParts({
            type: this.selecetdProductType,
            searchTerm: event.detail.searchTerm
        })
            .then(result => {
                console.log('== == ON Custom Search 3 Result ', result);
                this.records = result;
                let formatedResult = [];
                if (result) {
                    for (let data of result) {
                        if (data) {
                            let obj = {
                                id: data.Id,
                                title: data.Name,
                                ProductCode: data.ProductCode
                            };
                            formatedResult.push(obj);
                        }
                    }
                }
                console.log('== formatedResult ', formatedResult);
                if (formatedResult) {
                    this.lookupInputField.updateSearchResults(formatedResult);
                }

                this.showCheckStockButton = true;

            })
            .catch(error => {
                console.log('== == ON Custom Search 3 Error ', error);
                console.log('== == ON Custom Search 3 Result ', result);
            })

    }

    handlePartSelect(event) {
        console.log('== Select rec Id ', event.detail.value);

        if (event.detail.value) {
            const selectedRecordId = event.detail.value;
            this.selectedRecord = this.records.find(record => record.Id === selectedRecordId);
            console.log('== Selected Part Record ', this.selectedRecord);

            this.variantCode = this.records.find(record => record.Id === selectedRecordId).ProductCode;

        }else{
            this.showDetails = false;
        }

        this.showButton = true;

    }

    /*  retriveDelaerDataWhenParentSelected()
      .then(result => {
          console.log('== Code Dealer '+ data);
              this.dealerMapCode = result.dealerMapCode;
              this.locationCode = result.locationCode;
              this.parentCode = result.parentCode;
             // this.tempShowOutletTypes = true;
          this.error = undefined;
      })
      .catch(error => {
          this.error = error;
          this.showUserSpecific = undefined;
      });*/

    //Method to set the model picklist based on logged in user dealership type (Nexa , Arena ..)
    //Added as part of enhancement - DE 506
    setModelPicklist() {
        retriveModelList({})
            .then(result => {

                let keyArray = [];
                let valueArray = [];

                Object.keys(result).forEach(function (key) {
                    keyArray.push(key);
                });

                Object.values(result).forEach(function (val) {
                    valueArray.push(val);
                });

                /* eslint-disable no-console */

                for (let i = 0; i < valueArray.length; i++) {
                    let obj = {
                        label: keyArray[i],
                        value: valueArray[i]
                    }
                    this.modelList.push(obj);
                }

                this.isLoading = false;
            })
            .catch(error => {
                this.error = error;
                this.records = undefined;
            });
    }
   handleStateList(event){
        this.dealerAccountOptions=[];
        console.log('event.target.value '+event.target.value );
        getDealerList({
            state: event.target.value  
        })
        .then(result => {
            var citylist=[];
            if(result != undefined){
                this.dealerList=result.accountList;
                for (var key in result.mapOfCity) {
                    var keys=key;
                    if(key.length>15)
                    keys=key.substring(0,(key.length-3));
                    citylist.push({value:keys,label:result.mapOfCity[key]});
                    
                    console.log('key'+keys);
                  }
                  this.cityList=citylist;
            }
            this.showModelVariant = false;
            this.accessoriesTypeSelected=false;
            this.showTypeOptions=false;  
        this.selectedModel = undefined;
        this.selectedVariant = undefined;
        this.showAccountSearchUI = false;
        this.handleRemove();
            
        })
        .catch(error => {
            this.error = error;
            this.loadSpinner=false;
           this.tostMessage(UI_Error_Message, 0, 'Error', '');
        });
    }
    handleCityList(event){
        this.dealerAccountOptions=[];
        if (this.dealerList !== undefined && this.dealerList.length > 0) {
            var dealershipList =[];
            for (let i = 0; i < this.dealerList.length; i++) {
			if(this.dealerList[i].BillingCity){
                if(this.dealerList[i].BillingCity.length>15)
                this.dealerList[i].BillingCity=(this.dealerList[i].BillingCity).substring(0, (this.dealerList[i].BillingCity).length-3);
                if(this.dealerList[i].BillingCity===event.target.value){
                let objInfo = {};
                objInfo.value = this.dealerList[i].Id;
                let objLabel = this.dealerList[i].Name +
                    (this.dealerList[i].Dealer_Location__c ? (' - ' + this.dealerList[i].Dealer_Location__c) : '') +
                    (this.dealerList[i].BillingCity ? (' - ' + this.dealerList[i].BillingCity) : '');
                objInfo.label = objLabel;
                dealershipList.push(objInfo);
                }
			}
            }
            if(dealershipList.length>0 && this.isATM===true){
                this.showTypeOptions=true;   
                this.tempShowOutletTypes=true;
            }
            this.dealerAccountOptions=dealershipList;
        }
        
    }

    handleOutletchange(event) {
        getAccountList({
            name: event.detail.value
        })
            .then(result => {

                console.log(result);
                this.accountList = result.dataList;

            })
            .catch(error => {
                this.error = error;
                //this.loadSpinner=false;
                this.tostMessage(UI_Error_Message, 0, 'Error', '');
            });
    }

    //code updated by suraj get consigneeList()
    @track accLevel = 'E';
    get consigneeList() {

        return [{
            label: 'Dealer Level',
            value: 'E'
        },
        {
            label: 'Consignee Level',
            value: 'I'
        }
        ];
    }

   /* @track consigneeValueNew = '';
    handleConsigneeChange(event) {
        console.log('event.detail.value change >>> ', event.detail.value);
        this.accLevel = event.detail.value;
        console.log('this.accLevel before if change >>> ', this.accLevel);
        if (this.accLevel == 'I') {
            console.log('this.accLevel change >>> ', this.accLevel);
            retriveCOnsigneeCode()
                .then(result => {
                    this.consingneeCode = result;
                    console.log('retriveCOnsigneeCode change >>> ', this.consingneeCode);
                    // this.accountList = result.dataList;

                })
                .catch(error => {
                    //this.error = error;
                    //this.loadSpinner=false;
                    // this.tostMessage(UI_Error_Message, 0, 'Error', '');
                });
        }


    } */
    // This section is added by Satish on 13-05-2019 for Label stock check update
    /**Start** This function is used get Label options ****/
    get levelOptions() {

        return [{
            label: 'Outlet',
            value: 'O'
        },
        {
            label: 'Parent',
            value: 'S'
        }
        ];
        // alert(this.levelValue);


    }

    /*@wire(checkUserDesignation)
    wiredUser({data,error}){
         if(data){
            console.log('wired Data'+data);
                this.showUserSpecific=data.values;
         }

    }*/

    handleLevelChange(event) {
        //alert(event.detail.value);
        console.log('levelValue' + event.detail.value);
        this.levelValue = event.detail.value;
        console.log('levelValue' + this.levelValue);
        console.log('Current value of the input1: ' + event.target.value);
        if (event.detail.value === 'S') {
            //this.typeValue = event.detail.value;
            //this.typeValue=event.target.value;
            console.log('levelTypeValue' + this.typeValue);
            console.log('Current value of the input: ' + event.target.value);
            this.modelSearchBoxLabel = 'Search Label';
            this.accessoriesTypeSelected = false;
            this.placeHolder = 'choose label viz:-outlet,Parent'
        }
        if (event.detail.value === 'S' && this.showAccountSearch) {
            this.hideComponent = true;
            this.placeHolder = 'choose label viz:-outlet,Parent'
        }
        this.showModelVariant = true;
        //this.showTypeCombobox=false;

        this.selectedModel = undefined;
        this.selectedVariant = undefined;
        this.showAccountSearchUI = false;
        this.handleRemove();
    }
    /**End** This function is used get Label options ****/
    /***********************************************/
    handleVariantChange(event) {
        this.selectedVariant = event.detail.value;
    }
    handleModelChange(event) {
        this.selectedModel = event.detail.value;
        findVariantsForStockCheck({
            searchVar: this.selectedModel
        })
            .then(result => {
                //this.variants=result.dataList;
                this.variants = [];
                if (result.dataList.length > 0) {
                    result.dataList.forEach(element => {
                        this.variants.push({
                            label: element.Name,
                            value: element.Id
                        });
                        //this.variants = [...this.variants, {label:element.Name, value:element.ProductCode}];
                    })
                }
                console.log(this.variants);
            })
            .catch(error => {
                this.error = error;
                //this.loadSpinner=false;
                this.tostMessage(UI_Error_Message, 0, 'Error', '');
            });
    }
    tostMessage(message, code, status, id) {
        const showSuccess = new ShowToastEvent({
            title: status,
            message: message,
            variant: status,
        });
        this.dispatchEvent(showSuccess);
        if (code === 200) {
            this.redirct(id);
        }

    }
    get OutletNameWithConsingneeCode() {
        return this.selectedAccount.Name + ' ' + this.selectedAccount.Consingnee_Code__c;
    }
    /**** This function is used to handle onchange event of type dropdown  ****/

    get lookupInputField() {
        return this.template.querySelector("c-lookup-input-field");
    }

    get showAccSearch() {
        return this.typeValue === 'A' ? true : false;
    }

    get showVarSearch() {
        return this.typeValue === 'C' ? true : false;
    }

    get showVarSearchOnLabel() {
        return (this.levelValue === 'S' || this.levelValue === 'O') ? true : false;
    }

    handleOutletCustomSearch(event) {
        getAccountList({
            name: event.detail.searchTerm
        })
            .then(result => {

                console.log(result);
                this.accountList = result.dataList;
                let formatedResult = [];
                if (this.accountList) {
                    for (let data of this.accountList) {
                        if (data) {
                            let obj = {
                                id: data.Id,
                                title: data.Name + '   ' + data.Consingnee_Code__c
                            };
                            formatedResult.push(obj);
                        }
                    }
                }
                console.log('== formatedResult ', formatedResult);
                if (formatedResult) {
                    this.lookupInputField.updateSearchResults(formatedResult);
                }

            })
            .catch(error => {
                this.error = error;
                //this.loadSpinner=false;
                this.tostMessage(UI_Error_Message, 0, 'Error', '');
            });
    }

    handleOutletSelect(event) {
        console.log('Inside handleOutletSelect');
        this.isLoading = true;
        if(event.detail.value){
            const selectedRecordId = event.detail.value;
            console.log('== Record id ', selectedRecordId);
            console.log(this.accountList);
            this.selectedAccount = this.accountList.find(record => record.Id === selectedRecordId);
            this.dealerMapCode = this.selectedAccount.Dealer_Map_Code__c;
            this.locationCode = this.selectedAccount.Dealer_Location__c;
            this.parentCode = this.selectedAccount.Parent_Group__c;

            if(this.isMSILParts){
                this.userType = 'I';
                this.consingneeCode = this.selectedAccount.Consingnee_Code__c;
            }
        }else{
            this.showDetails = false;
        }
        this.showButton = true;
        this.isLoading = false;
    }

    handleCustomSearch(event) {
        console.log('== selectedVariant ', this.selectedVariant);
        console.log('== ON Custom Search 1 ', event.target.value);
        console.log('== ON Custom Search 2', event.detail.value);
        console.log('== ON Custom Search 3', event.detail.searchTerm);
        console.log('== ON Custom Search 8 type', this.typeValue);
        console.log('== 364 ON Custom Search 9 level', this.levelValue);
        /* if(this.levelValue==='S'){
             this.typeValue=this.levelValue;
            console.log('==367 ON Custom Search 7 level', this.levelValue);
         }*/
        console.log('== 369 ON Custom typee', this.typeValue);
        retriveModelVarient({
            name: event.detail.searchTerm,
            type: this.typeValue,
            variant: this.selectedVariant
        })
            .then(result => {
                console.log('== == ON Custom Search 3 Result ', result);
                this.records = result;
                let formatedResult = [];
                if (result) {
                    for (let data of result) {
                        if (data) {
                            let obj = {
                                id: data.Id,
                                title: data.Name,
                                ProductCode: data.ProductCode
                            };
                            formatedResult.push(obj);
                        }
                    }
                }
                console.log('== formatedResult ', formatedResult);
                if (formatedResult) {
                    this.lookupInputField.updateSearchResults(formatedResult);
                }

                if (result.length > 0 && this.typeValue === 'A' && this.tempShowOutletTypes) {
                    this.showOutletTypes = true;
                } else if (result.length > 0 && this.typeValue === 'A' && this.showAccountSearch) {
                    this.showAccountSearchUI = true;
                }
                console.log(this.showAccountSearchUI);
                this.showButton = true;

            })
            .catch(error => {
                console.log('== == ON Custom Search 3 Error ', error);
                console.log('== == ON Custom Search 3 Result ', result);
            })

    }

    handleProductSearch(event) {
        console.log('== Search Product ', event.target.value);
        console.log('== Deatil Value ', event.detail.value);
        console.log('== Detail Search term ', event.detail.searchTerm);
        console.log('== Detail handleProductSearch typeValue', this.typeValue);
        console.log('== Detail handleProductSearch typeValue', this.levelValue);
        /*if(this.levelValue==='S'){
            this.typeValue=this.levelValue;
           console.log('== ON Custom Search 3 level', this.levelValue);
        }*/

        if (event.detail.value) {
            const selectedRecordId = event.detail.value;
            this.selectedRecord = this.records.find(record => record.Id === selectedRecordId);
            console.log('== Selected Record ', this.selectedRecord);
            this.isLoading = true;
            if (this.typeValue === 'C' || this.typeValue === 'S') {
                retriveColorVarient({
                    productId: selectedRecordId
                })
                    .then(result => {
                        /*eslint-disable no-console */
                        console.log('== Color Varient Result  ', result);
                        this.colorVarientsRecords = result;

                        if (result.length > 0) {
                            this.variantCode = result[0].Variant__r.ProductCode;
                        }

                        this.colorOptions = [];
                        this.colorOptions.push({
                            label: 'All',
                            value: '%25'
                        });

                        for (let i = 0; i < result.length; i++) {
                            let objInfo = {};
                            objInfo.value = result[i].Color_Code__c;
                            objInfo.label = result[i].Name;
                            this.colorOptions.push(objInfo);
                        }
                        /*eslint-disable no-console */
                        console.log('== Final color Options  ', this.colorOptions);
                        //this.showButton = true;
                        this.isLoading = false;
                        this.records = undefined;
                    })
                    .catch(error => {
                        /*eslint-disable no-console */
                        console.log('== colorOptions Error ', error);
                        this.isLoading = false;
                    })
            } else {
                this.variantCode = this.records.find(record => record.Id === selectedRecordId).ProductCode;
                this.isLoading = false;
            }
        } else if (event.detail.value === undefined) {
            this.handleRemove();
        }
    }


    handleTypeChange(event) {
        this.showDealerCEOParts = false;
        this.typeValue = event.detail.value;
        if (event.detail.value === 'C') {
            this.modelSearchBoxLabel = 'Search Model Variant';
            this.accessoriesTypeSelected = false;
            this.placeHolder = 'Enter Variant Name e.g. Spresso vxi , Baleno Delta';
        } else if (event.detail.value === 'A') {
            this.modelSearchBoxLabel = 'Part Name';
            this.accessoriesTypeSelected = true;
            //this.showButton=true;
            this.placeHolder = 'Enter Accessories Description or Accessories Code';
        }
        if (event.detail.value === 'C' && this.showAccountSearch) {
            this.hideComponent = true;
            this.placeHolder = 'Enter Variant Name e.g. Spresso vxi , Baleno Delta';
        }
        this.showModelVariant = true;
        //this.showTypeCombobox=false;

        console.log('== handle Type value ', event.detail.value);
        if (event.detail.value !== 'C' && event.detail.value !== 'A') {
            this.selecetdProductType = event.detail.value;
            this.showPartTypeSelect = true;
            this.showDealerCEOParts = true;
            this.modelSearchBoxLabel = 'Part Name';
            this.placeHolder = 'Enter Part/Accessories Description or Code';
        }

        this.selectedModel = undefined;
        this.selectedVariant = undefined;
        this.showAccountSearchUI = false;
        this.handleRemove();
    }
    /**************************************************************************/

    handleOnChange(event) {
        this.isLoading = true;
        //event.preventDefault();
        const searchKey = event.detail.value;
        //this.records = null;
        /* eslint-disable no-console */

        /* Call the Salesforce Apex class method to find the Records */
        retriveModelVarient({
            name: searchKey,
            type: this.typeValue,
            variant: this.selectedVariant
        })
            .then(result => {
                /* eslint-disable no-console */
                this.records = result;
                this.error = undefined;
                if (result.length > 0 && this.typeValue === 'A' && this.tempShowOutletTypes) {
                    this.showOutletTypes = true;
                } else if (result.length > 0 && this.typeValue === 'A' && this.showAccountSearch) {
                    this.showAccountSearchUI = true;
                }
                this.showButton = true;
                this.isLoading = false;
            })
            .catch(error => {
                this.error = error;
                this.records = undefined;
            });
    }

    handleSelect(event) {
        this.isLoading = true;
        const selectedRecordId = event.detail;
        /* eslint-disable no-console*/
        console.log('== Record id ', selectedRecordId);

        this.selectedRecord = this.records.find(record => record.Id === selectedRecordId);
        console.log('== Selected Record ', this.selectedRecord);

        if (this.typeValue === 'C' || this.typeValue === 'S') {
            retriveColorVarient({
                productId: selectedRecordId
            })
                .then(result => {
                    /*eslint-disable no-console */
                    console.log('== Color Varient Result  ', result);
                    this.colorVarientsRecords = result;

                    if (result.length > 0) {
                        this.variantCode = result[0].Variant__r.ProductCode;
                    }

                    this.colorOptions = [];
                    this.colorOptions.push({
                        label: 'All',
                        value: '%25'
                    });

                    for (let i = 0; i < result.length; i++) {
                        let objInfo = {};
                        objInfo.value = result[i].Color_Code__c;
                        objInfo.label = result[i].Name;
                        this.colorOptions.push(objInfo);
                    }
                    /*eslint-disable no-console */
                    console.log('== Final color Options  ', this.colorOptions);
                    //this.showButton = true;
                    this.isLoading = false;
                    this.records = undefined;
                })
                .catch(error => {
                    /*eslint-disable no-console */
                    console.log('== colorOptions Error ', error);
                    this.isLoading = false;
                })
        } else {
            this.variantCode = this.records.find(record => record.Id === selectedRecordId).ProductCode;
            this.isLoading = false;
        }


    }

    handleDealerAccountSelect(event) {
        this.isLoading = true;
        this.showButton = true;
        this.showDetails = false;
        // this.selectedOutletType = event.target.value;
        /* eslint-disable no-console*/
        console.log('== Selected Outlet type ', event.target.value);

        retriveOutletAndForCodeFromAccount({
            accountId: event.target.value
        })
            .then(result => {
                /*eslint-disable no-console */
                console.log('== Outlet And For Code Result  ', result);
                this.dealerMapCode = result.dealerMapCode;
                this.locationCode = result.locationCode;
                this.parentCode = result.parentCode;
                this.consingneeCode = result.consingneeCode;
                this.userType = 'I';
                this.isLoading = false;
            })
            .catch(error => {
                /*eslint-disable no-console */
                console.log('== colorOptions Error ', error);
                this.isLoading = false;
            })
    }

    handleColor(event) {
        event.preventDefault();

        this.showDetails = false;
        this.selectedOutletType = undefined;

        if (this.tempShowOutletTypes && this.levelValue != 'S') {

            // if (this.tempShowOutletTypes){
            this.showOutletTypes = true;
            this.showButton = false;
        } else if (this.levelValue == 'S') {
            this.showOutletTypes = false;
            console.log('== Code Dealer Result' + this.parentCode);
            console.log('==805 Code Dealer Result' + this.dealerMapCode + "locationCode" + this.locationCode);
            retriveDelaerDataWhenParentSelected()
                .then(result => {
                    console.log('== Code Dealer Result' + result);
                    console.log('==805 Code Dealer Result' + result.dealerMapCode + "locationCode" + result.locationCode);
                    this.dealerMapCode = result.dealerMapCode;
                    this.locationCode = result.locationCode;
                    this.parentCode = result.parentCode;
                    console.log('== 809 Code Dealer Result' + this.dealerMapCode + "locationCode" + this.locationCode);
                });
            this.showButton = true;
        } else {
            this.showOutletTypes = false;
            console.log('== Code Dealer Result' + this.parentCode);
            console.log('==816 Code Dealer Result' + this.dealerMapCode + "locationCode" + this.locationCode);
            this.showButton = true;
        }

        this.colorCode = event.target.value;
    }

    handleRemove() {
        this.selectedRecord = undefined;
        this.showOutletTypes = false;
        this.showDetails = false;
        this.showButton = false;
        this.records = undefined;
        this.error = undefined;
        this.showCheckStockButton = false;
    }

    handleOutletRemove(event) {
        event.preventDefault();
        //this.selectedRecord = undefined;
        //this.showOutletTypes = false;
        //this.showDetails = false;
        //this.accessoriesTypeSelected=false;
        this.selectedAccount = undefined;
        this.showButton = false;

        //this.records = undefined;
        //this.error = undefined;
    }

    // After Search Component Data

    checkStock() {
        /*eslint-disable  no-console*/

        this.isLoading = true;


        console.log('== VariantCode ', this.variantCode);
        console.log('== ColorCode ', this.colorCode);
        console.log('== dealerMapCode ', this.dealerMapCode);
        console.log('== locationCode ', this.locationCode);
        console.log('== parentCode ', this.parentCode);
        console.log('== productType ', this.typeValue);
        console.log('== levelType ', this.levelValue);

        console.log('== this.userType ', this.userType);
        console.log('== this.consingneeCode ', this.consingneeCode);

        if (this.levelValue === 'S') {
            this.typeValue = this.levelValue;
            console.log('==808 ON Custom Search 3 level', this.levelValue);
        }
        console.log('==861 Outside', this.typeValue);

        let selectedTypeValue = this.typeValue;

        if (this.isParts) {
            selectedTypeValue = 'A';
        }
        if (this.showDealerCEOParts) {
            selectedTypeValue = 'A';
        }

        console.log('== selectedTypeValue ', selectedTypeValue);

        let stoctCheckQueryData = {
            "apiType": "Product Stock List",
            "variantCode": this.variantCode,
            "colorCode": this.colorCode,
            "dealerMapCode": this.dealerMapCode,
            "locationCode": this.locationCode,
            "parentCode": this.parentCode,
            "productType": selectedTypeValue,
            "consingneeCode": this.consingneeCode,
            "userType": this.userType
        };
        console.log('== In Fetch Result Query ==', stoctCheckQueryData);
        getProductStockList({
            queryData: JSON.stringify(stoctCheckQueryData)
        })
            .then(result => {

                /*eslint-disable  no-console*/
                console.log('== In Fetch Result ', result);
                if (result === UI_Error_Message) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: '',
                            message: UI_Error_Message,
                            variant: 'error'
                        })
                    );
                } else {
                    let dataValue = JSON.parse(result);
                    //let dataValue=JSON.parse('{"Variant": "MARUTI ERTIGA VXI CNG 1.5L 5MT", "DealerMapCode": 10749, "TransitCount": 0, "AllottedCount": 0, "AvailableCount": 1, "Model": "ER", "ParentGroup": "DDMOT", "LocationCode": "MAY", "ModelDescription": "NEW ERTIGA", "ColorCode": "ZHJ", "ColorDescription": "PEARL  ARCTIC WHITE", "StateCode": "DL", "VariantCode": "ERRCAV1" }') ;
                    console.log('dataValue==' + dataValue);
                    this.responseResult = dataValue.productStockList;
                    console.log(this.responseResult.length);
                    if (this.responseResult.length === 0) {
                        this.showNoDataError = true;
                    } else {
                        this.showNoDataError = false;
                    }
                    console.log('== ON Custom Search 4 level', this.levelValue);
                    if (this.levelValue === 'S') {
                        //this.typeValue=this.levelValue;
                        this.showVehicleStateLevel = true;
                        console.log('== ON Custom Search 10 level', this.levelValue);
                    } else {
                        //this.typeValue=this.levelValue;
                        this.showVehicleStateLevel = false;
                        console.log('== ON Custom Search false', this.levelValue);
                    }
                    console.log(this.showNoDataError);
                    console.log('== List Result ', this.responseResult);
                    this.showDetails = true;
                }
                this.isLoading = false;
            })
            .catch(error => {
                this.isLoading = false;
                /*eslint-disable  no-console*/
                console.log('== In Fetch Error Result', error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: '',
                        message: UI_Error_Message,
                        variant: 'error'
                    })
                );
            })
    }

    get browserFormFactor() {
        return this.deviceFormFactor === 'DESKTOP' ? true : false;
    }

}