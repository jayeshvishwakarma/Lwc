import { LightningElement, wire } from 'lwc';
import {fireEvent} from 'c/pubsub';
import {CurrentPageReference} from 'lightning/navigation';
//import getStudentRecords from '@salesforce/apex/ServerStudentController.getAllRecords';

export default class CompFirst extends LightningElement {
    lstStudents;
    error;

    @wire(CurrentPageReference) pageRef;

    constructor()
    {
        super();
       // this.lstStudents=null;
        //this.handleRefresh();
    }

    handleChange()
    {
        const value = this.template.querySelector('lightning-input').value;
        console.log(value);
        fireEvent(this.pageRef,'sendValueToSecondComp',value);
    }

   /* handleRefresh()
    {
        getStudentRecords().then((data)=>{this.lstStudents=data;}).catch((error)=>{this.error=error;});
        console.log('=================+++++++'+this.lstStudents);
        console.log('================='+this.error);
    }*/
}