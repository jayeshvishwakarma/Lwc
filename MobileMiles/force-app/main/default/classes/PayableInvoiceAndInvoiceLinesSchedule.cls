global class PayableInvoiceAndInvoiceLinesSchedule implements System.Schedulable{
    global void execute(System.SchedulableContext cntxt){
         PayableInvoiceAndInvoiceLinesBatch objBatch = new PayableInvoiceAndInvoiceLinesBatch();
         Database.executeBatch(objBatch, 48);
    }
}