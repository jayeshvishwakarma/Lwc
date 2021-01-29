/** 
 * Purpose: This class is extension to "RollupSummaryOnCloudCentrale" visual force page 
 * @ Created Date: 18-04-2014 
 * @ Modified Date: [18-04-2014] 
**/ 
public class RollupSummaryOnCloudCentraleExtension {

    private String cloudCentraleRecId;
    public List<RollupField> rollupFields { get; private set; } 
    public String errorSummary { get; private set; }

    // Constructor
    public RollupSummaryOnCloudCentraleExtension(ApexPages.StandardController stdController) 
    {
        cloudCentraleRecId = ((Cloud_Centrale__c) stdController.getRecord()).Id;
        errorSummary = 'Please provide Cloud Centrale record Id in URL <br/>' + 
                       'Example: https://<i>salesforce-instance-name</i>.com/apex/RollupSummaryOnCloudCentrale<b>?id=XXXXXXXXXXXXXXX</b>';
    }
    
    //--@Called From : caluculateRollupSummaryFields
    //--@Purpose     : Returns list of RollupField which contains name and its value
    private List<RollupField> createRollupFields()
    {
        List<RollupField> rollupFieldList = new List<RollupField>();
        
        // Describe the sobject               
        Schema.DescribeSObjectResult objDescResult = Cloud_Gebruikers__c.sObjectType.getDescribe(); 

        // Get a map of fields for the passed sobject    
        Map<String, Schema.SObjectField> fieldMap = objDescResult.fields.getMap(); 
        
        // Grab the list of picklist values for the passed field on the sobject        
        List<Schema.PicklistEntry> picklistValues = fieldMap.get('Gebruikersopties__c').getDescribe().getPickListValues(); 
    
        for (Schema.PicklistEntry picklistEntry : picklistValues) 
        { 
			rollupFieldList.add(new RollupField(picklistEntry.getValue()));
        }
                       
        return rollupFieldList;
    }
    

    //--@Called From : Visualforce page - on action of "<apex:page>"
    //--@Purpose     : Calculates roll up summary field on "Cloud Centrale" object depending on "Gebruikersopties__c" picklist 
    //                 values of "Cloud Gebruikers" object
    public void caluculateRollupSummaryFields()
    {
        rollupFields = createRollupFields();     
    
        // Retrieve Cloud User object records for specified Cloud Centrale record Id
        List<Cloud_Gebruikers__c> cloudUserList = [SELECT 
                                                       Id, Name,Gebruikersopties__c 
                                                   FROM
                                                       Cloud_Gebruikers__c
                                                   WHERE
                                                       Cloud_Centrale__c = :cloudCentraleRecId
                                                  ];
                                                  
        System.debug('\n\t========== ROLL UP FILEDS ==========\n\t' + rollupFields);
        
        // Iterate through list of Cloud Gebruikers records and count records as per value of "User Option" field
        for(Cloud_Gebruikers__c user : cloudUserList)
        {
            if(user.Gebruikersopties__c != null)
            	modifyRollupField(user.Gebruikersopties__c);            
        }
     
        List<RollupField> rollupFieldsBackup = new List<RollupField>();   
        rollupFieldsBackup = rollupFields;
        rollupFields = new List<RollupField>();                                
        String rollupFieldText = '';        
        
        // Build new list of roll up summary field by removing those field which having zero records associated with them
        for(RollupField rollupField : rollupFieldsBackup)                   
        {
            if(rollupField.fieldValue > 0)  
            {          
                rollupFields.add(rollupField);                
                rollupFieldText += '\n\t Field Name: '+ rollupField.fieldName + '[' + rollupField.fieldValue + ']';
            }
        }
        
        System.debug('\n\t========== ROLLUP SUMMARY FIELDS ========== \n\t' + rollupFieldText + '\n');
    }
    
    //--@Called From : this - caluculateRollupSummaryFields
    //--@Purpose     : Find field in list of RollupField and updates its value. 
    private void modifyRollupField(String userOption)    
    {
        // If userOption contains multiple user then split users and increment record count for each of them
        if(userOption.contains(';'))
        {
            Set<String> userOptionSet = new Set<String>(userOption.split(';'));
            Integer processUserCount = 0;
            
            for(RollupField rollupField : rollupFields)
            {
                if(userOptionSet.contains(rollupField.fieldName))
                {
                    rollupField.fieldValue++; 
                    processUserCount++; 
                    
                    if(processUserCount == userOptionSet.size())
                        break;
                }    
            }
            
        }
        else
        {
            // If user contains only one user in userOption then directly increment value in its Rollup Summary field
            for(RollupField rollupField : rollupFields)
            {
                if(rollupField.fieldName.equals(userOption))
                {
                    rollupField.fieldValue++; 
                    break;
                }                
            }
        }
    }
        
    //--@Purpose : Store rollup summary field with its name as "Picklist" options and value as number of records
    //             for that picklist option     
    public class RollupField
    {
        public String fieldName { get; private set; }
        public Integer fieldValue { get; private set; }
        
        public RollupField(String field_name)
        {
            fieldName = field_name;
            fieldValue = 0;
        }
    }
}