/* eslint-disable no-console */
import { LightningElement, track } from 'lwc';
 
export default class LightningDropDown extends LightningElement {
@track selectedObject = 'Opportunity';
@track defaultValue= 'Enquiry';

 
get objectOptions() {
    return [
             { label: 'Enquiry', value: 'Opportunity' },     
             { label: 'Event', value: 'Campaign' }
             
           ];
}
 
handleChange(event) {
  
        this.selectedObject = event.currentTarget.dataset.name;
        if(this.selectedObject === 'Opportunity'){
        this.defaultValue = 'Enquiry';
        }else {
          this.defaultValue = 'Event';
        }
       
        this.focus=false;
     }


     @track focus = false;
     focusHandler(){
         this.focus=true;
     }
  
     blurHandler(){
         this.focus=false;
     }

    
}