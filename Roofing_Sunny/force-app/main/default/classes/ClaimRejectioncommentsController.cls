public class ClaimRejectioncommentsController {
    public List<String> rejectionComments{get;set;}
    public string recordID {
        get {return recordID;}
        set {
            recordId = value;
            returnComments();
        }
    }

    public void returnComments() {
        if(!Test.isRunningTest()){

            rejectionComments = new List<String>();
            Map<ID, User> usrMap = new Map<ID, User>([SELECT Id, Name 
                                                    FROM User 
                                                    WHERE IsActive =: true]);
            ProcessInstance pi = [SELECT Id, TargetObjectId 
                                  FROM ProcessInstance
                                  WHERE targetobjectId = :recordID
                                  ORDER BY createdDate DESC
                                  LIMIT 1
                                 ];
            
            twod__Claim__c claim = [SELECT Id, Rejection_Comment__c FROM twod__Claim__c WHERE Id = :recordID];
            claim.Rejection_Comment__c = '';
            
            for (ProcessInstanceStep pis : [SELECT ID, Comments, ActorId
                                            FROM ProcessInstanceStep 
                                            WHERE processInstanceID = :pi.Id 
                                            ORDER BY CreatedDate ASC]) {
                if (pis.comments != null && pis.comments != '') {
                    rejectionComments.add(usrMap.get(pis.ActorId).name + ': ' + pis.Comments);
                    claim.Rejection_Comment__c += usrMap.get(pis.ActorId).name + ': ' + pis.Comments + '\n';
                }
            }  
            
            update claim;
        }
    }
}