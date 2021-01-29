import { LightningElement,api } from 'lwc';

export default class IbirdsRecordForm extends LightningElement {
    @api recordId;
    @api objectApiName;
    fields;

    constructor()
    {
        super();
        this.fields = ["FirstName" , "LastName", "Phone", "Email"];
    }

    handleSubmit()
    {

    }

    handleSave()
    {

    }

    handleError()
    {
        
    }
}