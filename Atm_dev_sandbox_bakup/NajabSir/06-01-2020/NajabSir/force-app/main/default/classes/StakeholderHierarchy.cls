/**
 Author: Deepak Kumar
 Company: Techmatrix
 Description: This class is used to deserialize the Json from the Dealer record
 History:
 * Version         Date                     Author                    Modification
 *==============================================================================
 * 1.0        07/07/2020                Deepak Kumar              Initial Version
**/
public class StakeholderHierarchy {

    public class Sales {
        public String recordId;
        public String email;
        public String phone;
        public String refName;
        public String stakeHolder; 
    }

    public List<Sales> sales;
    public List<Sales> serviceArena;
    public List<Sales> serviceNexa;
    public List<Sales> service;
    public List<Sales> accessories;
    public List<Sales> trueValue;
    public List<Sales> msds;
    public List<Sales> msgp;
    public List<Sales> msilQuery;
    public List<Sales> loyaltyProgram;
    public List<Sales> finance;
}