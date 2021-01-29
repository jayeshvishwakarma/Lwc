@isTest
public class twod_ClaimInterestedPartiesTriggerTest {
    
    public static testMethod void testmethod1(){
        
        insert new twod__WOD__c(
            Name='Enable OnPolicyChange',twod__isTriggered__c= false
        );
        insert new twod_TriggerControl__c(SetupOwnerId=UserInfo.getOrganizationId(), 
                                          twod_ClaimInterestedPartiesTrigger__c=true
                                         );                     
        twod__Claim__c claim = new twod__Claim__c();
        claim.name = 'test';
        //claim.recordtypeId=claimrecordMap.get('Standard');
        //claim.twod__Claim_Status__c= 'test';
        claim.Producing_Plant__c='avery';
        claim.Product_Group__c='Residential Roofing';         
        claim.twod__Date_of_Failure__c=system.today();
        claim.twod__Claim_Status__c = 'Approved';
        claim.Install_Date__c=system.today()-100;
        claim.Postal_code_BL__c='25077';
        //claim.State_BL__c='Alaska (AK)';
        claim.City_BL__c='dasda';
        insert claim;
        
        Claim_Interested_Parties__c cip=new Claim_Interested_Parties__c();
        cip.Type__c='Contractor';
        cip.Claim__c=claim.Id;
        cip.Zip_Code__c='12345';
        insert cip;
        
        update cip;
        
        cip=new Claim_Interested_Parties__c();
        cip.Type__c='Contractor';
        cip.Claim__c=claim.Id;
        cip.Zip_Code__c='12345';
        try{insert cip;}
        catch(exception e){}
        
        
    }
}