import { LightningElement, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation'
import { registerListener , unregisterAllListeners} from 'c/pubsub';
import getStudentRecord from '@salesforce/apex/ServerStudentController.studentRecord';

export default class CompThird extends LightningElement {

    idRecieved;

    @wire(CurrentPageReference) pageRef;

    connectedCallback()
    {
        registerListener('sendIdToDetail',this.handleRecieved,this);
    }
    disconnectedCallback()
    {
        unregisterAllListeners(this);
    }

    handleRecieved(parcel)
    {
        this.idRecieved= parcel;
        console.log('==================='+this.idRecieved);
    }

    @wire(getStudentRecord,{emailId : '$idRecieved'}) student;
}