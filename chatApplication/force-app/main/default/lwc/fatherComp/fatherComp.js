import { LightningElement, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';

export default class FatherComp extends LightningElement {
    sonName;
    daughterName;
    constructor()
    {
        super()
        this.sonName="Harsh Beniwal"
        this.daughterName="Faizal Khan";
    }

    @wire(CurrentPageReference) pageRef;
}