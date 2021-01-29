global class AccountRetrieval{
    webService static String getAccounts(String cli, String accQuery, String contQuery) {
       String whereac = accQuery.length() > 5 ? (' WHERE ' + accQuery) : '';
       String wherect = contQuery.length() > 5 ? (' WHERE ' + contQuery) : '';

       String sQuery = 'FIND \'' + cli + '\' IN PHONE FIELDS RETURNING Account(id, name' 
           + whereac + '), Contact(id, name' + wherect + ')';
       List<List<SObject>> searchList = search.query(sQuery);
       String JSONString = JSON.serialize(searchList);
       return JSONString;
    }
}