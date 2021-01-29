import { LightningElement,api,wire } from 'lwc';
import {CurrentPageReference} from 'lightning/navigation';
import {registerListener,unregisterAllListeners,fireEvent} from 'c/pubsub';

export default class IbirdsSonComp extends LightningElement {
    @api sonName;
    message;

    get sonDetail()
    {
        return 'Son : '+this.sonName;
    }

    @wire(CurrentPageReference) pageRef;

    connectedCallback()
    {
        console.log('Connected Call back Son ka========');
        registerListener('sendmessage',this.handleMessageRecieved ,this);
    }

    disconnectedCallback()
    {
        console.log('disconnected Call back son ka=======');
        unregisterAllListeners(this);
    }

    handleMessageRecieved(parcel)
    {
        console.log('handle message recieved son ka=========');
        this.message = parcel;
    }

    handleReply()
    {
        const replyMessage = this.template.querySelector('lightning-input').value;
        fireEvent(this.pageRef,'replymessage',replyMessage+'---- by - '+this.sonName);
    }
}