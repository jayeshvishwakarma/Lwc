@isTest
public class twod_CustomLookupController_Test {
    public static testmethod void testOne(){
        Plants__c wr = new Plants__c(City__c='Greater Noida',Plant_code__c='abc');
        insert wr;
        
        Product2 pr = new Product2(Producing_Warehouse__c=wr.Id, Brand__c='MyBrand',name='def');
        insert pr;
        
        PageReference pageRef = Page.CustomLookupPage;
        Test.setCurrentPage(pageRef);
        
        System.currentPageReference().getParameters().put('search', pr.Id);
        System.currentPageReference().getParameters().put('lksrch', 'abh');
        
        twod_CustomLookupController obj = new twod_CustomLookupController();
        obj.sortExpression='Name';
        string test1=obj.sortExpression;
        obj.getSortDirection();
        obj.setSortDirection('ASC');
        obj.search();
        obj.getFormTag();
        obj.getTextBox();
        obj.ViewData();
    }
    
    public static testmethod void testTwo(){
        Plants__c wr = new Plants__c(City__c='Greater Noida',Plant_code__c='abc');
        insert wr;
        
        Product2 pr = new Product2(Producing_Warehouse__c=wr.Id, Brand__c='MyBrand',name='def');
        insert pr;
        
        PageReference pageRef = Page.CustomLookupPage;
        Test.setCurrentPage(pageRef);
        
        System.currentPageReference().getParameters().put('search', null);
        System.currentPageReference().getParameters().put('lksrch', null);
        
        twod_CustomLookupController obj = new twod_CustomLookupController();
        obj.search();
    }
    
    public static testmethod void testThree(){
        Plants__c wr = new Plants__c(City__c='Greater Noida',Plant_code__c='abc');
        insert wr;
        
        Product2 pr = new Product2(Producing_Warehouse__c=wr.Id, Brand__c='MyBrand',name='def');
        insert pr;
        
        PageReference pageRef = Page.CustomLookupPage;
        Test.setCurrentPage(pageRef);
        
        System.currentPageReference().getParameters().put('search', '');
        System.currentPageReference().getParameters().put('lksrch', 'abh');
        
        twod_CustomLookupController obj = new twod_CustomLookupController();
        obj.search();
    }    
}