import { api, LightningElement } from 'lwc';

export default class Button extends LightningElement {

    @api label;
    @api icon;

    handleButton(){
        this.dispatchEvent(new CustomEvent('buttonclick',{
            bubble : true
        }))
    }
}