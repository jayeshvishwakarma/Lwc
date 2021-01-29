/*
        Name            :    PorteringenMobielTriggerHelper
        Author          :    Ranu Bari
        Date            :    01/23/2018
        Description     :    Used in PorteringenMobielTrigger
*/
public class PorteringenMobielTriggerHelper{
    static Map<String,String> mapOfFields;
    Static Boolean bool;
    
    // to update Porteringen_mobiel__c when Porteringen_mobiel__c KWT__c field is updated.
   public static void updatePorteringen(set<Id> accIds, set<Id> productIds, List<Porteringen_mobiel__c> lstPorteringens){
        
        Map<String, List<Porteringen_mobiel__c>> mapPorteringen = new Map<String, List<Porteringen_mobiel__c>>();
        
        for(Porteringen_mobiel__c objPorteringen : lstPorteringens){
			String uniqueKey = objPorteringen.Account__c + '-' + objPorteringen.Product__c;
			if (!mapPorteringen.containsKey(uniqueKey)) {
				mapPorteringen.put(uniqueKey, new List<Porteringen_mobiel__c>());
			}
			mapPorteringen.get(uniqueKey).add(objPorteringen);                
       }           
    
    List<Porteringen_mobiel__c> lstUpdatePorteringen = new List<Porteringen_mobiel__c>();
    for(KWT__c objKWT : [SELECT Id, Korting_per_aansluiting_p_mnd__c, Product__c, Bedrijf__c
                         FROM KWT__c 
                         where Product__c IN: productIds and Bedrijf__c IN: accIds]){  
                             
        List<Porteringen_mobiel__c> lstPorteringenTemp = mapPorteringen.get(objKWT.Bedrijf__c + '-' + objKWT.Product__c );
        
        if(lstPorteringenTemp != null && lstPorteringenTemp.size() > 0){
            for(Porteringen_mobiel__c objPorteringen : lstPorteringenTemp){
                lstUpdatePorteringen.add(new Porteringen_mobiel__c(Id = objPorteringen.Id, KWT__c = objKWT.Korting_per_aansluiting_p_mnd__c));
            }
        }
    }
    if(lstUpdatePorteringen.size() > 0)
        update lstUpdatePorteringen;
   
	}
    
    //To prevent ‘porteringen_mobiel__c’ records to be deleted when ‘IRMA_Id__c’ field is populated.
    //Called from PorteringenMobielTrigger
    public static void deletePorteringMobiels(List<Porteringen_mobiel__c> porteringens){
        for(Porteringen_mobiel__c pm : porteringens){
            if(pm.IRMA_Id__c != null && !Test.isRunningTest())
                pm.addError('You cannot delete this record, Please contact to System Administrator.');
        }
    }
    
