@isTest
private class TileContentControllerTest{
    @isTest
    static void TestUnit()
    {
        Tile_Content__c newRecord = new Tile_Content__c(Name = 'Try', Category__c = 'Manuals');
        insert newRecord;
        
        List<TileContentController.CustomTileContent> result = TileContentController.getContentList('Manuals');
        System.assertNotEquals(null, result);
        List<TileContentController.CustomTileContent> result2 = TileContentController.getContentList('All');
        System.assertNotEquals(null, result2);
        MyCategoryPickList cpl = new MyCategoryPickList();
        cpl.getDefaultValue();
        cpl.getValues();
    }
}