/**********************************************************************
Name:  twod_FindClaimPolServForNonSerilized
Copyright ? 2017  Tavant Technology Inc
==============================================================
===============================================================
Purpose: Class used find policy definition for non serilzied items

-------                                                             
===============================================================
===============================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE            DETAIL                         FEATURES/CSR/TTP
1.0 - Hampesh             19/07/2016     INITIAL DEVELOPMENT            
***********************************************************************/

global with sharing class twod_FindClaimPolServForNonSerilized
{
    
    /*******************************************************************
Purpose:  to update the Policy Definition for the claim                                                   
Parameters: N/A
Returns: none
Throws [Exceptions]:                                                      
********************************************************************/
    
    @InvocableMethod
    global static void findClaimPolicyForNonSerilized(List<twod__Claim__c> ObjClaimList){
        system.debug(LoggingLevel.Info,'-------$$$---------------'+ObjClaimList[0].id);
        Set<Id> claimSet=new  Set<Id>();
        set<String> PolicyDefinitionIdSet = new set<String>();
        List<String> claimId=new  List<String>();
        Set<String> setFieldMap = new Set<String>();
        Set<String> setOfCLFields = new Set<String>{'Id','CreatedDate','recordtype.developername','Primary_Defect_Code__r.Name'};
        Schema.DescribeFieldResult fieldResult = twod__Policy_Applicability_Term__c.twod__WR_Field_Mapping_NS__c.getDescribe();
        List<Schema.PicklistEntry> pickListEnt = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry ple: pickListEnt ){
            setFieldMap.add(Ple.getValue());
            if(!setOfCLFields.contains(Ple.getValue())) 
                setOfCLFields.add(Ple.getValue());
        }
        system.debug(LoggingLevel.Info,'setOfCLFields-->'+setOfCLFields);
        
        String queryCL = new twod.SoqlBuilder()
            .selectx(setOfCLFields)
            .fromx('twod__claim__c')
            .wherex(new twod.FieldCondition('id').EQUALS(ObjClaimList[0].id))
            .toSoql();
        
        twod__Claim__c objClaim;
        objClaim=database.query(queryCL);
        
        List<string> strSoql=new List<string>();
        String value;
        for(String s : setFieldMap) {
            if(!s.contains('.')){
                //system.debug(objClaim.get(s));
                value = String.valueOF(objClaim.get(s)); 
            }            
            else {
                value = splitString(s,objClaim);
            }
            if(value != '' && value != null) {
                strSoql.add(value);
            }     
            SYSTEM.debug(s+'-->'+value);
        }
        
        system.debug(LoggingLevel.Info,'---product--'+ObjClaimList[0].twod__Warranty_Product__c);
        //objClaim=database.query(queryCL);
        
        Map<String,String> groupMap=new Map<String,String>(); 
        if(objClaim.recordtype.developername !='Claim_Template') {          
            claimSet.add(Id.valueof(objClaim.twod__Warranty_Product__c));
            claimSet.add(Id.valueof(objClaim.Customer__c));
            
            
            List<twod__Group_Member__c> memberList=[select id ,twod__Group__c,twod__Group__r.twod__Object_Name__c from twod__Group_Member__c where twod__Record_Id__c in:claimSet];
            
            if(!memberList.isEmpty()){
                for(twod__Group_Member__c grpIds:memberList){
                    strSoql.add(string.valueOf(grpIds.twod__Group__c));
                    groupMap.put(string.valueOf(grpIds.twod__Group__c), grpIds.twod__Group__r.twod__Object_Name__c);   
                }
            } 
            
        } 
        
        system.debug(LoggingLevel.Info , 'strSoql '+strSoql);
        List<twod__Policy_Applicability_Term__c> PATList=[SELECT Id,twod__Policy_Definition__c FROM twod__Policy_Applicability_Term__c WHERE twod__Applicability_SubType__c = 'twod__Warranty_Product__r.Product_Type__r.Product_Type_Code__c' And twod__Applicability_Value__c IN :strSoql AND Policy_Active_From__c <=:objClaim.Install_Date__c AND Policy_Active_Untill__c >=:objClaim.Install_Date__c];
        
        for(twod__Policy_Applicability_Term__c PAT:PATList){
            system.debug(LoggingLevel.Info , 'Policy Matched');
            PolicyDefinitionIdSet.add(PAT.twod__Policy_Definition__c );
        }
        List<string> pdId=new List<string>(PolicyDefinitionIdSet);
        
        system.debug(LoggingLevel.Info,'PolicyDefinitionIdSet-->' + PolicyDefinitionIdSet);
        system.debug(LoggingLevel.Info,'PolicyDefinitionIdSet.size()-->' + PolicyDefinitionIdSet.size());
        
        if(PolicyDefinitionIdSet.size()>0){
            String soqlbld = new twod.SoqlBuilder()
                .selectx(new Set<Object>{'Id','Name','Product_Type_Code__c','Wind_Speed__c','SureStart_Period__c','twod__Active_From__c','twod__Months_Covered__c','twod__Active_Until__c','twod__Priority__c','twod__Status__c','twod__Transferable__c','twod__Transfer_Fee__c','twod__Type__c','twod__Is_Policy_Optional__c', 'Transfer_Specific_Months__c'})
                .fromx('twod__Policy_Definition__c')
                .wherex(new twod.AndCondition()
                        .add(new twod.FieldCondition('twod__Active_From__c').lessThanOrEqualTo(objClaim.Install_Date__c))
                        .add(new twod.FieldCondition('twod__Active_Until__c').greaterThanOrEqualTo(objClaim.Install_Date__c))
                        .add(new twod.FieldCondition('twod__Status__c').equals('Active'))
                        .add(new twod.SetCondition('Id').inx(pdId))
                       )
                .orderByx(new twod.OrderBy('twod__Priority__c').ascending().nullsLast())
                .toSoql();
            system.debug(LoggingLevel.Info,'---query--'+soqlbld);  
            pdId = new List<String>();  
            List<twod__Policy_Definition__c> activePolDefList=Database.query(soqlbld );
            for(twod__Policy_Definition__c policy:activePolDefList){
                pdId.add(policy.Id );
            }
            system.debug(LoggingLevel.Info,'Before Policy ');
            System.debug(LoggingLevel.Info,'---------------->>>' + pdId);
            System.debug(LoggingLevel.Info,'---------------->>>' + strSoql );
            System.debug(LoggingLevel.Info,'---------------->>>' + groupMap );
            if(!pdId.isEmpty()){
                //Code for Limiting the Policy
                twod_WarrantyRegistrationPolicyManager obj=new twod_WarrantyRegistrationPolicyManager();
                list<id> ppid=obj.searchPolicy(pdId,strSoql,groupMap,true);
                System.debug(LoggingLevel.Info,'---------ppid------->>>' + ppid );
                pdId=ppid;
                
                Set<Id> policySet=new  Set<Id>();
                for(String policy:pdId){
                    policySet.add(policy);
                }
                System.debug(LoggingLevel.Info,'---------policySet------->>>' + policySet );
                
                if(policySet.size()>0){
                    
                    List<twod__Policy_Definition__c> poldefList = twod_RuleEngine.RunEligibityRules(objClaim,policySet);
                    system.debug(LoggingLevel.Info,'----poldefList---------'+poldefList);
                    //List<twod__Policy_Definition__c> poldefList = new list<twod__Policy_Definition__c>();
                    list<twod__Claim__c> ClmUpdateList = new list<twod__Claim__c>();
                    Boolean voidWarranty;
                    for(twod__Claim__c tmpClm : ObjClaimList)
                    {               
                        voidWarranty=false;
                        twod__Claim__c crntClm = new twod__Claim__c(Id=objClaim.Id);
                        if (Schema.sObjectType.twod__Claim__c.fields.twod__Applicable_Policy__c.isCreateable() && Schema.sObjectType.twod__Claim__c.fields.twod__Applicable_Policy__c.isUpdateable()){
                            crntClm.twod__Applicable_Policy__c = poldefList.size() > 0 ? poldefList[0].Id :null;
                        }
                        if(poldefList.size() > 0){
                            Date CreatedDate =  date.newinstance(objClaim.CreatedDate.year(), objClaim.CreatedDate.month(), objClaim.CreatedDate.day());
                            system.debug(LoggingLevel.Info,'-----CreatedDate--------'+CreatedDate);
                            
                            if(objClaim.twod__Claim_Type__c == 'International'){
                                system.debug(LoggingLevel.Info,'---------international----policy----'+poldefList[0]);
                                system.debug(CreatedDate+'----'+objClaim.Install_Date__c+Integer.valueOf(poldefList[0].twod__Months_Covered__c));
                                system.debug(objClaim.Install_Date__c.addMonths(Integer.valueOf(poldefList[0].twod__Months_Covered__c)));
                                if(CreatedDate > objClaim.Install_Date__c.addMonths(Integer.valueOf(poldefList[0].twod__Months_Covered__c)))
                                    if (Schema.sObjectType.twod__Claim__c.fields.twod__Applicable_Policy__c.isCreateable() && Schema.sObjectType.twod__Claim__c.fields.twod__Applicable_Policy__c.isUpdateable()){
                                        voidWarranty=true;
                                    }
                            }else{
                                integer monthsUsed=0;
                                if(objClaim.OwnershipType__c == 'Second'){
                                    monthsUsed = objClaim.Install_Date__c.MonthsBetween(objClaim.Transferred_Date__c);
                                    //Commented so that date would not be considered while calculating months used.
                                    //if (monthsUsed!=0 && (objClaim.Transferred_Date__c).day() < (objClaim.Install_Date__c).day()) monthsUsed--;        
                                }
                                if(objClaim.OwnershipType__c == 'First'){
                                    if(CreatedDate > objClaim.Install_Date__c.addMonths(Integer.valueOf(poldefList[0].twod__Months_Covered__c)))
                                        if (Schema.sObjectType.twod__Claim__c.fields.twod__Applicable_Policy__c.isCreateable() && Schema.sObjectType.twod__Claim__c.fields.twod__Applicable_Policy__c.isUpdateable()){
                                            voidWarranty=true;
                                        }
                                }
                                else if(objClaim.OwnershipType__c == 'Second' && (monthsUsed <= poldefList[0].SureStart_Period__c || poldefList[0].SureStart_Period__c==0 || poldefList[0].SureStart_Period__c==null)) //Within SureStart or Surestart not applicable
                                {
                                    system.debug('Months between' + (objClaim.Transferred_Date__c).monthsBetween(objClaim.Install_Date__c ) );
                                    if(CreatedDate > objClaim.Install_Date__c.addMonths(Integer.valueOf(poldefList[0].twod__Months_Covered__c)))
                                        if (Schema.sObjectType.twod__Claim__c.fields.twod__Applicable_Policy__c.isCreateable() && Schema.sObjectType.twod__Claim__c.fields.twod__Applicable_Policy__c.isUpdateable()){
                                            voidWarranty=true;
                                        }
                                }
                    
                                else if(objClaim.OwnershipType__c == 'Second' && (monthsUsed > poldefList[0].SureStart_Period__c)) //out of SureStart
                                { 
                                    //25-Jul-2018: check if the transfer was within the transfer specific months else no warranty(Specific to warranty terms for years 1993-1996)
                                    //if(CreatedDate > objClaim.Transferred_Date__c.addMonths(Integer.valueOf(poldefList[0].After_SureShort_Warranty_Period__c)))
                                    if(CreatedDate > objClaim.Transferred_Date__c.addMonths(Integer.valueOf(poldefList[0].After_SureShort_Warranty_Period__c))
                                       || (poldefList[0].Transfer_Specific_Months__c != null && monthsUsed > poldefList[0].Transfer_Specific_Months__c)
                                       )
                                    if (Schema.sObjectType.twod__Claim__c.fields.twod__Applicable_Policy__c.isCreateable() && Schema.sObjectType.twod__Claim__c.fields.twod__Applicable_Policy__c.isUpdateable()){
                                        voidWarranty=true;
                                    }
                                }
                            }
                            if(crntClm.twod__Applicable_Policy__c != null && crntClm.Wind_Speed__c != null && poldefList[0].Wind_Speed__c != null)
                            {
                                if(crntClm.Wind_Speed__c < poldefList[0].Wind_Speed__c){
                                    crntClm.Warranty_Status__c ='<b><span style="color:red;font-size: small;"> No Matching Policies </span></b>'; 
                                    voidWarranty=true;
                                }
                                
                            }
                            if(crntClm.twod__Applicable_Policy__c != null){
                                if(voidWarranty){
                                    system.debug('defect code is : ' + objClaim.Primary_Defect_Code__r.Name);
                                    if(objClaim.Primary_Defect_Code__r.Name == 'SEAL'){
                                        crntClm.Warranty_Status__c ='<b><span style="color:red;font-size: small;"> Limited Wind Warranty Expired</span></b>';  
                                    }
                                    else if(objClaim.Primary_Defect_Code__r.Name == 'FUNG'){
                                        crntClm.Warranty_Status__c ='<b><span style="color:red;font-size: small;"> Limited Algae Warranty Expired</span></b>';  
                                    }
                                    else{
                                        crntClm.Warranty_Status__c ='<b><span style="color:red;font-size: small;"> Warranty Expired</span></b>';  
                                    }
                                }else{
                                    crntClm.Warranty_Status__c ='<b><span style="color:green;font-size: small;"> In Warranty </span></b>';
                                }
                                crntClm.twod__Claim_Status__c = 'Claim';
                            }else{      
                                crntClm.Warranty_Status__c ='<b><span style="color:red;font-size: small;"> No Matching Policies </span></b>';       
                            }
                        }else{                          
                            crntClm.Warranty_Status__c ='<b><span style="color:red;font-size: small;"> No Matching Policies </span></b>';        
                        }
                        ClmUpdateList.add(crntClm);
                    }
                    
                    if(ClmUpdateList != null && ClmUpdateList.size() > 0)
                    {
                        //updates the ratedetails for every claim
                        if(twod.CrudUtil.isClaimUpdatable()){
                            Database.SaveResult[] claimUpdateList = database.update(ClmUpdateList ,false);
                            
                            for(Database.SaveResult sr : claimUpdateList){
                                if (sr.isSuccess()){
                                    System.debug(LoggingLevel.Info,'Successfully updated claim Policy: ' + sr.getId());
                                }else{
                                    for(Database.Error err : sr.getErrors()) {
                                        System.debug(LoggingLevel.Info,'The following error has occurred while updating claim Policy.'+err);                 
                                    }
                                }
                            }
                        }
                        else
                        {
                            System.debug(LoggingLevel.Info,'-----INSUFFICIENT_ACCESS---');
                        }
                    }
                }else{      
                    twod__Claim__c crntClm = new twod__Claim__c(Id=objClaim.Id);        
                    crntClm.Warranty_Status__c ='<b><span style="color:red;font-size: small;"> No Matching Policies </span></b>';        
                    crntClm.twod__Applicable_Policy__c = null;      
                    update crntClm;     
                }
            }else{
                twod__Claim__c crntClm = new twod__Claim__c(Id=objClaim.Id);        
                crntClm.Warranty_Status__c ='<b><span style="color:red;font-size: small;"> No Matching Policies </span></b>';        
                crntClm.twod__Applicable_Policy__c = null;      
                update crntClm;  
            }
        }else{      
            twod__Claim__c crntClm = new twod__Claim__c(Id=objClaim.Id);        
            crntClm.Warranty_Status__c ='<b><span style="color:red;font-size: small;"> No Matching Policies </span></b>';        
            crntClm.twod__Applicable_Policy__c = null;      
            update crntClm;     
        }
    }
    
    /*******************************************************************
Purpose: Find the value of related list                                     
Parameters: String(value which we want) and Sobject Object
Returns: String value
Throws [Exceptions]: N/A                                            
*******************************************************************/
    
    public static String splitString(String text,sobject objectData)
    {
        String[] obj ;
        String val;
        system.debug('-------TEXT--------' + text );
        obj = text.split('\\.',2);
        system.debug('------OBJ---------' + obj );
        val=obj[1];
        sobject parentObject = objectData.getSobject(obj[0]);
        if(parentObject==null)
        {
            return '';
        }        
        if(val.contains('.'))
        {
            return( splitString(val,parentObject) );
        }
        else
        {
            return( (String)parentObject.get(obj[1]) );
        }
    }
    
}