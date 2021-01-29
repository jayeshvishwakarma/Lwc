public class OrderControlStatus{
    
    public String externalOrderId;
    public String irmaClientId;
    public String clientStatusCode;
    public String externalProductId;
    public String irmaOrderId;
    public String orderStatusCode;
    public DateTime FirstPossiblePortingDate;
    public DateTime PlannedPortingDate;
    public String PortingState;
    public String PhoneNumber;
    
    public OrderControlStatus(String externalOrderId, String irmaClientId, String clientStatusCode, String externalProductId, String irmaOrderId, String orderStatusCode, DateTime FirstPossiblePortingDate, DateTime PlannedPortingDate, String PortingState, String PhoneNumber){
        this.externalOrderId = externalOrderId;
        this.irmaClientId = irmaClientId;
        this.clientStatusCode = clientStatusCode;
        this.externalProductId = externalProductId;
        this.irmaOrderId = irmaOrderId;
        this.orderStatusCode = orderStatusCode;
        this.FirstPossiblePortingDate = FirstPossiblePortingDate;
        this.PlannedPortingDate = PlannedPortingDate;
        this.PortingState = PortingState;
        this.PhoneNumber = PhoneNumber;
    }
}