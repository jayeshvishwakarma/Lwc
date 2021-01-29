import { LightningElement, wire, track } from 'lwc';
import namesOfObjects from '@salesforce/apex/AllObjectNames.getAllObjectNames';
import getRecords from '@salesforce/apex/AllObjectNames.getRecordsOfObjects';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
export default class ObjectChart extends LightningElement {
    error;
    data;
    _selected = [];
    @track lstObjectNames = [];
    selectedNames;
    objNameCounts = {};
    @track wiredAccountList;
    isShowData = true;

   
    get selected() {
        return this._selected.length ? this._selected : 'none';
    }

    onSelectNames(event){
        this.selectedNames = event.detail.value;
        console.log('SELECTED VALUES+++++++++++',this.selectedNames);
    }
    renderedCallback(){
        if(this.isShowData)
            refreshApex(this.wiredAccountList);
        this.isShowData = false;    
    }


    showChart(){
        if(this.selectedNames.length >= 1 && this.selectedNames.length < 6){
            let listOfSelectedNames = [];
            this.selectedNames.forEach(element=>{
                listOfSelectedNames.push(element);
            });
            console.log('Show :', listOfSelectedNames);
            getRecords({lstObjectNames : listOfSelectedNames})
            .then(result=>{
                console.log('Success==>', result);
                

            }).catch(error=>{
                console.log('Error=====', error);
            });
        }else{
            const toastEvent = new ShowToastEvent({
                title : "Chart creation failed",
                message : "You can only select max 5 and min 1",
                variant : "error"
            });
            this.dispatchEvent(toastEvent);
        }
    }

    @wire(namesOfObjects)
    objectNames(result) {
        this.wiredAccountList = result;
        if (result.error) {
            this.error = result.error;
            console.log(this.error);
            // TODO: Error handling
        } else if(result.data){     
                let count = 0;
                result.data.forEach(element => {
                    console.log('element'+element) ;  
                   let obj = {
                       label : element,
                       value : element                   
                   };   
                                              
                   this.lstObjectNames.push(obj);
               });
               //console.log('OUTPUT : ',this.lstObjectNames);
           }
    }
}