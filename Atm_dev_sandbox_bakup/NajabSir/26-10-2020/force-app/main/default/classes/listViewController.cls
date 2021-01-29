/**
 * @File Name          : listViewController.cls
 * @Description        : This class is helper class used in AddLineItemCtrl class.
 * @Author             : Rahul Raghunathan
 * @Group              : 
 * @Last Modified By   : Rahul Raghunathan
 * @Last Modified On   : 05/27/2020, 6:51:48 AM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                Modification
 *==============================================================================
 * 1.0    05/27/2020, 6:51:48 AM      Rahul Raghunathan       Initial Version
**/

public with sharing class listViewController {

     /**
        Author: Rahul Raghunathan
        Company: Salesforce
        Description: This provides the list of listview available for the given user.
        Inputs: object for which the list views have to be fetched
        Returns: List of list views for the given user
        History:
        ================
        1.0     05/27/2020, 6:51:48 AM Rahul Raghunathan     Initial Version
    */
    @AuraEnabled(cacheable=true)
    public static list<listview> fetchLists1(string objectName){

        list<listview> returnList = new list<listview>();//create a new list view variables

        returnList = [select id, name,developername,sobjecttype
                        from listview
                        where sobjecttype = :objectName
                        WITH SECURITY_ENFORCED
                        ];
        
                        return returnList;
    }

}