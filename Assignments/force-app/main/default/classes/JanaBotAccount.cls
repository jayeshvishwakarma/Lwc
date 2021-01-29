public with sharing class JanaBotAccount {

    public class CityOutput{
    @InvocableVariable
    public String sgetAccounts;
    }
    
    public class CityInput{
    @InvocableVariable
    public String sCityInput;
    }
    
    @InvocableMethod(label='Accounts by City')
    public static List<Account> getAccountByCity(List<CityInput> cityInputs){
        Set<String> cities = new Set<String>();
        for(CityInput c : cityInputs){
            cities.add(c.sCityInput);
        }
        List<Account> lstAccounts = [SELECT name FROM Account WHERE ShippingCity in :cities];
        return lstAccounts;
    }
}