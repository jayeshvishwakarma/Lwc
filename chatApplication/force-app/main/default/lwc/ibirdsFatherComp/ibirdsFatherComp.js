import { LightningElement } from 'lwc';

export default class IbirdsFatherComp extends LightningElement {

    sonName;
    daughterName;
    constructor()
    {
        super();
        this.sonName='Rohit Sharma';
        this.daughterName='Virat Kohli';
    }
}