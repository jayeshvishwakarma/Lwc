import {LightningElement,api} from 'lwc';

export default class Child extends LightningElement{
    @api countryNames;
    checkedCountries;
    constructor()
    {
        super();
        this.checkedCountries=[];
    }
    
    handleChange(event)
    {
         const checkBoxValue = event.target;
         if(checkBoxValue.checked)
             this.checkedCountries.push(checkBoxValue.name);
         else
         {
             const index=this.checkedCountries.indexOf(checkBoxValue.name);
             this.checkedCountries.splice(index,1);
         }
    }

    handleClick()
    {
        const countries = this.checkedCountries.toString();
        var firstEvent = new CustomEvent('first',
                                            {
                                                 detail : {countries}
                                            }
                                        );
        this.dispatchEvent(firstEvent);

    }
    
    
}