public class SurveyResponse{
  @InvocableMethod
  public static List<String> saveSurveyResponse(List<String> flowResponse) {
    if(flowResponse != null && flowResponse.size() > 0){
       String temp= flowResponse[0].replaceAll('<[^>]+>',' ');
       String response = temp.replaceAll('&nbsp;',' ');
          if(response != ''){
            List<String> splitList = response.split('#');
             List<Survey_Response__c> surveyResponseList = new List<Survey_Response__c>();
             for(String str : splitList){
                List<String> tempList = new List<String>();
                tempList = str.split('@');
                Survey_Response__c sur = new Survey_Response__c();
                sur.Survey_Taker__c = 'a1D1s0000004i0SEAQ';
                sur.Question__c = tempList[0];
                if(tempList.size() > 1)
                sur.Answer__c = tempList[1]; 
                surveyResponseList.add(sur);
             }
             if(surveyResponseList.size() >0){
               insert surveyResponseList;
             }
          }
    }
    return null;
  }
}