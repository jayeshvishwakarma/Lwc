public with sharing class PriceAreaCallOut {

    public static List<PAPResponse> displayPricaAreaPricing(PAPRequest priceRequest){
        
        List<PAPResponse> lst = new List<PAPResponse>();
     
        try{
            PAPResponse record;
        
             tempuriOrgPricing.PriceAreaPricingImplSoap cls = new tempuriOrgPricing.PriceAreaPricingImplSoap  ();
         //   ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.info,string.valueOf(priceRequest)));
            sapComPricing.ZSdWsdlPriceAreaPriceFmResponse objRes = cls.responses(priceRequest.org, priceRequest.plant, priceRequest.ivdate, priceRequest.district, priceRequest.material, priceRequest.division1, priceRequest.ividc);
//ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.info,string.valueOf(objRes)));
            
            if(objRes != null){
            
if(objRes.GtOutput.item != null && objRes.GtOutput.item.size() > 0)
{                for(sapComPricing1.Ztsd_Price_Area_O itm : objRes.GtOutput.item){
                    
                    record = new PAPResponse();
                     
                    record.EffDate = itm.Eff_Date;
                    record.Plant = itm.Plant;
                    record.SalesOrg = itm.Sales_Org;
                    record.District = itm.District;
                    record.ItemClass = itm.Item_Class;
                    record.Material = itm.Material;
                    
record.Idc = itm.Idc;
record.UnitAreaPrice = itm.Unit_Area_Price;
record.UnitCurrency = itm.Unit_Currency;
record.UnitPriceUom = itm.Unit_Price_Uom;
record.SapSelPrice = itm.Sap_Sel_Price;
record.SapSelCurr = itm.Sap_Sel_Curr;
record.SapSelUom = itm.Sap_Sel_Uom;   
            
                    lst.add(record);
                    
}
//return lst;
}
else{
ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.info,'No SAP Price Found For This Product'));
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