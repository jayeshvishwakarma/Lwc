public with sharing class QuoteCloneController {
    private Id recordId;
    public QuoteCloneController(ApexPages.StandardController sc) {
        recordId = sc.getId();
    }

    public PageReference doClone() {
        if (recordId == null || (Id)recordId != recordId) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.FATAL, 'QuoteLineId must be supplied.'));
        }
        try {
            String query = 'select Quoteid, PricebookEntryId, Quantity, UnitPrice, Discount, Description, ServiceDate, ListPrice, Subtotal, TotalPrice ';
            // get all of the custom, writeable fields
            Map<String, Schema.SObjectField> fieldMap = QuoteLineItem.getSObjectTypE().getDescribe().fields.getMap();
            for (String key : fieldMap.keySet()) {
                Schema.SObjectField field = fieldMap.get(key);
                Schema.DescribeFieldResult result = field.getDescribe();
                if (result.isCustom() && !result.isCalculated()) {
                    query += ' ,'+result.getName();
                }
            }
            query += ' from QuoteLineItem where Id = :recordId';
            System.debug('Query quotelineitme : '+query);
            QuoteLineItem ql = Database.query(query);
            QuoteLineItem q2 = ql.clone();
            insert q2;
            return new PageReference('/'+q2.Id);
        } catch(DMLException e) {
            ApexPages.addMessages(e);
            return null;
        }
    }
}