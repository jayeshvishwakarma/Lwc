import { LightningElement, api } from 'lwc';

export default class IbirdsIdName extends LightningElement {
    @api recordId;
    @api objectApiName;
    @api recordApiName;

    constructor()
    {
        super();
    }
}