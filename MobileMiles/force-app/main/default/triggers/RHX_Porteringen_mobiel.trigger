trigger RHX_Porteringen_mobiel on Porteringen_mobiel__c
    (after delete, after insert, after undelete, after update, before delete) {
    
    if(!KWTTriggerHelper.isUpdatingKWT){
   
         Type rollClass = System.Type.forName('rh2', 'ParentUtil');
         if(rollClass != null) {
            rh2.ParentUtil pu = (rh2.ParentUtil) rollClass.newInstance();
            if (trigger.isAfter) {
                pu.performTriggerRollups(trigger.oldMap, trigger.newMap, new String[]{'Porteringen_mobiel__c'}, null);
            }
        }
    }
}