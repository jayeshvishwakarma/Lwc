public class CTIRedirectServiceClass {

    public static Map<String, String> urlParameters;
    
    public CTIRedirectServiceClass(){
        urlParameters = ApexPages.currentPage().getParameters();        
    }
    
    public PageReference redirect(){
        system.debug('>>>>>'+urlParameters);
        
        //string before = '{"componentDef":"forceSearch:searchPageDesktop","attributes":{"term":"8178856850","scopeMap":{"type":"TOP_RESULTS"},"groupId":"DEFAULT"},"state":{}}';
		string before = '{  "componentDef": "forceSearch:searchPageDesktop",  "attributes": {    "term": "9998822882",    "scopeMap": {      "type": "TOP_RESULTS"    }  }}';
        string Encoded = EncodingUtil.base64Encode(Blob.valueOf(before));
        
        /*if(urlParameters.get('Id') == '5001s000001bqCiAAI'){
            return new PageReference('/5001s000001bqCiAAI');
        }*/
        
        return new pageReference('/one/one.app#'+Encoded);
        //return null;
    }
    
}