public class TWOD_Payment_Cost_Update_Handler {
  
  @future()
  
    public static void updatePaymentCost(set<id> OrdList){

        List<Order> Orders = [Select o.Id, o.BPCS_Order__c, o.Total_Cost__c, o.Planned_Ship_Date__c, o.Currency__c, o.Sales_Org__c
                             From Order o
                             where o.id in: OrdList];
            
        List<Payment__c> PaymentsToUpdate = new List<Payment__c>(); //stores records to be updated
        List<Payment__c> Pymnt = new List<Payment__c>();    
 
        if (Orders.size()>0){
            for(Order ord: Orders){
                if(Ord.Total_Cost__c > 0){
                  Pymnt = [Select p.Id, p.Total_Cost__c, p.Total_Amount__c, p.Ship_Credit_Debit_Date__c, p.Total_Amount_Converted__c, p.Exchange_rate__c 
                          from Payment__c p 
                          where p.Order_Number__c = :Ord.BPCS_Order__c 
                          limit 1];  

                  if (Pymnt.size() > 0){ 
                      for(Payment__c pmt: Pymnt){ 
                          pmt.Total_Cost__c = Ord.Total_Cost__c;
                          //Added for Multi currency changes
                          //pmt.Total_Amount__c = Ord.Total_Cost__c;
                          
                          if(pmt.Exchange_Rate__c == null || pmt.Exchange_Rate__c == 0)
                              pmt.Exchange_Rate__c = 1.0;
                          
                          pmt.Total_Amount_Converted__c = Ord.Total_Cost__c;
                          pmt.Total_Amount__c = Ord.Total_Cost__c * pmt.Exchange_rate__c;
                          if(Ord.Planned_Ship_Date__c != null){ //INC0631901 - Sandip - 03/08/2019
                              pmt.Ship_Credit_Debit_Date__c = String.Valueof(Ord.Planned_Ship_Date__c.format());                        
                          }                                                   
                          PaymentsToUpdate.add(pmt);
                    }    
                  }    
               }    
            }
        }          
        
        if(PaymentsToUpdate.size()> 0 ){
        
            Database.SaveResult[] sOrdList = Database.update(PaymentsToUpdate, false);
        
            // Iterate through each returned result
            for (Database.SaveResult sr : sOrdList) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug(LoggingLevel.INFO,'Successfully updated record ID: ' + sr.getId());
                } else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug(LoggingLevel.INFO,'The following error has occurred.');                    
                        System.debug(LoggingLevel.INFO,err.getStatusCode() + ': ' + err.getMessage());
                    }
                }
            }
        }
    }
}