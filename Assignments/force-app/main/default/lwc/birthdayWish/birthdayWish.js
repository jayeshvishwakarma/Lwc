import { LightningElement, api } from 'lwc';

export default class BirthdayWish extends LightningElement {

    @api isShow;
    @api imageUrl;
    @api firstName;
    @api lastName;
    @api age;
    @api phone;
    @api emailId;
    @api city;
    @api birthdayMessage;

}