    //To call Web Http Request and Update Sim_Swap_Status when Simwissel_uitvoeren__c is checked
    //Called from PorteringenMobielTrigger
    @future(callout=true)
    public static void doSimSwap(Set<Id> recordIds){
        
        List<Porteringen_mobiel__c> porteringenMobielList = [Select name, id, Simwissel_uitvoeren__c, 
                                        IRMA_Id__c, Nieuw_SIM_kaart_nummer__c, SimCardSwapReason__c, account__r.IRMA_MKB_Office__c 
                                        from Porteringen_mobiel__c Where id in :recordIds];
        Http http;
        HttpRequest request;
        String requestBody='';
        
        String FResponse = '';  
        for(Porteringen_mobiel__c porteringen : porteringenMobielList){
            requestBody='';
            bool = true;
            mapOfFields = new Map<String,String>();
          
            requestBody = '<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:con="http://schemas.grexx.net/atalanta/connect">';
            requestBody += '<soap:Header/>';
            requestBody += '<soap:Body>';
            requestBody += '<con:grexxRequest>';
            requestBody += '<con:header>';
            requestBody += '<con:reference>'+porteringen.Id+'</con:reference>';  
            requestBody += '<con:PartnerReference>'+porteringen.Name+'</con:PartnerReference>';  
            requestBody += '<con:DateCreated>'+System.now()+'</con:DateCreated>';  
            requestBody += '</con:header>';
            requestBody += '<con:requestData>';
            requestBody += '<con:SimCardSwapRequest_V1>';  
            requestBody += '<con:OrderId>'+porteringen.IRMA_Id__c +'</con:OrderId>';
            requestBody += '<con:SimCard>';
            requestBody += '<con:ICCId>'+porteringen.Nieuw_SIM_kaart_nummer__c +'</con:ICCId>';
            requestBody += '</con:SimCard>';
            requestBody += '<con:SimCardSwapReason>'+porteringen.SimCardSwapReason__c +'</con:SimCardSwapReason>';
            requestBody += '</con:SimCardSwapRequest_V1>';
            requestBody += '</con:requestData>';
            requestBody += '</con:grexxRequest>';
            requestBody += '</soap:Body>';
            requestBody += '</soap:Envelope>';
               
            system.debug('requestBody -'+requestBody );
    
            http = new Http();   
            request = new HttpRequest();
           
            if( porteringen.account__r.IRMA_MKB_Office__c ) {
                request.setEndPoint('callout:MKB_Grexx/simswap');
            }else {
                request.setEndPoint('callout:Grexx/simswap');
            } 
            
            request.setMethod('POST');
            request.setHeader('Content-Type', 'text/xml');    
            request.setBody(requestBody);
            String statusCode = '';
            
            if(!Test.isRunningTest()){
                try{
                   HttpResponse response = http.send(request);
                   system.debug('response.getStatus() -- ' + response.getStatus());
                   if(response.getStatusCode() == 200){
                       FResponse = response.getBody();
                       system.debug('fresponse-'+FResponse);
                   }
                }catch(Exception ex){
                     System.debug('Exception Found !!' + ex.getMessage());
                     ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage());
                     ApexPages.addMessage(myMsg);
                }
            } else {
                FResponse = '<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><soap:Body><grexxResponse xmlns="http://schemas.grexx.net/atalanta/connect"><header><transactionID>1:6306:1169955</transactionID><reference>a6A0E0000005Em7</reference></header><status><code>0</code><message>Succes</message></status><responseData><QueueResponse><IsSuccess>true</IsSuccess><ErrorCode>0</ErrorCode></QueueResponse></responseData></grexxResponse></soap:Body></soap:Envelope>';
            }
            
            if(String.isNotBlank(FResponse)){
                Dom.Document doc = new Dom.Document();
                try{
                    doc.load(FResponse);
                }catch(Exception ee){
                    system.debug(ee.getMessage());
                }
                if(doc.getRootElement()!=NULL){
                    Dom.XmlNode root = doc.getRootElement();
                    parseXML(root);
                    System.debug('Map Of Fields '+ mapOfFields);
                   
                    for(String key : MapOfFields.keySet()){
                        if(key == 'message'){
                           porteringen.Sim_Swap_Status__c = mapOfFields.get(key);
                           if(mapOfFields.get(key) == 'Succes'){
                               porteringen.Verzend_simwissel_bevestiging__c = true;
                           } else {
                               porteringen.Simwissel_mislukt__c = true;
                           }
                        } //end if(key)  
                    }//end for(mapOfFields)  
                }//endif(getRootElement)
            }//endif FResponse
        }//end for(porteringen_mobiel list)
        
