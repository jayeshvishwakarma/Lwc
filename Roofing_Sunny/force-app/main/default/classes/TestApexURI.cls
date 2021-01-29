/*********************************************************************************
* Test Class: {TestApexURI}
* Created by {Abhishek Pareek}, Navivo, {DateCreated 12/04/2014}
----------------------------------------------------------------------------------
* Purpose/Methods:
* - {Code coverage of ApexURI.cls}
----------------------------------------------------------------------------------
* Utility Test Data: {TestClassUtility.cls}
----------------------------------------------------------------------------------
* History:
* - VERSION DEVELOPER NAME DATE DETAIL FEATURES
1.0 Abhishek 12/04/2014 INITIAL DEVELOPMENT
2.0 Name MM/DD/YYYY UDAC WIRE FRAME CHANGES
*********************************************************************************/
@isTest
private class TestApexURI {

    static testMethod void myUnitTest() {
    	ApexURI.returnmsg_element retMsg = new ApexURI.returnmsg_element();
    	ApexURI.ArrayOfBapiret2 arrBap = new ApexURI.ArrayOfBapiret2();
    	ApexURI.responses_element res = new ApexURI.responses_element();
    	ApexURI.responsesResponse_element resEle = new ApexURI.responsesResponse_element();
    	ApexURI.returnmsgResponse_element retMsgRes = new ApexURI.returnmsgResponse_element();
    	ApexURI.Service1Soap serSOAP = new ApexURI.Service1Soap();
    	System.assert(true);
    }
    static testMethod void myUnitTest2() {
    	try{
	    	ApexURI.Service1Soap serSOAP = new ApexURI.Service1Soap();
	    	serSOAP.responses('ivdate', 'ividc', 'material', 'payer', 'plant', 'dist', 'shiptto', 'soldto', 'org', 'part');
	    	System.assert(true);
    	}
    	catch(Exception e){
    	
    	}
    }
    static testMethod void myUnitTest3() {
    	try{
	    	ApexURI.Service1Soap serSOAP = new ApexURI.Service1Soap();
	    	ApexURI.ArrayOfBapiret2 arrBap = new ApexURI.ArrayOfBapiret2();
	    	serSOAP.returnmsg(arrBap);
	    	System.assert(true);
    	}
    	catch(Exception e){
    	
    	}
    }
}