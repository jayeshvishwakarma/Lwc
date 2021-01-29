public class StudentTriggerHelper {
	public static void frameEmailid(List<Student__c> lstStudents)
    {
        for(Student__c objStudent:lstStudents)
        {
            String strValue=objStudent.First_Name__c.subString(0,1);
            if(String.isNotBlank(objStudent.Last_name__c))
            {
                strValue += objStudent.Last_Name__c;
            }
            else
            {
                objStudent.last_name__c.addError(objStudent.first_name__c + ': Last Name is Missing');
            }
            strValue += '@iBirds.com';
                objStudent.first_name__c=strValue;
        }
    }
}