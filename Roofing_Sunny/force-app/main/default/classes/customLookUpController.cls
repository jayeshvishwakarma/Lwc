public class customLookUpController {
    @AuraEnabled
    public static List <sObject> fetchLookUpValues(String searchKeyWord,String fieldsToShow,String addlfieldsToQuery, String searchField, String lookupFilter, String orderByField, String ObjectName, Boolean doGlobalSearch) {        
        List < sObject > returnList = new List < sObject > ();  
        if(!doGlobalSearch){
            String searchKey = searchKeyWord + '%';                
            String[] searchFields = searchField.split(',');
            string searchString = '';
            for(String field : searchFields){
                if(searchString ==''){
                    searchString = field + ' LIKE: searchKey';
                }
                else{
                    searchString += ' OR ' + field + ' LIKE: searchKey';
                }           
            }
            searchString = '(' + searchString + ')';
            String sQuery =  'select id,' + fieldsToShow + addlfieldsToQuery + ' from ' +ObjectName + ' where ' + searchString;
            if(lookupFilter != ''){
                sQuery =  sQuery + ' AND '+ lookupFilter;    
            }  
            if(orderByField != ''){
                sQuery =  sQuery + ' order by '+ orderByField + ' ASC ';                
            }
            sQuery = sQuery + ' LIMIT 10';        
            system.debug('sQuery==>' + sQuery);
            List < sObject > lstOfRecords = Database.query(sQuery);        
            for (sObject obj: lstOfRecords) {
                returnList.add(obj);
            }
        }else{
            searchKeyWord = '\''+ searchKeyWord +'\'';
            String SOSL_search_string='FIND ' + searchKeyWord + ' IN ALL FIELDS RETURNING ' + ObjectName + '(id, ' + searchField + ' WHERE ' + lookupFilter +') LIMIT 10'; 
            system.debug('SOSL_search_string==>' + SOSL_search_string);
            List<List<SObject>>searchList=search.query(SOSL_search_string);
            for (sObject obj : searchList[0]) {               
                returnList.add(obj);
            } 			
        }    
        
        return returnList;
    }
}