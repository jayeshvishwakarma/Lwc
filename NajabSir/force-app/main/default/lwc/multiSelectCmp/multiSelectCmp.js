/* eslint-disable no-console */
import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
/******** Error messagess ***********/
import Error_Message_Time_Slot from '@salesforce/label/c.Error_Message_Time_Slot';
export default class MultiSelectCmp extends NavigationMixin(LightningElement) {
    //Label of the field
    @api mslabel;
    //List of options to be displayed in the dropdown.
    @api msoptions=[{'Id':'Jaipur','Name':'Jaipur'},
                    {'Id':'Pune','Name':'Pune'},
                    {'Id':'Hyderabad','Name':'Hyderabad'},
                    {'Id':'Delhi','Name':'Delhi'}];
    //This will store all the selected values
    @api selectedOptions=[];
    //This will show/hide filters.
    @api showFilters= false;
    //This will make the dropdown required
    @api valueRequired = false;
    //Input field placeholder
    @track msname='Select a value...'
    //Placeholder reverting back
    @track selectedLabel='Select a value...';
    //To make sure handleclick event should run on creation of the component
    @track initializationCompleted = false;
    //Max no. of selected values to be displayed
    @track maxSelectedShow=2; 
    //Variable to toggle the selected
    @track isSelected = false;
    
    /**
     * This will be called on creation of the component
     */
    connectedCallback() {
       if(!this.initializationCompleted){
            this.template.addEventListener('click', this.handleClick.bind(this));
            this.initializationCompleted = true; 
        }
    }

    
    /**
    * To show selected values after component has rendered.
    **/
    renderedCallback(){
        //let populateDetails = Object.assign({},{"Id":"Jaipur","Name":"Jaipur"});
        console.log(this.selectedOptions);
        let popArray = Array.from(this.selectedOptions);
        let mySet = new Set();
        //let mySetArray=[];
        //Fetch all the selcted values unique id
        popArray.forEach((key,value) => {
            console.log('value-->'+value);
            //console.log(key.Id);
            //console.log(key.Id.split('to')[0]);
            //console.log(mySetArray);
            //console.log(mySetArray.find(checkObject=>checkObject.includes(key.Id.split('to')[0])));
            mySet.add(key.Id);
           // mySetArray.push(key.Id);
        }); 
        
        //Set the selcted names
        this.setPickListName(this.selectedOptions); 

        let allSelectElements = this.template.querySelectorAll("li");
        Array.from(allSelectElements).forEach(function(node){
            if(mySet.has(node.dataset.id)){
                node.classList.add('slds-is-selected');
            }
        });
    }
 

    /**
     * This function will be called when input box value change 
     * */
    onInputChange(event){
        var inputText = event.target.value;
        this.filterDropDownValues(inputText);
    }


    /**
     * This function will be called when clear button is clicked
     * This will clear any current filters in place 
     * */
    onClearClick(){
        this.template.querySelector('[data-id="ms-filter-input"]').value='';
        this.resetAllFilters();
    }
    
    /**
     * This function clear the filters 
     * */

    resetAllFilters() {
        this.filterDropDownValues('');
    }

    /**
     * This function will be used to filter options based on input box value 
     * */
    filterDropDownValues(inputText){
        var allSelectElements = this.template.querySelectorAll("li");
        Array.from(allSelectElements).forEach(function(node){
            if(!inputText){
                node.style.display = "block";
            }
            else if(node.dataset.name.toString().toLowerCase().indexOf(inputText.toString().trim().toLowerCase()) !== -1){
                node.style.display = "block";
            } else{
                node.style.display = "none";
            }
        }); 
    }

    /**
     * This function will be used to filter options based on input box value 
     * */
    rebuildPicklist(){
        var allSelectElements = this.template.querySelectorAll("li");
        Array.from(allSelectElements).forEach(function(node){
            node.classList.remove('slds-is-selected');
        });

    }

    /**
     * This function will select all option
     **/
    selectAll(event){
        this.isSelected = !this.isSelected; 
        if(this.isSelected===true){
            event.target.label = 'Unselect all';
            let allSelectElements = this.template.querySelectorAll("li");
            Array.from(allSelectElements).forEach(function(node){
                node.classList.add('slds-is-selected');
            });
            this.selectedOptions = this.msoptions;
            this.setPickListName(this.selectedOptions);

        }else{
            event.target.label = 'Select all';
            this.onRefreshClick();
        }
        event.stopPropagation();
    }




    /**
     * This function will be called when refresh button is clicked
     * This will clear all selections from picklist and rebuild a fresh picklist 
     * */
    @api onRefreshClick(){
        this.selectedOptions = [];
        this.rebuildPicklist(); 
        this.setPickListName(this.selectedOptions);
    }

    /**
     * This function will close all multi-select drop down on the page 
     * */
    @api
    closeAllDropDown(){
        //Close drop down by removing slds class
        Array.from(this.template.querySelectorAll('[data-id="ms-picklist-dropdown"]')).forEach(function(node){
            node.classList.remove('slds-is-open');
        });
    }

