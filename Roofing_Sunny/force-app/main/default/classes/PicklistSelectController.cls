public with sharing class PicklistSelectController {
    @AuraEnabled
    public static String getFieldLabel( String objectName, String fieldName ) {        
        System.debug( 'Getting field label: objectName=' + objectName + ', fieldName=' + fieldName );        
        String label = Schema.getGlobalDescribe().get( objectName ).getDescribe().fields.getMap().get( fieldName ).getDescribe().getLabel();        
        System.debug( 'label= ' + label );        
        return label;
    }
    @AuraEnabled
    public static List<PicklistOption> getPicklistOptions( String objectName, String fieldName, String defaultSelected, boolean uppercase) {        
        System.debug( 'Getting picklist options: objectName=' + objectName + ', fieldName=' + fieldName );        
        List<PicklistOption> options = new List<PicklistOption>();            
        options.add( new PicklistOption(defaultSelected, '') );
        if(fieldName == 'Country__c'){
             if(uppercase){
                options.add( new PicklistOption('UNITED STATES', 'UNITED STATES'));
                options.add( new PicklistOption('CANADA', 'CANADA'));
             }
            else{
                 options.add( new PicklistOption('United States', 'United States'));
                options.add( new PicklistOption('Canada', 'Canada'));
            }
        }
        for ( PicklistEntry entry : Schema.getGlobalDescribe().get( objectName ).getDescribe().fields.getMap().get( fieldName ).getDescribe().getPicklistValues() ) {
            if((entry.getValue() != 'United States' && entry.getValue() != 'Canada') || fieldName != 'Country__c'){
                if(uppercase){
                    options.add( new PicklistOption( entry.getLabel().toUpperCase(), entry.getValue().toUpperCase() ) );
                }else{
                    options.add( new PicklistOption( entry.getLabel(), entry.getValue() ) );
                }
            }
            
           
        }        
        System.debug( 'options=' + options );        
        return options;
    }
    public class PicklistOption {        
        @AuraEnabled
        public String label { get; set; }        
        @AuraEnabled
        public String value { get; set; }        
        public PicklistOption( String label, String value ) {
            this.label = label;
            this.value = value;
        }        
    }
    
}