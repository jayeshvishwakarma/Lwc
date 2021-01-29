/* eslint-disable eqeqeq */
import { LightningElement, api } from 'lwc';
import getMessages from '@salesforce/apex/ChatApplicationController.getMessages';
import setMessages from '@salesforce/apex/ChatApplicationController.setMessages';
import TICK_MARK from '@salesforce/resourceUrl/TICK_MARK';

export default class ChatWindow extends LightningElement {

    userObj;
    message = '';
    sentMessage;
    error;
    userMessages = [];
    currentUserId;
    isLoading = false;
    lstMessages = [];
    messages;
    isRendered = false;

    renderedCallback(){
        console.log('Rendered call back : '+this.userObj.Id+',,,,,'+this.currentUserId);
        if(this.userObj.Id != '' && this.currentUserId != '' && this.isRendered == true){
            console.log('Rendered If : ');
            this.handleGetMessages();
        }
    }

    @api handleParcelRecievedFromParent(parcel){
        this.isLoading = true;
        this.userObj = parcel.userValue;
        this.currentUserId = parcel.currentUserId;
        this.handleGetMessages();
        //console.log('Recieved in chat window : '+JSON.stringify(this.userObj));
    }

    handleGetMessages(){
        getMessages({currentUserId : this.currentUserId, recieverUserId : this.userObj.Id })
        .then(result => {
            this.messages = result;
            //console.log(this.messages);
            let tempMessages = [];
            if(this.messages == null){
                this.lstMessages = [];
            }
            else{               
                
                this.messages.forEach(e => {
                    let obj =  e.split('#')
                    if(obj[1] == this.currentUserId){
                        let objMessage = {
                                            date : obj[0],
                                            id : obj[1],
                                            message : obj[2],
                                            styleClass : 'sentMessages slds-box slds-box_small slds-col slds-size_1-of-1 slds-large-size_12-of-12',
                                            tickImage : TICK_MARK
                                        };                                                              
                                        tempMessages.push(objMessage);  
                    }else if(obj[1] == this.userObj.Id){
                        let objMessage = {
                                            date : obj[0],
                                            id : obj[1],
                                            message : obj[2],
                                            styleClass : 'recievedMessages slds-box slds-box_small slds-col slds-size_1-of-1 slds-large-size_12-of-12',
                                            tickImage : ''
                                         };                                                              
                                         tempMessages.push(objMessage);
                        }                                
                    })
                //console.log('lstMessages : '+this.lstMessages);
            }
            this.lstMessages = tempMessages;
            this.isLoading = false;
        })
        .catch(error => {
            this.error = error;
            this.isLoading = false;
        });
    }

    handleChangeInput(event){
        this.message = event.target.value;
    }

    keycheck(component){
        if (component.which == 13){
            this.handleSendMessage();
        }
    }

    handleSendMessage(){ 
        const dateValue = new Date().toISOString();
        const userId = this.userObj.Id;
        let message = this.message;

        const sendingMessage = dateValue+"#"+this.currentUserId+"#"+message;
        //console.log(sendingMessage);
        setMessages({messages : sendingMessage, currentUserId : this.currentUserId, reciverUserId : userId})
        // eslint-disable-next-line no-unused-vars
        .then(result => {
            this.message = '';
            //console.log('Succesfully Sent to new method : '+result);
            this.handleGetMessages();
        })
        .catch(error => {
            this.error = error
        }
        );
    }

}