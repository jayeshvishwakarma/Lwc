/**
* @File Name          : updateEnqSource.cls
* @Description        : Class for temporary fix to update the Lead Source from description to Code till DMS fix is done.
* @Author             : 
* @Group              : 
* @Last Modified By   : Rahul Raghunathan
* @Last Modified On   : 17/01/2020, 10:26:17 PM
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0    17/01/2020, 10:26:17 PM    Rahul Raghunatahn          Initial Version
**/

public with sharing class updateEnqSource implements Schedulable {

    //vairable to store the description and code combination
    public static map <string,string> leadMap = new map<string,string>{
                                                'Business Associates'=>'DSA',
                                                'Existing Customers'=>'EML',
                                                'True Value'=>'EXM',
                                                'SMS Campaign'=>'FIN',
                                                'Banner/ Hoarding'=>'OTH',
                                                'TeleCalling'=>'TCL',
                                                'Telephoning'=>'TLP',
                                                'DSE Visit'=>'VST',
                                                'Web Enquiry'=>'WEB',
                                                'Showroom Walk-In'=>'WLK',
                                                'Advertisement'=>'ADV',
                                                'Campaign/Events'=>'EVT',
                                                'References'=>'REF',
                                                'Panchayat'=>'PCH',
                                                'Campaign/Events'=>'EVE',
                                                'Wheels of India'=>'WOI',
                                                'Anytime Maruti'=>'MUL',
                                                'Inbound Calls'=>'IBC',
                                                'Cold Visits'=>'DCV',
                                                'Insurance Database'=>'IND',
                                                'Workshop Enquiry'=>'WKE',
                                                'Mobile Enquiry'=>'MOB',
                                                'Maruti Driving School'=>'MDS',
                                                'My Maruti Suzuki'=>'MMS',
                                                'aCRM'=>'CRM',
                                                'Email'=>'EMA',
                                                'E-Booking'=>'EBK',
                                                'Website'=>'WES',
                                                'Newspaper Ads'=>'NDS',
                                                'Social Media'=>'SMD',
                                                'Online Booking'=>'OBK',
                                                'Mobile Terminal'=>'MTL',
                                                'aCRM Others'=>'ACR',
                                                'Cold Calling'=>'CLD',
                                                'Director/CEO'=>'DIR',
                                                'Generated'=>'GEN',
                                                'MCC'=>'MCC',
                                                'New Car Inbound'=>'NCI',
                                                'New Car Outbound'=>'NCO',
                                                'Own Generation'=>'OWN',
                                                'Staff Reference'=>'STF'};


    /**
        Author: Rahul Raghunathan
        Company: Salesforce
        Description: Method to check the enquiries where the LeadSource is description instead of name
        Inputs: None
        Returns: void
        History:
        ====================================================
        1.0     17 Sept 2019  Prabhat Sharma  Initial Version
    **/
    public void execute(SchedulableContext SC) {

        //Fetch the current of descriptions
        list<string> descript = new list<String> (leadMap.keyset());

        //Fetch the relevant opportunities.
        list<Opportunity> currentOpps = [select id, LeadSource 
                                            from Opportunity 
                                            where LeadSource in :descript
                                            LIMIT 9999];

        //Update the opportunities leadsource
        for (Opportunity opp :currentOpps){
            opp.LeadSource = leadMap.get(opp.LeadSource);
        }

        if(currentOpps.size() > 0){
            database.update(currentOpps,false);
        }
    }
}