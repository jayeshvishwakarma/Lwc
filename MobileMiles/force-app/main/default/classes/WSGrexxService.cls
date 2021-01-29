public class WSGrexxService {

    //WSGrexxOrderControl.grexxResponse_element response = WSGrexxService.WSGrexxOrderControl('',date.newInstance(2017, 1, 1),123,CE);
    public static WSGrexxOrderControl.grexxResponse_element WSGrexxOrderControl(String externalid,
                                                                                date orderwishdate,
                                                                                String reference,
                                                                                Boolean directOrder,
                                                                                WSGrexxOrderControl.order_client_element clientE,
                                                                                WSGrexxOrderControl.order_access_element accessE,
                                                                                WSGrexxOrderControl.order_grouporder_element grouporderE,
                                                                                list<WSGrexxOrderControl.order_mobilephonenumbers_mobilephonenumber_element> mobilephonenumbers,
                                                                                list<WSGrexxOrderControl.order_hardware_item_element> hardware,
                                                                                list<WSGrexxOrderControl.order_services_service_element> services,
                                                                                Boolean MKBOffice) { //24 Jan
        WSGrexxOrderControl.OrderControlRequestSoap OCRS = new WSGrexxOrderControl.OrderControlRequestSoap();
        if(MKBOffice != null && MKBOffice) {//24 Jan
            OCRS.endpoint_x = 'callout:MKB_Grexx/ordercontrol';
        }
        OCRS.timeout_x = 120000;
        //Basic authentication
        //OCRS.inputHttpHeaders_x = WSGrexxService.getAuthentication();

        //Create header
        WSGrexxOrderControl.header_element HeaderE = new WSGrexxOrderControl.header_element();
        HeaderE.reference = reference;

        //Create RequestData //20183101 not sure if neccesery
        WSGrexxOrderControl.partner_element partnerE = new WSGrexxOrderControl.partner_element();
        //WSGrexx_Settings__c grexxSettings = WSGrexx_Settings__c.getOrgDefaults();
        string partnerId = '{!$Credential.UserName}';
        string partnerPass = '{!$Credential.Password}';
        partnerE.partnerid = partnerId;
        partnerE.partnerpass = partnerPass;
        //partnerE.partnerid = '{!$Credential.Username}';
        //partnerE.partnerpass = '{!$Credential.Password}';

        WSGrexxOrderControl.order_data_element dataE = new WSGrexxOrderControl.order_data_element();
        if (externalid != null) {
            dataE.externalid = externalid;
        }
        dataE.orderwishdate = orderwishdate;
        dataE.directorder = directOrder == null ? false : directOrder;

        WSGrexxOrderControl.order_element orderE = new WSGrexxOrderControl.order_element();
        //heel veel elementen hier
        orderE.data = dataE;
        orderE.client = clientE;
        if (accessE != null) {
            orderE.access = accessE; //access_element
        }
        //system.debug('@@@@@ grouporderE ' + grouporderE);
        if (grouporderE != null) {
            orderE.grouporder = grouporderE; //grouporder_element
        }
        system.debug('@@@@@ orderE.grouporder ' + orderE.grouporder);
        if (mobilephonenumbers != null && mobilephonenumbers.size() > 0) {
            WSGrexxOrderControl.order_mobilephonenumbers_element mphoneE = new WSGrexxOrderControl.order_mobilephonenumbers_element();
            mphoneE.mobilephonenumber = mobilephonenumbers;
            orderE.mobilephonenumbers = mphoneE; //mobilephonenumbers_element
        }

        if (hardware != null && hardware.size() > 0) {
            WSGrexxOrderControl.order_hardware_element hardwareE = new WSGrexxOrderControl.order_hardware_element();
            hardwareE.item = hardware;
            orderE.hardware = hardwareE; //hardware_element
        }

        if (services != null && services.size() > 0) {
            WSGrexxOrderControl.order_services_element servicesE = new WSGrexxOrderControl.order_services_element();
            servicesE.service = services;
            orderE.services = servicesE; //services_element
        }

        WSGrexxOrderControl.ordercontrol_element ordercontrolE = new WSGrexxOrderControl.ordercontrol_element();
        ordercontrolE.partner = partnerE;
        ordercontrolE.order = orderE;

        WSGrexxOrderControl.requestData_element requestDataE = new WSGrexxOrderControl.requestData_element();
        requestDataE.ordercontrol = ordercontrolE;

        //WSGrexxOrderControl.grexxResponse_element response = OCRS.OrderControlRequest(HeaderE, requestDataE);
        WSGrexxOrderControl.grexxResponse_element response = OCRS.OrderControlRequest_Http(HeaderE, requestDataE);

        if (response.status.code != 0) {
            system.debug('Error code: ' + response.status.code + ': ' + response.status.message);
        }
        return response;
    }

    //public static map<string, string> getAuthentication() {
    //    map<string, string> authstring = new map<string, string> ();
    //    WSGrexx_Settings__c grexxSettings = WSGrexx_Settings__c.getOrgDefaults();
    //    string todecode = grexxSettings.PartnerId__c + ':' + grexxSettings.PartnerPass__c;
    //
    //    String Userpas = system.EncodingUtil.base64Encode(Blob.valueOf(todecode));
    //    authstring.put('Authorization', 'Basic ' + Userpas);
    //    return authstring;
    //}

}