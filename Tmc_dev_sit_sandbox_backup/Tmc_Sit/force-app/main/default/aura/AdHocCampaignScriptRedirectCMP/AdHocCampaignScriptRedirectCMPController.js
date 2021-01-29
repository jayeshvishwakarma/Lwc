({
    doInit : function(component, event, helper) {
        console.log('survey Id>>>', component.get("v.surveyId"));
        var surveyFormId= component.get("v.surveyId");
        var urlString = window.location.href;
        console.log('urlString', urlString);
        var baseUrl= urlString.substring(0, urlString.indexOf("/s/"));
        console.log('baseUrl___', baseUrl);

        var action = component.get('c.getSurveyUrl');
        
        action.setParams({
            'surveyname' : surveyFormId
        });
        action.setCallback(this, function(response){
            if(response.getState()==='SUCCESS'){
                var surveyURL = response.getReturnValue();
               // var url= baseUrl+'/apex/AdHocCampaignQuestinnairePage?id='+surveyFormId;
                var url= baseUrl+surveyURL;
                console.log('url__', url);
                component.set('v.surveyFormURL', url);
            }
            else {
                component.set('v.surveyFormURL', '');
            }
        });
        $A.enqueueAction(action);
        
    }
})