//Generated by wsdl2apex

public class ApexURI {
    public class returnmsg_element {
        public ApexURI.ArrayOfBapiret2 message;
        private String[] message_type_info = new String[]{'message','http://tempuri.org/',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/','true','false'};
        private String[] field_order_type_info = new String[]{'message'};
    }
    public class responses_element {
        public String ivdate;
        public String ividc;
        public String material;
        public String payer;
        public String plant;
        public String dist;
        public String shiptto;
        public String soldto;
        public String org;
        public String part;
        private String[] ivdate_type_info = new String[]{'ivdate','http://tempuri.org/',null,'0','1','false'};
        private String[] ividc_type_info = new String[]{'ividc','http://tempuri.org/',null,'0','1','false'};
        private String[] material_type_info = new String[]{'material','http://tempuri.org/',null,'0','1','false'};
        private String[] payer_type_info = new String[]{'payer','http://tempuri.org/',null,'0','1','false'};
        private String[] plant_type_info = new String[]{'plant','http://tempuri.org/',null,'0','1','false'};
        private String[] dist_type_info = new String[]{'dist','http://tempuri.org/',null,'0','1','false'};
        private String[] shiptto_type_info = new String[]{'shiptto','http://tempuri.org/',null,'0','1','false'};
        private String[] soldto_type_info = new String[]{'soldto','http://tempuri.org/',null,'0','1','false'};
        private String[] org_type_info = new String[]{'org','http://tempuri.org/',null,'0','1','false'};
        private String[] part_type_info = new String[]{'part','http://tempuri.org/',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/','true','false'};
        private String[] field_order_type_info = new String[]{'ivdate','ividc','material','payer','plant','dist','shiptto','soldto','org','part'};
    }
    public class ArrayOfBapiret2 {
        public sapCom.Bapiret2[] Bapiret2;
        private String[] Bapiret2_type_info = new String[]{'Bapiret2','http://tempuri.org/',null,'0','-1','true'};
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/','true','false'};
        private String[] field_order_type_info = new String[]{'Bapiret2'};
    }
    public class responsesResponse_element {
        public sapCom.ZsdWsdlCustSpriceResponse responsesResult;
        private String[] responsesResult_type_info = new String[]{'responsesResult','http://tempuri.org/',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/','true','false'};
        private String[] field_order_type_info = new String[]{'responsesResult'};
    }
    public class returnmsgResponse_element {
        public ApexURI.ArrayOfBapiret2 returnmsgResult;
        private String[] returnmsgResult_type_info = new String[]{'returnmsgResult','http://tempuri.org/',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/','true','false'};
        private String[] field_order_type_info = new String[]{'returnmsgResult'};
    }
    public class Service1Soap {
        public String endpoint_x = 'https://sfdc.certainteed.com/Prod_Customer_Specific_Pricing/Service1.asmx';
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;
        private String[] ns_map_type_info = new String[]{'http://tempuri.org/', 'ApexURI', 'urn:sap-com:document:sap:soap:functions:mc-style', 'sapCom', 'urn:sap-com:document:sap:rfc:functions', 'sapCom1'};
        public sapCom.ZsdWsdlCustSpriceResponse responses(String ivdate,String ividc,String material,String payer,String plant,String dist,String shiptto,String soldto,String org,String part) {
            ApexURI.responses_element request_x = new ApexURI.responses_element();
            request_x.ivdate = ivdate;
            request_x.ividc = ividc;
            request_x.material = material;
            request_x.payer = payer;
            request_x.plant = plant;
            request_x.dist = dist;
            request_x.shiptto = shiptto;
            request_x.soldto = soldto;
            request_x.org = org;
            request_x.part = part;
            ApexURI.responsesResponse_element response_x;
            Map<String, ApexURI.responsesResponse_element> response_map_x = new Map<String, ApexURI.responsesResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'http://tempuri.org/responses',
              'http://tempuri.org/',
              'responses',
              'http://tempuri.org/',
              'responsesResponse',
              'ApexURI.responsesResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.responsesResult;
        }
        public ApexURI.ArrayOfBapiret2 returnmsg(ApexURI.ArrayOfBapiret2 message) {
            ApexURI.returnmsg_element request_x = new ApexURI.returnmsg_element();
            request_x.message = message;
            ApexURI.returnmsgResponse_element response_x;
            Map<String, ApexURI.returnmsgResponse_element> response_map_x = new Map<String, ApexURI.returnmsgResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'http://tempuri.org/returnmsg',
              'http://tempuri.org/',
              'returnmsg',
              'http://tempuri.org/',
              'returnmsgResponse',
              'ApexURI.returnmsgResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.returnmsgResult;
        }
    }
}