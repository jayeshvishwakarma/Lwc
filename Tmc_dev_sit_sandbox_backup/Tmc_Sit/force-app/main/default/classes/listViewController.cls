public class listViewController {
    /*apex method to fetch wrapper of list view*/ 
    @AuraEnabled(Cacheable=true)
    public static list<ListView> listValues(string objectName){ 
      return [SELECT Id, Name, DeveloperName,sObjectType FROM ListView
                           WHERE sObjectType = : objectName ORDER By Name ASC];
    } 
    /*wrapper class to store listView details*/  
   
}