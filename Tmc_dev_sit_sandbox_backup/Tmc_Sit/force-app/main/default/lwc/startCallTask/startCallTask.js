import { LightningElement,api } from 'lwc';

export default class StartCallTask extends LightningElement {

    @api recordId;
    makeVisible = false;

    handleClick(event) {

        console.log(this.recordId);
        this.makeVisible = true;
    }

}