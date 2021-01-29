public class EscalationMatrix {

    /*
     Author : Gitika
     Company : Techmatrix Consulting
     Description : This helper method is used to fetch stakeholder mapping
     Return Type : list<stakeholderWrapper>
     */
    @AuraEnabled
    public static list<stakeholderWrapper> getEscalationMatrix(String JSON, String businessArea) {

        // map of recordId with Name
        map<string, string> mapOfRecordIdWithName = new map<String, String>();
        // list of stakeholder wrapper
        list<stakeholderWrapper> wrapperList = new list<stakeholderWrapper>();
        // string to store ABCD
        String ABCDString = 'ABCDE';
        // Set to store stakeholder sorting in integer form
        set<integer> sortedSet = new set<integer>();
        // list to store stakeholder sorting in integer form 
        list<integer> sortedList = new list<integer>();
        // map to store stakeholder details with unique key 
        map<string, stakeholderWrapper> mapOfStakeholder = new map<string, stakeholderWrapper>();
        // parsing JSON with help of parseStakeholderHierarchyJson method 
        List<StakeholderHierarchy.Sales> hierarchyList = StakeholderUtility.getSelectedHierarchyList(JSON, businessArea);
        // iterating to store Stakeholder Record Id 
        for (StakeholderHierarchy.Sales stakeholders : hierarchyList) {
            mapOfRecordIdWithName.put(stakeholders.recordId, null);
        }
        // Querying to get Stakeholder Name 
        if (mapOfRecordIdWithName.size() > 0) {
            for (User us : [select FirstName,LastName,Id from User where id in :mapOfRecordIdWithName.keyset()]) {
                String name = (us.FirstName != null ? us.FirstName : '') + ' ' + (us.LastName != null ? us.LastName : '');
                String Id = String.valueOf(us.id).left(15);
                mapOfRecordIdWithName.put(Id, name);
            }
        }
        // iterating StakeholderHierarchy
        for (StakeholderHierarchy.Sales stakeholders : hierarchyList) {
            stakeholderWrapper wrapper = new stakeholderWrapper();
            wrapper.Level = stakeholders.stakeHolder;
            wrapper.Designation = stakeholders.refName;
            wrapper.Phone = stakeholders.phone;
            wrapper.Email = stakeholders.email;
            if (stakeholders.recordId.length() > 15) {
                stakeholders.recordId = String.valueOf(stakeholders.recordId).left(15);
            }
            if (mapOfRecordIdWithName.containsKey(stakeholders.recordId)) {
                wrapper.Name = mapOfRecordIdWithName.get(stakeholders.recordId);
            }

            // removing first character of stakeholder
            string level = stakeholders.stakeHolder.substring(1);
            if (stakeholders.stakeHolder.StartsWith('L')) {
                String uniqueKey = '';
                if (ABCDString.contains(stakeholders.stakeHolder.right(1))) {
                    String alphabet = stakeholders.stakeHolder.right(1);
                    level = level.removeEnd(stakeholders.stakeHolder.right(1));
                    uniqueKey = level + ';' + alphabet;
                    wrapper.Level = 'L' + level;
                } else {
                    uniqueKey = level;
                    wrapper.Level = 'L' + level;
                }
                sortedSet.add(integer.valueOf(level));
                mapOfStakeholder.put(uniqueKey, wrapper);

                // Added by Deepak
                if (businessArea != ConstantsUtility.SALES_HIERARCHY || stakeholders.stakeHolder.contains('L2')) {
                    wrapper.Level = stakeholders.stakeHolder;
                }
            } else {
                wrapperList.add(wrapper);
            }
        }

        sortedList.addAll(sortedSet);
        // sorting list
        sortedList.sort();
        for (integer i : sortedList) {
            for (String str : mapOfStakeholder.keySet()) {
                if (str.contains(';')) {
                    string[] arry = str.split(';');
                    if (string.valueOf(i) == arry[0]) {
                        if (i >= 4)
                            mapOfStakeholder.get(str).Phone = '**********';
                        wrapperList.add(mapOfStakeholder.get(str));
                    }
                } else {
                    if (string.valueOf(i) == str) {
                        if (i >= 4)
                            mapOfStakeholder.get(str).Phone = '**********';
                        wrapperList.add(mapOfStakeholder.get(str));
                    }
                }
            }
        }

        return wrapperList;


    }
    public class stakeholderWrapper {
        @AuraEnabled public string Level;
        @AuraEnabled public string Designation;
        @AuraEnabled public string Name;
        @AuraEnabled public string Phone;
        @AuraEnabled public string Email;
    }
}