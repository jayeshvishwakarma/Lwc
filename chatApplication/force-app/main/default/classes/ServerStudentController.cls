public class ServerStudentController {
    public ServerStudentController() {
    }

   @AuraEnabled(cacheable=true)
   public static List<Student__C> studentRecords(String cityName)
   {
       if(cityName=='' || cityName==null){
           return null;
       }
       cityName= '%'+cityName+'%';
       
       return [SELECT ID,First_Name__c,Last_Name__C,ImageUrl__c,City__C,Full_Name__C,EmailId__c
                From Student__C 
                WHERE City__C Like :cityName AND ImageUrl__c!='' AND EmailId__c!=''
                ];
   }

   @AuraEnabled(cacheable=true)
   public static List<Student__c> studentRecord(String emailId){
       System.debug(emailId);
       return [SELECT ID,First_Name__c,Last_Name__C,EmailId__c,City__C ,ImageUrl__c,Full_Name__C
                FROM Student__C
                WHERE EmailId__c =:emailId
                ];
   }

   @AuraEnabled(cacheable=true)
   public static List<Student__C> getAllRecords(){
       System.debug('GetAll Resocrds');
       return [SELECT ID,First_Name__c,Last_Name__c,City__C,ImageUrl__c,EmailId__c
                FROM Student__C 
                WHERE ImageUrl__c!=''
                ];
       
   }
    
}