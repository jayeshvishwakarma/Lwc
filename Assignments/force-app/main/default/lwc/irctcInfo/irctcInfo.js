import { LightningElement } from 'lwc';

export default class IrctcInfo extends LightningElement {

    PNRNumber = "";
    catchPNR(event){
        this.PNRNumber = event.target.value;
    }
    getPNRStatus(){
    fetch("https://indianrailways.p.rapidapi.com/index.php?pnr="+ this.PNRNumber, {
        "method": "GET",
        "headers": {
            "x-rapidapi-key": "133814459dmshbd3367598024e36p1cbf27jsncd0afa63e984",
            "x-rapidapi-host": "indianrailways.p.rapidapi.com"
        }
    })
    .then(response => {
	    console.log('Response---->'+response.data);
    })
    .catch(err => {
	    console.error('Error--->'+err.message);
    });
  }
}