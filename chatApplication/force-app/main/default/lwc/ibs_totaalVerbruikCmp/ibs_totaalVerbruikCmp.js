import { LightningElement, api, track } from 'lwc';
import getRecordsFromSF from '@salesforce/apex/IBSReadOnlyRelatedListController.getSobjectData';

export default class Ibs_totaalVerbruikCmp extends LightningElement {
    @api recordId;
    @api parentType;
    objectName = 'Mobile_Usage__c';
    fieldsApiName = 'Totale_verbruikskosten__c,Groepsbundel__c,Groepsbundel_verbruikt__c,Groepsbundel_totaal__c';
    formualFld1 = 'Groepsbundel_totaal__c,Groepsbundel_verbruikt__c';
    paretnFieldApiName = 'Account__c';
    relatedListTitle = 'Totaal verbruik';
    iconName = 'custom:custom11'
    @track records;
    @track showSpinner = false;
    @track TotaleVerbruikskosten = '';
    
    connectedCallback(){
        this.getRecords();
    }

    getRecords() {
        this.showSpinner = true;
        getRecordsFromSF({
            objectApiName: this.objectName,
            fieldNames: this.fieldsApiName,
            recordId: this.recordId,
            parentFieldApiName: this.paretnFieldApiName,
            parentType: this.parentType,
            whereClause: '',
            orderBy: '',
            isFromEvent: false
        })
            .then(result => {
                console.log('result', result);
                this.records = [];
                if (result != null) {
                    this.TotaleVerbruikskosten = result[0].Totale_verbruikskosten__c;
                    result.forEach(ele => {
                        if(ele.Totale_verbruikskosten__c){
                            delete ele.Totale_verbruikskosten__c;
                        }
                    });

                    this.records = result;
                } else {
                    this.records = null;
                }
                this.showSpinner = false;
            }).catch(error => {
                this.showSpinner = false;
                console.log('error', error);
            });
    }

    @api refershList() {
        this.records = [];
        this.showSpinner = true;
        this.getRecords();
    }
}