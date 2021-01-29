public class StudentDetailsController {
    public boolean isShow{get;set;}
    public List<Student__C> lstStudents {get;set;}
    public studentDetailsController()
    {
        isShow=true;
        lstStudents= [SELECT id,name,city__C ,age__C
                      FROM Student__c 
                      LIMIT 25
                     ];
    }
    
}