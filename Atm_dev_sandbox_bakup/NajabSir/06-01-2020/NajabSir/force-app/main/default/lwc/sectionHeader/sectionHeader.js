import { LightningElement, api } from 'lwc';

export default class SectionHeader extends LightningElement {
    @api sectionHeading;
    @api sectionSubHeading;
    @api iconName;
}