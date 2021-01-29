public class SurveyResponseOneRecord{
  @InvocableMethod
  public static List<String> saveSurveyResponse(List<String> flowResponse) {
    if(flowResponse != null && flowResponse.size() > 0){
       String temp= flowResponse[0].replaceAll('<[^>]+>',' ');
       String response = temp.replaceAll('&nbsp;',' ');
          if(response != ''){
            List<String> splitList = response.split('#');
             Survey_Response_1__c surveyResponse = new Survey_Response_1__c();
             Decimal totalResponse = 1;
             List<Survey_Response_1__c> surveyRespList = [select id , name,Total_Response__c from Survey_Response_1__c 
                                                             where Survey_Taker__c='a1D1s0000004i0S'];
               if(surveyRespList.size()  > 0){
                surveyResponse = surveyRespList[0];
                totalResponse = surveyRespList[0].Total_Response__c;
               }else{
                 surveyResponse.Survey_Taker__c='a1D1s0000004i0S';
               }                                                
              
              for(String str:splitList){
                List<String> resp = str.split('@');
                String Question_Api = 'Question_'+totalResponse+'__c';
                String Answer_Api = 'Answer_'+totalResponse+'__c';
                
                surveyResponse.put(Question_Api ,resp[0]);
                if(resp.size() > 1)
                surveyResponse.put(Answer_Api ,resp[1]);
               
               totalResponse ++;
              }
             surveyResponse.Total_Response__c  =totalResponse; 
             upsert surveyResponse;
          }
    }
    return null;
  }
}