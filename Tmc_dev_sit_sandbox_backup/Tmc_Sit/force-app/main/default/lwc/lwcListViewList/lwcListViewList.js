/* eslint-disable no-console */
import { LightningElement,wire,api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import fetchLists1 from '@salesforce/apex/listViewController.listValues';



export default class LwcListViewList extends  NavigationMixin(LightningElement){
    @api objectname;
    @track listviews;

//    @wire(fetchLists, {objectName: '$oName'}) listviews;

   

     @wire(fetchLists1,{objectName:'$objectname'})
    wiredFetchlist ({error, data}) {
        if (error) {
            // TODO: Error handling
        } else if (data) {
        this.listviews = data;
        console.log(this.listviews);
        }
    }

    connectedCallBack(){
       
    }

    // navigateToListView(event) {
    //     console.log(">>>>>Navigate to ListView"+event.target.value.SobjectType);
    //     let currentValue = event.target.value;
    //     console.log(">>>>>>"+currentValue.SobjectType);
    //     console.log(">>>>>>"+currentValue.Id);

    //     // Navigate to the Contact object's Recent list view.
    //     this[NavigationMixin.Navigate]({
    //         type: 'standard__objectPage',
    //         attributes: {
    //             objectApiName: event.target.value.SobjectType,
    //             actionName: 'list'
    //         },
    //         state: {
    //             filterName: event.target.value.Id // or by 18 char '00BT0000002TONQMA4'
    //         }
    //     });

    //     console.log(">>>>>>Navifate complete");
    // }

    navigateToListHandler(event){
        let currentValue = event.currentTarget.dataset.id;
        let currentname = event.currentTarget.dataset.name;
        console.log(currentname)
     
   
        //currentname
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: this.objectname,
                actionName: 'list'
            },
            state: {
                // 'filterName' is a property on the page 'state'
                // and identifies the target list view.
                // It may also be an 18 character list view id.
                filterName: currentValue // or by 18 char '00BT0000002TONQMA4'
            }
        });
    }
    

}