import { LightningElement } from 'lwc';

export default class CustomerCarDetails extends LightningElement {
    lang = 'fr_CA';
    leadValue;
    isLeadIntrested;
    isLeadNotIntrested;

    sameCar;
    isSameCar;
    isNotSameCar;

    customerIntrstVal;
    customerInterested;
    customerNotInterested;

    fuelTypeVal;

    carExchangeVal;
    isCarExchange;

    isTestDrive;
    testDriveVal;

    testDriveTypeVal;

    carPlanVal;

    customerTypeVal;

    carBudgetVal;

    customerQueries;
    isCustomerQueries;

    get options() {
        return [
            { label: '--None--', value: 'noSelection' },
            { label: 'Yes', value: 'yes' },
            { label: 'No', value: 'no' },
        ];
    }

    handleChangeLead(event) {
        this.leadValue = event.target.value;
        this.isLeadIntrested = this.leadValue == 'yes' ? true : false;
        this.isLeadNotIntrested = this.leadValue == 'no' ? true : false;
    }

    handleChangeSameCar(event){
        this.sameCar = event.target.value;
        this.isSameCar = event.target.value == 'yes' || event.target.value == 'no'? true : false;
        this.isNotSameCar = event.target.value == 'no' ? true : false;
    }

    handleInterestedCustomer(event){
        this.customerIntrstVal = event.target.value;
        this.customerInterested = event.target.value == 'yes' ? true : false;
        this.customerNotInterested = event.target.value == 'no' ? true : false;
    }

    get fuelOptions(){
        return [
            { label: '--None--', value: 'noSelection' },
            {label: 'Petrol', value: 'petrol'},
            {label: 'Diesel', value: 'diesel'},
        ];
    }

    handleFuelType(event){
        this.fuelTypeVal = event.target.value;
    }

    handleExchangeCar(event){
        this.carExchangeVal = event.target.value;
        this.isCarExchange = event.target.value == 'yes' ? true : false;
    }

    handleTestDrive(event){
        this.testDriveVal = event.target.value;
        this.isTestDrive = event.target.value == 'yes' ? true : false;
    }

    get testDriveOptions(){
        return [
            { label: '--None--', value: 'noSelection'},
            {label: '<=7 days', value: '<=7 days'},
            {label: '8-15 days', value: '8-15 days'},
            {label: '>15 days', value: '>15 days'},
            {label: 'No test drv Reqd', value: 'No test drv Reqd'},
            {label: 'Not Defined', value: 'Not Defined'},
        ];
    }

    handleTestDriveType(event){
        this.testDriveTypeVal = event.target.value;
    }

    get carPlanOptions(){
        return [
            { label: '--None--', value: 'noSelection'},
            { label: '<= 1 month', value: '<= 1 month'},
            { label: '1-2 months', value: '1-2 months'},
            { label: '2-3 months', value: '2-3 months'},
            { label: 'after 3 Months', value: 'after 3 Months'},
        ];
    }

    handleCarPlanning(event){
        this.carPlanVal = event.target.value;
    }

    get customerTypeOptions(){
        return [
            { label: '--None--', value: 'noSelection'},
            { label: 'Hot', value: 'Hot'},
            { label: 'Warm', value: 'Warm'},
            { label: 'Cold', value: 'Cold'},
            { label: 'DDC', value: 'DDC'},
        ];
    }

    handleCustomerType(event){
        this.customerTypeVal = event.target.value;
    }

    get carBudgetOptions(){
        return [
            { label: '--None--', value: 'noSelection'},
            { label: '<2lac', value: '<2lac'},
            { label: '2-3 lac', value: '2-3 lac'},
            { label: '3-4 lac', value: '3-4 lac'},
            { label: '4-5 lac', value: '4-5 lac'},
            { label: '>5lac', value: '>5lac'},
        ];
    }

    handleCarBudget(event){
        this.carBudgetVal = event.target.value;
    }

    handleCustomerQueries(event){
        this.customerQueries = event.target.value;
        this.isCustomerQueries = this.customerQueries == 'yes' ? true : false;
    }

    
    submitLeadResponce() {
        let isAllValid = Array.from(this.template.querySelectorAll('.validate-inputs'))
            .reduce((validSoFar, inputCmp) => {
                return validSoFar && inputCmp.checkValidity();
            }, true);
        console.log('isValid : ',isAllValid);
        if (isAllValid) {
            alert('All form entries look valid. Ready to submit!');
        } else {
            alert('Please fill the required entries and try again.');
        }
    }
}