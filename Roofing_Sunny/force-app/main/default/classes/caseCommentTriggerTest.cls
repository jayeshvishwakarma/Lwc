@isTest(seeAllData=false)
private class caseCommentTriggerTest {

    static Case tCase;
    static CaseComment tComment;
    static Profile tProfile;
    static User tUser;
    
    static void createTestData(){
    
                            
        tCase = new Case();
        tCase.Description = 'TestDescription';
        tCase.Status = 'New';
        tCase.Subject = 'TestSubject';
          
        INSERT tCase;
        
        tComment = new CaseComment();
        tComment.ParentId = tCase.Id;
        tComment.CommentBody = 'test';
        tComment.IsPublished = TRUE;  
            
        INSERT tComment;
        
        tProfile = 
            [
                SELECT Id 
                FROM   Profile 
                WHERE  Name = 'System Administrator'
            ];
            
        tUser = new User(
            Alias = 'standt', 
            Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', 
            LastName='Testing', 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            ProfileId = tProfile.Id, 
            TimeZoneSidKey='America/Los_Angeles', 
            UserName='testuser@sometestorg.com'
        );
        
        INSERT tUser;
        
    }
    
    static testMethod void execCaseCommentUpdate(){
    
        test.startTest();
        
            createTestData();
            
            try{
                System.runAs(tUser){
                    UPDATE tComment;
                }
            }
            catch(Exception e){ }
            
        test.stopTest();
    
    }
    
    
    static testMethod void execCaseCommentDelete(){
        test.startTest();
        
            createTestData();
            
            try{
                System.runAs(tUser){
                    DELETE tComment;
                }
            }
            catch(Exception e){ }
            
        test.stopTest();
    }    
}