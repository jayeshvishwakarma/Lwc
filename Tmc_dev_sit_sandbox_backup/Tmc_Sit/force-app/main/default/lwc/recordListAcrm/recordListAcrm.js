/* eslint-disable no-console */
import { LightningElement, api } from 'lwc';

export default class RecordListAcrm extends LightningElement {
    @api record;
    @api fieldname;
    @api iconname;
    @api isAccessories = false;
    @api forproductcode = false;
    @api outletConsingneeCode = false;
    @api caseOwnerData = false; //This variable is used for Creating Cases in Inbound 1.1a
    connectedCallback() {
        if (this.outletConsingneeCode === true) {
            this.forproductcode = undefined;
        }
    }
    handleSelect(event) {
        event.preventDefault();
        const selectedRecord = new CustomEvent(
            "select", { detail: this.record.Id }
        );
        /* eslint-disable no-console */
        //console.log( this.record.Id);
        /* fire the event to be handled on the Parent Component */
        this.dispatchEvent(selectedRecord);
    }
}