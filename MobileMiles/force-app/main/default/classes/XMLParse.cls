public class XMLParse{
    
    List<OrderControlStatus> orderControlStatusList;
    
    public XMLParse(String XMLString){
        orderControlStatusList = new List<OrderControlStatus>();        
        DOM.Document doc=new DOM.Document();
        try{
            doc.load(XMLString);
            DOM.XmlNode statusUpdate =doc.getRootElement().getChildElement('StatusUpdate', null);
            String extId = statusUpdate.getChildElement('ExternalOrderId',null).getText();                       
            String irmaClientId = statusUpdate.getChildElement('Client', null).getChildElement('IrmaClientId',null).getText();
            String clientStatusCode = statusUpdate.getChildElement('Client', null).getChildElement('ClientStatusCode',null).getText();
            String extProdId = statusUpdate.getChildElement('Product', null).getChildElement('ExternalProductId',null).getText();
            String irmaOrderId = statusUpdate.getChildElement('Product', null).getChildElement('IrmaOrderId',null).getText();
            String orderStatusCode = statusUpdate.getChildElement('Product', null).getChildElement('OrderStatusCode',null).getText();
            DateTime FirstPossiblePortingDate;
            if(XMLString.contains('FirstPossiblePortingDate')){
                String firstPossibleDtstr = statusUpdate.getChildElement('Product', null).getChildElement('FirstPossiblePortingDate',null).getText();
                if(String.isNotBlank(firstPossibleDtstr)){
                    firstPossibleDtstr= firstPossibleDtstr.left(10);
                    List<String> firstPossibleDt = firstPossibleDtstr.split('-');                                    
                    FirstPossiblePortingDate = DateTime.newInstanceGmt(Integer.valueOf(firstPossibleDt.get(0)),
                                             Integer.valueOf(firstPossibleDt.get(1)),
                                             Integer.valueOf(firstPossibleDt.get(2)));
                }
            }
            
            DateTime PlannedPortingDate ;
            if(XMLString.contains('PlannedPortingDate')){
                String PlannedPortingStr = statusUpdate.getChildElement('Product', null).getChildElement('PlannedPortingDate',null).getText();
                if(String.isNotBlank(PlannedPortingStr)){
                    PlannedPortingStr = PlannedPortingStr.left(10);
                    List<String> PlannedPortingDt = PlannedPortingStr.split('-');                                    
                    PlannedPortingDate = DateTime.newInstanceGmt(Integer.valueOf(PlannedPortingDt.get(0)),
                                                         Integer.valueOf(PlannedPortingDt.get(1)),
                                                         Integer.valueOf(PlannedPortingDt.get(2)));
                }
            } 
            String PortingState = XMLString.contains('PortingState') ? statusUpdate.getChildElement('Product', null).getChildElement('PortingState',null).getText() : '';
            String PhoneNumber = XMLString.contains('PhoneNumber') ? statusUpdate.getChildElement('Product', null).getChildElement('PhoneNumber',null).getText() : '';
            
            orderControlStatusList.add(new OrderControlStatus(extId, irmaClientId, clientStatusCode, extProdId, irmaOrderId, orderStatusCode,FirstPossiblePortingDate, PlannedPortingDate, PortingState, PhoneNumber));
        }catch(exception e){
            system.debug(e.getMessage());
        }
    }    
}