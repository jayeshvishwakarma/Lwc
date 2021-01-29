@RestResource(urlmapping='/iBirds/BookManagement/*')
global class BookService {
    
    @httpGet
    global static String doGetBooks()
    {
        Book__c ObjBook= new Book__c(Name='java',Price__c=200);
        return 'Request Recieved...................?';
    }
    @httpPost
    global static String doCreateBook()
    {
        return null;
    }
    @httpPut
    global static String doUpdateBook()
    {
        return null;
    }
    @httpDelete
    global static String doDeleteBooks()
    {
        return null;
    }
    @httpPatch
    global static String doUpsertBooks()
    {
        return null;
    }

}