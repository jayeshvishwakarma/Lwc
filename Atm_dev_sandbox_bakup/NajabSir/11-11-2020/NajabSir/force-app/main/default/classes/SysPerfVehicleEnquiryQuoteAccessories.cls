/**
* @File Name          : SysPerfVehicleEnquiryQuoteAccessories.cls
* @Description        : This class will create a performance log Vehicle Enquiry quote accessories process.
* @Author             : 
* @Group              :  
* @Last Modified By   : Ravi Gupta
* @Last Modified On   : 28th Nov 2019
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author      		      Modification
*==============================================================================
* 1.0    28/11/2019,       			Ravi Gupta    			  Initial Version
**/
Public class SysPerfVehicleEnquiryQuoteAccessories implements HandlerInterface{
    
    public static void ProcessData(){
        Performance_Logger__c pLog = new Performance_Logger__c();
        Savepoint sp = Database.setSavepoint();
        // creating the variant product
        List<Product2> proVariantList = UtilityClass.createProduct(1);
        insert proVariantList;
        // storing the maximum limit for the loop to execute from custom label 
        integer maxLimit=integer.valueOf(System.Label.Maximum_Limit);
        //limit before
        UtilityClass.tempWrap lw =UtilityClass.LimitInitmthod();
        Decimal totTime =0;        
        for(Integer i=1; i<=maxLimit; i++){
            //ith Run
            decimal  timeBefore = Datetime.now().getTime();
            // defining the before time of enquiry creation
            timeBefore = Datetime.now().getTime();
            List<Product2> prodList = AddLineItemCtrlHelper.getAccessoriesInfo(ConstantsUtility.ACCESSORIES_SALES_CONST,proVariantList[0].Id,proVariantList[0].Name,'Name');
            
            // defining the after time of enquiry creation
            decimal timeAfter = Datetime.now().getTime();
            system.debug(timeBefore+'>>>'+timeAfter);
            // defining the actual time for the Enquiry creation  
            decimal tim= timeAfter - timeBefore;
            pLog.put('Run_'+i+'__c',tim);
            totTime+=tim;
        }
        //limit after
        UtilityClass.tempWrap lw1 =UtilityClass.LimitInitmthod();
        Database.rollback(sp);
        //avg
        pLog.Average_Run_Time__c = (totTime)/maxLimit;
        Performance__mdt prfm = UtilityClass.fetchMetadata('Vehicle_Enquiry_Quote_Accessories');
        plog.Use_Case__c = prfm.MasterLabel;
        plog.Category__c= prfm.Category__c;
        Map<string,Integer> limitMap = UtilityClass.calculateLimit(lw,lw1,maxLimit);
        system.debug('>>>'+limitMap);
        for(string ky : limitMap.keySet()){
            plog.put(ky+'__c',limitMap.get(ky));
        }
        insert pLog;          
    }
    
}