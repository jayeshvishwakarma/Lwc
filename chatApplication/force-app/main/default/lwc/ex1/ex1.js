import { LightningElement } from 'lwc';
import getAccounts from '@salesforce/apex/ServerAccContoller.getAccounts';

export default class Ex1 extends LightningElement {

    searchAccount = '';
    accountRecords;
    error;
    constructor(){
        super();
        this.accountRecords = null;
        this.error = null;
    }

   handleChange(event){
       console.log("Handle Change Chala");
       this.searchAccount = event.target.value;
       console.log(this.searchAccount);
   }

   get fieldNames()
    {
        return [ 
                 {label: "Name",fieldName : "Name", type : "text"},
                 {label: "Phone",fieldName : "Phone", type : "phone"},
                 {label : "Created Date",fieldName : "CreatedDate",type : "date"}
               ];
    }

   handleClick(){
       console.log("HandleClick");

    getAccounts({recName : this.searchAccount})
    .then(       
        (data) => {
                    console.log(data);
                    this.accountRecords=data;
                  }
        )             //function pass krenge as an argument
    .catch( 
        (error) => {
            console.log(error);
                     this.error=error;
                   }
          );   
   }


}