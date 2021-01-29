import { LightningElement, wire } from 'lwc';
import contactRecords from '@salesforce/apex/ServerContactController.contactRecords';
import getfieldsNames from '@salesforce/apex/ServerContactController.fieldsNames';
//import {fieldColumns} from './utility/share.js';

export default class ServerContact extends LightningElement {
    cityOptions=[];
    selectedCity;
    records;
    error;
    constructor()
    {
        super();
        this.selectedCity='All';
        this.cityOptions = [{label : "All Cities",value : "All"}];
    }

    handleChange(event)
    {
        this.selectedCity = event.target.value;
        console.log('=============='+this.selectedCity);
    }

    @wire (contactRecords,{cityName : '$selectedCity'}
        ) lstContactRecords({error,data}) {
            if(data){
               this.records = data;
                console.log("if me Aya============");
               if(data.length > 1){ 

                                     this.cityOptions=this.cityOptions.concat(data.map(element => 
                                        ({
                                          label: element.MailingCity,
                                          value: element.MailingCity,
                                          sortable : true
                                        })));
                                        //this.cityOptions.push({label : "All Cities" ,value : "All",sortable : true});
 
                                 }
            
            } else if(error)
            {
                this.error=error;
                console.log(error);
            }
        }

        @wire(getfieldsNames) lstFieldNames;

    
    /* wire property (variable) ye jo apna lstContactRecords jo variable h ye access krne ke kaam ayga 
    kyuki udhar jo data ya error aygi wo esme store hogi
     lstContactRecords.data
     lstContactRecords.error
    */
}