/*
Name            :    KWTTriggerHelper 
Author          :    Rajrishi Kaushik
Date            :    01/09/2020
Description     :    Used in KWTTrigger
*/
public class KWTTriggerHelper {
	public static boolean isUpdatingKWT = false;    
    public static void updatePorteringen(set<Id> accIds, set<Id> productIds, List<KWT__c> lstKWTs){
        
        Map<String, List<Porteringen_mobiel__c>> mapPorteringen = new Map<String, List<Porteringen_mobiel__c>>();
        
        for(Porteringen_mobiel__c objPorteringen : [SELECT Id, KWT__c, Product__c, Account__c
                                                    FROM Porteringen_mobiel__c 
                                                    where Product__c IN: productIds and Account__c IN: accIds]){
			String uniqueKey = objPorteringen.Account__c + '-' + objPorteringen.Product__c;
			if (!mapPorteringen.containsKey(uniqueKey)) {
				mapPorteringen.put(uniqueKey, new List<Porteringen_mobiel__c>());
			}
			mapPorteringen.get(uniqueKey).add(objPorteringen);                
       	}           
    
    List<Porteringen_mobiel__c> chunkPorteringList = new List<Porteringen_mobiel__c>();
    for(KWT__c objKWT : lstKWTs){                
        List<Porteringen_mobiel__c> lstPorteringenTemp = mapPorteringen.get(objKWT.Bedrijf__c + '-' + objKWT.Product__c );
        if(lstPorteringenTemp != null && lstPorteringenTemp.size() > 0){
            for(Porteringen_mobiel__c objPorteringen : lstPorteringenTemp){
                if(objPorteringen.KWT__c != objKWT.Korting_per_aansluiting_p_mnd__c){
                    objPorteringen.KWT__c = objKWT.Korting_per_aansluiting_p_mnd__c;                
                	chunkPorteringList.add(objPorteringen);
                }                
            }
        }
    }
        if(chunkPorteringList.size() > 0){
            isUpdatingKWT = true;
            update chunkPorteringList;
        }
        
   
	}
}