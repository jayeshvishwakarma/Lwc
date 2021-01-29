public class StudentInfoController {
    
    public List<Student__C> lstStudents {get;set;}
    public Decimal avgAge {get;set;}
    public String searchCity {get;set;}
    
    
    public StudentInfoController()
    {
        searchCity='%%';
        findCityRecords();
        searchCity='';
    }
    public void findCityRecords()
    {
        String searchCriteria='%' + searchCity + '%';
        lstStudents= [SELECT first_name__c,city__c,age__C 
                      FROM Student__C 
                      WHERE city__c Like :searchCriteria
                     ];
        if(lstStudents.size()>0)
        {
            Decimal sum=0;
            Integer Count=0;
            for(Student__C objStudent : lstStudents)
            {
                if(objStudent.age__c != null){
                    sum+=objStudent.age__C;
                    count++;
                }
                
            }
            if(count>0)
            {
                avgAge=sum/count;
            }
        }
    }
    public void ClearAll()
    {
        searchCity='';
        lstStudents=[SELECT first_name__c,city__c,age__c 
         			 FROM Student__C
        			];
    }
}