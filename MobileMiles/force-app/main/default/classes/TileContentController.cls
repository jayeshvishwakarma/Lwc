public class TileContentController{

    @AuraEnabled
    public static List<CustomTileContent> getContentList(String Category){
        List<CustomTileContent> contList = new List<CustomTileContent>();
        if(Category == 'All'){
            for(Tile_Content__c tl: [Select Id, Name, PDF__c, Description__c,Type__c, Category__c, Sort_Order__c, Thumbnail__c from Tile_Content__c Order By Sort_Order__c]){
                CustomTileContent tileContent = new CustomTileContent();
                tileContent.tileContent = tl;
                tileContent.isVisible = true;
                contList.add(tileContent);
            }
        } else {
            for(Tile_Content__c tl: [Select Id, Name, PDF__c, Description__c,Type__c, Category__c, Sort_Order__c, Thumbnail__c from Tile_Content__c Where Category__c =: Category Order By Sort_Order__c]){
                CustomTileContent tileContent = new CustomTileContent();
                tileContent.tileContent = tl;
                tileContent.isVisible = true;
                contList.add(tileContent);
            }
        }
        return contList;
    }
    
    public class CustomTileContent{
        @AuraEnabled
        public boolean isVisible{get;set;}
        @AuraEnabled
        public Tile_Content__c tileContent {get;set;}
    }
}