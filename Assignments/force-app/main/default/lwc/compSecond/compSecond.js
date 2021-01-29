import { LightningElement, wire } from 'lwc';
import {fireEvent,registerListener,unregisterAllListeners} from 'c/pubsub';
import {CurrentPageReference} from 'lightning/navigation';
import getStudentsRecords from '@salesforce/apex/ServerStudentController.studentRecords';

export default class CompSecond extends LightningElement {

    valueRecieved;

    @wire(CurrentPageReference) pageRef;

    connectedCallback()
    {
        console.log('=========Connected calll back Comp Second');
        registerListener('sendValueToSecondComp',this.handleMessageRecieved,this);
    }

    disconnectedCallback()
    {
        unregisterAllListeners(this);
    }

    handleMessageRecieved(parcel)
    {
        this.valueRecieved = parcel;
    }

    @wire(getStudentsRecords,{cityName : '$valueRecieved'}) lstStudents;

    handleClick(event)
    {
        const IdOfRecord =event.target.value;
        console.log('================+++++++++++++++'+IdOfRecord);
        fireEvent(this.pageRef,'sendIdToDetail',IdOfRecord);
    }

}