/**
 * Name             : IBSCarouselComponentController
 * Description      : This is component controller for LWC component ibs_carousel
 * Author           : Aslam Bari (iBirds Services)
 * Date             : 29 May, 2020
**/
public class IBSCarouselComponentController {
    
    @AuraEnabled(cacheable=true)  
    public static List<FeedItemModel> fetchFeedDataFromApexClass(string apexClassName, string titleField, string linkField,
                                                  string descriptionField, string authorField, string publishDateField,
                                                  string tagField, string imageField){
        Type clsName = Type.forName(apexClassName);
        IBSCarouselClassInterface ibsInterface = (IBSCarouselClassInterface)clsName.newInstance();
        List<Map<string,string>> feedDataList = ibsInterface.getDataListMap();
        
        System.debug('@@@feedDataList '+feedDataList);
        List<FeedItemModel> feedList = new List<FeedItemModel>();
        for(Map<string,string> record : feedDataList){

           feedList.add( new FeedItemModel(
                    record.containsKey(titleField)? record.get(titleField) : '',
                    record.containsKey(linkField) ? record.get(linkField):  '',
                    record.containsKey(descriptionField) ? record.get(descriptionField) : '',
                    record.containsKey(authorField) ? record.get(authorField) : '',
                    record.containsKey(publishDateField) ? record.get(publishDateField) : '',
                    record.containsKey(tagField) ? record.get(tagField).split(',') : new List<string>(),
                    record.containsKey(imageField) ? record.get(imageField) : ''
           ));
        }
    
        return feedList;
                                                      
    }
    
    public class FeedItemModel{
        @AuraEnabled
        public string title;
        
        @AuraEnabled
        public string link;
        
        @AuraEnabled
        public string description;
        
        @AuraEnabled
        public string author;
        
        @AuraEnabled
        public string publishdate;
        
        @AuraEnabled
        public List<string> tags;
        
        @AuraEnabled
        public string imageurl;
        
        public FeedItemModel(string titleFieldData, string linkFieldData,
                             string descriptionFieldData, string authorFieldData, 
                             string publishDateFieldData, List<string> tagFieldData, string imageFieldData){
                  this.title = titleFieldData;   
                  this.link = linkFieldData;
                  this.description = descriptionFieldData;
                  this.author = authorFieldData;
                  this.publishdate = publishDateFieldData;
                  this.tags = tagFieldData;
                  this.imageurl = imageFieldData;               
        }
    } 
}