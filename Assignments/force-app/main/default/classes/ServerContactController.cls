public  class ServerContactController {

        public ServerContactController() {
        }

        @AuraEnabled(cacheable=true)
        public static List<Contact> contactRecords(String cityName)
        {
            System.debug(cityName);
            System.debug(Database.query('SELECT ID,firstName,LastName,Email,Phone From Contact LIMIT 20'));
            if(cityName=='All'){
            return [ SELECT ID,FirstName,LastName,Email,Phone,MailingCity 
                    From Contact 
                    WHERE MailingCity != null
                ];
            }
            else {
                return [ SELECT ID,FirstName,LastName,Email,Phone,MailingCity 
                        From Contact
                        WHERE MailingCity =:cityName
                    ];
                
                }
        }

        @AuraEnabled(cacheable=true)
        public static List<Wrapper> fieldsNames()
        {
            List<Wrapper> lstWrapper = new List<Wrapper>();
            lstWrapper.add(new Wrapper('FirstName','FirstName','text'));
            lstWrapper.add(new Wrapper('LastName','LastName','text'));
            lstWrapper.add(new Wrapper('Phone','Phone','phone'));
            lstWrapper.add(new Wrapper('MailingCity','MailingCity','text'));
            lstWrapper.add(new Wrapper('Email','Email','email'));
            return lstWrapper;

        }
        public class Wrapper{
            @AuraEnabled public String label;
            @AuraEnabled public String fieldName;
            @AuraEnabled public String type;

           public Wrapper(String value1, String value2, String value3)
           {
               label = value1;
               fieldName = value2;
               type = value3;
           }
        }
        
    }