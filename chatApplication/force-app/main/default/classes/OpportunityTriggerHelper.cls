/* Name : OpportunityTriggerHelper
* Author : Jayesh vishwakarma
* Date : 23 March, 2020
* Description : This Helper Class is used to find products and create their assests
and link them to respective Opportunity Parent Account
* */
public class OpportunityTriggerHelper 
{
    public static void CreateAssests(List<Opportunity> lstUpdatedOpportunites){
        List<Asset> lstAssets;
        Asset ObjAsset = new Asset();
        List<Product2> lstProducts = [Select Id, Name
                                      From Product2
                                     ];
        for(Opportunity objOpportunity : lstUpdatedOpportunites)
        {
            for(Product2 objProduct : lstProducts){
                objAsset.Name = objProduct.Name;
                objAsset.AccountId= objOpportunity.AccountId;
                lstAssets.add(ObjAsset);
                insert objAsset;
            }
        }
       
    }
}