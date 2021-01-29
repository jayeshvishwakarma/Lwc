public class CsvUploadPortMobielController {
    public Blob csvFileBody{get;set;}
    public string csvAsString{get;set;}
    public List<List<String>> csvFileLines{get;set;}
    public List<Porteringen_mobiel__c> porMobielList{get;set;}
    private String quoteId;
    
    public CsvUploadPortMobielController(ApexPages.StandardController sc){
        csvFileLines = new List<List<String>>();
        porMobielList = New List<Porteringen_mobiel__c>(); 
        quoteId = sc.getId();
     }
    
    public void importCSVFile(){
        try{
            system.debug('csvAsString' + csvAsString);
            if(csvFileBody != Null){
                csvAsString = csvFileBody.toString();
                csvFileLines = CSVReader.read(csvAsString); 
                system.debug('csvFileLines' + csvFileLines);
                Integer recordIndex = 0;
                for(List<String> csvRecordData : csvFileLines){   
                    if(recordIndex != 0){
                        system.debug('csvRecordData' + csvRecordData);
                        Porteringen_mobiel__c porMobObj = new Porteringen_mobiel__c();
                        porMobObj.Product_KPN_EEN__c = csvRecordData[1] ;  
                        system.debug('porMobObj.Product_KPN_EEN__c' + porMobObj.Product_KPN_EEN__c);
                        porMobObj.Huidige_provider__c = csvRecordData[2];
                        porMobObj.Klant_nummer__c = csvRecordData[3];
                        porMobObj.Label__c = csvRecordData[4];
                        system.debug('quoteId' + quoteId);
                        porMobObj.Offerte__c = quoteId;
                        porMobObj.Name =  csvRecordData[5];
                        porMobObj.Type_aanvraag__c = csvRecordData[6];
                        String Datum_eind_date = csvRecordData[7];
                        if(String.isNotBlank(Datum_eind_date)){
                            system.debug('Datum_eind_date' + Datum_eind_date+'--');
                            porMobObj.Datum_eind_contract__c = date.parse(Datum_eind_date.trim()); 
                            system.debug('porMobObj.Datum_eind_contract__c' + porMobObj.Datum_eind_contract__c);
                        }
                        String Wens_date = csvRecordData[8];
                        if(String.isNotBlank(Wens_date)){
                            system.debug('Wens_date' + Wens_date+'--');
                            porMobObj.Wensdatum__c = date.parse(Wens_date.trim()); 
                            system.debug('porMobObj.Datum_eind_contract__c' + porMobObj.Datum_eind_contract__c);
                        }
                        porMobObj.RecordTypeId = csvRecordData[9];
                        porMobObj.Type_huidig_abonnement__c = csvRecordData[10];
                        porMobielList.add(porMobObj);
                    }
                    recordIndex++;
                    
                }
                if(porMobielList.size() > 0){
                    insert porMobielList;
                    system.debug('porMobielList ' + porMobielList);
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM, + recordIndex-1 +' Records successfully inserted'));
                }
            }
            else{
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,' Please Select a file'));
            }
        }
        catch (Exception e){
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured while importing data. Please make sure input csv file is correct' + e.getMessage());
            ApexPages.addMessage(errorMessage);
        }  
    }
}