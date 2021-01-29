@isTest(SeeAllData=True)
public class TWOD_Payment_Cost_Update_Handler_Test {
  static testMethod void run()
  {  List<Order> Orders = [Select o.Id, o.BPCS_Order__c, o.Total_Cost__c From Order o where o.Total_Cost__c > 0 AND o.Planned_Ship_Date__c != null limit 10];   
     List<Order> OrdersToUpdate = new List<Order>(); //stores records to be updated
        set<id> OrderIds = new set<id>();
             
        if (Orders.size()>0){
            for(Order ord: Orders){
                    ord.Total_Cost__c = ord.Total_Cost__c + .01;
                    OrdersToUpdate.add(ord);
                    OrderIDs.add(ord.Id);
                }
             }
      
       if( OrdersToUpdate.size()> 0 ){
            Database.SaveResult[] srList = Database.update(OrdersToUpdate);
         }
   
    Account ac = new Account();
           ac.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Carrier').getRecordTypeId();
           ac.Name = 'test';
           ac.Type = 'Carrier';
   
    Order od = new Order();
    od.Name = 'test';
        Test.startTest();
            
           insert ac;
           insert od;
           update ac;
        Test.stopTest();
       //Test.startTest();     
            //TWOD_Payment_Cost_Update_Handler.updatePaymentCost(OrderIds); 
             
      // Test.stopTest();   
  }
}