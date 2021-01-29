import { LightningElement,track } from 'lwc';

export default class L8Approvals extends LightningElement {
decisionValue = '';
reasonValue = '';
remarks = '';
reasonOption = [{ label: '--None--', value: '' },
{ label: 'Delay in delivery', value: 'Delay in delivery'},
{ label: 'Demanded repair not captured', value: 'Demanded repair not captured' },
{ label: 'Demanded repair not completed', value: 'Demanded repair not completed'},
{ label: 'Insurance claim settlement', value: 'Insurance claim settlement' },
{ label: 'Poor Diagnosis', value: 'Poor Diagnosis'},
{ label: 'Poor Response', value: 'Poor Response' },
{ label: 'Misbehaviour', value: 'Misbehaviour'},
{ label: 'Poor Washing Quality', value: 'Poor Washing Quality' },
{ label: 'Spares not available', value: 'Spares not available' },
{ label: 'Poor workmanship', value: 'Poor workmanship'},
{ label: 'Overcharging of amount', value: 'Overcharging of amount' },
{ label: 'Poor PDI', value: 'Poor PDI'},
{ label: 'Vehicle damaged/misuse in workshop', value: 'Vehicle damaged/misuse in workshop' },
{ label: 'Inventory Mismatch', value: 'Inventory Mismatch' }
];
 decisionOption = [
        { label: '--None--', value: '' },
        { label: 'Approve', value: 'Approve' },
        { label: 'Reject', value: 'Reject' },
    ];

    showReason = false;

    handleDecision(event) {
        this.decisionValue = event.target.value;
        if(event.target.value === 'Reject') {
            this.showReason = true;
        }
        else {
            this.showReason = false;
        }
    }

    handleReason(event) {
        this.reasonValue = event.target.value;
    }

    handleRemarks(event) {
        this.remarks = event.target.value;
    }
}