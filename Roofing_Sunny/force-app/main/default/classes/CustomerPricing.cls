public with sharing class CustomerPricing {

    public String part { get; set; }

    public String idc { get; set; }

    public String payer { get; set; }

    public String shipto { get; set; }

    public String soldto { get; set; }

    public String division { get; set; }

    public String material { get; set; }

  public String message { get; set; }
    public String ivdate { get; set; }
    public List<CustomerResponse> lstCustomerResponse {get;set;}
    public List<CustomerResponse> lstCustomerResponse1 {get;set;}
    private CustomerRequest customerRequest {get;set;}
    public Boolean isSearchResultView {get;set;}
    public transient String displayMsg {get;set;}
    
    public String plant {get;set;}    
        public CustomerPricing(){
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
                
        return null;
    }
      //Set Search Result Panel
    public void showSearchResultView(){
        isSearchResultView = true;
    }
    
    //Search Callout on the basis of selected attributes
    public void searchProducts(){
        try{
            
            lstCustomerResponse = new List<CustomerResponse>();
          lstCustomerResponse1 = new List<CustomerResponse>();
            customerRequest = new CustomerRequest();
            
            customerRequest.plant = plant; 
             customerRequest.ivdate = ivdate;   
              customerRequest.part = part;
               customerRequest.org ='1501';
                customerRequest.soldto = soldto;
                
customerRequest.shipto = shipto;
customerRequest.payer = payer;
customerRequest.ividc = idc;    
customerRequest.dist = division; 
customerRequest.part = part;
customerRequest.material = material;   

            lstCustomerResponse = CustomerPricingCallout.displayCustomerPricing(customerRequest);
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