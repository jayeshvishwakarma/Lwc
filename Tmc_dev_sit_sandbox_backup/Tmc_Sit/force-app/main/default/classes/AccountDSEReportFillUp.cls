/**
* @File Name          : AccountDSEReportFillUp.cls
* @Description        : Class to update fields that are used in DSE report for his performance
* @Author             : Rahul Sharma
**/
    public class AccountDSEReportFillUp {
        
            
        // Calculating SF adoption by DSE total
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
            system.debug('account list is updateDSEFields : '+ newAccList);
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
        
        // Calculating SF adoption by DSE for monthly count
        public static void updateDSEFieldsForMonthlyCount(List<Account> lstAcc)
        {
            //Parameters and Collections
           List<Account> newAccList = new List<Account>();
           List<Account> newAccList1 = new List<Account>();
           set<string> usrIds = new set<string>();
           map<string, Integer> oppMap = new map<string, Integer>();
           map<string, Integer> oppMapHostessUnAssigned = new map<string, Integer>();
           map<string, Integer> oppMapHostessAssigned = new map<string, Integer>();
           map<string, Integer> oppMapDSECreated = new map<string, Integer>();
           map<string, Integer> totalOppMap = new map<string, Integer>();
           map<string, Integer> oppMapPB = new map<string, Integer>();
           map<string, Integer> oppMapRetail = new map<string, Integer>();
           map<string, Integer> oppMapBooking = new map<string, Integer>();
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
           map<string, Integer> bcrSentOnEnquiry = new map<string, Integer>();
           map<string, Integer> brochureSentOnEnquiry = new map<string, Integer>();
           map<string, Integer> quoteSentOnEnquiry = new map<string, Integer>();
           map<string, Integer> fcSentOnEnquiry = new map<string, Integer>();
           map<string, Integer> dcSentOnEnquiry = new map<string, Integer>();
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
            system.debug('account list is updateDSEFieldsForMonthlyCount: '+ newAccList);
            for(Account acc : newAccList)
            {    
                system.debug('account is :'+ acc);
                if(acc != null && acc.Id != null && acc.User__c != null)
                    usrIds.add(acc.User__c);
            }
           List<DSE_Report_RUn__c> dseRun =DSE_Report_RUn__c.getAll().values();  
           DateTime dt2 = dseRun[0].Monthly_Run_TIme__c;
           Integer year = dt2.year();
           Integer mon = dt2.month();
           if(mon == 1)
               year = year - 1;
           String month = dt2.format('MMMM');
           system.debug('year  509 ' + year + month );
           List<Adoption_Report_MDT__mdt> monDSEList = new list<Adoption_Report_MDT__mdt>([SELECT MasterLabel,Start_Date__c,End_Date__c
                                                                                            FROM Adoption_Report_MDT__mdt
                                                                                            WHERE MasterLabel=:month]);
           system.debug('monDSEList'+monDSEList );
           //Integer day1 = Integer.valueOf((monDSEList[0].Start_Date__c).substringBefore('/'));
           DateTime dt5 = DateTime.newinstance(year, Integer.valueOf((monDSEList[0].Start_Date__c).substringAfter('/')), Integer.valueOf((monDSEList[0].Start_Date__c).substringBefore('/')),0,0,0);
           DateTime dt6 = DateTime.newinstance(year, Integer.valueOf((monDSEList[0].End_Date__c).substringAfter('/')), Integer.valueOf((monDSEList[0].End_Date__c).substringBefore('/')),23,59,59);
           system.debug('dt ' + dt5 + ' ' +dt6);
            //convert above GMT datetime to local datetime
            Datetime dt3 = dt5.Date();
            dt3 = dt3.addHours(dt5.hour());
            dt3 = dt3.addMinutes(dt5.minute());
            dt3 = dt3.addSeconds(dt5.second());
            Datetime dt4 = dt6.Date();
            dt4 = dt4.addHours(dt6.hour());
            dt4 = dt4.addMinutes(dt6.minute());
            dt4 = dt4.addSeconds(dt6.second());
            Date dt7 = date.newinstance(dt3.year(), dt3.month(), dt3.day());
            Date dt8 = date.newinstance(dt4.year(), dt4.month(), dt4.day());
           system.debug('dt ' + dt2+' '+dt3 + ' ' +dt4);
           //Get all records of DSEs for each required object
            User u = [Select Id from user where Name =: 'DMS Admin'];
            if( usrIds.size() >0 )
            {
             lstOpps = [select id,OwnerId,StageName,CreatedById,CreatedBy.Profile.Name,Owner.Profile.Name,
                                  Pre_Booking_Number__c,Booking_Number__c,Retail_Completed_Date__c,DMS_Created_Date__c,DMS_Enquiry_Name__c,
                                  Send_BCR_Time__c,Brochure_Sent_Time__c ,Finance_Checklist_Time__c,
                                  Delivery_Checklist_Time__c,Quote_Sent_time__c,DSE_Allocation_Time__c,CreatedDate,
                                  Pre_booking_Submission_Date__c,Booking_Date__c
                                  FROM Opportunity where OwnerId In: usrIds 
                                  and DMS_Enquiry_Name__c != null
                                  and ((DMS_Created_Date__c >=: dt7 and DMS_Created_Date__c <=: dt8) or 
                                  (DSE_Allocation_Time__c >=: dt3 and DSE_Allocation_Time__c <=: dt4) or
                                  (Send_BCR_Time__c >=: dt3 and Send_BCR_Time__c <=: dt4) or
                                  (Brochure_Sent_Time__c >=: dt3 and Brochure_Sent_Time__c <=: dt4) or
                                  (Finance_Checklist_Time__c >=: dt3 and Finance_Checklist_Time__c <=: dt4) or
                                  (Delivery_Checklist_Time__c >=: dt3 and Delivery_Checklist_Time__c <=: dt4) or
                                  (Quote_Sent_time__c >=: dt3 and Quote_Sent_time__c <=: dt4) or
                                  (Pre_booking_Submission_Date__c >=: dt7 and Pre_booking_Submission_Date__c <=: dt8) or
                                  (Booking_Date__c >=: dt7 and Booking_Date__c <=: dt8) or
                                  (Retail_Completed_Date__c >=: dt7 and Retail_Completed_Date__c <=: dt8) )];
                                  
             lstTestDrives = [select id,CreatedById FROM Test_Drive__c where CreatedById In: usrIds
                                 and CreatedDate >=: dt3 and CreatedDate <=: dt4];
             lstEvents = [select id,CreatedById FROM Event where CreatedById In: usrIds
                                 and CreatedDate >=: dt3 and CreatedDate <=: dt4];
             leadLst = [select id,CreatedById FROM Lead where CreatedById In: usrIds
                                 and CreatedDate >=: dt3 and CreatedDate <=: dt4];
             lstVisitPlans = [select id,CreatedById,Status__c FROM Event_Visit_Plan__c where CreatedById In: usrIds
                                 and CreatedDate >=: dt3 and CreatedDate <=: dt4];
             oppFeedChatterUsed = [select id,CreatedById FROM OpportunityFeed where CreatedById In: usrIds
                                 and CreatedDate >=: dt3 and CreatedDate <=: dt4];
             lstMCComm = [select id,CreatedById,Type__c FROM MC_Communication__c where CreatedById In: usrIds
                                 and CreatedDate >=: dt3 and CreatedDate <=: dt4];   
             lstFollowUps = [select id,CreatedById,OwnerId,Status FROM Task where OwnerId In: usrIds
                                 and CreatedDate >=: dt3 and CreatedDate <=: dt4];
            }            
            
            system.debug('lstOpps: '+ lstOpps.size());
            
           //Getting Count of bcr done on enquiry by each DSE
           if(lstOpps.size() > 0 && newAccList.size() > 0)
           {
                for(i=0; i< newAccList.size();i++)
                {
                    k=0;
                    for(j=0; j< lstOpps.size();j++)
                    {
                        if(newAccList[i].User__c == lstOpps[j].OwnerId && lstOpps[j].Send_BCR_Time__c != null && lstOpps[j].Send_BCR_Time__c >= dt3 && lstOpps[j].Send_BCR_Time__c<= dt4)
                            k++;
                    }        
                    system.debug('newAccList[i].User__c'+newAccList[i].User__c + k);
                    bcrSentOnEnquiry.put(newAccList[i].User__c, k);
                }
           }
           
           //Getting Count of brochure done on enquiry by each DSE
           if(lstOpps.size() > 0 && newAccList.size() > 0)
           {
                for(i=0; i< newAccList.size();i++)
                {
                    k=0;
                    for(j=0; j< lstOpps.size();j++)
                    {
                        if(newAccList[i].User__c == lstOpps[j].OwnerId && lstOpps[j].Brochure_Sent_Time__c != null && lstOpps[j].Brochure_Sent_Time__c >= dt3 && lstOpps[j].Brochure_Sent_Time__c <= dt4)
                            k++;
                    }        
                    system.debug('newAccList[i].User__c'+newAccList[i].User__c + k);
                    brochureSentOnEnquiry.put(newAccList[i].User__c, k);
                }
           }
           
           //Getting Count of Finance Checklist done on enquiry by each DSE
           if(lstOpps.size() > 0 && newAccList.size() > 0)
           {
                for(i=0; i< newAccList.size();i++)
                {
                    k=0;
                    for(j=0; j< lstOpps.size();j++)
                    {
                        if(newAccList[i].User__c == lstOpps[j].OwnerId && lstOpps[j].Finance_Checklist_Time__c != null && lstOpps[j].Finance_Checklist_Time__c >= dt3 && lstOpps[j].Finance_Checklist_Time__c <= dt4)
                            k++;
                    }        
                    system.debug('newAccList[i].User__c'+newAccList[i].User__c + k);
                    fcSentOnEnquiry.put(newAccList[i].User__c, k);
                }
           }
           
           //Getting Count of delivery Checklist done on enquiry by each DSE
           if(lstOpps.size() > 0 && newAccList.size() > 0)
           {
                for(i=0; i< newAccList.size();i++)
                {
                    k=0;
                    for(j=0; j< lstOpps.size();j++)
                    {
                        if(newAccList[i].User__c == lstOpps[j].OwnerId && lstOpps[j].Delivery_Checklist_Time__c != null && lstOpps[j].Delivery_Checklist_Time__c >= dt3 && lstOpps[j].Delivery_Checklist_Time__c <= dt4)
                            k++;
                    }        
                    system.debug('newAccList[i].User__c'+newAccList[i].User__c + k);
                    dcSentOnEnquiry.put(newAccList[i].User__c, k);
                }
           }
           
           //Getting Count of quote done on enquiry by each DSE
           if(lstOpps.size() > 0 && newAccList.size() > 0)
           {
                for(i=0; i< newAccList.size();i++)
                {
                    k=0;
                    for(j=0; j< lstOpps.size();j++)
                    {
                        if(newAccList[i].User__c == lstOpps[j].OwnerId && lstOpps[j].Quote_Sent_time__c != null && lstOpps[j].Quote_Sent_time__c >= dt3 && lstOpps[j].Quote_Sent_time__c <= dt4)
                            k++;
                    }        
                    system.debug('newAccList[i].User__c'+newAccList[i].User__c + k);
                    quoteSentOnEnquiry.put(newAccList[i].User__c, k);
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
                        if(newAccList[i].User__c == lstOpps[j].OwnerId && ((lstOpps[j].DMS_Created_Date__c >= dt7 && lstOpps[j].DMS_Created_Date__c <= dt8) || 
                                  (lstOpps[j].DSE_Allocation_Time__c >= dt3 && lstOpps[j].DSE_Allocation_Time__c <= dt4)))
                            k++;
                    }        
                    system.debug('newAccList[i].User__c'+newAccList[i].User__c + k);
                    totalOppMap.put(newAccList[i].User__c, k);
                }
           }
              
           //Getting Count of opps assigned to each DSE and created in SF only
           if(lstOpps.size() > 0 && newAccList.size() > 0)
           {
                for(i=0; i< newAccList.size();i++)
                {
                    k=0;
                    for(j=0; j< lstOpps.size();j++)
                    {
                        if(newAccList[i].User__c == lstOpps[j].OwnerId && lstOpps[j].CreatedById != u.Id && ((lstOpps[j].DMS_Created_Date__c >= dt7 && lstOpps[j].DMS_Created_Date__c <= dt8) || 
                                  (lstOpps[j].DSE_Allocation_Time__c >= dt3 && lstOpps[j].DSE_Allocation_Time__c <= dt4)))
                            k++;
                    }        
                    oppMap.put(newAccList[i].User__c, k);
                }
           }
           /*
           //Getting Count of opps created by hostess in sf but not assigned to DSE
           if(lstOpps.size() > 0 && newAccList.size() > 0)
           {
                for(i=0; i< newAccList.size();i++)
                {
                    k=0;
                    for(j=0; j< lstOpps.size();j++)
                    {
                        if(newAccList[i].User__c == lstOpps[j].OwnerId && lstOpps[j].CreatedById != u.Id && lstOpps[j].CreatedBy.Profile.Name == 'Dealer Hostess' && lstOpps[j].Owner.Profile.Name == 'Dealer Hostess')
                            k++;
                    }        
                    oppMapHostessUnAssigned.put(newAccList[i].User__c, k);
                }
           }
           
           //Getting Count of opps created by hostess in sf and are assigned to DSE
           if(lstOpps.size() > 0 && newAccList.size() > 0)
           {
                for(i=0; i< newAccList.size();i++)
                {
                    k=0;
                    for(j=0; j< lstOpps.size();j++)
                    {
                        if(newAccList[i].User__c == lstOpps[j].OwnerId && lstOpps[j].CreatedById != u.Id && lstOpps[j].CreatedBy.Profile.Name == 'Dealer Hostess' && lstOpps[j].Owner.Profile.Name == 'Dealer Sales Executive')
                            k++;
                    }        
                    oppMapHostessAssigned.put(newAccList[i].User__c, k);
                }
           }
           */
           //Getting Count of opps created by DSE in sf
           if(lstOpps.size() > 0 && newAccList.size() > 0)
           {
                for(i=0; i< newAccList.size();i++)
                {
                    k=0;
                    for(j=0; j< lstOpps.size();j++)
                    {
                        if(newAccList[i].User__c == lstOpps[j].OwnerId && lstOpps[j].CreatedById != u.Id && lstOpps[j].CreatedBy.Profile.Name == 'Dealer Sales Executive' && ((lstOpps[j].DMS_Created_Date__c >= dt7 && lstOpps[j].DMS_Created_Date__c <= dt8) || 
                                  (lstOpps[j].DSE_Allocation_Time__c >= dt3 && lstOpps[j].DSE_Allocation_Time__c <= dt4)))
                            k++;
                    }        
                    oppMapDSECreated.put(newAccList[i].User__c, k);
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
           
            //Getting Count of opps punched by each DSE and stage not equal to New
           if(lstOpps.size() > 0 && newAccList.size() > 0)
           {
                for(i=0; i< newAccList.size();i++)
                {
                    k=0;
                    for(j=0; j< lstOpps.size();j++)
                    {
                        if(newAccList[i].User__c == lstOpps[j].OwnerId && lstOpps[j].Pre_Booking_Number__c != null && lstOpps[j].CreatedById != u.Id && lstOpps[j].Pre_booking_Submission_Date__c >= dt7 && lstOpps[j].Pre_booking_Submission_Date__c <= dt8 )
                            k++;
                    }        
                    oppMapPB.put(newAccList[i].User__c, k);
                }
           }
           
           //Getting Count of retails opps assigned to each DSE
           if(lstOpps.size() > 0 && newAccList.size() > 0)
           {
                for(i=0; i< newAccList.size();i++)
                {
                    k=0;
                    for(j=0; j< lstOpps.size();j++)
                    {
                        if(newAccList[i].User__c == lstOpps[j].OwnerId && lstOpps[j].Retail_Completed_Date__c != null && lstOpps[j].Retail_Completed_Date__c >= dt7 && lstOpps[j].Retail_Completed_Date__c <= dt8)
                                  
                            k++;
                    }        
                    oppMapRetail.put(newAccList[i].User__c, k);
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
           
           //Getting Count of booking opps assigned to each DSE
           if(lstOpps.size() > 0 && newAccList.size() > 0)
           {
                for(i=0; i< newAccList.size();i++)
                {
                    k=0;
                    for(j=0; j< lstOpps.size();j++)
                    {
                        if(newAccList[i].User__c == lstOpps[j].OwnerId && lstOpps[j].Booking_Number__c != null && lstOpps[j].Booking_Date__c>= dt7 && lstOpps[j].Booking_Date__c<= dt8)
                            k++;
                    }        
                    oppMapBooking.put(newAccList[i].User__c, k);
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
                        if(newAccList[i].User__c == lstFollowUps[j].OwnerId && lstFollowUps[j].Status == 'Completed')
                            k++;
                    }        
                    totalFollowUpMap.put(newAccList[i].User__c, k);
                }
           }
           
           List<DSE_Adoption__c> dseLst = new List<DSE_Adoption__c>();
           
           for(i=0; i< newAccList.size();i++)
           {
                DSE_Adoption__c dse = new DSE_Adoption__c();
                
                if(totalOppMap.containsKey(newAccList[i].User__c))
                    dse.Count__c= totalOppMap.get(newAccList[i].User__c);
                
                if(oppMap.containsKey(newAccList[i].User__c))
                    dse.Enquiries_Assignes_To_DSE__c = oppMap.get(newAccList[i].User__c);
                
                if(oppMapHostessUnAssigned.containsKey(newAccList[i].User__c))
                    dse.Enquiries_Punched_Through_Salesforce__c= oppMapHostessUnAssigned.get(newAccList[i].User__c);    
                
                if(oppMapHostessAssigned.containsKey(newAccList[i].User__c))
                    dse.Enquiry_Punch_By_Hostess_and_Assigned__c= oppMapHostessAssigned.get(newAccList[i].User__c);    
                
                if(oppMapDSECreated.containsKey(newAccList[i].User__c))
                    dse.Enquiry_Punch_By_DSE__c = oppMapDSECreated.get(newAccList[i].User__c); 
                    
                if(testDriveMap.containsKey(newAccList[i].User__c))
                    dse.Test_Drive_Through_SF__c = testDriveMap.get(newAccList[i].User__c); 
                    
                if(oppMapPB.containsKey(newAccList[i].User__c))
                    dse.PreBooking_Enquiries_Punched_through_SF__c= oppMapPB.get(newAccList[i].User__c);            
                    
                if(oppMapRetail.containsKey(newAccList[i].User__c))
                    dse.No_of_Retail_Enquires__c= oppMapRetail.get(newAccList[i].User__c); 
                
                if(eventMap.containsKey(newAccList[i].User__c))
                    dse.No_of_Events_Punch_Through_SF__c = eventMap.get(newAccList[i].User__c);
                    
                if(leadsMap.containsKey(newAccList[i].User__c))
                    dse.No_of_Leads_Generated__c = leadsMap.get(newAccList[i].User__c);            
                 
                if(visitPlanMap.containsKey(newAccList[i].User__c))
                    dse.No_of_Visit_Plans_Created__c= visitPlanMap.get(newAccList[i].User__c);   
                
                if(visitPlanDoneMap.containsKey(newAccList[i].User__c))
                    dse.No_of_Visit_Plan_Completed__c= visitPlanDoneMap.get(newAccList[i].User__c);           
                
                if(chatterUsedMap.containsKey(newAccList[i].User__c))
                    dse.No_of_Times_Chatter_Used__c= chatterUsedMap.get(newAccList[i].User__c);
                    
                if(oppMapBooking.containsKey(newAccList[i].User__c))
                    dse.Total_Booking__c= oppMapBooking.get(newAccList[i].User__c);
                    
                if(financeChecklistMap.containsKey(newAccList[i].User__c))
                    dse.Finance_Checklist_Mailed__c= financeChecklistMap.get(newAccList[i].User__c);            
                 
                if(deliveryChecklistMap.containsKey(newAccList[i].User__c))
                    dse.Delivery_Checklist_Through_SF__c= deliveryChecklistMap.get(newAccList[i].User__c);   
                
                if(bcrMap.containsKey(newAccList[i].User__c))
                    dse.BCR_Through_SF__c= bcrMap.get(newAccList[i].User__c);           
                
                if(broshureMap.containsKey(newAccList[i].User__c))
                    dse.Brochures_Through_SF__c= broshureMap.get(newAccList[i].User__c);
                    
                if(quoteMap.containsKey(newAccList[i].User__c))
                    dse.Quotes_Through_SF__c= quoteMap.get(newAccList[i].User__c);                       
                    
                if(completedFollowUpMap.containsKey(newAccList[i].User__c))
                    dse.Follow_Up_Completed_in_SF__c = completedFollowUpMap.get(newAccList[i].User__c);
                    
                if(totalFollowUpMap.containsKey(newAccList[i].User__c))
                    dse.Total_Follow_Ups_Completed__c = totalFollowUpMap.get(newAccList[i].User__c);
                    
                if(bcrSentOnEnquiry.containsKey(newAccList[i].User__c))
                    dse.Unique_BCR_Through_SF__c = bcrSentOnEnquiry.get(newAccList[i].User__c);           
                
                if(brochureSentOnEnquiry.containsKey(newAccList[i].User__c))
                    dse.Unique_Brochures_Through_SF__c= brochureSentOnEnquiry.get(newAccList[i].User__c);
                    
                if(quoteSentOnEnquiry.containsKey(newAccList[i].User__c))
                    dse.Unique_Quotes_Through_SF__c= quoteSentOnEnquiry.get(newAccList[i].User__c);                       
                    
                if(fcSentOnEnquiry.containsKey(newAccList[i].User__c))
                    dse.Unique_Finance_Checklist_Mailed__c= fcSentOnEnquiry.get(newAccList[i].User__c);
                    
                if(dcSentOnEnquiry.containsKey(newAccList[i].User__c))
                    dse.Unique_Delivery_Checklist_Through_SF__c= dcSentOnEnquiry.get(newAccList[i].User__c);  
                
                if(dse.count__c != null || dse.Enquiries_Punched_Through_Salesforce__c != null || dse.Enquiries_Punched_Through_Salesforce__c != null
                 || dse.Enquiry_Punch_By_Hostess_and_Assigned__c != null || dse.Enquiry_Punch_By_DSE__c != null || dse.Test_Drive_Through_SF__c != null
                 || dse.PreBooking_Enquiries_Punched_through_SF__c != null || dse.No_of_Retail_Enquires__c != null || dse.No_of_Leads_Generated__c != null
                 || dse.No_of_Visit_Plans_Created__c != null || dse.No_of_Visit_Plan_Completed__c != null || dse.No_of_Times_Chatter_Used__c != null
                 || dse.Total_Booking__c != null || dse.Quotes_Through_SF__c != null || dse.Brochures_Through_SF__c != null || dse.BCR_Through_SF__c != null
                 || dse.Delivery_Checklist_Through_SF__c != null || dse.Finance_Checklist_Mailed__c != null | dse.Follow_Up_Completed_in_SF__c != null 
                 || dse.Total_Follow_Ups_Completed__c != null || dse.Unique_Delivery_Checklist_Through_SF__c != null || dse.Unique_Finance_Checklist_Mailed__c != null
                 || dse.Unique_Quotes_Through_SF__c != null || dse.Unique_Brochures_Through_SF__c != null || dse.Unique_BCR_Through_SF__c != null )
                {
                    dse.DSEAccount__c = newAccList[i].id;
                    dse.IsMonthly__c = true;
                    dseLst.add(dse);
                }   
          }
          
          if(!dseLst.IsEmpty())
              insert dseLst;
 } 
             // Calculating SF adoption by DSE for daily count
        public static void updateDSEFieldsForDailyCount(List<Account> lstAcc)
        {
            //Parameters and Collections
           List<Account> newAccList = new List<Account>();
           List<Account> newAccList1 = new List<Account>();
           set<string> usrIds = new set<string>();
           map<string, Integer> oppMap = new map<string, Integer>();
           map<string, Integer> oppMapHostessUnAssigned = new map<string, Integer>();
           map<string, Integer> oppMapHostessAssigned = new map<string, Integer>();
           map<string, Integer> oppMapDSECreated = new map<string, Integer>();
           map<string, Integer> totalOppMap = new map<string, Integer>();
           map<string, Integer> oppMapPB = new map<string, Integer>();
           map<string, Integer> oppMapRetail = new map<string, Integer>();
           map<string, Integer> oppMapBooking = new map<string, Integer>();
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
           map<string, Integer> bcrSentOnEnquiry = new map<string, Integer>();
           map<string, Integer> brochureSentOnEnquiry = new map<string, Integer>();
           map<string, Integer> quoteSentOnEnquiry = new map<string, Integer>();
           map<string, Integer> fcSentOnEnquiry = new map<string, Integer>();
           map<string, Integer> dcSentOnEnquiry = new map<string, Integer>();
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
            system.debug('account list is updateDSEFieldsForDailyCount : '+ newAccList);
            for(Account acc : newAccList)
            {    
                system.debug('account is :'+ acc);
                if(acc != null && acc.Id != null && acc.User__c != null)
                    usrIds.add(acc.User__c);
            }
           List<DSE_Report_RUn__c> dseRun =DSE_Report_RUn__c.getAll().values();  
           DateTime dt3 = dseRun[0].Daily_Run_Time__c;
            DateTime dt4 = dt3.addHours(24);           
            DateTime dt5 = DateTime.newinstance(dt3.Year(), dt3.month(), dt3.day(),0,0,0);
            DateTime dt6 = DateTime.newinstance(dt4.Year(), dt4.month(), dt4.day(),23,59,59);
            //convert above GMT datetime to local datetime
            dt3 = dt5.Date();
            dt3 = dt3.addHours(dt5.hour());
            dt3 = dt3.addMinutes(dt5.minute());
            dt3 = dt3.addSeconds(dt5.second());
            dt4 = dt6.Date();
            dt4 = dt4.addHours(dt6.hour());
            dt4 = dt4.addMinutes(dt6.minute());
            dt4 = dt4.addSeconds(dt6.second());
            Date dt7 = date.newinstance(dt3.year(), dt3.month(), dt3.day());
           system.debug('dt ' + dt3 + ' ' +dt4);
           //Get all records of DSEs for each required object
            User u = [Select Id from user where Name =: 'DMS Admin'];
            if( usrIds.size() >0 )
            {
             lstOpps = [select id,OwnerId,StageName,CreatedById,CreatedBy.Profile.Name,Owner.Profile.Name,
                                  Pre_Booking_Number__c,Booking_Number__c,Retail_Completed_Date__c,DMS_Created_Date__c,DMS_Enquiry_Name__c,
                                  Send_BCR_Time__c,Brochure_Sent_Time__c ,Finance_Checklist_Time__c,
                                  Delivery_Checklist_Time__c,Quote_Sent_time__c,DSE_Allocation_Time__c,CreatedDate,
                                  Pre_booking_Submission_Date__c,Booking_Date__c
                                  FROM Opportunity where OwnerId In: usrIds 
                                  and DMS_Enquiry_Name__c != null
                                  and ((DMS_Created_Date__c =: dt7) or 
                                  (Send_BCR_Time__c >=: dt3 and Send_BCR_Time__c <=: dt4) or
                                  (Brochure_Sent_Time__c >=: dt3 and Brochure_Sent_Time__c <=: dt4) or
                                  (Finance_Checklist_Time__c >=: dt3 and Finance_Checklist_Time__c <=: dt4) or
                                  (Delivery_Checklist_Time__c >=: dt3 and Delivery_Checklist_Time__c <=: dt4) or
                                  (Quote_Sent_time__c >=: dt3 and Quote_Sent_time__c <=: dt4) or
                                  (Pre_booking_Submission_Date__c =: dt7 ) or
                                  (Booking_Date__c =: dt7) or
                                  (Retail_Completed_Date__c =: dt7) )];
             lstTestDrives = [select id,CreatedById FROM Test_Drive__c where CreatedById In: usrIds
                                 and CreatedDate >=: dt3 and CreatedDate <: dt4];
             lstEvents = [select id,CreatedById FROM Event where CreatedById In: usrIds
                                 and CreatedDate >=: dt3 and CreatedDate <: dt4];
             leadLst = [select id,CreatedById FROM Lead where CreatedById In: usrIds
                                 and CreatedDate >=: dt3 and CreatedDate <: dt4];
             lstVisitPlans = [select id,CreatedById,Status__c FROM Event_Visit_Plan__c where CreatedById In: usrIds
                                 and CreatedDate >=: dt3 and CreatedDate <: dt4];
             oppFeedChatterUsed = [select id,CreatedById FROM OpportunityFeed where CreatedById In: usrIds
                                 and CreatedDate >=: dt3 and CreatedDate <: dt4];
             lstMCComm = [select id,CreatedById,Type__c FROM MC_Communication__c where CreatedById In: usrIds
                                 and CreatedDate >=: dt3 and CreatedDate <: dt4];   
             lstFollowUps = [select id,CreatedById,OwnerId,Status FROM Task where OwnerId In: usrIds
                                 and CreatedDate >=: dt3 and CreatedDate <: dt4];
            }            
            
            system.debug('lstOpps: '+ lstOpps.size());
            
           //Getting Count of bcr done on enquiry by each DSE
           if(lstOpps.size() > 0 && newAccList.size() > 0)
           {
                for(i=0; i< newAccList.size();i++)
                {
                    k=0;
                    for(j=0; j< lstOpps.size();j++)
                    {
                        if(newAccList[i].User__c == lstOpps[j].OwnerId && lstOpps[j].Send_BCR_Time__c != null && lstOpps[j].Send_BCR_Time__c >= dt3 && lstOpps[j].Send_BCR_Time__c < dt4)
                            k++;
                    }        
                    system.debug('newAccList[i].User__c'+newAccList[i].User__c + k);
                    bcrSentOnEnquiry.put(newAccList[i].User__c, k);
                }
           }
           
           //Getting Count of brochure done on enquiry by each DSE
           if(lstOpps.size() > 0 && newAccList.size() > 0)
           {
                for(i=0; i< newAccList.size();i++)
                {
                    k=0;
                    for(j=0; j< lstOpps.size();j++)
                    {
                        if(newAccList[i].User__c == lstOpps[j].OwnerId && lstOpps[j].Brochure_Sent_Time__c != null && lstOpps[j].Brochure_Sent_Time__c >= dt3 && lstOpps[j].Brochure_Sent_Time__c < dt4)
                            k++;
                    }        
                    system.debug('newAccList[i].User__c'+newAccList[i].User__c + k);
                    brochureSentOnEnquiry.put(newAccList[i].User__c, k);
                }
           }
           
           //Getting Count of Finance Checklist done on enquiry by each DSE
           if(lstOpps.size() > 0 && newAccList.size() > 0)
           {
                for(i=0; i< newAccList.size();i++)
                {
                    k=0;
                    for(j=0; j< lstOpps.size();j++)
                    {
                        if(newAccList[i].User__c == lstOpps[j].OwnerId && lstOpps[j].Finance_Checklist_Time__c != null && lstOpps[j].Finance_Checklist_Time__c >= dt3 && lstOpps[j].Finance_Checklist_Time__c < dt4)
                            k++;
                    }        
                    system.debug('newAccList[i].User__c'+newAccList[i].User__c + k);
                    fcSentOnEnquiry.put(newAccList[i].User__c, k);
                }
           }
           
           //Getting Count of delivery Checklist done on enquiry by each DSE
           if(lstOpps.size() > 0 && newAccList.size() > 0)
           {
                for(i=0; i< newAccList.size();i++)
                {
                    k=0;
                    for(j=0; j< lstOpps.size();j++)
                    {
                        if(newAccList[i].User__c == lstOpps[j].OwnerId && lstOpps[j].Delivery_Checklist_Time__c != null && lstOpps[j].Delivery_Checklist_Time__c >= dt3 && lstOpps[j].Delivery_Checklist_Time__c < dt4)
                            k++;
                    }        
                    system.debug('newAccList[i].User__c'+newAccList[i].User__c + k);
                    dcSentOnEnquiry.put(newAccList[i].User__c, k);
                }
           }
           
           //Getting Count of quote done on enquiry by each DSE
           if(lstOpps.size() > 0 && newAccList.size() > 0)
           {
                for(i=0; i< newAccList.size();i++)
                {
                    k=0;
                    for(j=0; j< lstOpps.size();j++)
                    {
                        if(newAccList[i].User__c == lstOpps[j].OwnerId && lstOpps[j].Quote_Sent_time__c != null && lstOpps[j].Quote_Sent_time__c >= dt3 && lstOpps[j].Quote_Sent_time__c < dt4)
                            k++;
                    }        
                    system.debug('newAccList[i].User__c'+newAccList[i].User__c + k);
                    quoteSentOnEnquiry.put(newAccList[i].User__c, k);
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
                        if(newAccList[i].User__c == lstOpps[j].OwnerId && lstOpps[j].DMS_Created_Date__c == dt7)
                            k++;
                    }        
                    system.debug('newAccList[i].User__c'+newAccList[i].User__c + k);
                    totalOppMap.put(newAccList[i].User__c, k);
                }
           }
              
           //Getting Count of opps assigned to each DSE and created in SF only
           if(lstOpps.size() > 0 && newAccList.size() > 0)
           {
                for(i=0; i< newAccList.size();i++)
                {
                    k=0;
                    for(j=0; j< lstOpps.size();j++)
                    {
                        if(newAccList[i].User__c == lstOpps[j].OwnerId && lstOpps[j].CreatedById != u.Id && lstOpps[j].DMS_Created_Date__c == dt7)
							k++;
                    }        
                    oppMap.put(newAccList[i].User__c, k);
                }
           }
           /*
           //Getting Count of opps created by hostess in sf but not assigned to DSE
           if(lstOpps.size() > 0 && newAccList.size() > 0)
           {
                for(i=0; i< newAccList.size();i++)
                {
                    k=0;
                    for(j=0; j< lstOpps.size();j++)
                    {
                        if(newAccList[i].User__c == lstOpps[j].OwnerId && lstOpps[j].CreatedById != u.Id && lstOpps[j].CreatedBy.Profile.Name == 'Dealer Hostess' && lstOpps[j].Owner.Profile.Name == 'Dealer Hostess')
                            k++;
                    }        
                    oppMapHostessUnAssigned.put(newAccList[i].User__c, k);
                }
           }
           
           //Getting Count of opps created by hostess in sf and are assigned to DSE
           if(lstOpps.size() > 0 && newAccList.size() > 0)
           {
                for(i=0; i< newAccList.size();i++)
                {
                    k=0;
                    for(j=0; j< lstOpps.size();j++)
                    {
                        if(newAccList[i].User__c == lstOpps[j].OwnerId && lstOpps[j].CreatedById != u.Id && lstOpps[j].CreatedBy.Profile.Name == 'Dealer Hostess' && lstOpps[j].Owner.Profile.Name == 'Dealer Sales Executive')
                            k++;
                    }        
                    oppMapHostessAssigned.put(newAccList[i].User__c, k);
                }
           }
           */
           //Getting Count of opps created by DSE in sf
           if(lstOpps.size() > 0 && newAccList.size() > 0)
           {
                for(i=0; i< newAccList.size();i++)
                {
                    k=0;
                    for(j=0; j< lstOpps.size();j++)
                    {
                        if(newAccList[i].User__c == lstOpps[j].OwnerId && lstOpps[j].CreatedById != u.Id && lstOpps[j].CreatedBy.Profile.Name == 'Dealer Sales Executive' && lstOpps[j].DMS_Created_Date__c == dt7)
                            k++;
                    }        
                    oppMapDSECreated.put(newAccList[i].User__c, k);
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
           
            //Getting Count of opps punched by each DSE and stage not equal to New
           if(lstOpps.size() > 0 && newAccList.size() > 0)
           {
                for(i=0; i< newAccList.size();i++)
                {
                    k=0;
                    for(j=0; j< lstOpps.size();j++)
                    {
                        if(newAccList[i].User__c == lstOpps[j].OwnerId && lstOpps[j].Pre_Booking_Number__c != null && lstOpps[j].CreatedById != u.Id && lstOpps[j].Pre_booking_Submission_Date__c == dt7)
                            k++;
                    }        
                    oppMapPB.put(newAccList[i].User__c, k);
                }
           }
           
           //Getting Count of retails opps assigned to each DSE
           if(lstOpps.size() > 0 && newAccList.size() > 0)
           {
                for(i=0; i< newAccList.size();i++)
                {
                    k=0;
                    for(j=0; j< lstOpps.size();j++)
                    {
                        if(newAccList[i].User__c == lstOpps[j].OwnerId && lstOpps[j].Retail_Completed_Date__c != null && lstOpps[j].Retail_Completed_Date__c == dt7)
                            k++;
                    }        
                    oppMapRetail.put(newAccList[i].User__c, k);
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
           
           //Getting Count of booking opps assigned to each DSE
           if(lstOpps.size() > 0 && newAccList.size() > 0)
           {
                for(i=0; i< newAccList.size();i++)
                {
                    k=0;
                    for(j=0; j< lstOpps.size();j++)
                    {
                        if(newAccList[i].User__c == lstOpps[j].OwnerId && lstOpps[j].Booking_Number__c != null && lstOpps[j].Booking_Date__c == dt7)
                            k++;
                    }        
                    oppMapBooking.put(newAccList[i].User__c, k);
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
                        if(newAccList[i].User__c == lstFollowUps[j].OwnerId && lstFollowUps[j].Status == 'Completed')
                            k++;
                    }        
                    totalFollowUpMap.put(newAccList[i].User__c, k);
                }
           }
           
           List<DSE_Adoption__c> dseLst = new List<DSE_Adoption__c>();
           
           for(i=0; i< newAccList.size();i++)
           {
                DSE_Adoption__c dse = new DSE_Adoption__c();
                
                if(totalOppMap.containsKey(newAccList[i].User__c))
                    dse.Count__c= totalOppMap.get(newAccList[i].User__c);
                
                if(oppMap.containsKey(newAccList[i].User__c))
                    dse.Enquiries_Assignes_To_DSE__c = oppMap.get(newAccList[i].User__c);
                
                if(oppMapHostessUnAssigned.containsKey(newAccList[i].User__c))
                    dse.Enquiries_Punched_Through_Salesforce__c= oppMapHostessUnAssigned.get(newAccList[i].User__c);    
                
                if(oppMapHostessAssigned.containsKey(newAccList[i].User__c))
                    dse.Enquiry_Punch_By_Hostess_and_Assigned__c= oppMapHostessAssigned.get(newAccList[i].User__c);    
                
                if(oppMapDSECreated.containsKey(newAccList[i].User__c))
                    dse.Enquiry_Punch_By_DSE__c = oppMapDSECreated.get(newAccList[i].User__c); 
                    
                if(testDriveMap.containsKey(newAccList[i].User__c))
                    dse.Test_Drive_Through_SF__c = testDriveMap.get(newAccList[i].User__c); 
                    
                if(oppMapPB.containsKey(newAccList[i].User__c))
                    dse.PreBooking_Enquiries_Punched_through_SF__c= oppMapPB.get(newAccList[i].User__c);            
                    
                if(oppMapRetail.containsKey(newAccList[i].User__c))
                    dse.No_of_Retail_Enquires__c= oppMapRetail.get(newAccList[i].User__c); 
                
                if(eventMap.containsKey(newAccList[i].User__c))
                    dse.No_of_Events_Punch_Through_SF__c = eventMap.get(newAccList[i].User__c);
                    
                if(leadsMap.containsKey(newAccList[i].User__c))
                    dse.No_of_Leads_Generated__c = leadsMap.get(newAccList[i].User__c);            
                 
                if(visitPlanMap.containsKey(newAccList[i].User__c))
                    dse.No_of_Visit_Plans_Created__c= visitPlanMap.get(newAccList[i].User__c);   
                
                if(visitPlanDoneMap.containsKey(newAccList[i].User__c))
                    dse.No_of_Visit_Plan_Completed__c= visitPlanDoneMap.get(newAccList[i].User__c);           
                
                if(chatterUsedMap.containsKey(newAccList[i].User__c))
                    dse.No_of_Times_Chatter_Used__c= chatterUsedMap.get(newAccList[i].User__c);
                    
                if(oppMapBooking.containsKey(newAccList[i].User__c))
                    dse.Total_Booking__c= oppMapBooking.get(newAccList[i].User__c);
                    
                if(financeChecklistMap.containsKey(newAccList[i].User__c))
                    dse.Finance_Checklist_Mailed__c= financeChecklistMap.get(newAccList[i].User__c);            
                 
                if(deliveryChecklistMap.containsKey(newAccList[i].User__c))
                    dse.Delivery_Checklist_Through_SF__c= deliveryChecklistMap.get(newAccList[i].User__c);   
                
                if(bcrMap.containsKey(newAccList[i].User__c))
                    dse.BCR_Through_SF__c= bcrMap.get(newAccList[i].User__c);           
                
                if(broshureMap.containsKey(newAccList[i].User__c))
                    dse.Brochures_Through_SF__c= broshureMap.get(newAccList[i].User__c);
                    
                if(quoteMap.containsKey(newAccList[i].User__c))
                    dse.Quotes_Through_SF__c= quoteMap.get(newAccList[i].User__c);                       
                    
                if(completedFollowUpMap.containsKey(newAccList[i].User__c))
                    dse.Follow_Up_Completed_in_SF__c = completedFollowUpMap.get(newAccList[i].User__c);
                    
                if(totalFollowUpMap.containsKey(newAccList[i].User__c))
                    dse.Total_Follow_Ups_Completed__c = totalFollowUpMap.get(newAccList[i].User__c);
                    
                if(bcrSentOnEnquiry.containsKey(newAccList[i].User__c))
                    dse.Unique_BCR_Through_SF__c = bcrSentOnEnquiry.get(newAccList[i].User__c);           
                
                if(brochureSentOnEnquiry.containsKey(newAccList[i].User__c))
                    dse.Unique_Brochures_Through_SF__c= brochureSentOnEnquiry.get(newAccList[i].User__c);
                    
                if(quoteSentOnEnquiry.containsKey(newAccList[i].User__c))
                    dse.Unique_Quotes_Through_SF__c= quoteSentOnEnquiry.get(newAccList[i].User__c);                       
                    
                if(fcSentOnEnquiry.containsKey(newAccList[i].User__c))
                    dse.Unique_Finance_Checklist_Mailed__c= fcSentOnEnquiry.get(newAccList[i].User__c);
                    
                if(dcSentOnEnquiry.containsKey(newAccList[i].User__c))
                    dse.Unique_Delivery_Checklist_Through_SF__c= dcSentOnEnquiry.get(newAccList[i].User__c);  
                
                if(dse.count__c != null || dse.Enquiries_Punched_Through_Salesforce__c != null || dse.Enquiries_Punched_Through_Salesforce__c != null
                 || dse.Enquiry_Punch_By_Hostess_and_Assigned__c != null || dse.Enquiry_Punch_By_DSE__c != null || dse.Test_Drive_Through_SF__c != null
                 || dse.PreBooking_Enquiries_Punched_through_SF__c != null || dse.No_of_Retail_Enquires__c != null || dse.No_of_Leads_Generated__c != null
                 || dse.No_of_Visit_Plans_Created__c != null || dse.No_of_Visit_Plan_Completed__c != null || dse.No_of_Times_Chatter_Used__c != null
                 || dse.Total_Booking__c != null || dse.Quotes_Through_SF__c != null || dse.Brochures_Through_SF__c != null || dse.BCR_Through_SF__c != null
                 || dse.Delivery_Checklist_Through_SF__c != null || dse.Finance_Checklist_Mailed__c != null | dse.Follow_Up_Completed_in_SF__c != null 
                 || dse.Total_Follow_Ups_Completed__c != null || dse.Unique_Delivery_Checklist_Through_SF__c != null || dse.Unique_Finance_Checklist_Mailed__c != null
                 || dse.Unique_Quotes_Through_SF__c != null || dse.Unique_Brochures_Through_SF__c != null || dse.Unique_BCR_Through_SF__c != null )
                {
                    dse.DSEAccount__c = newAccList[i].id;
                    dse.IsMonthly__c = false;
                    dseLst.add(dse);
                }   
          }
          
          if(!dseLst.IsEmpty())
              insert dseLst;
          }
}