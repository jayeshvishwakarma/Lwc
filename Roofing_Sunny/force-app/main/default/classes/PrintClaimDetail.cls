/*
*	Name : PrintClaimDetail
*  Created By : Lalit K Malav (Appirio India)
*  Created Date : 4/18/2018 
*  Reference : S-543096
*/
public with sharing class PrintClaimDetail {
	private final twod__Claim__c claim;
	public List<twod__Claim__History> claimHistoryList{get;set;}
	//public List<AttachmentWrapper> attachmenWrapList{get;set;}
	public List<Attachment> attList {get;set;}
	public List<Note> noteList {get;set;}
	public List<ContentDocumentLink> contentDocList ;
	public List<ContentVersion> contentVersionList {get;set;}
	
	public PrintClaimDetail(ApexPages.StandardController stdController) {
        this.claim = (twod__Claim__c)stdController.getRecord();
        claimHistoryList = new List<twod__Claim__History>();
        //attachmenWrapList = new List<AttachmentWrapper>();
        attList = new List<Attachment>();
        noteList = new List<Note>();
        contentDocList = new List<ContentDocumentLink>();
        contentVersionList = new List<ContentVersion>();
        getClaimHistories();
    }
    private void getClaimHistories(){
    		claimHistoryList = [Select ParentId, OldValue, NewValue,  Id, Field, CreatedDate, CreatedBy.name From twod__Claim__History where parentId= :claim.id Order By CreatedDate];
    		//attachmentList = [Select Name, LastModifiedDate, LastModifiedById,body From Attachment where parentId= :claim.id Order By CreatedDate];
    		
    		/*for(Attachment att :[Select Name, LastModifiedDate, LastModifiedById From Attachment where parentId= :claim.id Order By CreatedDate]){
    			String strBodyUnEncode = EncodingUtil.base64Encode(att.body);
    			//String decodedStr = EncodingUtil.urlDecode(strBodyUnEncode,'UTF-8');
    			attachmenWrapList.add(new AttachmentWrapper(strBodyUnEncode, att)); 
    		}*/
    		attList = [Select id, Name, LastModifiedDate, LastModifiedById From Attachment where parentId= :claim.id Order By CreatedDate];
    		noteList= [Select Id, Body, LastModifiedDate,Title,CreatedBy.name from Note where parentId= :claim.id Order By CreatedDate];
    		Set<Id> contentDocIdSet = new  Set<Id>();
    		for(ContentDocumentLink contentDoc : [SELECT Id,LinkedEntityId,ContentDocumentId, ContentDocument.Description,ContentDocument.title,ContentDocument.lastmodifiedDate FROM ContentDocumentLink  WHERE ContentDocument.PublishStatus = 'P' AND ContentDocument.FileType = 'SNOTE' AND ContentDocument.IsArchived=false AND LinkedEntityId = :claim.id Order By ContentDocument.lastmodifiedDate]){
    			contentDocIdSet.add(contentDoc.ContentDocumentId);
    		}
    		if(contentDocIdSet.size() > 0){
    			for(Contentversion cv: [SELECT Id,Description, Title,PublishStatus,CreatedBy.name,VersionData, TextPreview,lastmodifiedDate from Contentversion where ContentDocumentId in :contentDocIdSet AND PublishStatus='P' AND IsLatest=true]){
    				
    				String tempData = cv.VersionData.toString();
    				cv.Description = tempData;
    				contentVersionList.add(cv);
    			}
    			 
    		}
    }
    /*public class AttachmentWrapper{ 
	    	public String attachBody {get; set;}
	    public 	Attachment attach {get; set;}
	    	public AttachmentWrapper(String body, Attachment att){
	    		this.attachBody = body;
	    		this.attach = att;
	    	}
    }*/
}