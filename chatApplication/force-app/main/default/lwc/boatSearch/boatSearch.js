/* eslint-disable no-unused-vars */
import { LightningElement , track} from 'lwc';
import { NavigationMixin } from 'lightning/navigation'

// imports
export default class BoatSearch extends NavigationMixin(LightningElement) {
    @track isLoading = false;

    // Handles loading event
    // eslint-disable-next-line no-unused-vars
    handleLoading(event) {
        this.isLoading = true;
    }

    // Handles done loading event
    handleDoneLoading(event) {
        this.isLoading = false;
    }

    // Handles search boat event
    // This custom event comes from the form
    searchBoats(event) {
        const boatTypeId = event.detail.boatTypeId;
        this.template.querySelector("c-boat-search-results").searchBoats(boatTypeId);
    }

    createNewBoat() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Boat__c',
                actionName: 'new'
            }
        });
    }

    handleChange()
    {
        this.selectedBoatTypeId = this.template.querySelector('c-boat-search-form').selectedBoatTypeId;
        this.template.querySelector('c-boat-search-form').handleSearchOptionChange(this.selectedBoatTypeId);
    }
}