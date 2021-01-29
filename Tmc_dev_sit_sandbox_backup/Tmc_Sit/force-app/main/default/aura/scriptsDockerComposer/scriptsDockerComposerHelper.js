({
    startScript : function(cmp, mdt){
        console.log('inside startScript');
        var currTaskObj = cmp.find("cacheCmp").retrieveObjectArrayFromCache();
        console.log(currTaskObj.Id);
        if (mdt.Child_Flow_Name__c != '' && typeof mdt.Child_Flow_Name__c != 'undefined') {
            cmp.set("v.showFlow", true);
            cmp.set("v.showSurvey", false);
            cmp.set("v.showChoices", false);
            cmp.set("v.displayFlow",true);
            //show flow 
            var flow = cmp.find("flowData");
            var inputVariables = [
            {
                name : "recordId",
                type : "String",
                value : currTaskObj.Id
            },
            {
                name : "customerName",
                type : "String",
                value : currTaskObj.Contact_ID__r.Name
            }
            ,
            {
                name : "caseId",
                type : "String",
                value : currTaskObj.Case__c
            }
        ];
            if(mdt.Child_Flow_Name__c==='First_Free_Service_and_Welcome_Call' || mdt.Child_Flow_Name__c==='Second_Third_and_Paid_Service_Call' || mdt.Child_Flow_Name__c==='SMR_Paid_Service_Arena'){
               flow.startFlow(mdt.Child_Flow_Name__c, inputVariables); 
            }
            else{
                flow.startFlow(mdt.Child_Flow_Name__c);
            }
            //flow.startFlow(mdt.Child_Flow_Name__c, inputVariables);
            //console.log(cmp.get("v.displayFlow", inputVariables));
            
        } else if ((mdt.Survey_Id__c != '' && typeof mdt.Survey_Id__c != 'undefined')) {
            //show survey iframe
            /*
            var flowVar = [{
                name: "surveyId",
                type: "String",
                value: mdt.Survey_Id__c
            }];
            flow.startFlow("Ad_Hoc_Campaigns_Questionnaire_SubFlow", flowVar);
            */
           cmp.set("v.surveyId",mdt.Survey_Id__c);
           cmp.set("v.surveyFormURL",mdt.Survey_Urls__c);
           cmp.set("v.showSurvey",true);
           cmp.set("v.showFlow", false);
           cmp.set("v.showChoices", false);           
        }
    },

    callScript : function (cmp,event){
        console.log('Inside CallScript');
        //Retrieve cached task data from cacheServiceLayerCMP
        var currTaskObj = cmp.find("cacheCmp").retrieveObjectArrayFromCache();
        if(currTaskObj){
            cmp.set("v.showError", false);
            let caseRecId = currTaskObj.Case__c;
            let contactRecId = currTaskObj.Contact_ID__c;
            if (currTaskObj.Enquiry__c)
                cmp.set("v.enquiryId",currTaskObj.Enquiry__c);
            if (caseRecId)
                cmp.set("v.caseId",caseRecId);
            if (contactRecId){
                console.log(contactRecId);
                cmp.set("v.accountId",contactRecId);
            }
            //  cmp.set("accountId",contactRecId);
            //Retrieve metadata to find which scripts should be shown
            var action = cmp.get("c.getMetadataRecords");
            console.log(JSON.stringify(currTaskObj));
            console.log(currTaskObj.Case__r);
            action.setParams({
                campaignType: currTaskObj.Service_Type__c,
                campaignId: currTaskObj.CampaignId__c,
                lob:currTaskObj.Case__r.Dealer_Name__r.Channel__c
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var data = response.getReturnValue();
                    //generate choices to be shown to the user
                    let choicesPbj = [];
                    if(data.lstmdtRecord){
                        cmp.set("v.campMetadata",data.lstmdtRecord);
                        data.lstmdtRecord.forEach(mdt => {
                            console.log(mdt);
                            let option = {'label': mdt.Script_Name__c, 'value': mdt.Script_Name__c};
                                                  choicesPbj.push(option);
                        
                    });
                    //if only 1 script, start it automatically else show the user the choices
                    if(choicesPbj.length === 1){ 
                        console.log('calling helper');                              
                        this.startScript(cmp,data.lstmdtRecord[0]);
                    }
                    else {
                        cmp.set("v.choices",choicesPbj);
                        cmp.set("v.showChoices",true);
                    }
                }
                else {
                    console.log('in error with no mdt');
                    cmp.set("v.showError", true);
                }
            }
                               else {
            cmp.set("v.showError", true);
        }
    });
    $A.enqueueAction(action); 
    }
     else {
     //cache is not set so show message to start call
     cmp.set("v.showError", true);
     cmp.set("v.showChoices", false);
     cmp.set("v.displayFlow",false);
     cmp.set("v.showSurvey",false);

   }
},      
})