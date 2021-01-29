trigger StudentTrigger on Student__c (before insert,after insert,before update,after update,before delete,after delete,after undelete) {
    if(Trigger.isBefore)
    {
        if(Trigger.isInsert)
        {
            StudentTriggerHelper.frameEmailId(Trigger.New);
        }
        else if(Trigger.isUpdate)
        {
            System.debug('before update Trigger Invoked');
            List<Student__C> lstStudents=new List<Student__c>();
            for(Student__c newVerStudent:Trigger.New)
            {
                Student__c oldVerStudent=Trigger.oldMap.get(newVerStudent.Id);
                if(!newVerStudent.First_Name__c.equalsIgnoreCase(oldVerStudent.First_Name__c))
                {
                    lstStudents.add(newVerStudent);
                }
                  else if(String.isNotBlank(newVerStudent.Last_Name__c) || (!newVerStudent.last_Name__c.equalsIgnoreCase(oldVerStudent.last_Name__c)))
                {
 					                   lstStudents.add(newVerStudent);
                }
            }
            if(lstStudents.size()>0)
            {
                StudentTriggerHelper.frameEmailId(lstStudents);
            }
        }
        else
        {
            System.debug('===========before Delete trigger Invoked=================');
            
        }
        
    }
    /*else if(Trigger.isAfter)
{

}*/
}