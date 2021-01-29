import {LightningElement} from 'lwc';

export default class Child2 extends LightningElement{

    handleChange()
    {
        const sendingMsg = {msg : "Miss You Bro...",name : "Ashish"};
        const firstEvent = new CustomEvent('first',
                                            {
                                                detail : sendingMsg
                                            }
                                          );
        this.dispatchEvent(firstEvent);
    }
    
}