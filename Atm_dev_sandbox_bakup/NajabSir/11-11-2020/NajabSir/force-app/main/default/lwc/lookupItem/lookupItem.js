import { LightningElement, api } from 'lwc';  
 export default class LookupItem extends LightningElement {  
   @api record;  
   // This method handles the selection of lookup value  
   // eslint-disable-next-line no-unused-vars
   handleSelect(event) {  
     // Event will be triggerred and bubbled to parent and grandparent.  
     // Check the parameters passed.  
     const selectEvent = new CustomEvent('lookupselect', {  
       detail: this.record,  
       bubbles: true,  
       composed: true  
     });  
     // Fire the custom event  
     this.dispatchEvent(selectEvent);  
   }  
 }