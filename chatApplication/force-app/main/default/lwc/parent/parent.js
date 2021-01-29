import { LightningElement, track, api } from 'lwc';
import {makeData} from './utility/share.js';

export default class Parent extends LightningElement {
    countriesCatched;
    total;
    label;
   
    get countries()
    {
            return makeData;
    }

    handleUpload(event)
    {
        this.label='Countries Visited : ';
        this.countriesCatched=event.detail.countries.split(',');
        this.total='Total - '+this.countriesCatched.length;
        if(this.countriesCatched==''){
            this.label='Countries Visited : None';
            this.total='Total - '+0;
        }
    }
}