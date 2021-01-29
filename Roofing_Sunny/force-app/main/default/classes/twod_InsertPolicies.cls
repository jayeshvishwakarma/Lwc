public class twod_InsertPolicies {
    public void insertPolicies(List<Policy_Dummy__c> lstPolicyDummy){
        //map to collect policy and Market Family
        map<twod__Policy_Definition__c,List<String>> mapPolicy_MarketFamily = new map<twod__Policy_Definition__c,List<String>>();
        
        List<twod__Policy_Definition__c> lstPolicyToInsert = new List<twod__Policy_Definition__c>();
        List<twod__Policy_Applicability_Term__c> lstPATToInsert = new List<twod__Policy_Applicability_Term__c>();
        List<twod__Warranty_Rule__c> lstWarrantyRule = new List<twod__Warranty_Rule__c>();
        List<twod__Warranty_Rule_Criteria__c> lstWarrantyRuleCriteria = new List<twod__Warranty_Rule_Criteria__c>();
        List<twod__Warranty_Rule_Association__c> lstWarrantyRuleAssociation = new List<twod__Warranty_Rule_Association__c>();
        
        map<String,Id> mapDefectCodeName_Id = new map<String,Id>();
        map<String,String> mapWarrantyRuleExtId_UniqueNumber = new map<String,String>();
        Set<String> setWarrantyRuleExtId = new Set<String>();
        /*
         List<Policy_Dummy__c> lstPolicyDummy = [Select Id,Claim_Type__c,Algae_Protection_YR__c,Maxiumum_Liability__c,Product_Type_Code__c,Reduction_Factor_MO__c,Second_Owner_IN_Surestart__c,
                                                Second_Owner_OUT_Surestart__c,Wind_Warranty_Term_Years__c,Workmanship_Coverage_Years__c,Building_Type_Application__c,Defect_Code__c,End_Date__c,
                                                Homeowner_s_Insurance_First_Y_N__c,Ignore_Defect_Code__c,Labor_Included_Y_N__c,Material_Included_Y_N__c,Ownership__c,
                                                PAT_Policy_ExternalId__c,Policy_Active_Y_N__c,Priority__c,Prorated_Y_N__c,Start_Date__c,
                                                SureStart_Period__c,Warranty_Period__c,WR_External_Id__c,Unique_Warranty_Registration__c,Warranty_Registration_Type__c,Wind_Speed__c 
                                                from Policy_Dummy__c 
                                                where CREATEDDATE = TODAY];
        */
        
        for(twod__Warranty_Code__c objDefectCode: [Select Id,Name from twod__Warranty_Code__c]){
            mapDefectCodeName_Id.put(objDefectCode.Name,objDefectCode.Id);
        }                                   
        for(twod__Warranty_Rule__c objWarrantyRule: [Select Unique_Warranty_Registration__c,Warranty_Rule_External_Id__c from twod__Warranty_Rule__c]){
            setWarrantyRuleExtId.add(objWarrantyRule.Unique_Warranty_Registration__c);
            mapWarrantyRuleExtId_UniqueNumber.put(objWarrantyRule.Unique_Warranty_Registration__c,objWarrantyRule.Warranty_Rule_External_Id__c);
        }
        for(Policy_Dummy__c objPolicyDummy: lstPolicyDummy){
            twod__Policy_Definition__c objPolicyDef = new twod__Policy_Definition__c();
            objPolicyDef.Product_Type_Code__c= objPolicyDummy.Product_Type_Code__c;
            objPolicyDef.twod__Active_From__c = objPolicyDummy.Start_Date__c;
            objPolicyDef.twod__Active_Until__c = objPolicyDummy.End_Date__c;
            objPolicyDef.Policy_External_Id__c = objPolicyDummy.PAT_Policy_ExternalId__c;
            objPolicyDef.twod__Priority__c = objPolicyDummy.Priority__c;
            if(objPolicyDummy.SureStart_Period__c != null)
                objPolicyDef.SureStart_Period__c = objPolicyDummy.SureStart_Period__c*12;
            objPolicyDef.Name = objPolicyDummy.PAT_Policy_ExternalId__c;
            objPolicyDef.Reduction_Factor_MO__c = objPolicyDummy.Reduction_Factor_MO__c;
            if(objPolicyDef.Workmanship_Coverage_Years__c != null)
                objPolicyDef.Workmanship_Coverage_Years__c = objPolicyDummy.Workmanship_Coverage_Years__c*12;
            objPolicyDef.Maxiumum_Liability__c = objPolicyDummy.Maxiumum_Liability__c;
            objPolicyDef.Wind_Speed__c = objPolicyDummy.Wind_Speed__c;
            objPolicyDef.twod__Status__c='Active';
            
            //system.debug(objPolicyDummy.Id);
            //system.debug(objPolicyDummy.PAT_Policy_ExternalId__c);
            if(objPolicyDummy.Ownership__c == '2' || objPolicyDummy.Ownership__c == '2+'){
                if(objPolicyDummy.Second_Owner_OUT_Surestart__c != null) 
                    objPolicyDef.After_SureShort_Warranty_Period__c = objPolicyDummy.Second_Owner_OUT_Surestart__c*12;
                if(objPolicyDummy.Second_Owner_IN_Surestart__c != null) 
                    objPolicyDef.twod__Months_Covered__c = objPolicyDummy.Second_Owner_IN_Surestart__c*12;
            }else{
                if(objPolicyDummy.Warranty_Period__c != null) 
                    objPolicyDef.twod__Months_Covered__c = objPolicyDummy.Warranty_Period__c*12;
            }
            
            /*
            if(objPolicyDummy.Second_Owner_OUT_Surestart__c != null) 
                objPolicyDef.twod__Months_Covered__c = objPolicyDummy.Second_Owner_OUT_Surestart__c*12;
            else if(objPolicyDummy.Wind_Warranty_Term_Years__c != null) 
                objPolicyDef.twod__Months_Covered__c = objPolicyDummy.Wind_Warranty_Term_Years__c*12;
            else if(objPolicyDummy.Algae_Protection_YR__c != null) 
                objPolicyDef.twod__Months_Covered__c = objPolicyDummy.Algae_Protection_YR__c*12;
            
            else if(objPolicyDummy.Second_Owner_IN_Surestart__c != null) 
                objPolicyDef.twod__Months_Covered__c = objPolicyDummy.Second_Owner_IN_Surestart__c*12;
            else  
                objPolicyDef.twod__Months_Covered__c = objPolicyDummy.Warranty_Period__c*12;
            */
            if(objPolicyDummy.Unique_Warranty_Registration__c != null && objPolicyDummy.Unique_Warranty_Registration__c !='' ){
                twod__Warranty_Rule_Association__c objWarrantyRuleAssociation = new twod__Warranty_Rule_Association__c();
                if(setWarrantyRuleExtId.contains(objPolicyDummy.Unique_Warranty_Registration__c)){
                    //
                }else{
                    String LogicalGrouping;
                    String CriteriaType;
                    if(objPolicyDummy.Defect_Code__c != null && objPolicyDummy.Defect_Code__c != ''){
                        LogicalGrouping = 'OR';
                        CriteriaType = 'Equals';
                    }else if(objPolicyDummy.Ignore_Defect_Code__c != null && objPolicyDummy.Ignore_Defect_Code__c != ''){
                        LogicalGrouping = 'AND';
                        CriteriaType = 'Not Equal To';
                    }
                    
                    twod__Warranty_Rule__c objWarrantyRule = new twod__Warranty_Rule__c();
                    objWarrantyRule.twod__Logical_Grouping__c = LogicalGrouping;
                    objWarrantyRule.twod__Object_API_Name__c = 'twod__Claim__c';
                    objWarrantyRule.twod__Object_Type__c = 'Claim';
                    objWarrantyRule.twod__Rule_Type__c = 'Eligibility Rule';
                    objWarrantyRule.Warranty_Rule_External_Id__c = objPolicyDummy.WR_External_Id__c;
                    objWarrantyRule.Unique_Warranty_Registration__c = objPolicyDummy.Unique_Warranty_Registration__c;
                    objWarrantyRule.Name = objPolicyDummy.WR_External_Id__c;
                    lstWarrantyRule.add(objWarrantyRule);
                    
                    List<String> lstDefectCode = new List<String>();
                    if(objPolicyDummy.Defect_Code__c != null && objPolicyDummy.Defect_Code__c !='' && objPolicyDummy.Defect_Code__c.contains(',')){
                        lstDefectCode = objPolicyDummy.Defect_Code__c.split(',');
                    }else if(objPolicyDummy.Defect_Code__c != null && objPolicyDummy.Defect_Code__c !='' && !objPolicyDummy.Defect_Code__c.contains(',')){
                        lstDefectCode.add(objPolicyDummy.Defect_Code__c);
                    }else if(objPolicyDummy.Ignore_Defect_Code__c != null && objPolicyDummy.Ignore_Defect_Code__c !='' && objPolicyDummy.Ignore_Defect_Code__c.contains(',')){
                        lstDefectCode = objPolicyDummy.Ignore_Defect_Code__c.split(',');
                    }else if(objPolicyDummy.Ignore_Defect_Code__c != null && objPolicyDummy.Ignore_Defect_Code__c !='' && !objPolicyDummy.Ignore_Defect_Code__c.contains(',')){
                        lstDefectCode.add(objPolicyDummy.Ignore_Defect_Code__c);
                    }
                    Integer i=1;
                    for(String objDefectCode: lstDefectCode){
                        twod__Warranty_Rule_Criteria__c objWarrantyRuleCriteria = new twod__Warranty_Rule_Criteria__c();
                        objWarrantyRuleCriteria.twod__Criteria_Type__c = CriteriaType;
                        objWarrantyRuleCriteria.twod__Criteria_Value__c = mapDefectCodeName_Id.get(objDefectCode);
                        objWarrantyRuleCriteria.twod__Field_API_Name__c = 'Primary_Defect_Code__c';
                        objWarrantyRuleCriteria.twod__Field_Name__c = 'Primary Defect Code';
                        objWarrantyRuleCriteria.twod__Field_Type__c = 'REFERENCE';
                        objWarrantyRuleCriteria.twod__Related_Object__c = 'twod__Warranty_Code__c';
                        objWarrantyRuleCriteria.twod__Sequence__c = i;
                        objWarrantyRuleCriteria.twod__Warranty_Rule__r =  new twod__Warranty_Rule__c(Warranty_Rule_External_Id__c = objPolicyDummy.WR_External_Id__c);
                        i++;
                        lstWarrantyRuleCriteria.add(objWarrantyRuleCriteria);
                    }
                    mapWarrantyRuleExtId_UniqueNumber.put(objPolicyDummy.Unique_Warranty_Registration__c,objPolicyDummy.WR_External_Id__c);
                }
                objWarrantyRuleAssociation.twod__Policy_Definition__r = new twod__Policy_Definition__c( Policy_External_Id__c=objPolicyDummy.PAT_Policy_ExternalId__c); 
                objWarrantyRuleAssociation.twod__Warranty_Rule__r = new twod__Warranty_Rule__c(Warranty_Rule_External_Id__c = mapWarrantyRuleExtId_UniqueNumber.get(objPolicyDummy.Unique_Warranty_Registration__c));
                objWarrantyRuleAssociation.twod__Is_Active__c=true;
                lstWarrantyRuleAssociation.add(objWarrantyRuleAssociation);
                setWarrantyRuleExtId.add(objPolicyDummy.Unique_Warranty_Registration__c);
                
            }
            
            if(objPolicyDummy.Homeowner_s_Insurance_First_Y_N__c == 'Y')
                objPolicyDef.Homeowner_s_Insurance_First_Y_N__c = true;
            else
                objPolicyDef.Homeowner_s_Insurance_First_Y_N__c = false;
            
            if(objPolicyDummy.Labor_Included_Y_N__c == 'Y')
                objPolicyDef.Labor_Included_Y_N__c = true;
            else
                objPolicyDef.Labor_Included_Y_N__c = false;
            
            if(objPolicyDummy.Material_Included_Y_N__c == 'Y')
                objPolicyDef.Material_Included_Y_N__c = true;
            else
                objPolicyDef.Material_Included_Y_N__c = false;
            
            if(objPolicyDummy.Prorated_Y_N__c == 'Y')
                objPolicyDef.Prorated_Y_N__c = true;
            else
                objPolicyDef.Prorated_Y_N__c = false;
            
           
            
            /*
            if(objPolicyDummy.Second_Owner_IN_Surestart__c!= null || objPolicyDummy.Second_Owner_OUT_Surestart__c != null){
                twod__Policy_Applicability_Term__c objPATBeforeSureStart = new twod__Policy_Applicability_Term__c();
                objPATBeforeSureStart.twod__Applicability_SubType__c ='is_Before_SureStart__c';
                objPATBeforeSureStart.twod__Applicability_Term_Type__c ='Referred by Text';
                if(objPolicyDummy.Second_Owner_IN_Surestart__c != null){
                    objPATBeforeSureStart.twod__Applicability_Value__c ='Y';
                    objPATBeforeSureStart.twod__Applicability_Label__c ='Y';
                }else if(objPolicyDummy.Second_Owner_OUT_Surestart__c != null){
                    objPATBeforeSureStart.twod__Applicability_Value__c ='N';
                    objPATBeforeSureStart.twod__Applicability_Label__c ='N';
                }
                objPATBeforeSureStart.twod__WR_Field_Mapping__c ='twod__Claim__r.is_Before_SureStart__c';
                twod__Policy_Definition__c policyReference = new twod__Policy_Definition__c( Policy_External_Id__c=objPolicyDummy.PAT_Policy_ExternalId__c);  
                objPATBeforeSureStart.twod__Policy_Definition__r =policyReference;             
                lstPATToInsert.add(objPATBeforeSureStart);
            }            
            twod__Policy_Applicability_Term__c objPATWarrantyType = new twod__Policy_Applicability_Term__c();
            objPATWarrantyType.twod__Applicability_SubType__c ='Warranty_Registration_Type__c';
            objPATWarrantyType.twod__Applicability_Term_Type__c ='Referred by Text';
            
            if(objPolicyDummy.Claim_Type__c == 'STANDARD'){
                objPATWarrantyType.twod__Applicability_Value__c ='Standard';
                objPATWarrantyType.twod__Applicability_Label__c ='Standard';
            }else if(objPolicyDummy.Claim_Type__c == 'INTERNATIONAL'){
                objPATWarrantyType.twod__Applicability_Value__c ='International';
                objPATWarrantyType.twod__Applicability_Label__c ='International';
            }else{
                objPATWarrantyType.twod__Applicability_Value__c =objPolicyDummy.Claim_Type__c;
                objPATWarrantyType.twod__Applicability_Label__c =objPolicyDummy.Claim_Type__c;
            }
            
            objPATWarrantyType.twod__WR_Field_Mapping__c ='twod__Claim__r.Warranty_Registration_Type__c';
            
            objPATWarrantyType.twod__Policy_Definition__r =policyReference; 
            lstPATToInsert.add(objPATWarrantyType); 
            */
            twod__Policy_Definition__c policyReference = new twod__Policy_Definition__c( Policy_External_Id__c=objPolicyDummy.PAT_Policy_ExternalId__c);  
            twod__Policy_Applicability_Term__c objPATPolicyType = new twod__Policy_Applicability_Term__c();
            objPATPolicyType.twod__Applicability_SubType__c ='RecordType.DeveloperName';
            objPATPolicyType.twod__Applicability_Term_Type__c ='Referred by Text';
            if(objPolicyDummy.Claim_Type__c == 'STANDARD'){
                objPATPolicyType.twod__Applicability_Value__c ='Standard';
                objPATPolicyType.twod__Applicability_Label__c ='Standard';
            }else if(objPolicyDummy.Claim_Type__c == 'INTERNATIONAL'){
                objPATPolicyType.twod__Applicability_Value__c ='International';
                objPATPolicyType.twod__Applicability_Label__c ='International';
            }else{
                objPATPolicyType.twod__Applicability_Value__c =objPolicyDummy.Claim_Type__c;
                objPATPolicyType.twod__Applicability_Label__c =objPolicyDummy.Claim_Type__c;
            }
            objPATPolicyType.twod__WR_Field_Mapping__c ='twod__Claim__r.RecordType.DeveloperName';
            objPATPolicyType.twod__Policy_Definition__r =policyReference; 
            lstPATToInsert.add(objPATPolicyType);
            
            twod__Policy_Applicability_Term__c objPATBuildingType = new twod__Policy_Applicability_Term__c();
            objPATBuildingType.twod__Applicability_SubType__c ='Building_Type__c';
            objPATBuildingType.twod__Applicability_Term_Type__c ='Referred by Text';
            if(objPolicyDummy.Building_Type_Application__c == 'SFD'){
                objPATBuildingType.twod__Applicability_Value__c ='Single Family Home';
                objPATBuildingType.twod__Applicability_Label__c ='Single Family Home';
            }else if(objPolicyDummy.Building_Type_Application__c == 'OTHER'){
                objPATBuildingType.twod__Applicability_Value__c ='Other';
                objPATBuildingType.twod__Applicability_Label__c ='Other';
            }else{
                objPATBuildingType.twod__Applicability_Value__c =objPolicyDummy.Building_Type_Application__c;
                objPATBuildingType.twod__Applicability_Label__c =objPolicyDummy.Building_Type_Application__c;
            }
            objPATBuildingType.twod__WR_Field_Mapping__c ='twod__Claim__r.Building_Type__c';
            objPATBuildingType.twod__Policy_Definition__r =policyReference; 
            lstPATToInsert.add(objPATBuildingType);
            
            twod__Policy_Applicability_Term__c objPATOwnershipType = new twod__Policy_Applicability_Term__c();
            objPATOwnershipType.twod__Applicability_SubType__c ='OwnershipType__c';
            objPATOwnershipType.twod__Applicability_Term_Type__c ='Referred by Text';
            objPATOwnershipType.twod__WR_Field_Mapping__c ='twod__Claim__r.OwnershipType__c';
            if(objPolicyDummy.Ownership__c == '1'){
                objPATOwnershipType.twod__Applicability_Value__c ='First';
                objPATOwnershipType.twod__Applicability_Label__c ='First';
            }else if(objPolicyDummy.Ownership__c == '2' || objPolicyDummy.Ownership__c == '2+'){
                objPATOwnershipType.twod__Applicability_Value__c ='Second';
                objPATOwnershipType.twod__Applicability_Label__c ='Second';
            }
            objPATOwnershipType.twod__Policy_Definition__r =policyReference;
            lstPATToInsert.add(objPATOwnershipType);
            
            if(objPolicyDummy.Product_Type_Code__c.contains(',')){
                system.debug('objPolicyDummy.Product_Type_Code__c'+objPolicyDummy.Product_Type_Code__c);
                List<String> lstMarketFamily = objPolicyDummy.Product_Type_Code__c.split(',');
                system.debug('lstMarketFamily'+lstMarketFamily);
                mapPolicy_MarketFamily.put(objPolicyDef,lstMarketFamily);
            }else{
                twod__Policy_Applicability_Term__c objPATMarketFamily = new twod__Policy_Applicability_Term__c();
                objPATMarketFamily.twod__Applicability_SubType__c ='twod__Warranty_Product__r.Product_Type__r.Product_Type_Code__c';
                objPATMarketFamily.twod__Applicability_Term_Type__c ='Referred by Text';
                objPATMarketFamily.twod__Applicability_Value__c =objPolicyDummy.Product_Type_Code__c;
                objPATMarketFamily.twod__Applicability_Label__c =objPolicyDummy.Product_Type_Code__c;
                objPATMarketFamily.twod__WR_Field_Mapping__c ='twod__Claim__r.twod__Warranty_Product__r.Product_Type__r.Product_Type_Code__c';
                objPATMarketFamily.twod__Policy_Definition__r =policyReference;
                lstPATToInsert.add(objPATMarketFamily);
            }
            lstPolicyToInsert.add(objPolicyDef);    
        }
        
        for(twod__Policy_Definition__c objPolicy: mapPolicy_MarketFamily.keyset()){
            List<String> lstMarketFamily = mapPolicy_MarketFamily.get(objPolicy);
            for(String objMarketFamily:lstMarketFamily ){
                twod__Policy_Applicability_Term__c objPATMarketFamily = new twod__Policy_Applicability_Term__c();
                objPATMarketFamily.twod__Applicability_SubType__c ='twod__Warranty_Product__r.Product_Type__r.Product_Type_Code__c';
                objPATMarketFamily.twod__Applicability_Term_Type__c ='Referred by Text';
                objPATMarketFamily.twod__Applicability_Value__c =objMarketFamily.trim();
                objPATMarketFamily.twod__Applicability_Label__c =objMarketFamily.trim();
                objPATMarketFamily.twod__WR_Field_Mapping__c ='twod__Claim__r.twod__Warranty_Product__r.Product_Type__r.Product_Type_Code__c';
                twod__Policy_Definition__c policyReference = new twod__Policy_Definition__c( Policy_External_Id__c=objPolicy.Policy_External_Id__c);  
                objPATMarketFamily.twod__Policy_Definition__r =policyReference; 
                lstPATToInsert.add(objPATMarketFamily);
            }
        }
        if(!lstPolicyToInsert.isEmpty())
            insert lstPolicyToInsert;
        if(!lstPATToInsert.isEmpty())
            insert lstPATToInsert;
        if(!lstWarrantyRule.isEmpty())
            insert lstWarrantyRule;
        system.debug('lstWarrantyRuleCriteria-->'+lstWarrantyRuleCriteria);
        if(!lstWarrantyRuleCriteria.isEmpty())
            insert lstWarrantyRuleCriteria;
        
        List<twod__Warranty_Rule__c> updateWarrantyRules = new List<twod__Warranty_Rule__c>();
        for(twod__Warranty_Rule__c objWR: [Select Id from twod__Warranty_Rule__c where ID IN:lstWarrantyRule]){
            objWR.twod__Enabled__c = true;
            updateWarrantyRules.add(objWR);
        }
        
        system.debug('updateWarrantyRules-->'+updateWarrantyRules);
        if(!updateWarrantyRules.isEmpty())
            update updateWarrantyRules;
        
        system.debug('lstWarrantyRuleAssociation-->'+lstWarrantyRuleAssociation);
        if(!lstWarrantyRuleAssociation.isEmpty())
            insert lstWarrantyRuleAssociation;
        
    }
    public void updateWarrantyProductSureStart(){
        List<twod__Warranty_Product__c> lstWarrantyProducts = new list<twod__Warranty_Product__c>();
        map<String,Decimal> mapProductType_SureStart = new map<String,Decimal>();
        List<Policy_Dummy__c> lstPolicyDummy = [Select Id,Product_Type_Code__c,SureStart_Period__c from Policy_Dummy__c where CREATEDDATE = TODAY];
        for(Policy_Dummy__c objPolicyDummy :lstPolicyDummy){
            if(objPolicyDummy.SureStart_Period__c != null){
                mapProductType_SureStart.put(objPolicyDummy.Product_Type_Code__c,objPolicyDummy.SureStart_Period__c);
            }
        }
        for(twod__Warranty_Product__c objWarrantyProduct: [Select Id,Product__r.Product_Type__r.Product_Type_Code__c from twod__Warranty_Product__c where Product__r.Product_Type__r.Product_Type_Code__c IN: mapProductType_SureStart.keyset()]){
            objWarrantyProduct.SureStart_Period__c = mapProductType_SureStart.get(objWarrantyProduct.Product__r.Product_Type__r.Product_Type_Code__c);
            lstWarrantyProducts.add(objWarrantyProduct);
        }
        if(!lstWarrantyProducts.isEmpty())
            update lstWarrantyProducts;
    }
    
}