/**
* @Autho:- Rohit Gupta
* @Company-: Techmatrix Consulting
* @Description-: Batch class to count Number of posts posted by dealer in chatter Groups
* =============================================================
* Version   Date            Author      Modification
* =============================================================
* 1.0       25 Jun 2020    Rohit     Intial Version
**/

public without sharing class CountNumberOfPostsBatch implements Database.Batchable<sObject>, Database.Stateful{
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        DateTime past24 = system.now().AddDays(-1);
        return Database.getQueryLocator([SELECT BestCommentId,Body,CommentCount,CreatedById,CreatedDate,Id,
                                         InsertedById,IsDeleted,IsRichText,LastModifiedDate,LikeCount,
                                         LinkUrl,NetworkScope,ParentId,RelatedRecordId,SystemModstamp,
                                         Title,Type,Visibility 
                                         FROM CollaborationGroupFeed WHERE CreatedDate >= :past24]);
        
    }
    public void execute(Database.BatchableContext bc, List<CollaborationGroupFeed> scope){
        DateTime past24 = system.now().AddDays(-1);
        Set<Id> userIdSet = new Set<Id>();
        List<CollaborationGroupFeed> cgfList = new List<CollaborationGroupFeed>();
        Integer i, j, k;
        Map<String, Integer> cgfMap = new Map<String, Integer>();
        List<Account> accList = new List<Account>();
        for(CollaborationGroupFeed cgf: scope){
            if(cgf.CreatedById != null){
                userIdSet.add(cgf.CreatedById);
            }
        }
        if(userIdSet.size() > 0){
            cgfList = [Select id,CreatedById from CollaborationGroupFeed where CreatedById In: userIdSet and CreatedDate >= :past24];
        }
        System.debug('cgfList '+cgfList);
        if(userIdSet.size() > 0){
            for(i=0; i< scope.size(); i++){
                k=0;
                for(j=0;j<cgfList.size(); j++){
                    if(scope[i].CreatedById == cgfList[j].CreatedById){
                        k++;
                    }
                }
                cgfMap.put(scope[i].CreatedById , k);
            }
        }
        System.debug('cgfMap '+cgfMap);
        for(Account acc: [Select id, number_of_posts__c, user__c from Account where user__c In :userIdSet]){
            if(cgfMap.containsKey(acc.User__c)){
                acc.Number_of_posts__c = cgfMap.get(acc.User__c);
                accList.add(acc);
            }
        }
        System.debug('@@ accList '+ accList);
        if(accList.size() > 0){
            update accList;
        }
    }
    public void finish(Database.BatchableContext bc){
        CalculateRankByNumberOfPosts.calculateRank();
        
    }
}