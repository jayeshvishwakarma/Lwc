import { LightningElement } from 'lwc';
import {options,fieldHeading} from './utility/share.js';
import getContactRecords from '@salesforce/apex/ServerContactController.contactRecords';

export default class ImperativeComp extends LightningElement {

    selectedCity;
    lstContactRecords;
    error;
    constructor()
    {
        super();
        this.selectedCity = "all";
        this.lstContactRecords=null;
        this.error=null;
    }
    get cityOptions()
    {
        return options;
    }

    get fieldNames()
    {
        return fieldHeading;
    }

    handleRefresh()
    {
        console.log("Chala button to");
        
        // javaScript callBack method promise method
        getContactRecords({cityName : this.selectedCity})
        .then(       
                    (data) => {
                                this.lstContactRecords=data;
                              }
            )             //function pass krenge as an argument
        .catch( 
                    (error) => {
                                 this.error=error;
                               }
            );           //function pass krenge as an argument
    }
}