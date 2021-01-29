import { LightningElement,wire,api } from 'lwc';
import { fireEvent } from 'c/pubsub';
import { CurrentPageReference } from 'lightning/navigation';

export default class DaughterComp extends LightningElement {

    @api daughterName;

    get daughterDetails()
    {
        return "Daughter : "+this.daughterName;
    }
    
    @wire( CurrentPageReference ) pageRef;

    handleSend()
    {
        const message = this.template.querySelector("lightning-input").value;
        fireEvent( this.pageRef, 'sendmessage', message +" by - "+ this.daughterName);
    }
}