/**
 * @File Name          : ChatterNotification.cls
 * @Description        : 
 * @Author             : Sunit Kumar Chand
 * @Group              : 
 * @Last Modified By   : Sunit Kumar Chand
 * @Last Modified On   : 29/07/2019, 12:45:23 PM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    29/07/2019, 12:45:23 PM   Sunit Kumar Chand     Initial Version
**/
public without sharing class ChatterNotification {
 /**
   Author: Sunit kumar chand
   Company: Techmatrix
   Description: Method to be accessed by process builder
   Inputs: List of Opportunities
   Returns:
   History:
   ================
   1.0     29 Jul 2019      Sunit Kumar Chand     Initial Version
*/
    @InvocableMethod(label='Notify Owner')
    public static void postFeed(List<Opportunity> oppList)
    {
        for(Opportunity opp: oppList)
        {
            createChatterPost(opp.OwnerId,opp.Id,'new');
            if(UserInfo.getUserId()!=opp.Previous_Enquiry_Owner__c)
            {
                System.debug('Hi Inside if');
                createChatterPost(opp.Previous_Enquiry_Owner__c,opp.Id,'old');
            }
            
        }
        
    }
 /**
   Author: Sunit kumar chand
   Company: Techmatrix
   Description: Its a utility method used to create chatter post.
   Inputs: userId,OpportunityId and type
   Returns:
   History:
   ================
   1.0     29 Jul 2019      Sunit Kumar Chand     Initial Version
*/
    public static void createChatterPost(String ownerId,String oppId,String typeMessage)
    {
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        ConnectApi.MarkupBeginSegmentInput markupBeginSegmentInput= new ConnectApi.MarkupBeginSegmentInput();
            markupBeginSegmentInput.markupType=ConnectApi.MarkupType.PARAGRAPH;
            ConnectApi.MarkupEndSegmentInput markupEndSegment;
            ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
            ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
            ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
        	
            mentionSegmentInput.id =ownerId;
        	
            messageBodyInput.messageSegments.add(markupBeginSegmentInput);
            messageBodyInput.messageSegments.add(mentionSegmentInput);
        	
        	textSegmentInput.text = ' A new prospect has been assigned to you. Here are the details, Please get in touch asap.\n\tName:\n\tPhone:\n\tE-Mail:';
        	if(typeMessage=='old')
            {
                textSegmentInput.text = ' Here are the details, Please get in touch asap.\n\tName:\n\tPhone:\n\tE-Mail:';
            }
            messageBodyInput.messageSegments.add(textSegmentInput);
            markupEndSegment = new ConnectApi.MarkupEndSegmentInput();
            markupEndSegment.markupType = ConnectApi.MarkupType.PARAGRAPH;
            messageBodyInput.messageSegments.add(markupEndSegment);
            System.debug(messageBodyInput);
            feedItemInput.body = messageBodyInput;
            feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
            feedItemInput.subjectId = oppId;
            feedItemInput.visibility = ConnectApi.FeedItemVisibilityType.AllUsers;
			ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkid(), feedItemInput);
    }
}