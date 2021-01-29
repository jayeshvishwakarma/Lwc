/**
* @File Name          : CategoryTriggerHandler.cls
* @Description        : Trigger handler class for Category Object
* @Author             : 
* @Group              : 
* @Last Modified By   : 
* @Last Modified On   : 4/6/2020, 11:29:29 PM
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0    4/6/2020, 11:29:29 PM                               Initial Version 
**/ 
public class CategoryTriggerHandler extends TriggerHandler{
	
    //List variable for trigger.new records
    private list<Category__c> newCategoryList;
    
    //Constructor
    public CategoryTriggerHandler() {
        this.newCategoryList= (List<Category__c>) Trigger.new;
    }
    
    //Method to run on Before Insert
    public override void beforeInsert() {
        //method to update the external Id fields on the Category Object
        updateExternalId();
    }
    
    //Method to run on Before Insert
    public override void beforeUpdate() {
        //method to update the external Id fields on the Category Object
        updateExternalId();
    }
    
    
    /**
        Author: Gitika
        Company: Techmatrix
        Description: Method to update the external Id fields on Category records to maintain uniqueness of each record. 
        Returns: void
        History:
        * Ver         Date                     Author                    Modification
        *==============================================================================
        * 1.0        05/06/2020                Deepak                   Initial Version
	**/ 
    public void updateExternalId(){
        
        //Loop through all the Category List
        for(Category__c cat : this.newCategoryList){
            //Variable to store the unique external Id
            String external_Id = cat.Name;
            //Variable to store the external Id for query optimzation
            String query_external_Id = '';
             
            
            //If category type is not blank
            if(cat.Type__c!=null){
                external_Id+= ConstantsUtility.UNDER_SCORE+cat.Type__c;
            }
            //If category channel is not blank
            if(cat.Channel__c!=null){
                external_Id +=ConstantsUtility.UNDER_SCORE+cat.Channel__c;
                query_external_Id = cat.Channel__c;
            }
            //If category Case Type is not blank
            if(cat.Case_Type__c!=null){
                external_Id +=ConstantsUtility.UNDER_SCORE+cat.Case_Type__c;
                query_external_Id+= ConstantsUtility.UNDER_SCORE+cat.Case_Type__c;
            }
            //If category business area is not blank
            if(cat.Business_Area__c!=null){
                external_Id +=ConstantsUtility.UNDER_SCORE+cat.Business_Area__c;
                query_external_Id+= ConstantsUtility.UNDER_SCORE+cat.Business_Area__c;
            }
            //If category case stage is not blank
            if(cat.Case_Stage__c!=null){
                external_Id +=ConstantsUtility.UNDER_SCORE+cat.Case_Stage__c;
                query_external_Id+= ConstantsUtility.UNDER_SCORE+cat.Case_Stage__c;
            }
            //If category type is not blank
            if(cat.Type__c!=null){
                query_external_Id+=ConstantsUtility.UNDER_SCORE+cat.Type__c;
            }
            //If Primary category is not blank
            if(cat.Primary_Category__c!=null){
                external_Id +=ConstantsUtility.UNDER_SCORE+cat.Primary_Category__c;
                query_external_Id+=ConstantsUtility.UNDER_SCORE+cat.Primary_Category__c;
            }
            //If Secondary category is not blank
            if(cat.Secondary_Category__c!=null){
                external_Id +=ConstantsUtility.UNDER_SCORE+cat.Secondary_Category__c;
                query_external_Id+=ConstantsUtility.UNDER_SCORE+cat.Secondary_Category__c;
            }
            
            //Populate Unique External ID field
            cat.External_ID__c = external_Id;
            //Populate Non-Unique ExternaL ID field for query optimzation
            cat.External_ID_Query__c = query_external_Id;
            
        }
    }
}