@isTest
public class TestEditTileContentController {
	@isTest
    public static void testMethod1(){
        PageReference pageRef = Page.EditTileContentPage;
        Tile_Content__c tileConObj = new Tile_Content__c();
        tileConObj.Name = 'testtile';
        tileConObj.Type__c = 'YouTube';
        tileConObj.PDF__c = 'https://www.youtube.com/watch?v=aTUS-SFSvfw';
        insert tileConObj; 
   
        Test.setCurrentPage(pageRef);
   		pageRef.getParameters().put('id',tileConObj.id);
        EditTileContentController conObj = new EditTileContentController(new ApexPages.StandardController(tileConObj));
        conObj.SaveTile();    
       
    }
    @isTest
    public static void testMethod2(){
        PageReference pageRef = Page.EditTileContentPage;
        Tile_Content__c tileConObj = new Tile_Content__c();
        tileConObj.Name = 'testtile';
        tileConObj.Type__c = 'PDF'; 
        
        Attachment attach=new Attachment();   	
    	attach.Name='Unit Test Attachment';
    	Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
    	attach.body=bodyBlob;
        attach.Description='Thumbnail';
        
        Attachment attach2=new Attachment();   	
    	attach2.Name='Unit Test Attachment';
    	Blob bodyBlob2=Blob.valueOf('Unit Test Attachment Body');
    	attach2.body=bodyBlob2;
        attach2.Description='PDF';
   
        EditTileContentController conObj = new EditTileContentController(new ApexPages.StandardController(tileConObj));
        conObj.tileThumbAttachment = attach;
        conObj.tilePdfAttachment = attach2;
        conObj.SaveTile();   
        
        pageRef.getParameters().put( 'id', tileConObj.Id );
       	Test.setCurrentPage( pageRef );
        
        Attachment attach3=new Attachment();   	
    	attach3.Name='Unit Test Attachment';
    	Blob bodyBlob3=Blob.valueOf('Unit Test Attachment Body');
    	attach3.body=bodyBlob3;
        attach3.Description='PDF';
        
        EditTileContentController conObj2 = new EditTileContentController(new ApexPages.StandardController(tileConObj));
        conObj2.tilePdfAttachment =attach3;
        conObj2.SaveTile();    
    }
}