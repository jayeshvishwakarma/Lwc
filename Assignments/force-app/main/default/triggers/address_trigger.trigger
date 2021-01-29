/* Name : AddressTrigger
* Author : Jayesh Vishwakarma
* Date : 20 march 2020
* Description : This Trigger is used to give the list of contacts which have active address.
* */


trigger address_trigger on Address__c (after insert) {
    
    set<Id> setIds=new Set<ID>(); 
    for(Address__C objAddress : Trigger.New)
    {
        if(objAddress.isActive__c==true)
        {
            setIds.add(objAddress.Contact__C);
        }
    }
    List<Contact> lstContacts=[SELECT AccountId,Account.most_recent_address__c,
                               (SELECT name From Addresses__r ORDER BY createdDate ASC)
                               FROM Contact
                               WHERE id IN : setIds
                              ];
    if(lstContacts.size()>0) AddressTriggerHelper.addMostRecentAddress(lstContacts);
}