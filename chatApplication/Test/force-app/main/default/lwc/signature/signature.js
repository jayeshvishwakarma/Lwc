import { LightningElement,api } from 'lwc';

let isDownFlag, 
    isDotFlag = false,
    prevX = 0,
    currX = 0,
    prevY = 0,
    currY = 0;            
       
let x = "black"; //blue color
let y = 1.5; //weight of line width and dot.       

let canvasElement, ctx; //storing canvas context

let dataURL,convertedDataURI; //holds image data

export default class CapturequestedEventignature extends LightningElement {
    empty = '';
    //event listeners added for drawing the signature within shadow boundary
    constructor() {
        super(); 
        
        this.template.addEventListener('mousemove', this.handleMouseMove.bind(this));
        this.template.addEventListener('touchmove', this.handleTouchMove.bind(this));
        this.template.addEventListener('mousedown', this.handleMouseDown.bind(this));
        this.template.addEventListener('touchstart', this.handleTouchStart.bind(this));
        this.template.addEventListener('mouseup', this.handleMouseUp.bind(this));
        this.template.addEventListener('mouseup', this.handleMouseUp.bind(this));
        this.template.addEventListener('mouseout', this.handleMouseOut.bind(this));
    }

    renderedCallback(){
        canvasElement = this.template.querySelector('canvas[data-id=canvasFirst]');
        ctx = canvasElement.getContext("2d");
    }
    
    //handler for mouse move operation
    handleMouseMove(event){
        this.searchCoordinatesForEvent('move', event);      
    }
    handleTouchMove(e){
        if (isDownFlag) {
            var touch = e.touches[0];
            const clientRect = canvasElement.getBoundingClientRect();
            prevX = currX;
            prevY = currY;
            currX = touch.clientX -  clientRect.left;
            currY = touch.clientY - clientRect.top;
                this.redraw();
            }

    }
    
    //handler for mouse down operation
    handleMouseDown(event){
        this.searchCoordinatesForEvent('down', event);         
    }

    handleTouchStart(e){
       
        
        
  var touch = e.touches[0];


  const clientRect = canvasElement.getBoundingClientRect();
        prevX = currX;
        prevY = currY;
        currX = touch.clientX -  clientRect.left;
        currY = touch.clientY - clientRect.top;

        isDownFlag = true;
        isDotFlag = true;
        if (isDotFlag) {
            this.drawDot();
            isDotFlag = false;
        }
    }

    
    
    //handler for mouse up operation
    handleMouseUp(event){
        this.searchCoordinatesForEvent('up', event);       
    }

    //handler for mouse out operation
    handleMouseOut(event){
        this.searchCoordinatesForEvent('out', event);         
    }

    //clear the signature from canvas
    @api 
    handleClearClick(){
        ctx.clearRect(0, 0, canvasElement.width, canvasElement.height);  
        const signClear = new CustomEvent('clear', { detail: '' });
// Dispatches the event.
        this.dispatchEvent(signClear);        
    }

    searchCoordinatesForEvent(requestedEvent, event){
        event.preventDefault();
        if (requestedEvent === 'down') {
            this.setupCoordinate(event);           
            isDownFlag = true;
            isDotFlag = true;
            if (isDotFlag) {
                this.drawDot();
                isDotFlag = false;
            }
        }
        if (requestedEvent === 'up' || requestedEvent === "out") {
            isDownFlag = false;
        }
        if (requestedEvent === 'move') {
            if (isDownFlag) {
                this.setupCoordinate(event);
                this.redraw();
            }
        }
    }

    //This method is primary called from mouse down & move to setup cordinates.
    setupCoordinate(eventParam){
        //get size of an element and its position relative to the viewport 
        //using getBoundingClientRect which returns left, top, right, bottom, x, y, width, height.
        const clientRect = canvasElement.getBoundingClientRect();
        prevX = currX;
        prevY = currY;
        currX = eventParam.clientX -  clientRect.left;
        currY = eventParam.clientY - clientRect.top;
    }

    //For every mouse move based on the coordinates line to redrawn
    redraw() {
        ctx.beginPath();
        ctx.moveTo(prevX, prevY);
        ctx.lineTo(currX, currY);
        ctx.strokeStyle = x; //sets the color, gradient and pattern of stroke
        ctx.lineWidth = y;        
        ctx.closePath(); //create a path from current point to starting point
        ctx.stroke(); //draws the path
    }
    
    //this draws the dot
    drawDot(){
        ctx.beginPath();
        ctx.fillStyle = x; //blue color
        ctx.fillRect(currX, currY, y, y); //fill rectrangle with coordinates
        ctx.closePath();
    }

    @api getSignatureUrl(){    
        const second = this.template.querySelector("canvas[data-id=canvasSecond]");
        this.empty = second.toDataURL("image/png");
        //console.log("========================================="+this.empty);
        //set to draw behind current content
        ctx.globalCompositeOperation = "destination-over";
        ctx.fillStyle = "#FFF"; //white
        ctx.fillRect(0,0,canvasElement.width, canvasElement.height); 

        //convert to png image as dataURL
        dataURL = canvasElement.toDataURL("image/png");
        //console.log(dataURL);
        //convert that as base64 encoding
        convertedDataURI = dataURL.replace(/^data:image\/(png|jpg);base64,/, "");
        // if(dataURL.localeCompare(this.empty)){
        //     console.log("If");
        //     return null;
        
        // }else{
        //     console.log("else");
        //     return convertedDataURI;
        // }
          return  convertedDataURI;
    }
}