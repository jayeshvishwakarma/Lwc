/* Name : CaseTriggerHelper
* Author : Jayesh Vishwakarma
* Date : 28 march 2020
* Description : This Helper Class is used to change the status of parent if all the childs cases are closed.
* */

public class CaseTriggerHelper {
    
    public static void changeStatus(Set<Id> setIds)
    {
        List<Case> lstCases =new List<Case>();
        Map<Id,List<Case>> mapParentCases=new Map<Id,List<Case>>(); 
        
        for(Case objCase : [SELECT id,ParentId,Status
                            FROM Case
                            WHERE ParentId IN : setIds
                           ])
        {
            if(mapParentCases.containsKey(objCase.ParentId)) mapParentCases.get(objCase.ParentId).add(objCase);
            else
                mapParentCases.put(objCase.ParentId,new List<Case>{objCase});
        }
        
        for(Id parentId : mapParentCases.keySet())
        {
            for(Case objCase2 : mapParentCases.get(ParentId))
            {
                if(objCase2.Status=='Closed')
                {
                    lstCases.add(new Case(id=ParentId,status='Closed'));
                }
            }
        }
        Database.update(lstCases);
    }
}