       //updating porteringenMobielList list
       update porteringenMobielList;
    }//end function
    
    
    //Parsing XML code
    private static void parseXML(DOM.XMLNode node) {
        if (node.getNodeType() == DOM.XMLNodeType.ELEMENT) {
            system.debug(node.getName()); 
            if(node.getName() == 'message'){
                system.debug(node.getName()); 
                mapOfFields.put(node.getName(), node.getText());
                bool = false;
            }
            if(node.getName() == 'ErrorMessage'){
                mapOfFields.put(node.getName(), node.getText());
            }
            
        }
        for (Dom.XMLNode child: node.getChildElements()) {
            if(bool != false){
                parseXML(child);    
            }
            
        }
        
    }
    
    
    //To call Web Http Request when Mobiele_settings_ophalen__c is checked (25 june 2019 by shikha)
    //Called from PorteringenMobielTrigger
    //@future(callout=true)
    public static void MobileSettingsGREXX(Set<Id> mobielIds){
        System.debug('MobileSettingsGREXX called...');
        List<Porteringen_mobiel__c> porteringenMobielList = [Select name, id, 
                                        IRMA_Id__c, Mobiele_settings_ophalen__c 
                                        from Porteringen_mobiel__c Where id in :mobielIds];
                                        
        Integer totalporteringenMobiel = porteringenMobielList.size();
        List<Porteringen_mobiel__c> firstBatchPM = new List<Porteringen_mobiel__c>();
        List<Porteringen_mobiel__c> secondBatchPM = new List<Porteringen_mobiel__c>();
        //List<Porteringen_mobiel__c> thirdBatchPM = new List<Porteringen_mobiel__c>();
        //List<Porteringen_mobiel__c> fourthBatchPM = new List<Porteringen_mobiel__c>();
        
        Last_Batch_Run__c lastBatch = Last_Batch_Run__c.getValues('Mobile Setting');
        DateTime lastScheduledRun = lastBatch.Last_Scheduled_Batch__c;
        Integer batchSize = Integer.valueOf(lastBatch.Batch_Size__c);
        Integer loopStart = batchSize; 
        BatchMobileSettingsGREXX mobielBatch;
        Set<String> pmIds = new Set<String>();     
        for(Integer i=0; i<batchSize && i < totalporteringenMobiel; i++){
            firstBatchPM.add(porteringenMobielList[i]);
        }
        for(Integer i=loopStart; i<loopStart+batchSize && i < totalporteringenMobiel; i++){
            secondBatchPM.add(porteringenMobielList[i]);          
        }
        /*loopStart = loopStart + batchSize;
        for(Integer i=loopStart; i<loopStart+batchSize && i < totalporteringenMobiel; i++){
            thirdBatchPM.add(porteringenMobielList[i]);
        }
        loopStart = loopStart + batchSize;
        for(Integer i=loopStart; i<loopStart+batchSize && i < totalporteringenMobiel; i++){
            fourthBatchPM.add(porteringenMobielList[i]);
        }*/
        
        //Call batch class directly, remove scheduler process on 23Aug 2019 by shikha
        //calling for firstBatchPM
        if(firstBatchPM.size() > 0){
            pmIds = new Set<String>(new Map<String,SObject>(firstBatchPM).keySet());
            mobielBatch = new BatchMobileSettingsGREXX(pmIds);
            Database.executeBatch(mobielBatch);
        } 
        //calling for secondBatchPM
        if(secondBatchPM.size() > 0){
            pmIds = new Set<String>(new Map<String,SObject>(secondBatchPM).keySet());
            mobielBatch = new BatchMobileSettingsGREXX(pmIds);
            Database.executeBatch(mobielBatch); 
        }
        //calling for thirdBatchPM
        /*if(thirdBatchPM.size() > 0){
            pmIds = new Set<String>(new Map<String,SObject>(thirdBatchPM).keySet());
            mobielBatch = new BatchMobileSettingsGREXX(pmIds);
            Database.executeBatch(mobielBatch);
        } 
        //calling for fourthBatchPM
        if(fourthBatchPM.size() > 0){
            pmIds = new Set<String>(new Map<String,SObject>(fourthBatchPM).keySet());
            mobielBatch = new BatchMobileSettingsGREXX(pmIds);
            Database.executeBatch(mobielBatch); 
        }*/
        
        //Commented to remove scheduler process on 23Aug 2019 by shikha
        /*if(lastScheduledRun<system.now()){
            lastScheduledRun = system.now();
        }
        if(firstBatchPM.size() > 0){ 
            lastScheduledRun = setScheduler(lastScheduledRun, firstBatchPM);            
        }
        if(secondBatchPM.size() > 0){ 
            lastScheduledRun = setScheduler(lastScheduledRun, secondBatchPM);                      
        }
        if(thirdBatchPM.size() > 0){ 
            lastScheduledRun = setScheduler(lastScheduledRun, thirdBatchPM);                    
        }
        if(fourthBatchPM.size() > 0){ 
            lastScheduledRun = setScheduler(lastScheduledRun, fourthBatchPM);                        
        }     
        lastBatch.Last_Scheduled_Batch__c =  lastScheduledRun;
        update lastBatch;*/ 
    }
    
    //Commented to remove scheduler process on 23Aug 2019 by shikha
    /*private static DateTime setScheduler(DateTime scheduleTime, List<Porteringen_mobiel__c> porteringenMobielList){
        DateTime batchTime = scheduleTime.addHours(1);  
        Set<String> pmIds = new Set<String>(new Map<String,SObject>(porteringenMobielList).keySet());
        String chronExpression = '' + batchTime.second() + ' ' + batchTime.minute() + ' ' + batchTime.hour() + ' ' + batchTime.day() + ' ' + batchTime.month() + ' ? ' + batchTime.year();
        System.schedule('Mobile Setting' + batchTime + system.now().millisecond(), chronExpression, new ScheduledMobileSettingsGREXX(pmIds)); 
        return batchTime;
    }*/
    
    
    
    //To call Web Http Request when Contract_duur_afloopdatum_wijzigen__c is checked (26 june 2019 by shikha)
    //Called from PorteringenMobielTrigger
    //@future(callout=true)
    public static void ModifyContractTerminationGREXX(Set<Id> contractIds){
        System.debug('ModifyContractTerminationGREXX called...');
        List<Porteringen_mobiel__c> porteringenMobielList = [Select name, id,  
                                        IRMA_Id__c, Contract_duur_afloopdatum_wijzigen__c  
                                        from Porteringen_mobiel__c Where id in :contractIds];
                                        
        Integer totalporteringenMobiel = porteringenMobielList.size();
        List<Porteringen_mobiel__c> firstBatchPM = new List<Porteringen_mobiel__c>();
        List<Porteringen_mobiel__c> secondBatchPM = new List<Porteringen_mobiel__c>();
        //List<Porteringen_mobiel__c> thirdBatchPM = new List<Porteringen_mobiel__c>();
        //List<Porteringen_mobiel__c> fourthBatchPM = new List<Porteringen_mobiel__c>();
        
        Last_Batch_Run__c lastBatch = Last_Batch_Run__c.getValues('Contract Termination');
        DateTime lastScheduledRun = lastBatch.Last_Scheduled_Batch__c;
        Integer batchSize = Integer.valueOf(lastBatch.Batch_Size__c);
        Integer loopStart = batchSize;   
        BatchModifyContractTermination mobielBatch;
        Set<String> pmIds = new Set<String>();
        for(Integer i=0; i<batchSize && i < totalporteringenMobiel; i++){
            firstBatchPM.add(porteringenMobielList[i]);
        }
        for(Integer i=loopStart; i<loopStart+batchSize && i < totalporteringenMobiel; i++){
            secondBatchPM.add(porteringenMobielList[i]);          
        }
        /*loopStart = loopStart + batchSize;
        for(Integer i=loopStart; i<loopStart+batchSize && i < totalporteringenMobiel; i++){
            thirdBatchPM.add(porteringenMobielList[i]);
        }
        loopStart = loopStart + batchSize;
        for(Integer i=loopStart; i<loopStart+batchSize && i < totalporteringenMobiel; i++){
            fourthBatchPM.add(porteringenMobielList[i]);
        }*/
        
        //Call batch class directly, remove scheduler process on 23Aug 2019 by shikha
        //calling for firstBatchPM
        if(firstBatchPM.size() > 0){
            pmIds = new Set<String>(new Map<String,SObject>(firstBatchPM).keySet());
            mobielBatch = new BatchModifyContractTermination(pmIds);
            Database.executeBatch(mobielBatch); 
        } 
        //calling for secondBatchPM
        if(secondBatchPM.size() > 0){
            pmIds = new Set<String>(new Map<String,SObject>(secondBatchPM).keySet());
            mobielBatch = new BatchModifyContractTermination(pmIds);
            Database.executeBatch(mobielBatch); 
        }
        //calling for thirdBatchPM
        /*if(thirdBatchPM.size() > 0){
            pmIds = new Set<String>(new Map<String,SObject>(thirdBatchPM).keySet());
            mobielBatch = new BatchModifyContractTermination(pmIds);
            Database.executeBatch(mobielBatch);
        } 
        //calling for fourthBatchPM
        if(fourthBatchPM.size() > 0){
            pmIds = new Set<String>(new Map<String,SObject>(fourthBatchPM).keySet());
            mobielBatch = new BatchModifyContractTermination(pmIds);
            Database.executeBatch(mobielBatch); 
        }*/
        
        //Commented to remove scheduler process on 23Aug 2019 by shikha
        /*if(lastScheduledRun<system.now()){
            lastScheduledRun = system.now();
        }
        if(firstBatchPM.size() > 0){ 
            lastScheduledRun = setContractScheduler(lastScheduledRun, firstBatchPM);            
        }
        if(secondBatchPM.size() > 0){ 
            lastScheduledRun = setContractScheduler(lastScheduledRun, secondBatchPM);                      
        }
        if(thirdBatchPM.size() > 0){ 
            lastScheduledRun = setContractScheduler(lastScheduledRun, thirdBatchPM);                    
        }
        if(fourthBatchPM.size() > 0){ 
            lastScheduledRun = setContractScheduler(lastScheduledRun, fourthBatchPM);                        
        }     
        lastBatch.Last_Scheduled_Batch__c =  lastScheduledRun;
        update lastBatch; */
    }
    
    //Commented to remove scheduler process on 23Aug 2019 by shikha
    /*private static DateTime setContractScheduler(DateTime scheduleTime, List<Porteringen_mobiel__c> porteringenMobielList){
        DateTime batchTime = scheduleTime.addHours(1);  
        Set<String> pmIds = new Set<String>(new Map<String,SObject>(porteringenMobielList).keySet());
        String chronExpression = '' + batchTime.second() + ' ' + batchTime.minute() + ' ' + batchTime.hour() + ' ' + batchTime.day() + ' ' + batchTime.month() + ' ? ' + batchTime.year();
        System.schedule('Contract Termination' + batchTime + system.now().millisecond(), chronExpression, new ScheduledModifyContractTermination(pmIds)); 
        return batchTime;
    }*/
    
    
    
    //To call Web Http Request when Mobiele_settings_ophalen__c is checked (25 june 2019 by shikha)
    //Called from PorteringenMobielTrigger
    //@future(callout=true)
    public static void ModifyMobileSettingsGREXX(Set<Id> mobielIds){
        System.debug('ModifyMobileSettingsGREXX called...');
        List<Porteringen_mobiel__c> porteringenMobielList = [Select name, id, 
                                        IRMA_Id__c, Mobiele_settings_ophalen__c 
                                        from Porteringen_mobiel__c Where id in :mobielIds];
                                        
        Integer totalporteringenMobiel = porteringenMobielList.size();
        List<Porteringen_mobiel__c> firstBatchPM = new List<Porteringen_mobiel__c>();
        List<Porteringen_mobiel__c> secondBatchPM = new List<Porteringen_mobiel__c>();
        //List<Porteringen_mobiel__c> thirdBatchPM = new List<Porteringen_mobiel__c>();
        //List<Porteringen_mobiel__c> fourthBatchPM = new List<Porteringen_mobiel__c>();
        
        Last_Batch_Run__c lastBatch = Last_Batch_Run__c.getValues('Modify Mobile Settings');
        DateTime lastScheduledRun = lastBatch.Last_Scheduled_Batch__c;
        Integer batchSize = Integer.valueOf(lastBatch.Batch_Size__c);
        Integer loopStart = batchSize;
        BatchModifyMobileSettingsGREXX mobielBatch;
        Set<String> pmIds = new Set<String>();
        for(Integer i=0; i<batchSize && i < totalporteringenMobiel; i++){
            firstBatchPM.add(porteringenMobielList[i]);
        }
        for(Integer i=loopStart; i<loopStart+batchSize && i < totalporteringenMobiel; i++){
            secondBatchPM.add(porteringenMobielList[i]);          
        }
        /*loopStart = loopStart + batchSize;
        for(Integer i=loopStart; i<loopStart+batchSize && i < totalporteringenMobiel; i++){
            thirdBatchPM.add(porteringenMobielList[i]);
        }
        loopStart = loopStart + batchSize;
        for(Integer i=loopStart; i<loopStart+batchSize && i < totalporteringenMobiel; i++){
            fourthBatchPM.add(porteringenMobielList[i]);
        }*/
        
        //Call batch class directly, remove scheduler process on 23Aug 2019 by shikha
        //calling for firstBatchPM
        if(firstBatchPM.size() > 0){
            pmIds = new Set<String>(new Map<String,SObject>(firstBatchPM).keySet());
            mobielBatch = new BatchModifyMobileSettingsGREXX(pmIds);
            Database.executeBatch(mobielBatch); 
        } 
        //calling for secondBatchPM
        if(secondBatchPM.size() > 0){
            pmIds = new Set<String>(new Map<String,SObject>(secondBatchPM).keySet());
            mobielBatch = new BatchModifyMobileSettingsGREXX(pmIds);
            Database.executeBatch(mobielBatch); 
        }
        //calling for thirdBatchPM
        /*if(thirdBatchPM.size() > 0){
            pmIds = new Set<String>(new Map<String,SObject>(thirdBatchPM).keySet());
            mobielBatch = new BatchModifyMobileSettingsGREXX(pmIds);
            Database.executeBatch(mobielBatch);
        } 
        //calling for fourthBatchPM
        if(fourthBatchPM.size() > 0){
            pmIds = new Set<String>(new Map<String,SObject>(fourthBatchPM).keySet());
            mobielBatch = new BatchModifyMobileSettingsGREXX(pmIds);
            Database.executeBatch(mobielBatch); 
        }*/
        
        //Commented to remove scheduler process on 23Aug 2019 by shikha
        /*if(lastScheduledRun<system.now()){
            lastScheduledRun = system.now();
        }
        if(firstBatchPM.size() > 0){ 
            lastScheduledRun = setModifyMobileScheduler(lastScheduledRun, firstBatchPM);            
        }
        if(secondBatchPM.size() > 0){ 
            lastScheduledRun = setModifyMobileScheduler(lastScheduledRun, secondBatchPM);                      
        }
        if(thirdBatchPM.size() > 0){ 
            lastScheduledRun = setModifyMobileScheduler(lastScheduledRun, thirdBatchPM);                    
        }
        if(fourthBatchPM.size() > 0){ 
            lastScheduledRun = setModifyMobileScheduler(lastScheduledRun, fourthBatchPM);                        
        }     
        lastBatch.Last_Scheduled_Batch__c =  lastScheduledRun;
        update lastBatch; */
    }
    
    //Commented to remove scheduler process on 23Aug 2019 by shikha
    /*private static DateTime setModifyMobileScheduler(DateTime scheduleTime, List<Porteringen_mobiel__c> porteringenMobielList){
        system.debug('scheduleTime--'+scheduleTime);
        DateTime batchTime = scheduleTime.addHours(1);  
        Set<String> pmIds = new Set<String>(new Map<String,SObject>(porteringenMobielList).keySet());
        String chronExpression = '' + batchTime.second() + ' ' + batchTime.minute() + ' ' + batchTime.hour() + ' ' + batchTime.day() + ' ' + batchTime.month() + ' ? ' + batchTime.year();
        System.schedule('Modify Mobile Settings' + batchTime + system.now().millisecond(), chronExpression, new ScheduledModifyMobileSettingsGREXX(pmIds)); 
        return batchTime;
    }*/
    
   /* //To update Active/Inactive lookup of account in PorteringenMobiel by shikha(24/5/2019)
    public static void SetPMLookup(List<Porteringen_mobiel__c> portMobNewData, Map<ID, Porteringen_mobiel__c> portMobOldData){
        for(Porteringen_mobiel__c porteringen : portMobNewData){
            if((porteringen.Datum_opheffen__c != null || porteringen.Datum_actief__c != null) && (Trigger.isInsert || 
              (Trigger.isUpdate && (porteringen.Datum_opheffen__c != portMobOldData.get(porteringen.id).Datum_opheffen__c || 
               porteringen.Datum_actief__c != portMobOldData.get(porteringen.id).Datum_actief__c)))){
                
                if(porteringen.Active_lookup__c == null && (porteringen.Datum_opheffen__c > System.TODAY() || 
                                                            porteringen.Datum_actief__c <= System.TODAY())){
                    porteringen.Active_lookup__c = porteringen.Account__c;
                    porteringen.Inactive_lookup__c = null;  
                }else if(porteringen.Inactive_lookup__c == null && (porteringen.Datum_opheffen__c <= System.TODAY() || 
                                                            porteringen.Datum_actief__c > System.TODAY())){
                    porteringen.Active_lookup__c = null;
                    porteringen.Inactive_lookup__c = porteringen.Account__c;        
                }
            }
            
        }
    }*/
}