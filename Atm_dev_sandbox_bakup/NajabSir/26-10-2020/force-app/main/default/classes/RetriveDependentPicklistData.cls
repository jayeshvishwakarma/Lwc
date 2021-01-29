/**
 * @File Name          : RetriveDependentPicklistData.cls
 * @Description        : This class is used to get the list of dependent values related to a perticular picklist value.
 * @Author             : Anuj Kumar
 * @Group              : 
 * @Last Modified By   : Anuj Kumar
 * @Last Modified On   : 29/7/2019 05:30 PM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                Modification
 *==============================================================================
 * 1.0    29/7/2019 11:17 AM          Anuj Kumar            Initial Version
**/

public class RetriveDependentPicklistData {

    /*
        @Author:                  Anuj Kumar
        @Created Date :           29/7/2019
        @Discription:             Take input as a SObject type, controlling field and dependent field and return the map of 
                                  controlling field with its dependent list of values.
        @Date Of Modification :   29/7/2019
    */
    @AuraEnabled 
    public static Map<String, List<String>> getDependentMap(sObject objDetail, string contrfieldApiName,string depfieldApiName) {
        String controllingField = contrfieldApiName.toLowerCase();
        String dependentField = depfieldApiName.toLowerCase();
        
        Map<String,List<String>> objResults = new Map<String,List<String>>();
        
        Schema.sObjectType objType = objDetail.getSObjectType();
        if (objType==null){
            return objResults;
        }
        
        Map<String, Schema.SObjectField> objFieldMap = objType.getDescribe().fields.getMap();
        
        if (!objFieldMap.containsKey(controllingField) || !objFieldMap.containsKey(dependentField)){
            return objResults;     
        }
        
        Schema.SObjectField theField = objFieldMap.get(dependentField);
        Schema.SObjectField ctrlField = objFieldMap.get(controllingField);
        
        List<Schema.PicklistEntry> contrEntries = ctrlField.getDescribe().getPicklistValues();
        List<PicklistEntryWrapper> depEntries = wrapPicklistEntries(theField.getDescribe().getPicklistValues());
        List<String> controllingValues = new List<String>();
        
        for (Schema.PicklistEntry ple : contrEntries) {
            String value = ple.getValue();
            objResults.put(value, new List<String>());
            controllingValues.add(value);
        }
        
        for (PicklistEntryWrapper plew : depEntries) {
            String value = plew.value;
            String validForBits = base64ToBits(plew.validFor);
            for (Integer i = 0; i < validForBits.length(); i++) {
                String bit = validForBits.mid(i, 1);
                if (bit == '1') {
                    objResults.get(controllingValues.get(i)).add(value);
                }
            }
        }
        return objResults;
    }
    
    /*
        @Author:                  Anuj Kumar
        @Created Date :           29/7/2019
        @Discription:             Method To convert the integer value to binary.
        @Date Of Modification :   29/7/2019
    */
    public static String decimalToBinary(Integer val) {
        String bits = '';
        while (val > 0) {
            Integer remainder = Math.mod(val, 2);
            val = Integer.valueOf(Math.floor(val / 2));
            bits = String.valueOf(remainder) + bits;
        }
        return bits;
    }
    
    /*
        @Author:                  Anuj Kumar
        @Created Date :           29/7/2019
        @Discription:             Method To convert the base64 characters To Bits.
        @Date Of Modification :   29/7/2019
    */
    public static String base64ToBits(String validFor) {
        if (String.isEmpty(validFor)){
            return '';
        }
        
        String validForBits = '';
        
        for (Integer i = 0; i < validFor.length(); i++) {
            String thisChar = validFor.mid(i, 1);
            Integer val = BASE64CHARS.indexOf(thisChar);
            String bits = decimalToBinary(val).leftPad(6, '0');
            validForBits += bits;
        }
        
        return validForBits;
    }
    
    private static final String BASE64CHARS = '' +
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
        'abcdefghijklmnopqrstuvwxyz' +
        '0123456789+/';
    
    
    private static List<PicklistEntryWrapper> wrapPicklistEntries(List<Schema.PicklistEntry> pickListEntries) {
        return (List<PicklistEntryWrapper>)
            JSON.deserialize(JSON.serialize(pickListEntries), List<PicklistEntryWrapper>.class);
    }
    
    public class PicklistEntryWrapper{
        public String active {get;set;}
        public String defaultValue {get;set;}
        public String label {get;set;}
        public String value {get;set;}
        public String validFor {get;set;}
        public PicklistEntryWrapper(){            
        }
        
    }
}