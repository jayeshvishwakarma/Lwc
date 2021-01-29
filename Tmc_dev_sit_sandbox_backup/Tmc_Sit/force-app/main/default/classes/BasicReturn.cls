/**
 * @File Name          : BasicReturn.cls
 * @Description        : This class is used for custom return type(From Apex to LWC)
 * @Author             : Sunit Kumar Chand
 * @Group              : 
 * @Last Modified By   : Sunit Kumar Chand
 * @Last Modified On   : 8/01/2019,11:37:23 AM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                    Modification
 *==============================================================================
 * 1.0    8/01/2019,11:37:23 AM   Sunit Kumar Chand     Initial Version
 * 
**/

//CODE REVIEWED BY: Prabhat Sharma

public class BasicReturn {
    @AuraEnabled
    public String message {get;set;}
    @AuraEnabled
    public String status {get;set;}
    @AuraEnabled
    public Integer code {get;set;}
    @AuraEnabled
    public List<Object> dataList {get;set;}
    @AuraEnabled
    public String createdId {get;set;}
    @AuraEnabled
    public Object data {get;set;}
    @AuraEnabled
    public Map<String,String> getStringMap {get;set;}
            

}