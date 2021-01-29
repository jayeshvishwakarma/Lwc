/*------------------------------------------------------------------------------------
Author:        Sumit Gupta
Description:   Lookup Input Field Controller

History
Date            Author             Comments
--------------------------------------------------------------------------------------
13-12-2019      Sumit Gupta        Initial Release
------------------------------------------------------------------------------------*/
public without sharing class LookupInputFieldCtrl {
    
    private static String BASE_QUERY = 'FIND {0} IN NAME FIELDS RETURNING {1}(Id, Name WHERE Name Like {2} {3} LIMIT 200)';

    @AuraEnabled(Cacheable=true)
    public static List<SearchResult> search(String objectName, String searchTerm, String recordType) {
        String whereClause = '';
        if(String.isNotBlank(recordType)){
            whereClause = 'AND RecordType.DeveloperName = \'' + recordType + '\'';
        }
        List<Object> formatOptions = new List<Object>{ '\'' + searchTerm + '*\'', objectName, '\'%' + searchTerm + '%\'', whereClause };
        List<SObject> records = Search.query(String.format(BASE_QUERY, formatOptions)).get(0);
        // Prepare results
        List<SearchResult> results = new List<SearchResult>();
        for (SObject record : records) {
            results.add(new SearchResult(String.valueOf(record.get('Id')), String.valueOf(record.get('Name'))));
        }
        return results;
    }

    public class SearchResult {
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public String title { get; set; }

        public SearchResult(String id, String title){
            this.id = id;
            this.title = title;
        }
    }
}