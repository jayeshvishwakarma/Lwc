// Created BY Rahul R

public class updateCategoryies{


    public Map<string,Category__c> categoryMap= new Map<string,Category__c>();

    public updateCategoryies(){
        for(Category__c cat:[select id, External_ID__c, Primary_Category__c,Secondary_Category__c
        from Category__c
        Limit 50000]){
            categoryMap.put(cat.External_ID__c.toLowerCase(),cat);

            system.debug('%%%%%%%%%%%%%%%%%'+cat.External_ID__c.toLowerCase());
        }

    }



    public list<Case> updatePrimaryCategory(list<Case> cases, string state){

        for(Case cas:cases){
            //Populate the Primary Id
            string mapKey = '';
            string primaryk,secondaryk,tertiaryk;
            cas.MSCRM_DM_Error__c = '';

            if(string.IsNotEmpty(cas.Primary_Category__c)){
                mapKey = populateStringID(cas,'Primary',null,null);
                if(mapKey!= null){
                    primaryk = mapKey;
                    cas.Primary_Category_Id__c = categoryMap.get(mapKey).Id;
                }else{
                    cas.Primary_Category_Id__c = '';
                    mapKey = null;
                }
            }

            if(string.IsNotEmpty(cas.Secondary_Category__c)){
                mapKey = populateStringID(cas,'Secondary',primaryk,null);

                if(mapKey!= null){
                    secondaryk = mapKey;
                    cas.Secondary_Category_ID__c = categoryMap.get(mapKey).Id;

                }else{
                    cas.Secondary_Category_ID__c = '';
                    secondaryk = null;
                }
                // cas.Secondary_Category_ID__c = (mapKey!= null)?(categoryMap.get(mapKey).Id):('');

            }

            if(string.IsNotEmpty(cas.Tertiary_Category__c)){
                mapKey = populateStringID(cas,'Tertiary',primaryk,secondaryk);

                if(mapKey!= null){
                    tertiaryk = mapKey;
                    cas.Tertiary_Category_ID__c = categoryMap.get(mapKey).Id;
                }else{
                    cas.Tertiary_Category_ID__c = '';
                    mapKey = null;
                }

                //cas.Tertiary_Category_ID__c = (mapKey!= null)?(categoryMap.get(mapKey).Id):('');

            }

            if(cas.Dealer_Name__c == null){
                cas.MSCRM_DM_Error__c += '$$$Dealer#Dealership MIssing####';
            }

            if((cas.Dealer_Name__c != null) &&
                    (cas.Dealer_Name__r.Nexa_SRV_TSM__c == null) &&
                    (cas.Business_Area__c != null) &&
                    (cas.Business_Area__c.Contains('Service')) &&
                    (cas.Channel__c == 'Nexa')){
                cas.MSCRM_DM_Error__c += '$$$Dealer#Nexa TSM Missing####';
            }

            if((cas.Dealer_Name__c != null) &&
                    (cas.Dealer_Name__r.Arena_SRV_TSM__c == null) &&
                    (cas.Business_Area__c != null) &&
                    (cas.Business_Area__c.Contains('Service')) &&
                    (cas.Channel__c == 'Arena')){
                cas.MSCRM_DM_Error__c += '$$$Dealer#Arena TSM Missing####';
            }


            if((cas.Dealer_Name__c != null) &&
                    (cas.Dealer_Name__r.Territory_Sales_Manager__c == null) &&
                    (cas.Business_Area__c != null) &&
                    (cas.Business_Area__c.Contains('Sales')) &&
                    (cas.Channel__c == 'Arena')){
                cas.MSCRM_DM_Error__c += '$$$Dealer#Sales TSM Missing####';
            }


            if(string.isEmpty(cas.Dealer_Name__r.DMS_Primaries__c)){
                //cas.MSCRM_DM_Error__c += '$$$Dealer#DMS Primary missing####';
            }


            cas.MSCRM_Processed__c = state;
            system.debug('>>>'+cas.Primary_Category_Id__c+'>>>>>'+cas.Secondary_Category_ID__c+'>>>'+cas.Tertiary_Category_ID__c);

        }
        return cases;
    }



    private string populateStringID(Case cas, string keyType, string primaryKey, string secondaryKey){
        string keyID = '';
        string ErrorCode = '';

        system.debug('>>>>>'+keyType+'>>>>>>'+primaryKey+'>>>>>.'+secondaryKey);

        if((string.IsNotEmpty(cas.Primary_Category__c))&&(keyType == 'Primary')){
            keyID = cas.Primary_Category__c +'_'+keyType;
            ErrorCode += '$$$'+keyType+'#';

        }else if((string.IsNotEmpty(cas.Primary_Category__c))&&(keyType == 'Secondary')){
            keyID = cas.Secondary_Category__c +'_'+keyType;
            ErrorCode += '$$$'+keyType+'#';
        }else{
            keyID = cas.Tertiary_Category__c +'_'+keyType;
            ErrorCode += '$$$'+keyType+'#';
        }


        if(string.IsNotEmpty(cas.Channel__c)){
            keyID += '_'+ cas.Channel__c ;
        }else{
            ErrorCode += 'Channel Missing#';
        }

        if(string.IsNotEmpty(cas.Case_Type__c)){
            keyID += '_'+ cas.Case_Type__c ;
        }else{
            ErrorCode += 'Case type Missing#';
        }

        if(string.IsNotEmpty(cas.Business_Area__c)){
            keyID += '_'+ cas.Business_Area__c ;
        }else{
            ErrorCode += 'BNusiness Area Missing#';
        }

        if(string.IsNotEmpty(cas.Case_Stage__c)){
            keyID += '_'+ cas.Case_Stage__c ;
        }else{
            ErrorCode += 'Case Stage Missing#';
        }

        if(keyType == 'Secondary'){
            if((primaryKey !=null)&&(categoryMap.get(primaryKey).Id != null)){
                keyId += '_' + categoryMap.get(primaryKey).Id;
            }else{
                ErrorCode += 'Primary Key Missing#';
            }

        }
        if(keyType == 'Tertiary'){
            if((secondaryKey != null)&&(categoryMap.get(secondaryKey).Id != null)){
                keyId += '_' + categoryMap.get(secondaryKey).Id;
            }else{
                ErrorCode += 'Secondary Key Missing#';
            }

        }



        if(categoryMap.containsKey(keyId.toLowerCase())){
            system.debug('>>>>>>>>1'+keyId);
            ErrorCode = '';
            return keyID.toLowerCase();
        }else{
            system.debug('>>>>>>>>2'+keyId);
            cas.MSCRM_DM_Error__c += ErrorCode +'#Couldnt Find Id' + '###';
            return null;
        }

    }
}