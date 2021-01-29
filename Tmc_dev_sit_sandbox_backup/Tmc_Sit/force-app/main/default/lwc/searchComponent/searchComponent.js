import { LightningElement, track, api } from 'lwc';

export default class SearchComponent extends LightningElement {
    @api label;
    @api placeHolderName='Enter Variant Name';
    @api reqiredCheck=false;
    @track searchKey;
    @api name;
    handleChange(event){
        /* eslint-disable no-console */
        console.log('Search Event Started ', event.target.value);
        const searchKey = event.target.value;
        /* eslint-disable no-console */
        event.preventDefault();
        const searchEvent = new CustomEvent(
            'change', 
            { 
                detail : searchKey
            }
        );
        this.dispatchEvent(searchEvent);
    }
}