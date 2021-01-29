public with sharing class CustomerPricingCallout {
    
    public static List<CustomerResponse> displayCustomerPricing(CustomerRequest cusRequest){
        
        List<CustomerResponse> lst = new List<CustomerResponse>();
        //List<CustomerResponse> lst1 = new List<CustomerResponse>();
        try{
            CustomerResponse record;
            CustomerResponse record1;
            ApexURI.Service1Soap cls = new ApexURI.Service1Soap ();
            
            sapCom.ZsdWsdlCustSpriceResponse objRes = cls.responses(cusRequest.ivdate, cusRequest.ividc, cusRequest.material, cusRequest.payer, cusRequest.plant, cusRequest.dist, cusRequest.shipto, cusRequest.soldto, cusRequest.org, cusRequest.part);
            // ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.info,string.valueOf(objRes)));
            
            if(objRes != null){
            
                if(objRes.GtOutput.item != null && objRes.GtOutput.item.size() > 0){     
                               
                    for(sapCom1.ZSSD_CUST_SPRICE_OUT itm : objRes.GtOutput.item){
                        
                        record = new CustomerResponse();
                         
                        record.EffDate = itm.EFF_DATE;
                        record.Plant = itm.PLANT;
                        record.SalesOrg = itm.SALES_ORG;
                        record.District = itm.DISTRICT;
                        record.ItemClass = itm.ITEM_CLASS;
                        record.Material = itm.MATERIAL;
                                        
                        record.Idc = itm.IDC;
                        record.UnitAreaPrice = itm.UNIT_AREA_PRICE;
                        record.UnitCurrency = itm.UNIT_CURRENCY;
                        record.UnitPriceUom = itm.UNIT_PRICE_UOM;
                        record.SapSelPrice = itm.SAP_SEL_PRICE;
                        record.SapSelCurr = itm.SAP_SEL_CURR;
                        record.SapSelUom = itm.SAP_SEL_UOM;
                                    
                        lst.add(record);
                                            
                    }
                } else {
                    //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'No SAP Price Found For This Product'));
                    
                    //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, String.valueOf(objRes.Messages.item)));
                    /*
                    for(sapCom.Bapiret2 itm1 : objRes.Messages.item){
                        record = new CustomerResponse();               
                        record.Message = itm1.Message;
                        record.LogMsgNo = itm1.LogMsgNo;
                        record.Type = itm1.Type_x;
                        record.Number_x = itm1.Number_x;
                        lst.add(record);
                    }*/
                }  
         } 
            
        }catch(Exception ex){ 
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,ex.getMessage()));
           // ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'SAP Service not Available - Please try again')); 
            return null;
        }
        return lst;
    }
    
}