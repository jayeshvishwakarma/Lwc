public with sharing class ProductAvailabilityCallout {
    
    //Using New Web Service (2/4/2015)
    public static List<ProductAvailabilityResponse> searchProductAvailability(ProductAvailabilityRequest productAvailabilityRequest){
        
        List<ProductAvailabilityResponse> lst = new List<ProductAvailabilityResponse>();
        
        try{
            ProductAvailabilityResponse record;
            PA_tempuriOrg.StockAvailabilityImplSoap cls = new PA_tempuriOrg.StockAvailabilityImplSoap ();
            PA_tempuriOrg.ArrayOfZTSD_STOCK_AV objRes = cls.responses(productAvailabilityRequest.plant, productAvailabilityRequest.material)  ;
            System.debug('Response:::' + objRes );
            
            if(objRes != null && objRes.ZTSD_STOCK_AV != null){
                
                for(PA_sapComDocumentSapRfcFunctions.ZTSD_STOCK_AV itm : objRes.ZTSD_STOCK_AV){
                    
                    record = new ProductAvailabilityResponse();
                     
                    record.Plant = itm.PLANT;
                    record.Material = itm.MATERIAL;
                    record.UOM = itm.UOM;
                    record.Date_x = itm.DATE_x;
                    record.AvailQty = itm.AVAIL_QTY;
                    //record.UOM = itm.UOM;
                    
                    lst.add(record);
                    
                    
                }
                
            }else{
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'SAP Service returned nothing.'));
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'No Inventory Currently Available.'));
            }
           
        }catch(Exception ex){ 
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,ex.getMessage()));
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'SAP Service not Available - Please try again')); 
            return null;
        }
        return lst;
    }
    
    //Method using OLD web Service.
    /*public static List<ProductAvailabilityResponse> searchProductAvailability(ProductAvailabilityRequest productAvailabilityRequest){
        
        List<ProductAvailabilityResponse> lst = new List<ProductAvailabilityResponse>();
        
        try{
            ProductAvailabilityResponse record;
            tempuriOrg.StockAvailabilityImplSoap cls = new tempuriOrg.StockAvailabilityImplSoap ();
            tempuriOrg.ArrayOfZTSD_STOCK_AV objRes = cls.responses(productAvailabilityRequest.plant, productAvailabilityRequest.material)  ;
            System.debug('Response:::' + objRes );
            if(objRes != null){
                
                for(sapComDocumentSapRfcFunctions.ZTSD_STOCK_AV itm : objRes.ZTSD_STOCK_AV){
                    
                    record = new ProductAvailabilityResponse();
                     
                    record.Plant = itm.PLANT;
                    record.Material = itm.MATERIAL;
                    record.UOM = itm.UOM;
                    record.Date_x = itm.DATE_x;
                    record.AvailQty = itm.AVAIL_QTY;
                    //record.UOM = itm.UOM;
                    
                    lst.add(record);
                    
                    
                }
                
            }else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'SAP Service returned nothing.'));
            }
           
        }catch(Exception ex){ 
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,ex.getMessage()));
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'SAP Service not Available - Please try again')); 
            return null;
        }
        return lst;
    }*/
    
}