import { LightningElement ,api,wire} from 'lwc';
import {fireEvent,registerListener,unregisterAllListeners} from 'c/pubsub';
import { CurrentPageReference } from 'lightning/navigation';

export default class IbirdsDaughterComp extends LightningElement {
    @api daughterName;
    messageRecieved;

    @wire(CurrentPageReference) pageRef;

    get daughterDetail()
    {
        return 'Daughter : '+this.daughterName;
    }
    
    handleSend()
    {
        const message = this.template.querySelector('lightning-input').value;
        fireEvent(this.pageRef, 'sendmessage', message +'---- by - '+this.daughterName);
    }
    
    connectedCallback()
    {
        console.log('connected call back gaughter Wala=========');
        registerListener('replymessage',this.handleMessageRecieved,this);
    }

    disconnectedCallback()
    {
        console.log('Disconnected call back daughter wala -----========');
        unregisterAllListeners(this);
    }

    handleMessageRecieved(parcel)
    {
        this.messageRecieved = parcel;
    }
}