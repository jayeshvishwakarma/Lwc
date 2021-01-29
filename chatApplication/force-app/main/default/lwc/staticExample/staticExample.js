import { LightningElement } from 'lwc';
import IPHONE12_IMAGE from '@salesforce/resourceUrl/Iphone12';
import My_MESSAGE from '@salesforce/label/c.Message_Label';

export default class StaticExample extends LightningElement {
    imageUrl;
    message;
    constructor()
    {
        super();
        this.message = My_MESSAGE;
        this.imageUrl = IPHONE12_IMAGE;
    }
}