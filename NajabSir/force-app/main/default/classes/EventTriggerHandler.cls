/** ------------------------------------------------------------------------------------
    Author:         Deepak Kumar
    Description:    Event Trigger handler
    History:
    Date            Author             Comments
    --------------------------------------------------------------------------------------
    23-06-2020      Deepak Kumar       Initial Release
  ------------------------------------------------------------------------------------*/
public without sharing class EventTriggerHandler extends TriggerHandler {

    private Map<Id, Event> newEventMap; //Used to store the map of new Events
    private List<Event> newEventList; // Used to store the list of new Events
    private Map<Id, Event> oldEventMap; // Used to store Map of old Events

    //Constructor -- assigns all the trigger context variables objects into class variables defined above
    public EventTriggerHandler() {
        this.newEventMap = (Map<Id, Event>) Trigger.newMap;
        this.newEventList = (List<Event>) Trigger.new;
        this.oldEventMap = (Map<Id, Event>) Trigger.oldMap;
    }
    public override void beforeInsert() {
        populateDelegationRequestDetails();
    }
    //Methods executions before update of Events
    public override void beforeUpdate() {

    }
    //Methods executions after Insert of Events
    public override void afterInsert() {
        addRequesterAsInvitee();
    }
    //Methods executions after update of Events
    public override void afterUpdate() {
        updateDelegatedApproverOnUser();
    }
    /**
    Author:         Deepak Kumar
    Description:    Method to populated the Delegation Request details
    History:
    Date            Author             Comments
    ------------------------------------------------------------
    23-06-2020      Deepak Kumar       Initial Release
    ------------------------------------------------------------- */
    public void populateDelegationRequestDetails() {
        for (Event event : newEventList) {
            event.Delegation_Requested_By__c = UserInfo.getUserId();
            event.Delegation_Request_Status__c = ConstantsUtility.EVENT_DELEGATION_REQUEST_STATUS_PENDING;
        }
    }
    /**
    Author:         Deepak Kumar
    Description:    Method to create EventRelation based on the Delegation Request details
    History:
    Date            Author             Comments
    ------------------------------------------------------------
    23-06-2020      Deepak Kumar       Initial Release
    ------------------------------------------------------------- */
    public void addRequesterAsInvitee() {
        try {
            List<EventRelation> eventRelations = new List<EventRelation>();
            for (Event event : newEventList) {
                if (event.Delegation_Requested_By__c != null && event.Delegation_Request_Status__c == ConstantsUtility.EVENT_DELEGATION_REQUEST_STATUS_PENDING) {
                    EventRelation eventRelation = new EventRelation();
                    eventRelation.EventId = event.Id;
                    eventRelation.IsInvitee = true;
                    eventRelation.Status = ConstantsUtility.EVENT_RELATION_STATUS_NEW;
                    eventRelation.RelationId = event.Delegation_Requested_By__c ;
                    eventRelations.add(eventRelation);
                    //System.debug('event ::'+event);
                }
            }
            if (eventRelations.size() > 0) {
                insert eventRelations;
            }
        } catch (Exception exp) {
            ExceptionHandler.LogError('EventTriggerHandler - addRequesterAsInvitee', exp.getMessage(), 'Event', null, null);
            throw new unexpectedException('An exception has occurred. Please contact your salesforce administrator ::  '+exp.getMessage());
        }
    }
    /**
      Author:         Deepak Kumar
      Description:    Method to update the User based on Delegation Request
      History:
      Date            Author             Comments
      ------------------------------------------------------------
      23-06-2020      Deepak Kumar       Initial Release
      ------------------------------------------------------------- */
    public void updateDelegatedApproverOnUser() {
        try {
            List<User> usersToUpdate = new List<User>();
            for (Event event : newEventList) {
                if (event.Delegation_Request_Status__c == ConstantsUtility.EVENT_DELEGATION_REQUEST_STATUS_ACCEPTED &&
                        event.Delegation_Request_Status__c != oldEventMap.get(event.Id).Delegation_Request_Status__c) {
                    User user = new User();
                    user.Id = event.Delegation_Requested_By__c;
                    user.DelegatedApproverId = event.OwnerId;
                    user.Is_Delegated_User__c = true;
                    usersToUpdate.add(user);
                }
            }
            if (usersToUpdate.size() > 0) {
                TriggerHandler.bypass('UserTriggerHandler');
                update usersToUpdate;
                TriggerHandler.clearBypass('UserTriggerHandler');
            }
        } catch (Exception exp) {
            ExceptionHandler.LogError('EventTriggerHandler - updateDelegatedApproverOnUser', exp.getMessage(), 'Event', null, null);
            throw new unexpectedException('An exception has occurred. Please contact your salesforce administrator: '+exp.getMessage());
        }
    }
}