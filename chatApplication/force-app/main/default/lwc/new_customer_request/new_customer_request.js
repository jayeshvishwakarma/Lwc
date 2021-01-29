import { LightningElement, track, api } from 'lwc';
import createCustomer from '@salesforce/apex/NewCustomerService.createCustomer';


export default class New_customer_request extends LightningElement {
    @track success = false;
    @track Klantnummer = '';
    @track Email = '';
    @track Aanhef = '';
    @track Voornaam = '';
    @track Achternaam = '';
    @track Telefoon = '';
    @track errMsg = '';
    @track contactId;
    handleSuccess(event) {
        this.contactId = event.detail.id;
    }
    submitRecord(){
        let spinner = this.template.querySelector(".processing");
        //spinner.classList.remove("hide");
        spinner.classList.add("show");
        let allvalid = true;
        let requiredList = this.template.querySelectorAll(".required");
        requiredList = [...requiredList];
        requiredList.map( item => {
            if(item.value){
                item.classList.remove("error");
            }
        });
        requiredList.map( item => {
            if(!item.value){
                item.classList.add("error");
                allvalid = false;
            }
        });
        
        if(allvalid){
            console.log(this.Klantnummer);
            console.log(this.Aanhef);
            console.log(this.Email, this.Voornaam, this.Achternaam, this.Telefoon);
            createCustomer({accNumber: this.Klantnummer, 
                           title : this.Aanhef,
                           fname : this.Voornaam,
                           lname : this.Achternaam,
                           email : this.Email,
                           phone :  this.Telefoon}).then((resp)=>{
                            
                            if(resp != 'Success'){
                                this.errMsg = resp;
                            }else{
                                this.success = true;
                            }
                            
                            //spinner.classList.add("hide");
                            spinner.classList.remove("show");
                
                }).catch((err) => {
                // Handle any error that occurred in any of the previous
                // promises in the chain.
                    this.success = false;
                    this.errMsg = err.body.message;
                    console.log(JSON.stringify(err));
                    //spinner.classList.add("hide");
                    spinner.classList.remove("show");
                });
            
        }else{
            //spinner.classList.add("hide");
            spinner.classList.remove("show");
        }
            

    }

    genericOnChange(event){
        this[event.target.name] = event.target.value;
    }

}