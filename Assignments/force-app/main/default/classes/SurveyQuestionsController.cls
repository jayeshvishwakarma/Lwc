public class SurveyQuestionsController {
    
    public List<SurveyQuestion> lstSurveyQuestions{get;set;}
    
    public boolean isResponseSection{get;set;}
    
    public boolean isQuestionSection{get;set;}
    
    public boolean isPieChart{get;set;}
    
    public SurveyQuestion objSurveyQuestion{get;set;}
    
    public List<SurveyQuestionChoice> lstSurveyQuestionChoices{get;set;}
    
    public String EmailIdFromLoginPage{get;set;}
    
    public String nameFromLoginPage{get;set;}
    
    private INTEGER count {get;set;}
    
    public String choice{get;set;}
    
    public List<Response__c> lstResponses{get;set;}
    
    public SurveyQuestionsController()
    {    
        System.debug('Name:'+nameFromLoginPage);
        nameFromLoginPage='Welcome '+ApexPages.currentPage().getParameters().get('nameFromLoginPage');
        EmailIdFromLoginPage=ApexPages.currentPage().getParameters().get('EmailIdFromLoginPage');
        
        if(emailIdFromLoginPage==null)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'You may have To Login First'));
        }else
        {
            count=1;
            
            isResponseSection=false;
            
            isQuestionSection=isPieChart=true;
            
            SurveyVersion objSurveyVersion=[SELECT id,name,SurveyStatus,SurveyId 
                                            FROM SurveyVersion 
                                            WHERE Name='GeneralSurvey'];       
            
            lstSurveyQuestions=[SELECT id,Name,SurveyVersionId 
                                FROM SurveyQuestion 
                                WHERE SurveyVersionId=:objSurveyVersion.id
                               ];
            
            
            lstSurveyQuestionChoices=[SELECT name,questionId 
                                      FROM surveyQuestionChoice 
                                      WHERE questionId=:lstSurveyQuestions.get(0).id];
            
            objSurveyQuestion=lstSurveyQuestions.get(0);
            
            lstResponses=new List<Response__C>();
            
            lstResponses=[SELECT ContactId__C 
                          FROM Response__C 
                          WHERE ContactId__c=:emailIdFromLoginPage];
            if(lstResponses.size()>0)
            {
                emailIdFromLoginPage=null;
                isResponseSection=isQuestionSection=isPiechart=false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Your Response in recorded You Can not do again'));
            }
        }
    }
    
    public List<SelectOption> getChoices() 
    {
        List<SelectOption> options = new List<SelectOption>();
        for(SurveyQuestionChoice obj : lstSurveyQuestionChoices)
        {
            options.add(new SelectOption(obj.Name,obj.Name));
        }
        return options;
    }
    
    public void submit()
    {
        System.Debug('Chala');
        System.debug('Choice:'+choice);
        if(choice!=null)
        {
            for(SurveyQuestionChoice obj : lstSurveyQuestionChoices){
                if(obj.name==Choice){
                    System.debug(obj.Name);
                    lstResponses.add(new Response__c(Survey_Question__c=obj.QuestionId,Choice__c=choice,ContactID__c=EmailIdFromLoginPage));
                }
            }
            
            if(count==5)
            {
                Database.insert(lstResponses);
                isResponseSection=true;
                isPieChart=isQuestionSection=false;
                
                System.debug('ListWaliSize: '+lstResponses.size());
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO,'Thank You !! ,Your Response is Recorded.'));
            }
            else if(Count<5)
            {
                
                objSurveyQuestion=lstSurveyQuestions.get(Count);
                lstSurveyQuestionChoices=[SELECT name,questionId 
                                          FROM surveyQuestionChoice 
                                          WHERE questionId=:lstSurveyQuestions.get(Count).id];
                count++;
            }
            
        }
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.WARNING, 'Please Select At least One Option'));
        }
    }
    
    public PageReference logoutAccount()
    {
        emailIdFromLoginPage=null;
        return Page.login_contact;  
    }
    
    public List<Object> getPieData(){
        List<Object> Data = new List<Object>();
        
        for(AggregateResult obj : [SELECT count(id),Choice__c 
                                   FROM Response__c 
                                   WHERE survey_question__c=:lstSurveyQuestions.get(count-1).id group by choice__c]){
                                       //System.debug(obj);
                                       Decimal vl=(Decimal)obj.get('expr0');
                                       data.add(new PieWedgeData(obj.get('Choice__c').toString(),vl));
                                   }
        return data;
    }
    
    //Wrapper class
    public class PieWedgeData{
        public String name {get;set;}
        public Decimal data {get;set;}        
        public PieWedgeData(String name, Decimal data){
            this.name = name;
            this.data = data;
        }
    }
    
}