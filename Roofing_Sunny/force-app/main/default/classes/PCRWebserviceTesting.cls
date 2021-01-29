public with sharing class PCRWebserviceTesting {
  
  public tempuriOrgPCR.ArrayOfZtsdPriceAreaO response {get;set;}
  
  public void ztsdPriceAreaDetails(){
    try{
      response = new tempuriOrgPCR.ArrayOfZtsdPriceAreaO();
      tempuriOrgPCR.Service1Soap cls = new tempuriOrgPCR.Service1Soap();
      tempuriOrgPCR.ArrayOfZtsdPriceArea ztParam = new tempuriOrgPCR.ArrayOfZtsdPriceArea();
      
      Datetime dt = Datetime.newInstance(2014, 10, 27, 0, 0, 0);
      
      sapComDocumentSapSoapFunctionsMcSPCR.ZtsdPriceArea zt = new sapComDocumentSapSoapFunctionsMcSPCR.ZtsdPriceArea();
      zt.Idc = 'R3I';
      zt.ItemClass = '30';
      zt.Material = '000000000000900004';
      
      ztParam.ZtsdPriceArea = new List<sapComDocumentSapSoapFunctionsMcSPCR.ZtsdPriceArea>();
      ztParam.ZtsdPriceArea.add(zt);
      
       
      response = cls.responses('1501','0277','2014-09-09','101',ztParam);
      
      System.debug('output Result:::' + response);
      
      ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.info,'=============' + response));
      
      
    }catch(Exception ex){ 
      ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,ex.getMessage())); 
     
    }
  }
}