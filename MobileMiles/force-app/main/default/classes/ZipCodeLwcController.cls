public  class ZipCodeLwcController {
   
    @AuraEnabled
    public static  List<ZipCodeWrapper> getZipCode(String accountId, String portfolio, String zipcode, String houseNr, String hourseNrExtension){
        System.debug('accountId'+accountId);
        System.debug('portfolio'+portfolio);
        System.debug('zipcode'+zipcode);
        System.debug('houseNr'+houseNr);
        System.debug('hourseNrExtension'+hourseNrExtension);
        ZipCodeCheck.executeAPI(accountId, portfolio, zipcode, houseNr, hourseNrExtension);
        Map<string, List<Available_Speed__c>> mapOfBoth = ZipCodeCheck.getResultData();
        //Map<string, List<Available_Speed__c>> mapOfBoth = new Map<string, List<Available_Speed__c>>();
        List<Available_Speed__c> speedList = new  List<Available_Speed__c>();
        // Available_Speed__c newSpeed = new Available_Speed__c();
        List<ZipCodeWrapper> zipLst = new List<ZipCodeWrapper>();

        // newSpeed.Availability__c  = 'Green';
        // newSpeed.Description__c = '960/5839 kbit/sec';
        // newSpeed.Technology__c = 'ADSL 2+';
        // speedList.add(newSpeed);

        // newSpeed = new Available_Speed__c();
        // newSpeed.Availability__c  = 'Yellow';
        // newSpeed.Description__c = '960/12595 kbit/sec';
        // newSpeed.Technology__c = 'ADSL 2+';
        // speedList.add(newSpeed);

        // newSpeed = new Available_Speed__c();
        // newSpeed.Availability__c  = 'Green';
        // newSpeed.Description__c = '1362/13943 kbit/sec';
        // newSpeed.Technology__c = 'VDSL';
        // speedList.add(newSpeed);

        // mapOfBoth.put('KPN', speedList);

        // speedList = new  List<Available_Speed__c>();
        // newSpeed = new Available_Speed__c();

        // newSpeed.Availability__c  = 'Yellow';
        // newSpeed.Description__c = 'Gebiedscode A On-net fiber NLS 3';
        // newSpeed.Technology__c = 'WEAS Fiber';
        // speedList.add(newSpeed);

        // newSpeed = new Available_Speed__c();
        // newSpeed.Availability__c  = 'Red';
        // newSpeed.Description__c = '';
        // newSpeed.Technology__c = 'WEAS Koper';
        // speedList.add(newSpeed);

        // mapOfBoth.put('KPNWEAS', speedList);
        Map<String,String> mapOfFileds = ZipCodeCheck.getResponseMessages();
        if(mapOfFileds.get('ErrorMessage') != null){
            throw new AuraHandledException('Server Error: '+mapOfFileds.get('ErrorMessage'));
        }else if(mapOfBoth.size() > 0){
            for(String mapOfKey : mapOfBoth.keySet()){
                ZipCodeWrapper zipObj = new ZipCodeWrapper();
                List<SpeedListWrapper> speedWrpLst = new List<SpeedListWrapper>();
                zipObj.supplierName = mapOfKey.trim().replace('null-', '');
                speedList = mapOfBoth.get(mapOfKey);
                for(Available_Speed__c avaSpeedObj : speedList){
                    SpeedListWrapper speedWrpObj = new SpeedListWrapper();
                    speedWrpObj.availability = avaSpeedObj.Availability__c;
                    speedWrpObj.technology = avaSpeedObj.Technology__c;
                    speedWrpObj.description = avaSpeedObj.Description__c;
                    speedWrpObj.classes = 'slds-badge '+avaSpeedObj.Availability__c;
                    speedWrpLst.add(speedWrpObj);
                }
                zipObj.speedList = speedWrpLst;   
                zipLst.add(zipObj);         
            }
        }

        return zipLst;
    }

    Class ZipCodeWrapper{
        @AuraEnabled public String supplierName;
        @AuraEnabled public List<SpeedListWrapper> speedList;
    }
    Class SpeedListWrapper{
        @AuraEnabled public String availability;
        @AuraEnabled public String technology;
        @AuraEnabled public String description;
        @AuraEnabled public String classes;
    }
}