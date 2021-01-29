({
    initialize : function(component, event, helper) {

        var isResetRequest = component.get("v.isReset");
        var PriorityArray=component.get('v.MaxPriority');
        var status=component.get('v.status');
        PriorityArray["0"]=0;
        component.set('v.MaxPriority',PriorityArray);    
        component.set('v.MinPriority',PriorityArray);                
        if(status=='Draft'){
            helper.setQuestionOrder(component,event);
        }
        else {
            if(isResetRequest){
                helper.reset(component,event);
            }else{
                //helper.showAlert(component,{});
                helper.initialize(component, event);
                //helper.markAnswerNew(component, event);
                
                var reportStatusId = component.get("v.reportStatusId");
                var query="Select Current_Display_Order__c from Sequence_Question__c where Report_Status__c='"+reportStatusId+"' ORDER BY Current_Display_Order__c DESC LIMIT 1";
                helper.readRaw(component, event, helper, query, function(resultStatusResponse) {
                    console.log('resultStatusResponse--');
                    console.log(resultStatusResponse);    
                    var totalQuestions=resultStatusResponse.sObjectList["0"]["Current_Display_Order__c"];
                    var maxQuestionsOnPage=component.get("v.maxQuestionsOnPage");            
                    var totalPage=(totalQuestions+1)/maxQuestionsOnPage;
                    totalPage=Math.ceil(totalPage); 
                    console.log(totalPage);
                    var opts =[];
                    for(var i=1;i<=totalPage;i++){            
                        opts.push('Page-'+i);
                    }                    	
                    component.set('v.optionsPage',opts);
                    component.set('v.maxPage',opts.length);
                });
            }
        }                        
    },
    
    pageSelected : function(component, event, helper) {
      	console.log(event.getSource().get("v.value"));   
        var page=event.getSource().get("v.value");
        var stringArray=page.split('-');
        component.set('v.pageNumber',(parseInt(stringArray[1])-1));
         helper.next(component, event);
    },
    
    next : function(component, event, helper) {
        component.set('v.backPressed',false);
        helper.next(component, event, false);                 
    },
    
    
    submit : function(component, event, helper) {
        var alertboxContent = {
            message: 'Answer are getting submitted',
            heading: 'Submitting..',
            class: 'slds-theme--info',
            buttonHeading: null
        };
        helper.showAlert(component, alertboxContent);
        
        component.set('v.backPressed',false);
        helper.next(component, event, false);                 
    },
    
    back : function(component, event, helper) {  
               
        component.set('v.backPressed',true);
        helper.next(component, event, false);
       /*
         
         
       var completedQuestions=component.get('v.completedQuestions');
        var length=completedQuestions.length;
       
        //Already loaded questions
        var questionsAlreadyLoaded=component.get('v.questionsAlreadyLoaded');
        questionsAlreadyLoaded.push(component.get('v.sectionListToDisplay'));       
        component.set('v.questionsAlreadyLoaded',questionsAlreadyLoaded);
        
        component.set('v.sectionListToDisplay',completedQuestions.pop());
        component.set('v.completedQuestions',completedQuestions);
        

		console.log(component.get("v.answer")); 
        console.log(component.get("v.questionsAlreadyAnswered")["0"]);
        var answers=component.get("v.questionsAlreadyAnswered")["0"];
        var answersList=component.get("v.answer");
       var questions=component.get('v.sectionListToDisplay');
        var questionList=questions["0"]["questionList"];
        console.log(questionList.length);        
        for(var i=0;i<questionList.length;i++)
        {            
            var expectedAnswer=questionList[i]["Question__r"]["Expected_Answers__r"];
            for(var j=0;j<answersList.length;j++){                                  
                for(var k=0;k<expectedAnswer.length;k++){
                    if(expectedAnswer[k]["Id"]==answersList[j]["Expected_Answer__c"])
                    {
                        //expectedAnswer[k]["value"]=true;
                        console.log('aa');
                    }
                }
            }
            
        }
        
        questions["0"]["questionList"]=questionList;
        component.set('v.sectionListToDisplay',questions);
        console.log();
        */
    },
    
    
    markAnswer : function(component, event, helper){
         //helper.markAnswerNew(component, event);
         helper.markAnswer(component, event);        
    },

    redirectToTarget : function(component, event, helper){
        helper.redirectToTarget(component, event);
    },

    updateReportingStatus : function(component,event,helper){
        helper.updateReportingStatus(component,event);
    },

    saveAsDraft : function(component,event,helper){

      helper.saveAsDraft(component,event);

    },

    closeAlert : function(component,event,helper){

      var body=component.get('v.body');
      body.pop();
      component.set('v.body',body);

    },
    isNumberKey:function(evt)
       {
          
       },
    validateDate:function(event){
        alert("coming");
        var currentDate=event.getSource().get("v.value");
        currentDate=new Date(currentDate);    
        var today=new Date();
        if(currentDate > today){
            alert("Future date is not allowed");
        }
    },
    validateNumber:function(event) {
              alert(event.getSource().get("v.value"));
               //var keyEvent = new KeyEvent.wrap(keyboardEvent);
                var e = event || window.event;
                var key = e.keyCode || e.which;
                 
                 if(event.keyCode === 13){
                   
                  }
                if (!e.shiftKey && !e.altKey && !e.ctrlKey &&
                // numbers   
                key >= 48 && key <= 57 ||
                // Numeric keypad
                key >= 96 && key <= 105 ||
                // Backspace and Tab and Enter
                key == 8 || key == 9 || key == 13 ||
                // Home and End
                key == 35 || key == 36 ||
                // left and right arrows
                key == 37 || key == 39 ||
                // comma, period and minus, . on keypad
                key == 190 || key == 188 || key == 109 || key == 110 ||
                // Del and Ins
                key == 46 || key == 45) {
                    // input is VALID
                    
                }
                else {
                    alert("valid");
                // input is INVALID
               // e.returnValue = false;
                if (e.preventDefault) e.preventDefault();
                }
            }
})