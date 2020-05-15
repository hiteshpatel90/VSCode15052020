import { LightningElement,api, wire  } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import NAME_FIELD from '@salesforce/schema/Research__c.Name';
import TEMPLATE_FIELD from '@salesforce/schema/Research__c.Research_Template__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import sendEmailToparticipant from '@salesforce/apex/sendDocumentToParticipantController.sendSignRequestToParticipant';
const fields = [NAME_FIELD, TEMPLATE_FIELD];
export default class SendDocumentToParticipant extends LightningElement {
    @api recordId;
    @api objectApiName = 'Research__c';
    @wire(getRecord, { recordId: '$recordId', fields })
    objResearch;
    get name() {
        return getFieldValue(this.objResearch.data, NAME_FIELD);
    }
    get templateName() {
        return getFieldValue(this.objResearch.data, TEMPLATE_FIELD);
    }
    handleSendClick(event) {
        sendEmailToparticipant({ strResearchId: this.recordId })
        .then(result => {this.accounts = result;
            this.dispatchEvent(new ShowToastEvent({
                title: 'Success',
                message: 'Sign Request has been sent successfully.',
                variant: 'success',
              }));
              this.dispatchEvent(new CustomEvent('close'));
        })
        .catch(error => {
            this.error = error;
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: error,
                variant: 'errpr',
              }));
        });
    }
}