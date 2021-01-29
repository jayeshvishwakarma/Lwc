public with sharing class PriceAreaPricing {
  public String district { get; set; }

    public String ividc { get; set; }
public String ivdate { get; set; }
    
    public String division1 { get; set; }

    public String material { get; set; }
 public String plant {get;set;} 
//public tempuriOrg.ArrayOfZtsdPriceArea input {get; set;}
  
   
    public List<PAPResponse> lstPAPResponse {get;set;}
    
    private PAPRequest pricingRequest {get;set;}
    public Boolean isSearchResultView {get;set;}
    public transient String displayMsg {get;set;}
    
       
        public PriceAreaPricing(){
        try{
           // userInfo = UtilityClass.userDetail;
            
         //   territoryId = null;
                      //  lstCustomerResponse = new List<CustomerResponse>();
            
            
        }
        catch(Exception ex){
            System.debug('Exception:::' + ex.getMessage());
        }
    }
    
    //called below method on page load
    public Pagereference onPageLoad(){
               isSearchResultView=false; 
        return null;
    }
      //Set Search Result Panel
    public void showSearchResultView(){
        isSearchResultView = true;
    }
    
    //Search Callout on the basis of selected attributes
    public void searchProducts(){
        try{
            isSearchResultView=true;
            lstPAPResponse = new List<PAPResponse>();
         
            pricingRequest = new PAPRequest();
            
            pricingRequest.plant = plant; 
             pricingRequest.ivdate = ivdate;   
              pricingRequest.district = district;
               pricingRequest.org ='1501';
           //  input = new tempuriOrg.ArrayOfZtsdPriceArea();
             //  sapComDocumentSapSoapFunctionsMcS.ZtsdPriceArea zt = new sapComDocumentSapSoapFunctionsMcS.ZtsdPriceArea();

            pricingRequest.material = material;
      pricingRequest.division1 = division1;
            pricingRequest.ividc= ividc;
 
      
            lstPAPResponse = PriceAreaCallOut.displayPricaAreaPricing(pricingRequest);
            
      //      ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.info,string.valueOf(pricingRequest)));
           // lstCustomerResponse1 = CustomerPricingCallout.displayCustomerPricing(customerRequest);
            
        }catch(Exception ex){ 
            System.debug('============================= ERROR '+ex.getMessage());
            System.debug('============================= Full Stack Track '+ex.getStackTraceString());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,ex.getMessage())); 
        }
    }
    
       
    public void refreshPage(){
        
    }
}