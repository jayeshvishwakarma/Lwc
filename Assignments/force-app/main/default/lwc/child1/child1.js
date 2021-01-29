import {LightningElement,api} from 'lwc';

export default class Child extends LightningElement{
    recievedMsg;
    @api msgRecieved(recMsgFromParent)
    {
        this.recievedMsg=recMsgFromParent;
    }
}