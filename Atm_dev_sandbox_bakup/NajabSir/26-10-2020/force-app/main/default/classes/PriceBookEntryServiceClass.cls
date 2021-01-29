/**
 * @File Name          : PriceBookEntryServiceClass.cls
 * @Description        : This class is used for 
 * @Author             : Sunit Kumar Chand
 * @Group              : 
 * @Last Modified By   : Sunit Kumar Chand
 * @Last Modified On   : 8/28/2019, 10:37:23 AM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    8/28/2019, 10:37:23 AM   Sunit Kumar Chand     Initial Version
 * 
**/
public with sharing class PriceBookEntryServiceClass {
/**
   Author: Sunit kumar chand
   Company: Techmatrix
   Description: 
   Inputs: 
   Returns: 
   History:
   ================
   1.0     28 Aug 2019      Sunit     Initial Version
*/
    public static BasicReturn createPriceBookEntry(List<Product2> proList,String priceBookName)
    {
        BasicReturn br=new BasicReturn();
        try{
            if(proList.size()>0 && string.isNotBlank(priceBookName)){
            list<Pricebook2> priceBookList = new list<Pricebook2>([SELECT id from Pricebook2 where Name =: priceBookName]);
            list<PricebookEntry> pricebookEntryList = new list<PricebookEntry>();
            for(integer i=0 ;i<proList.size() ;i++){
                PricebookEntry priceBookEntryVar = new PricebookEntry();
                
                priceBookEntryVar.Pricebook2Id = priceBookList[0].id;
                priceBookEntryVar.Product2Id = proList[i].id;
                priceBookEntryVar.UnitPrice = 0;
                priceBookEntryVar.IsActive =true;
                pricebookEntryList.add(priceBookEntryVar);
            } 
            if(pricebookEntryList.size()>0){
                Database.SaveResult[] ds= Database.insert(pricebookEntryList,false);
                br.code=200;
                br.status='Success';
                br.message='Success';
            }
        }
        }
        catch(exception e){
            ExceptionHandler.stackTrace ehst=new ExceptionHandler.stackTrace();
            ehst.componentName='PriceBookEntryServiceClass';
            ehst.userId=UserInfo.getUserId();
            ExceptionHandler.LogError('createPriceBookEntry', e.getMessage(), 'createPriceBookEntry', '', ehst);
            br.code=0;
            br.status='Failed';
            br.message=e.getMessage();
        }
        return br;
    }
}