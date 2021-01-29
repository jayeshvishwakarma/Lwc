/**
    Author: Deepak Kumar
    Company: Techmatrix
    Description: This apex class is design to send the chatter notification to the users
    History:
    * Ver         Date                     Author                    Modification
    *==============================================================================
    * 1.0        30/06/2020                Deepak Kumar              Initial Version
**/
public with sharing class ChatterNotificationUtil {
    /**
        Author: Deepak Kumar
        Company: Techmatrix
        Description: This method is design to post the chatter notifications
        inputs : Map of RecordId and Set of related users String, recordId and related Message Map
        History:
        * Ver         Date                     Author                    Modification
        *==============================================================================
        * 1.0        30/06/2020                Deepak Kumar              Initial Version
    **/
    public static void sendChatterNotification(Map<Id, Set<String>> escalationUsers,Map<Id, String> recordIdVsMessageMap){

       try {

           //For bulk chatter post
           List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();
           for (String recId : escalationUsers.keySet()) {
               //Create chatter message body
               ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
               messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
               //Create text message for chatter
               ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
               //Feed element input
               ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();

               //Get the message based on escalation type
               String messageBody = recordIdVsMessageMap.get(recId);

               //Add the message body in body input of feedElement
               textSegmentInput.text = messageBody + ' ';
               messageBodyInput.messageSegments.add(textSegmentInput);

               //Add all the users id to receive chatter post and notification
               for (String chatterUser : escalationUsers.get(recId)) {
                   ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
                   mentionSegmentInput.id = chatterUser;
                   messageBodyInput.messageSegments.add(mentionSegmentInput);
               }
               //Add the complete body along with @mentioned users in feed body
               feedItemInput.body = messageBodyInput;
               feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
               //Chatter post against enquiry
               feedItemInput.subjectId = recId;
               //Make it visible to internal and external users
               feedItemInput.visibility = ConnectApi.FeedItemVisibilityType.AllUsers;
               //Create a batch of inputs for bulk chatter post
               ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(feedItemInput);
               batchInputs.add(batchInput);
           }
           Bypass_Setting__c bypass = Bypass_Setting__c.getInstance();
           if (!Test.isRunningTest() && !bypass.Skip_ATM_Chatter_Notification__c) {
               //Post to chatter
               //System.debug('batchInputs' + batchInputs);
               List<ConnectApi.BatchResult> batchResults = ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchInputs);
               for (ConnectApi.BatchResult batchResult : batchResults) {
                   System.debug('Send Chatter notification is success :: ' + batchResult.isSuccess());
                   System.debug(batchResult.getErrorMessage());
                   // System.debug('batchResult '+batchResult.errorMessage);
               }
           }
       } catch (Exception exp) {
           System.debug('Exception  Message :: ' + exp.getMessage() + ' At ' + exp.getStackTraceString());
           ExceptionHandler.LogError('ChatterNotificationUtil', exp.getMessage(), '', '', null);
       }

    }

}