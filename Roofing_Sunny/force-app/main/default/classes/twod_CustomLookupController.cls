public with sharing class twod_CustomLookupController {
    
    public Account account {get;set;} // new account to create
    public List<twod__warranty_product__c> results{get;set;} // search results
    public string searchString{get;set;} // search keyword
    public string search{get;set;} // search
    private String sortDirection = 'ASC';
    private String sortExp;
    private String soqlSort;
    
    public String sortExpression
    {
        get
        {
            return sortExp;
        }
        set
        {
            //if the column is clicked on then switch between Ascending and Descending modes
            if (value == sortExp)
                sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
            else
                sortDirection = 'ASC';
            sortExp = value;
        }
    }
    
    public String getSortDirection()
    {
        //if not column is selected 
        if (sortExpression == null || sortExpression == '')
            return 'ASC';
        else
            return sortDirection;
    }
    
    public void setSortDirection(String value)
    {  
        sortDirection = value;
    }
    
    
    
    public PageReference ViewData() {
        //build the full sort expression
        string sortFullExp = sortExpression  + ' ' + sortDirection;
        
        //query the database based on the sort expression
        results = Database.query(soqlSort +' order by ' + sortFullExp + ' LIMIT 1000');
        return null;
    }

    public twod_CustomLookupController() {
        account = new Account();
        // get the current search string
        searchString = System.currentPageReference().getParameters().get('lksrch');
        search = System.currentPageReference().getParameters().get('search');
        runSearch();  
    }
    
    // performs the keyword search
    public PageReference search() {
        runSearch();
        return null;
    }
    
    // prepare the query and issue the search command
    private void runSearch() {
        // TODO prepare query string for complex serarches & prevent injections
        results = performSearch(searchString);               
    } 
    
    // run the search and return the records found. 
    private List<twod__warranty_product__c> performSearch(string searchString) {
        
        String soql = 'select id, twod__Description__c,name,Product_Colour__c,twod__Product_Name__c,Producing_Plant__c,Producing_Plant__r.Name,Producing_Plant__r.Warehouse_Description__c,Product_Type__r.Name,Active__c,Is_Obsolete__c from twod__warranty_product__c';
        if(searchString != '' && searchString != null)
        {    
            if(search!='')
                soql = soql +  ' where (name LIKE \'%' + searchString +'%\' or twod__Product_Name__c LIKE \'%' + searchString +'%\')and Producing_Plant__c =\'' +search+'\'' ;
            else
                soql = soql +  ' where name LIKE \'%' + searchString +'%\'';
        }
        else
        {
             if(search!='')
                soql = soql +  ' where Producing_Plant__c =\'' +search+'\'' ;            
        }        
        soqlSort = soql;
        soql=soql+' LIMIT 1000 ';
        System.debug(soql);
        try{
        return database.query(soql); 
        }
        catch(Exception e)
        {
           soql = 'select id, twod__Description__c,name,Product_Colour__c,twod__Product_Name__c,Producing_Plant__c,Producing_Plant__r.Name,Producing_Plant__r.Warehouse_Description__c,Product_Type__r.Name,Active__c,Is_Obsolete__c from twod__warranty_product__c';
            if(searchString!='')
                soql = soql +  ' where name LIKE \'%' + searchString +'%\' LIMIT 1000';
            soql = soql;
            return database.query(soql);
        }
        
    }
    
    // save the new account record
   /* public PageReference saveAccount() {
        insert account;
        // reset the account
        account = new Account();
        return null;
    }*/
    
    // used by the visualforce page to send the link to the right dom element
    public string getFormTag() {
        return System.currentPageReference().getParameters().get('frm');
    }
    
    // used by the visualforce page to send the link to the right dom element for the text box
    public string getTextBox() {
        return System.currentPageReference().getParameters().get('txt');
    }
    
}