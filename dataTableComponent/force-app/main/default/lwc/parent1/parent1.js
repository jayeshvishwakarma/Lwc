import {LightningElement} from 'lwc';

export default class Parent1 extends LightningElement{

    handleUpload(event)
    {
        console.log("parent");
        const recMsgFromBro = event.detail.sendingMsg.msg+" : "+ "by - " +event.detail.sendingMsg.name;
        const childObj = this.template.querySelector("c-child1[data-my-id=childComp1]");
        childObj.msgRecieved(recMsgFromBro);
    }

}