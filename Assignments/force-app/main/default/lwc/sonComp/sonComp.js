import { LightningElement,api,wire } from 'lwc';
import { CurrentPageReference} from 'lightning/navigation';
import { registerListener, unregisterAllListeners,fireEvent } from 'c/pubsub';

export default class SonComp extends LightningElement {
    @api sonName;
    message;

    constructor()
    {
        super();
        this.message=null;
    }

    get sonDetails()
    {
        return "Son : "+this.sonName;
    }

    @wire( CurrentPageReference ) pageRef;

    connectedCallback()
    {
        registerListener('sendmessage', this.handleMessageRecieved, this);
    }

    disconnectedCallback()
    {
        unregisterAllListeners(this);
    }

    handleMessageRecieved(parcel)
    {
        this.message = parcel;
    }


}