public class StudentRecordsController {
    
    public List<StudentWrapper> lstStudentWrapper {get;set;}
    public String searchCity {get;set;}
    
    public StudentRecordsController()
    {
        // esa Bhi Kr skte h , ye dynamic changes ke liye for example insert update delete
        //List<Student__C> lstStudents=Database.query('SELECT first_name__c,city__c,joining_date__c FROM Student__c LMIT 20');
        List<Student__C> lstStudents=[SELECT first_name__c,last_name__c,joining_date__c,city__C 
                                      FROM Student__c LIMIT 20
                                     ];
        lstStudentWrapper = new List<StudentWrapper>();
        
        if(lstStudents.size()>0)
        {
            Integer count=1;	
            for(Student__c objStudent: lstStudents)
            {
                if(objStudent.Joining_Date__c!=null)
                {
                    StudentWrapper objWrapper=new StudentWrapper(objStudent,count++);
                    lstStudentWrapper.add(objWrapper);
                }
            }
        }
    }
    
    
    public class StudentWrapper
    {
        public Student__c objStudent {get;set;}
        public Integer sNo {get;set;}
        public Integer daysAfterJoining {get;set;}
        public Boolean isSelected {get;set;}
        
        public StudentWrapper(Student__c obj,Integer sNo)
        {
            objStudent=obj;
            this.sNo=sNo;  
            isSelected=false;
            if(obj.Joining_Date__c!=null)
                daysAfterJoining=obj.Joining_Date__c.daysBetween(System.today());
            else
                daysAfterJoining=0;
        }
        
    }
    public void deleteRecords()
    {
        List<Student__c> lstStudentSelected=new List<Student__c>();
        for(Integer i=lstStudentWrapper.size()-1;i>=0;i--)
        {
            if(lstStudentWrapper.get(i).isSelected==true)
            {
                lstStudentSelected.add(lstStudentWrapper.get(i).objStudent);
                lstStudentWrapper.remove(i);
            }
        }
        if(lstStudentSelected.size()>0)
        {
            delete lstStudentSelected;
                   
        }
    }
    
  
    
   
}