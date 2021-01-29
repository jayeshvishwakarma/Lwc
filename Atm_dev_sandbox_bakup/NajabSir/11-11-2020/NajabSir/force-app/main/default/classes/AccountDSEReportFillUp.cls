/**
* @File Name          : AccountDSEReportFillUp.cls
* @Description        : Class to update fields that are used in DSE report for his performance
* @Author             : Rahul Sharma
**/
    public class AccountDSEReportFillUp {
        
        // Calculating enq punched by DSE
        public static void updateDSEFields(List<Account> lstAcc)
        {            
            //Parameters and Collections
            List<Account> newAccList = new List<Account>();
            List<Account> newAccList1 = new List<Account>();
            set<string> usrIds = new set<string>();
            map<string, Integer> oppMap = new map<string, Integer>();
            map<string, Integer> totalOppMap = new map<string, Integer>();
            map<string, Integer> oppMapPB = new map<string, Integer>();
            map<string, Integer> oppMapRetail = new map<string, Integer>();
            map<string, Integer> followUpMap = new map<string, Integer>();
            map<string, Integer> totalFollowUpMap = new map<string, Integer>();
            map<string, Integer> completedFollowUpMap = new map<string, Integer>();
            map<string, Integer> testDriveMap = new map<string, Integer>();
            map<string, Integer> financeChecklistMap = new map<string, Integer>();
            map<string, Integer> eventMap = new map<string, Integer>();
            map<string, Integer> visitPlanMap = new map<string, Integer>();
            map<string, Integer> deliveryChecklistMap = new map<string, Integer>();
            map<string, Integer> bcrMap = new map<string, Integer>();
            map<string, Integer> quoteMap = new map<string, Integer>();
            map<string, Integer> broshureMap = new map<string, Integer>();
            map<string, Integer> chatterUsedMap = new map<string, Integer>();
            map<string, Integer> visitPlanDoneMap = new map<string, Integer>();
            map<string, Integer> leadsMap = new map<string, Integer>();
            map<string, DateTime> lastTimeAppUsedMap = new map<string, DateTime>();
            map<string, Integer> noOfTimesAppOpenedMap = new map<string, Integer>();
            List<Opportunity> lstOpps = new List<Opportunity>(); 
            List<Task> lstFollowUps = new List<Task>(); 
            List<Test_Drive__c> lstTestDrives = new List<Test_Drive__c>(); 
            List<MC_Communication__c> lstMCComm  = new List<MC_Communication__c>(); 
            List<Event> lstEvents = new List<Event>(); 
            List<Event_Visit_Plan__c> lstVisitPlans = new List<Event_Visit_Plan__c>(); 
            List<OpportunityFeed> oppFeedChatterUsed = new List<OpportunityFeed>(); 
            List<Lead> leadLst = new List<Lead>(); 
            List<OauthToken> OAuthLst = new List<OauthToken>(); 
            Integer i,j,k;
            DateTime dt;
            newAccList = lstAcc;
            system.debug('account list is :'+ newAccList);
            for(Account acc : newAccList)
            {    
                system.debug('account is :'+ acc);
                if(acc != null && acc.Id != null && acc.User__c != null)
                    usrIds.add(acc.User__c);
            }
            
            //Get all records of DSEs for each required object
            User u = [Select Id from user where Name =: 'DMS Admin'];
            if( usrIds.size() >0 )
            {
             lstOpps = [select id,OwnerId,StageName,CreatedById FROM Opportunity where OwnerId In: usrIds];
             lstFollowUps = [select id,CreatedById,OwnerId,Status FROM Task where OwnerId In: usrIds];
             lstTestDrives = [select id,CreatedById FROM Test_Drive__c where CreatedById In: usrIds];
             lstMCComm = [select id,CreatedById,Type__c FROM MC_Communication__c where CreatedById In: usrIds];
             lstEvents = [select id,CreatedById FROM Event where CreatedById In: usrIds];
             lstVisitPlans = [select id,CreatedById,Status__c FROM Event_Visit_Plan__c where CreatedById In: usrIds];
             oppFeedChatterUsed = [select id,CreatedById FROM OpportunityFeed where CreatedById In: usrIds];
             leadLst = [select id,CreatedById FROM Lead where CreatedById In: usrIds];
             OAuthLst = [SELECT AppName,LastUsedDate,UseCount,UserId FROM OauthToken WHERE UserId In: usrIds];
            }
            system.debug('OAuthLst : '+ OAuthLst.size());
            system.debug('leadLst : '+ leadLst.size());
            system.debug('oppFeedChatterUsed: '+ oppFeedChatterUsed.size());
            system.debug('lstVisitPlans: '+ lstVisitPlans.size());
            system.debug('lstEvents: '+ lstEvents.size());
            system.debug('lstMCComm: '+ lstMCComm.size());
            system.debug('lstTestDrives: '+ lstTestDrives.size());
            system.debug('lstFollowUps : '+ lstFollowUps.size());
            system.debug('lstOpps: '+ lstOpps.size());
              
           //Getting Count of opps assigned to each DSE and created in SF only
           if(lstOpps.size() > 0 && newAccList.size() > 0)
           {
                for(i=0; i< newAccList.size();i++)
                {
                    k=0;
                    for(j=0; j< lstOpps.size();j++)
                    {
                        if(newAccList[i].User__c == lstOpps[j].OwnerId && lstOpps[j].CreatedById != u.Id)
                            k++;
                    }        
                    oppMap.put(newAccList[i].User__c, k);
                }
           }
           
           //Getting Count of total opps assigned to each DSE
           if(lstOpps.size() > 0 && newAccList.size() > 0)
           {
                for(i=0; i< newAccList.size();i++)
                {
                    k=0;
                    for(j=0; j< lstOpps.size();j++)
                    {
                        if(newAccList[i].User__c == lstOpps[j].OwnerId )
                            k++;
                    }        
                    system.debug('newAccList[i].User__c'+newAccList[i].User__c + k);
                    totalOppMap.put(newAccList[i].User__c, k);
                }
           }
           
            //Getting Count of opps punched by each DSE and stage not equal to New
           if(lstOpps.size() > 0 && newAccList.size() > 0)
           {
                for(i=0; i< newAccList.size();i++)
                {
                    k=0;
                    for(j=0; j< lstOpps.size();j++)
                    {
                        if(newAccList[i].User__c == lstOpps[j].OwnerId && lstOpps[j].StageName != 'New' && lstOpps[j].CreatedById != u.Id)
                            k++;
                    }        
                    oppMapPB.put(newAccList[i].User__c, k);
                }
           }
           
           //Getting Count of opps punched by each DSE and stage equal to retail
           if(lstOpps.size() > 0 && newAccList.size() > 0)
           {
                for(i=0; i< newAccList.size();i++)
                {
                    k=0;
                    for(j=0; j< lstOpps.size();j++)
                    {
                        if(newAccList[i].User__c == lstOpps[j].OwnerId && lstOpps[j].StageName == 'Retail')
                            k++;
                    }        
                    oppMapRetail.put(newAccList[i].User__c, k);
                }
           }
           
            //Getting Count of Follow Up owned by each DSE and created through SF
           if(lstFollowUps.size() > 0 && newAccList.size() > 0)
           {
                for(i=0; i< newAccList.size();i++)
                {
                    k=0;
                    for(j=0; j< lstFollowUps.size();j++)
                    {
                        if(newAccList[i].User__c == lstFollowUps[j].OwnerId && lstFollowUps[j].CreatedById != u.Id)
                            k++;
                    }        
                    followUpMap.put(newAccList[i].User__c, k);
                }
           }
           
            //Getting Count of Follow Up owned by each DSE and created through SF
           if(lstFollowUps.size() > 0 && newAccList.size() > 0)
           {
                for(i=0; i< newAccList.size();i++)
                {
                    k=0;
                    for(j=0; j< lstFollowUps.size();j++)
                    {
                        if(newAccList[i].User__c == lstFollowUps[j].OwnerId && lstFollowUps[j].CreatedById != u.Id && lstFollowUps[j].Status == 'Completed')
                            k++;
                    }        
                    completedFollowUpMap.put(newAccList[i].User__c, k);
                }
           }
           
            //Getting Count of Follow Up owned by each DSE 
           if(lstFollowUps.size() > 0 && newAccList.size() > 0)
           {
                for(i=0; i< newAccList.size();i++)
                {
                    k=0;
                    for(j=0; j< lstFollowUps.size();j++)
                    {
                        if(newAccList[i].User__c == lstFollowUps[j].OwnerId)
                            k++;
                    }        
                    totalFollowUpMap.put(newAccList[i].User__c, k);
                }
           }
           
            //Getting Count of Test Drive punched by each DSE
           if(lstTestDrives.size() > 0 && newAccList.size() > 0)
           {
                for(i=0; i< newAccList.size();i++)
                {
                    k=0;
                    for(j=0; j< lstTestDrives.size();j++)
                    {
                        if(newAccList[i].User__c == lstTestDrives[j].CreatedById)
                            k++;
                    }        
                    testDriveMap.put(newAccList[i].User__c, k);
                }
           }
           
           //Getting Count of Finance Checklist punched by each DSE
           if(lstMCComm.size() > 0 && newAccList.size() > 0)
           {
                for(i=0; i< newAccList.size();i++)
                {
                    k=0;
                    for(j=0; j< lstMCComm.size();j++)
                    {
                        if(newAccList[i].User__c == lstMCComm[j].CreatedById && lstMCComm[j].Type__c == 'Finance Checklist')
                            k++;
                    }        
                    financeChecklistMap.put(newAccList[i].User__c, k);
                }
           }
           
           //Getting Count of Delivery Checklist punched by each DSE
           if(lstMCComm.size() > 0 && newAccList.size() > 0)
           {
                for(i=0; i< newAccList.size();i++)
                {
                    k=0;
                    for(j=0; j< lstMCComm.size();j++)
                    {
                        if(newAccList[i].User__c == lstMCComm[j].CreatedById && lstMCComm[j].Type__c == 'Delivery Checklist')
                            k++;
                    }        
                    deliveryChecklistMap.put(newAccList[i].User__c, k);
                }
           }
           
           //Getting Count of BCR punched by each DSE
            if(lstMCComm.size() > 0 && newAccList.size() > 0)
           {
                for(i=0; i< newAccList.size();i++)
                {
                    k=0;
                    for(j=0; j< lstMCComm.size();j++)
                    {
                        if(newAccList[i].User__c == lstMCComm[j].CreatedById && lstMCComm[j].Type__c == 'BCR')
                            k++;
                    }        
                    bcrMap.put(newAccList[i].User__c, k);
                }
           }
           
            //Getting Count of Brochure punched by each DSE
            if(lstMCComm.size() > 0 && newAccList.size() > 0)
           {
                for(i=0; i< newAccList.size();i++)
                {
                    k=0;
                    for(j=0; j< lstMCComm.size();j++)
                    {
                        if(newAccList[i].User__c == lstMCComm[j].CreatedById && lstMCComm[j].Type__c == 'Send Brochure')
                            k++;
                    }        
                    broshureMap.put(newAccList[i].User__c, k);
                }
           }
           
           //Getting Count of Brochure punched by each DSE
            if(lstMCComm.size() > 0 && newAccList.size() > 0)
           {
                for(i=0; i< newAccList.size();i++)
                {
                    k=0;
                    for(j=0; j< lstMCComm.size();j++)
                    {
                        if(newAccList[i].User__c == lstMCComm[j].CreatedById && lstMCComm[j].Type__c == 'Quote')
                            k++;
                    }        
                    quoteMap.put(newAccList[i].User__c, k);
                }
           }
           
           //Getting Count of Event punched by each DSE
           if(lstEvents.size() > 0 && newAccList.size() > 0)
           {
                for(i=0; i< newAccList.size();i++)
                {
                    k=0;
                    for(j=0; j< lstEvents.size();j++)
                    {
                        if(newAccList[i].User__c == lstEvents[j].CreatedById)
                            k++;
                    }        
                    eventMap.put(newAccList[i].User__c, k);
                }
           }
           
           //Getting Count of Visit Plan punched by each DSE are are planned
           if(lstVisitPlans.size() > 0 && newAccList.size() > 0)
           {
                for(i=0; i< newAccList.size();i++)
                {
                    k=0;
                    for(j=0; j< lstVisitPlans.size();j++)
                    {
                        if(newAccList[i].User__c == lstVisitPlans[j].CreatedById && lstVisitPlans[j].Status__c == 'Planned')
                            k++;
                    }        
                    visitPlanMap.put(newAccList[i].User__c, k);
                }
           }
           
            //Getting Count of Visit Plan punched by each DSE and are completed
           if(lstVisitPlans.size() > 0 && newAccList.size() > 0)
           {
                for(i=0; i< newAccList.size();i++)
                {
                    k=0;
                    for(j=0; j< lstVisitPlans.size();j++)
                    {
                        if(newAccList[i].User__c == lstVisitPlans[j].CreatedById && lstVisitPlans[j].Status__c == 'Completed')
                            k++;
                    }        
                    visitPlanDoneMap.put(newAccList[i].User__c, k);
                }
           }
           
           //Getting Count of chatter post punched by each DSE
           if(oppFeedChatterUsed.size() > 0 && newAccList.size() > 0)
           {
                for(i=0; i< newAccList.size();i++)
                {
                    k=0;
                    for(j=0; j< oppFeedChatterUsed.size();j++)
                    {
                        if(newAccList[i].User__c == oppFeedChatterUsed[j].CreatedById)
                            k++;
                    }        
                    chatterUsedMap.put(newAccList[i].User__c, k);
                }
           }
           
           //Getting Count of lead punched by each DSE
           if(leadLst.size() > 0 && newAccList.size() > 0)
           {
                for(i=0; i< newAccList.size();i++)
                {
                    k=0;
                    for(j=0; j< leadLst.size();j++)
                    {
                        if(newAccList[i].User__c == leadLst[j].CreatedById)
                            k++;
                    }        
                    leadsMap.put(newAccList[i].User__c, k);
                }
           }
           
           //Getting Count of oAuth punched by each DSE
           if(OAuthLst.size() > 0 && newAccList.size() > 0)
           {
                for(i=0; i< newAccList.size();i++)
                {
                    k=0;
                    for(j=0; j< OAuthLst.size();j++)
                    {
                        if(newAccList[i].User__c == OAuthLst[j].UserId)
                            k= OAuthLst[j].UseCount;
                    }        
                    noOfTimesAppOpenedMap.put(newAccList[i].User__c, k);
                }
           }
           
           //Getting Count of OAuth punched by each DSE
           if(OAuthLst.size() > 0 && newAccList.size() > 0)
           {
                for(i=0; i< newAccList.size();i++)
                {
                    for(j=0; j< OAuthLst.size();j++)
                    {
                        if(newAccList[i].User__c == OAuthLst[j].UserId)
                            dt = OAuthLst[j].LastUsedDate;
                    }        
                    lastTimeAppUsedMap.put(newAccList[i].User__c, dt);
                }
           }
           
           //Updating Counters on Account
           for(i=0; i< newAccList.size();i++)
           {
                Account acc = new Account(id=newAccList[i].id);
                
                if(oppMap.containsKey(newAccList[i].User__c))
                    acc.Enquiries_Punched_Through_Salesforce__c = String.valueOf(oppMap.get(newAccList[i].User__c));
                
                if(totalOppMap.containsKey(newAccList[i].User__c))
                    acc.Total_Enquiries__c = String.valueOf(totalOppMap.get(newAccList[i].User__c));
                
                if(oppMapPB.containsKey(newAccList[i].User__c))
                    acc.PreBooking_Enquiries_Punched_through_SF__c= String.valueOf(oppMapPB.get(newAccList[i].User__c));
                
                if(followUpMap.containsKey(newAccList[i].User__c))
                    acc.Follow_up_Through_SF__c = String.valueOf(followUpMap.get(newAccList[i].User__c));
                    
                if(totalFollowUpMap.containsKey(newAccList[i].User__c))
                    acc.Total_Followups__c = String.valueOf(totalFollowUpMap.get(newAccList[i].User__c));   
                    
                if(testDriveMap.containsKey(newAccList[i].User__c))
                    acc.Test_Drives_Through_SF__c = String.valueOf(testDriveMap.get(newAccList[i].User__c));
                
                if(financeChecklistMap.containsKey(newAccList[i].User__c))
                    acc.Finance_Checklist_Mailed__c = String.valueOf(financeChecklistMap.get(newAccList[i].User__c));
                
                if(eventMap.containsKey(newAccList[i].User__c))
                    acc.No_of_Events_created__c = String.valueOf(eventMap.get(newAccList[i].User__c));
                                
                if(visitPlanMap.containsKey(newAccList[i].User__c))
                    acc.No_of_Visit_Plans_Created__c = String.valueOf(visitPlanMap.get(newAccList[i].User__c));
                    
                if(deliveryChecklistMap.containsKey(newAccList[i].User__c))
                    acc.Delivery_Checklist_Through_SF__c = String.valueOf(deliveryChecklistMap.get(newAccList[i].User__c));
                
                if(bcrMap.containsKey(newAccList[i].User__c))
                    acc.BCR_Through_SF__c = String.valueOf(bcrMap.get(newAccList[i].User__c));
                                
                if(quoteMap.containsKey(newAccList[i].User__c))
                    acc.Quotes_Through_SF__c = String.valueOf(quoteMap.get(newAccList[i].User__c));

                if(broshureMap.containsKey(newAccList[i].User__c))
                    acc.Brochures_Through_SF__c = String.valueOf(broshureMap.get(newAccList[i].User__c));
                
                if(chatterUsedMap.containsKey(newAccList[i].User__c))
                    acc.No_of_Times_Chatter_Used__c = String.valueOf(chatterUsedMap.get(newAccList[i].User__c));
                    
                if(visitPlanDoneMap.containsKey(newAccList[i].User__c))
                    acc.No_of_Visit_Plan_Completed__c = String.valueOf(visitPlanDoneMap.get(newAccList[i].User__c));    
                    
                if(leadsMap.containsKey(newAccList[i].User__c))
                    acc.No_of_Leads_Generated__c = String.valueOf(leadsMap.get(newAccList[i].User__c));

                if(oppMapRetail.containsKey(newAccList[i].User__c))
                    acc.No_of_Retail_Enquires__c = String.valueOf(oppMapRetail.get(newAccList[i].User__c));
                    
                if(lastTimeAppUsedMap.containsKey(newAccList[i].User__c))
                    acc.Last_time_app_used__c = lastTimeAppUsedMap.get(newAccList[i].User__c);

                if(noOfTimesAppOpenedMap.containsKey(newAccList[i].User__c))
                    acc.No_of_Times_App_Opened__c = String.valueOf(noOfTimesAppOpenedMap.get(newAccList[i].User__c));   
                    
                 if(completedFollowUpMap.containsKey(newAccList[i].User__c))
                    acc.No_Of_FollowUp_Created_Through_SF__c = String.valueOf(completedFollowUpMap.get(newAccList[i].User__c));       
                 
                newAccList1.add(acc);
            }
            
            if(newAccList1.size() > 0)
                update newAccList1;
        }
        
}