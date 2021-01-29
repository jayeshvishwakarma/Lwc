import { LightningElement, wire } from 'lwc';
import {fieldColumns} from './utility/share.js';
import {CurrentPageReference} from 'lightning/navigation';
import {registerListener, unregisterAllListeners} from 'c/pubsub';
import { deleteRecord,updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import  ACCOUNT_NAME from '@salesforce/schema/Account.Name';
import ACCOUNT_PHONE from '@salesforce/schema/Account.Phone';
import ACCOUNT_CITY from '@salesforce/schema/Account.BillingCity';
import ID_FIELD from '@salesforce/schema/Account.Id';
import { refreshApex } from '@salesforce/apex';

export default class CreatedAccounts extends LightningElement {
    fieldColumns;
    MYDATA;
    draftValues=[];

    constructor()
    {
        super();
         this.fieldColumns = fieldColumns;
         this.MYDATA=[];
    }

    @wire(CurrentPageReference) pageRef;

    connectedCallback()
    {
        console.log('connected call back chaala=============');
        registerListener('newAccount',this.ParcelRecieved,this);
    }

    ParcelRecieved(parcel)
    {
        const recieved = parcel;
        console.log('Parcel Recieved========='+JSON.stringify(recieved));
           this.MYDATA = [...this.MYDATA, {
                                                    Id: recieved.id,
                                                    Name: recieved.fields.Name.value,
                                                    Phone:recieved.fields.Phone.value,
                                                    BillingCity:recieved.fields.BillingCity.value
                                            }
                            
                        ];
        console.log(this.MYDATA);
    }

    handleRowActions(event){
        const row = event.detail.row;
        console.log(row);
        console.log("Record Id", row.Id);
        
        if(event.detail.action.name === 'Delete_Record'){
            console.log("Delete button Chala");
            deleteRecord(row.Id)
                .then(() => { 
                                this.MYDATA=this.MYDATA.filter(
                                                                (a) => {
                                                                         return a.Id != row.Id
                                                                       }, this);
                            
                                this.dispatchEvent(
                                        new ShowToastEvent({
                                            title: 'Success',
                                            message: 'Record Is  Deleted',
                                            variant: 'success',
                                        }),
                                );
                })
                .catch(error => {
                                this.dispatchEvent(
                                    new ShowToastEvent({
                                        title: 'Error While Deleting record',
                                        message: error.message,
                                        variant: 'error',
                                    }),
                                );
                });
            
        }
        else if (event.detail.action.name === 'Edit_Record'){
            console.log("Edit button Clicked");
        }
       
    }

    handleSave(event){
        //alert(JSON.stringify(event.detail.draftValues));
    const fields = {};
    fields[ID_FIELD.fieldApiName] = event.detail.draftValues[0].Id;
    fields[ACCOUNT_NAME.fieldApiName]=event.detail.draftValues[0].Name;
    fields[ACCOUNT_PHONE.fieldApiName]=event.detail.draftValues[0].Phone;
    fields[ACCOUNT_CITY.fieldApiName]=event.detail.draftValues[0].BillingCity;
    
    const recordInput = {fields};

    updateRecord(recordInput)
    .then((objAccount) => {

           /* let tempArr=[];
            this.MYDATA.forEach(item => {
                if(item.Id==objAccount.id){
                    console.log("id matched");
                    tempArr=[...tempArr,{
                                            Id: objAccount.id,
                                            Name: objAccount.fields.Name.value,
                                            Phone:objAccount.fields.Phone.value,
                                            BillingCity:objAccount.fields.BillingCity.value
                                        }             
                            ]
                        //arr = [1,2];
                        //arr = [...arr,3] => arr=[1,2,3];
                }
            });
            this.MYDATA=tempArr;*/

            this.MYDATA = this.MYDATA.map(element => {
                if(element.Id == objAccount.id){
                    console.log('===='+JSON.stringify(objAccount));
                    console.log("idMatched");
                                                this.MYDATA=[...this.MYDATA, {   
                                                                    Id: objAccount.id,
                                                                    Name : objAccount.fields.Name.value,
                                                                    Phone : objAccount.fields.Phone.value,
                                                                    BillingCity : objAccount.fields.BillingCity.value
                                                              }]

                                                 return this.MYDATA;       
                                                }
                 });

             this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Contact updated',
                variant: 'success'
            })
        );
        // Clear all draft values
        this.draftValues = [];
        return refreshApex(this.MYDATA);

    }).catch(error => {
        this.dispatchEvent(
            new ShowToastEvent({
  title: 'Error creating record',
                message: error.body.message,
                variant: 'error'
            })
        );
    });
}
    disconnectedCallback()
    {
        unregisterAllListeners(this);
    }
}