trigger Order_Triggers on Order (after update, after insert) {

    /* Author: Sunny Singh (Capgemini)
     * Description: Added check against Custom Setting "Automation Controller", to see if trigger should run
     * Date: 10 December 2020
     */
    if(!Test.isRunningTest() && !Automation_Controller__c.getOrgDefaults().All_Triggers_enabled__c)  return;
    
    if(!Test.isRunningTest() && !Automation_Controller__c.getOrgDefaults().Order_Triggers_Trigger_enabled__c)  return;
    
    
    set<id> OrderIds = new set<id>();
    
    system.debug(LoggingLevel.INFO,'**** Trigger fired');
    
    if(trigger.isafter){
        if(trigger.isUpdate){
           for(Order Ord:trigger.new){
                if(Ord.Sales_Org__c == '1502' || Ord.Sales_Org__c == '1102' || Ord.Sales_Org__c == '1501'){
                    if( (Ord.Total_Cost__c != 0 && Ord.Total_Cost__c != null) || Ord.Planned_Ship_Date__c != null){
                        Order oldOrd = Trigger.oldMap.get(Ord.Id);
                        if(Ord.Total_Cost__c != oldOrd.Total_Cost__c || Ord.Planned_Ship_Date__c != oldOrd.Planned_Ship_Date__c){
                            OrderIds.add(Ord.id);
                            system.debug(LoggingLevel.INFO,'**** Updating cost from' + oldOrd.Total_Cost__c + ' to ' + Ord.Total_Cost__c + ' for order id ' + Ord.id);
                        } 
                     }   
                }    
            }
        }
            
        if(trigger.isInsert){
            for(Order Ord:trigger.new){
                if(Ord.Sales_Org__c == '1502' || Ord.Sales_Org__c == '1102' || Ord.Sales_Org__c == '1501'){
                    if( (Ord.Total_Cost__c != 0 && Ord.Total_Cost__c != null) || Ord.Planned_Ship_Date__c != null ){
                        OrderIds.add(Ord.id);
                        system.debug(LoggingLevel.INFO,'**** Adding cost of ' + Ord.Total_Cost__c + ' to order id ' + Ord.id);
                    }
                }
            }
            
            List<Order> odrList = new List<Order>();
            List<Account> accList = new List<Account>();
            List<Account> lstacctoUpdate;
            set<id> ordIds = new set<id>();
            set<id> accid = new set<id>();
            
            for(Order od : trigger.new){
                ordIds.add(od.id);
            }
            odrList = [select id, Name, EffectiveDate, Ship_To__c from Order where id =: ordIds Order By EffectiveDate ASC];
            for(Order odr : odrList){
                accid.add(odr.Ship_To__c);
            }
            
            /* Start: Need To Universal*/    
            accList = [select id, Name,CX_Last_Order_Date__c from Account where id =:accid];
            lstacctoUpdate = new List<Account>(); 
            for(Order ord : odrList){
                for(Account acc: accList){
                    if(ord.Ship_To__c == acc.id){
                        if(ord.EffectiveDate != null && ord.EffectiveDate != acc.CX_Last_Order_Date__c){
                            acc.CX_Last_Order_Date__c = ord.EffectiveDate;
                            
                            if(!lstacctoUpdate.contains(acc)){
                                lstacctoUpdate.add(acc);
                            } 
                        }
                    }
                }
            }
            /* End:  Need To Universal*/
            
            if(!lstacctoUpdate.isEmpty()){
                update lstacctoUpdate;  
            }
        }
    }
    
    //call Apex class to update total cost in Tavant Payment object. 
    if(OrderIds.size() > 0) {
       system.debug(LoggingLevel.INFO,'**** Calling TWOD_Payment_Cost_Update_Handler'); 
       TWOD_Payment_Cost_Update_Handler.updatePaymentCost(OrderIds); 
    } 
        
}