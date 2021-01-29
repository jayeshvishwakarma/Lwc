import { LightningElement } from 'lwc';

export default class ChatApp extends LightningElement {

    
    handleObjectRecieved(event){
        const obj = event.detail;
        const sendToChatWindow = this.template.querySelector("c-chat-window[data-my-id=chatUsers]");
        sendToChatWindow.handleParcelRecievedFromParent(obj);
    }
}