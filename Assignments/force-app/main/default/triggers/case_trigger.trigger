/* Name : Trigger on Case
* Author : Jayesh Vishwakarma
* Date : 27 march 2020
* Description : Trigger used to Check the parent id and if having parent id then give the list of 
ids to Helper
* */

trigger case_trigger on Case (after insert,after update) {
    
    if(Trigger.isAfter)
    {
        System.debug('Case Triger Chala');
        Set<Id> setIds= new Set<Id>();
        for(Case objCase : Trigger.New)
        {
            if(objCase.ParentId!=null) 
            {
                setIds.add(objCase.ParentId);
            }
            if(setIds.size()>0)
            {
            CaseTriggerHelper.changeStatus(setIds);
            }
        }
    }
}