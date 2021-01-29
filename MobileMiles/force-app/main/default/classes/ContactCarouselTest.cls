public class ContactCarouselTest implements IBSCarouselClassInterface{
    Public static List<Map<String, String>> getDataListMap(){
        List<Map<String, String>> mapOfContactsToReturn = new List<Map<String, String>>();
        Map<String, String> perticularMap = new Map<String, String>();
        for(Contact con : [SELECT Id, Name, Account.Name, Description, Phone, MobilePhone, Email, Owner.Name, createdDate FROM Contact LIMIT 100]){
            perticularMap = new Map<String, String>();
            perticularMap.put('name', con.Name);
            perticularMap.put('description', con.Description);
            String contacts = con.Phone != NULL ? con.Phone : '' +con.MobilePhone!= NULL ? ','+String.valueOf(con.MobilePhone): ''+con.Email != NULL ? ','+String.valueOf(con.Email): '';
            perticularMap.put('contacts', contacts);
            perticularMap.put('link', con.Email);
            perticularMap.put('owner', con.Owner.Name);
            perticularMap.put('pubDate', con.createdDate.format());
            mapOfContactsToReturn.add(perticularMap);
            
        }
        System.debug(mapOfContactsToReturn);
        return mapOfContactsToReturn;
    }
}