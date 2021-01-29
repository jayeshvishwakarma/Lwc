import {
    LightningElement,
    track,
    api,
    wire
} from 'lwc';
import {
    getRecord
} from "lightning/uiRecordApi";
import currentUserId from "@salesforce/user/Id";
import Server_Error from "@salesforce/label/c.UI_Error_Message";
import getFeedbacks from "@salesforce/apex/FeedbacksRelatedList.getFeedbacks";

const columns = [{
    label: 'Feedback Id',
    fieldName: 'nameUrl',
    type: 'url',
    typeAttributes: {
        label: {
            fieldName: 'Name'
        },
        target: '_blank'
    },
    sortable: true
}];

export default class FeedbacksRelatedList extends LightningElement {

    @api recordId;
    @track feedbackRec = [];
    @track columns = columns;
    @track error;
    errorMessage;
    @track showTable = false;
    feedbackCount = 0;

    /*@wire(getRecord, {
        recordId: currentUserId,
        fields: ["User.Contact.AccountId"]
    })
    currentUser({
        error,
        data
    }) {
        if (data) {
            this.dealerRecordId = data.fields.Contact.value.fields.AccountId.value;
            //this.getserverData();
        } else {
            console.log(error);
        }
    }*/

    connectedCallback() {
        console.log('Record Id------>' + this.recordId);
        getFeedbacks({
            customerID: this.recordId
        }).then(result => {
            console.log('result------->', result);
            let nameUrl;
            console.log('result.length----->' + result.length);
            if (result.length) {
                this.showTable = true;
                this.feedbackCount = result.length;
                this.feedbackRec = result.map(row => {
                    nameUrl = `/${row.Id}`;
                    return {
                        ...row,
                        nameUrl
                    }
                })
                this.error = null;
            }

        }).catch(error => {
            this.handleError(error);
        })
    }

    navigateToDetailPage(event) {
        console.log('event---->', event);
    }

    handleError(error) {
        this.errorMessage = Server_Error;
    }


}