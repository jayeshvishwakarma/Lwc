global class InvoiceAndInvoiceLinesSchedule implements System.Schedulable{
    global void execute(System.SchedulableContext cntxt){
         SalesInvoiceAndInvoiceLinesBatch objBatch = new SalesInvoiceAndInvoiceLinesBatch();
         Integer rowsLimit = 48;
        if(Test.isRunningTest()){
            rowsLimit = 200;
        }
         Database.executeBatch(objBatch, rowsLimit);
    }
}