    /**
     * This function will handle clicks on within and outside the component 
     * */
    @api
    handleClick(event){
        //this.isOpen = !this.isOpen;
        
        let tempElement = event.target;   
        let outsideComponent = true;  
        //c lick indicator
        //1. Drop-Down is clicked
        //2. Option item within dropdown is clicked
        //3. Clicked outside drop-down
        //loop through all parent element
        if(tempElement.dataset.id!==undefined && tempElement!==null){
            while(tempElement){
                if(tempElement.dataset.id === 'ms-dropdown-items'){
                    //3. Clicked somewher within dropdown which does not need to be handled
                    //Break the loop here
                    outsideComponent = false;
                    break;
                } else if(tempElement.dataset.id === 'ms-input'){
                    //1. Handle logic when dropdown is clicked  
                    this.onDropDownClick(); 
                    outsideComponent = false;
                    break;
                }
                else{
                    this.onOptionClick(event.target); 
                    outsideComponent = false;
                    break;
                }
                //get parent node
               // tempElement = tempElement.parentNode;
            }
        }
        if(outsideComponent){
            this.closeAllDropDown();
        }
        event.stopPropagation();
    }

    /**
     * This function will be called on drop down button click
     * It will be used to show or hide the drop down 
     * */
    onDropDownClick(){
        var classObj = this.template.querySelector('[data-id="ms-picklist-dropdown"]'); 
        var classObjList = String(classObj.classList);  
        if(!classObjList.includes("slds-is-open")){
            //First close all drp down
            this.closeAllDropDown();
            //Open dropdown by adding slds class
            classObj.classList.add('slds-is-open');
        } else{
           //Close all drp down
            this.closeAllDropDown();
        }
    }

    /**
     * This function will be called when an option is clicked from the drop down
     * It will be used to check or uncheck drop down items and adding them to selected option list
     * Also to set selected item value in input box 
     * */
    onOptionClick(ddOption){ 
        var clickedValue = Object.assign({},{"Id":ddOption.closest("li").getAttribute('data-id'),
                            "Name":ddOption.closest("li").getAttribute('data-name')});
                                            
       //console.log(this.selectedOptions.find(checkVal=>checkVal.Id.includes(clickedValue.Id.split('to')[0])));
        //Get all selected options
        var selectedOptions = Array.from(this.selectedOptions);
        
        //Boolean to indicate if value is alredy present
        var alreadySelected = false;
        console.log('HI');
        console.log(this.selectedOptions);
        //console.log(this.selectedOptions.find(checkVal=>checkVal.Id.split(' to ')[0]==='07:00'));
        //console.log(this.selectedOptions.find(checkVal=>checkVal.Id.includes(clickedValue.Id.split(' to ')[0])));
        if(this.selectedOptions.find(checkVal=>checkVal.Id.includes(clickedValue.Id.split(' to ')[0])) || this.selectedOptions.length===0)
        {
            
            selectedOptions.forEach((option,index) => { 
                if(option.Id === clickedValue.Id){
                    //Clicked value already present in the set
                    selectedOptions.splice(index, 1);
                    //Make already selected variable true	
                    alreadySelected = true;
                    //remove check mark for the list item
                    ddOption.closest("li").classList.remove('slds-is-selected');
                }
            });
            //If not already selected, add the element to the list
            if(!alreadySelected){ 
                selectedOptions.push(clickedValue); 
                //Add check mark for the list item
                ddOption.closest("li").classList.add('slds-is-selected');
            } 
            this.selectedOptions = Array.from(selectedOptions);
            this.setPickListName(selectedOptions); 
        }
        else{
            this.tostMessage(Error_Message_Time_Slot,0,'Error','');
        }
        //Looping through all selected option to check if clicked value is already present
        
    }

    /**
     * This function will set text on picklist 
     * */
    @api
    setPickListName(selectedOptions){
        const maxSelectionShow = this.maxSelectedShow;
        var selectedOptionsValues = Array.from(selectedOptions);
        //Set drop-down name based on selected value
        if(selectedOptionsValues.length < 1){
            this.selectedLabel =  this.msname;
            if(this.valueRequired)
                this.markMandatory(false);
        } else if(selectedOptionsValues.length > maxSelectionShow){
            this.selectedLabel =  selectedOptionsValues.length+' Options Selected';
            this.markMandatory(true);
        } else{
            let selections = '';
            selectedOptionsValues.forEach(option => {
                selections += option.Name+',';
            });
            this.selectedLabel=  selections.slice(0, -1);
            this.markMandatory(true);
        }

        this.fireEvent(selectedOptionsValues);
    }


    //This function will mark the input as mandatory by adding custom css to the input box
    markMandatory(valid){
        var inputObj = this.template.querySelector('[data-id="ms-input"]');
        var textObj = this.template.querySelector('[data-id="customerror"]');
        if(!valid){
            inputObj.classList.remove('ms-input');
            inputObj.classList.add('ms-input-required');
            textObj.classList.remove('slds-hide');
        }
        else{
            let clsList = String(inputObj.classList);
            if(clsList.includes('ms-input-required')){
                inputObj.classList.remove('ms-input-required');
                inputObj.classList.add('ms-input');
            }  
            let txtClsList = String(textObj.classList)
            if(!txtClsList.includes('slds-hide'))
                textObj.classList.add('slds-hide');
        }

    }

    //Fire the event fom child component and pass the selected values to parent component
    fireEvent(selOptions){
        //Fire an event
        const selectedEvent = new CustomEvent('selected', { detail: selOptions});
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }
    tostMessage(message,code,status)
    {
        const showSuccess = new ShowToastEvent({
            title: status,
            message: message,
            variant: status,
        });
        this.dispatchEvent(showSuccess);
        
    }

    
}