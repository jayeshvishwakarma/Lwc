/**
	*Developer: Divya Babani;
	*Date: 12/7/2019
 **/
public class EditTileContentController {
    public Tile_Content__c tileContent {get;set;}
    public Attachment tilePdfAttachment{get;set;}
    public Attachment tileThumbAttachment{get;set;}
    public String pdfUrl{get;set;}
    public String thumbnailUrl{get;set;}
    private Attachment pdfData;
    private Attachment thumbnailData;
    
    public boolean isSuccess{get;set;}
    
    public EditTileContentController(ApexPages.StandardController controller) {
        isSuccess = FALSE;
        //Get Id for existing record
        String editContentId = ApexPages.currentPage().getParameters().get('id');
        if(editContentId != null){
            String query = 'SELECT Id,Description FROM Attachment WHERE ParentId=:editContentId';
            List<Attachment> attachmentsList = Database.query(query); 
            for( Attachment att : attachmentsList ){
                if( att.Description != NULL && att.Description == 'Thumbnail' ){
                    thumbnailUrl = getUploadedFileUrl(att.Id);
                    thumbnailData = att;
                    
                }else if(att.Description != NULL && att.Description == 'PDF'){
                    pdfUrl = getUploadedFileUrl(att.Id);
                    pdfData = att;
                }
            }
        }
        tileContent = (Tile_Content__c) controller.getrecord();
        tilePdfAttachment = new Attachment();
        tileThumbAttachment = new Attachment();
    }
    public PageReference SaveTile(){
        try{
            if(tileContent.Type__c == 'YouTube'){
                String fullFileURL = tileContent.PDF__c;
                System.PageReference pageReference = new System.PageReference(fullFileURL );
				Map<String,String> parameters = pageReference.getParameters();	
                if( parameters != NULL && parameters.size() > 0 && parameters.containsKey( 'v' ) ){
                    tileContent.Thumbnail__c = 'https://img.youtube.com/vi/'+ parameters.get( 'v' ) +'/hqdefault.jpg';    
                }
                thumbnailUrl = tileContent.Thumbnail__c;
                if(thumbnailData != NULL){
                    Delete thumbnailData;    
                }
            }
            upsert tileContent;
            if( tilePdfAttachment.Name != NULL ){
                String parentId = tileContent.id;
                tilePdfAttachment.parentId = tileContent.id;
                tilePdfAttachment.Description = 'PDF';
                if(pdfData != NULL){
                    Delete pdfData;    
                }
                insert tilePdfAttachment;
                //String imageURL ='/servlet/servlet.FileDownload?file=';
                String fullFileURL = getUploadedFileUrl(tilePdfAttachment.id);
                tileContent.PDF__c = fullFileURL;
                pdfUrl = fullFileURL;
                update tileContent;
                tilePdfAttachment = new Attachment();
                
            }
            
            if( tileThumbAttachment.Name != NULL ){
                    String parentId = tileContent.id;
                    tileThumbAttachment.parentId = tileContent.id;
                    tileThumbAttachment.Description = 'Thumbnail'; 
                    if(thumbnailData != NULL){
                        Delete thumbnailData;    
                    }
                    insert tileThumbAttachment;
                    //String imageURL ='/servlet/servlet.FileDownload?file=';
                    String fullFileURL = getUploadedFileUrl(tileThumbAttachment.id);
                    tileContent.Thumbnail__c = fullFileURL  ;
                    thumbnailUrl = fullFileURL  ;
                    update tileContent;
                    tileThumbAttachment = new Attachment();
            }
            
            isSuccess = TRUE;
        }Catch( Exception e){
            
        }
        
        return null;
    }
    
    private String getUploadedFileUrl(String attachmentId){
        String imageURL ='/servlet/servlet.FileDownload?file='; 
        String fullFileURL = imageURL + attachmentId;
        return fullFileURL;
    }
}