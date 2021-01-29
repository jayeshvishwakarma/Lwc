/*
    Test Class for AddProductsController
*/
@isTest
public class AddProductsControllerCloneTest{
    @isTest
    private static void unitTest1(){   
          Profile p = [select id from profile where name = 'Cloud ÉÉN Community']; 
          account accRc = new account();
            accRc.name = 'Test Act';
            insert accRc;
            
          Contact Con = new contact(LastName = 'testContact',email='genelia.dsouza@gmail.com', AccountId = accRc.Id); 
        insert Con;    
          User usr = new User(alias = 'standt', 
                email=con.email,
                emailencodingkey='UTF-8', 
                lastname=con.lastname,
                firstname=con.firstname, 
                languagelocalekey='en_US',
                localesidkey='en_US', 
                profileid = p.Id, 
                CommunityNickname = 'testUser123',
                contactId=con.Id,
                timezonesidkey='America/Los_Angeles',
                username=con.email,
                isActive=true);
                
           insert usr;  
        
            account actObj = new account();
            actObj.name = 'Test Act';
            insert actObj;
            Contact c = new Contact();
            c.LastName = 'TestContact';
            c.AccountId = actObj.Id;
            insert c;
            Product2 prod = new Product2(Name = 'Laptop X200', 
                Family = 'Hardware', isActive = true, merk__c = 'Samsung');
            insert prod;
            
            Product2 prod2 = new Product2(Name = 'Verzilveren MobileMiles', 
                Family = 'Hardware', isActive = true, merk__c = 'Apple');
            insert prod2;
            
            // Get standard price book ID.
            // This is available irrespective of the state of SeeAllData.
            Id pricebookId = Test.getStandardPricebookId();
            
            // 1. Insert a price book entry for the standard price book.
            // Standard price book entries require the standard price book ID we got earlier.
            PricebookEntry standardPrice = new PricebookEntry(
                Pricebook2Id = pricebookId, Product2Id = prod.Id,
                UnitPrice = 10000, IsActive = true);
            insert standardPrice;
            
            // Create a custom price book
            Pricebook2 customPB = new Pricebook2(Name='Cloud EEN portal', isActive=true);
            insert customPB;
            
            // 2. Insert a price book entry with a custom price.
            PricebookEntry customPrice = new PricebookEntry(
                Pricebook2Id = customPB.Id, Product2Id = prod.Id,
                UnitPrice = 12000, IsActive = true);
            insert customPrice;
        	system.runas(usr){     
            PaymentTransactionSetting__c customSetting = new PaymentTransactionSetting__c (Name = 'config', Redirect_URL__c = 'https://devsnd-kpneen.cs89.force.com/s/paymentresponse', Service_Id__c = 'SL-5516-2570',Token__c ='6eb4bb2f8b67d08a7cf9b3e9cdae31d62def1315', Merchant_User_Name__c = 'jvanvoorst@mobilemiles.nl', Password__c = '5Xn*B!5U$dt3Fm6', End_URL__c = '   https://rest-api.pay.nl/v7/Transaction/start/json');
            insert customSetting;
            List<PricebookEntry> PricebookEntries =  AddProductsControllerClone.fetchProducts('Alle merken'); 
                List<String> productsIds = new List<String>();
                
                for(PricebookEntry priceBook : PricebookEntries){
                    productsIds.add(priceBook.Product2Id);
                }
            AddProductsControllerClone.getBrandsName();
            List<AddProductsControllerClone.Response> ModalObjectList = AddProductsControllerClone.getAccounts();
            //AddProductsControllerObj.getAccounts();
            //accRc.Betaalwijze_bestelling__c = '';
            AddProductsControllerClone.Response response = AddProductsControllerClone.changeAccount(ModalObjectList[0].value);   
              response.objAccount.Betaalwijze_bestelling__c = 'iDeal';
            List<Product2> products = AddProductsControllerClone.getProducts(productsIds);
                String productStr = '';
                 List<Object> lstMaps = new List<Object>(); 
                for(Product2 product : products){                  
                   Map<String, Object> productMap = new Map<String, Object>();
                    productMap.put('productId',product.Id);
                    productMap.put('productName',product.Name);
                    productMap.put('Pricebook2Id',product.PricebookEntries[0].Pricebook2Id);
                    productMap.put('UnitPrice',product.PricebookEntries[0].UnitPrice);
                    productMap.put('quantity',1);
                    productMap.put('applianceInsuranc','Totaal');
                    lstMaps.add(productMap);
                }
               productStr = JSON.serialize(lstMaps);
            AddProductsControllerClone.createRecord(response, productStr, '45674'); 
            PnlPaymentHandlerClone.doTransactionRequest(100,'test','test','test','test','test');
            PnlPaymentHandlerClone.parseTransactionRequestResult('{"request": {"result":"1","errorId":"","errorMessage":""}, "endUser":{"blacklist":"0"}, "transaction": {"transactionId":"922160230X4a1dc6", "paymentURL":"https:", "popupAllowed":"0", "paymentReference":"5000 0009 2216 0230"} }');        
            
        }
    }
}