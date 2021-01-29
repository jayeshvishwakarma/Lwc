/* eslint-disable no-console */
/*eslint-disable no-alert*/
/*eslint(no-use-before-define)*/
import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import saveSignatureMethod from '@salesforce/apex/SaveSignature.saveSignatureMethod'; 

export default class SignaturCapture extends LightningElement {
    @api recordId;
    @api closeModal = false;
    @api dontShowButton =false;
    @track showspinner = false;

    canvas = false
    ctx = false
    flag = false
    prevX = 0
    currX = 0
    prevY = 0
    currY = 0
    dot_flag = false;
    x = "black";
    y = 2;
    w;
    h;
    ratio;
    padTOuched = false;


    //Method to run on every rendered callback of component
    renderedCallback() {
        this.canvas = this.template.querySelector('[data-id="can"]');
        this.ratio = Math.max(window.devicePixelRatio || 1, 1);
        this.w = this.canvas.width * this.ratio;
        this.h = this.canvas.height * this.ratio;

        //For desktop mouse move events
        this.canvas.addEventListener('mousemove', this.handlemouseMove.bind(this));
        this.canvas.addEventListener('mousedown', this.handlemousedown.bind(this));
        this.canvas.addEventListener('mouseup', this.handlemouseup.bind(this));
        this.canvas.addEventListener('mouseout', this.handlemouseout.bind(this));

        // Set up touch events for mobile, etc
        this.canvas.addEventListener('touchstart', this.handletouchstart.bind(this));
        this.canvas.addEventListener('touchend', this.handletouchend.bind(this));
        this.canvas.addEventListener('touchmove', this.handletouchmove.bind(this));
    }


    //Method to move the pointer in the Canvas and perform draw event
    handlemouseMove(e) {
        const rect = this.canvas.getBoundingClientRect();
        if (this.flag) {
            this.prevX = this.currX;
            this.prevY = this.currY;
            this.currX = e.clientX - rect.left;
            this.currY = e.clientY - rect.top;
            this.draw(this.template, this.ctx);
        }
    }

    //Method to calculate the x, y coordinates of the mouse in canvas when button is clicked
    handlemousedown(e) {
        this.ctx = this.canvas.getContext("2d");
        const rect = this.canvas.getBoundingClientRect();
        this.prevX = this.currX;
        this.prevY = this.currY;
        this.currX = e.clientX - rect.left;
        this.currY = e.clientY - rect.top;

        this.flag = true;
        this.dot_flag = true;
        if (this.dot_flag) {
            this.ctx.beginPath();
            this.ctx.fillRect(this.currX, this.currY, 2, 2);
            this.ctx.closePath();
            this.dot_flag = false;
        }
    }

    handlemouseup() {
        this.flag = false;
    }

    //method to check if the pointer is inside the canvas or not
    handlemouseout() {
        this.flag = false;
    }

    // Set up touch events for mobile, etc
    handletouchstart(e) {
        var touch = e.touches[0];
        var mouseEvent = new MouseEvent("mousedown", {
            clientX: touch.clientX,
            clientY: touch.clientY
        })
        this.canvas.dispatchEvent(mouseEvent);
        e.preventDefault();
    }

    // Set up touch events for mobile, etc     
    handletouchend() {
        var mouseEvent = new MouseEvent("mouseup", {});
        this.canvas.dispatchEvent(mouseEvent);
    }

    // Set up touch events for mobile, etc
    handletouchmove(e) {
        var touch = e.touches[0];
        var mouseEvent = new MouseEvent("mousemove", {
            clientX: touch.clientX,
            clientY: touch.clientY
        });
        this.canvas.dispatchEvent(mouseEvent);
        e.preventDefault();
    }

    //method to draw on canvas
    draw() {
        this.padTOuched = true;
        this.ctx.beginPath();
        this.ctx.moveTo(this.prevX, this.prevY);
        this.ctx.lineTo(this.currX, this.currY);
        this.ctx.stroke();
        this.ctx.closePath();
        console.log(this.padTOuched);
        const signatureCollected=new CustomEvent('signature',{detail:this.padTOuched});
        this.dispatchEvent(signatureCollected);

    }


    //Erase signature
    @api eraseHelper() {
        if (confirm('Are you sure?')) {
            this.padTOuched = false;
            let canvas = this.template.querySelector('[data-id = "can"]');
            let ctx = canvas.getContext("2d");
            let w = canvas.width;
            let h = canvas.height;
            ctx.clearRect(0, 0, w, h);
        }
    }

    //Method to save the signature under the related record
    //Calls the server side controller passing 
    @api save() { 
        console.log('Inside Save');
        console.log(this.testDriveId);
        if(this.padTOuched===true){
            this.showspinner = true;
            let pad = this.template.querySelector('[data-id="can"]');
            let dataURL = pad.toDataURL();
            let strDataURI = dataURL.replace(/^data:image\/(png|jpg);base64,/, "");
            console.log('Inside Save 1');
            console.log(strDataURI);
            console.log(this.recordId);
            //Calling server side action and passing base64 of signature and parent record Id to the server side method
            saveSignatureMethod({
                signatureBody: strDataURI,
                recordId: this.recordId
            })
            //Show toast message 
            .then(() => {
                this.showspinner = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'SUCCESS',
                        message: 'Signature registered successfully',
                        variant: 'SUCCESS'
                    })
                )
            })
            //after show toast message close quick action
            
            .then(() => {
                    this.dispatchEvent(new CustomEvent('close'));
                    this.showspinner = false;
                
            })
            
            //Catch error 
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error on signature save',
                        message: error.message.body,
                        variant: 'error'
                    })
                )
            })
        }else{
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error:',
                    message: 'Please add signature',
                    variant: 'error'
                })
            )
        }
    }

    

    
}