/**
* @File Name          : ConstantsUtility.cls
* @Description        : This class will have all the constants defined to be used in various other classes
* @Author             : 
* @Group              : 
* @Last Modified By   : Rajesh Ramachandran
* @Last Modified On   : 10/12/2019, 8:18:06 AM
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                    Modification
*==============================================================================
* 1.0    7/31/2019, 9:14:54 PM      Prabhat Sharma                Initial Version
**/


public with sharing class ConstantsUtility {
     //Added by Avaneesh for Vehicle Allotment R1.2
     public static final String COMMERCIAL_CHANNEL = 'Commercial';


     //ATM Constants
     public static final String QA_INITIATION = 'QA Inititation';
     public static final String QA_DISCARD = 'QA Discard';
     public static final String QA_NEW_ALLOCATION = 'QA New Allocation';

    //ATM Constants
    public static final String DEALER_TYPE_S = 'S';
    public static final String DEALER_TYPE_3S = '3S';
    public static final String DEALER_TYPE_2S = '2S';
    public static final String DEALER_TYPE_TV = 'TV';
    public static final String DEALER_TYPE_M = 'M';
    public static final String C_ALPHABET = 'C';
    public static final String UNJUSTIFIED_APPROVAL_L8_DECISION_NOT_UNIFIED = 'Revalidation_Service_Unjustified_L8_Decision';

    public static final String UNJUSTIFIED_COMPLAINT_REVALIDATION = 'Unjustified Complaint Revalidation';
    public static final String PRODUCT_COMPLAINT_REVALIDATION = 'Product Complaint Revalidation';

    public static final String SALES_REVALIDATION = 'Sales Revalidation';
    public static final String SERVICE_REVALIDATION = 'Service Revalidation';
    public static final String CASE_TRANSFER_APPROVAL_NAME = 'Case_Transfer_Approval';
    public static final String QC_STATUS_NOT_OK = 'Not OK';
    public static final String CASE_SOURCE_EMAIL = 'Email';
    public static final String QC_CHECK_DONE = 'QC_Check_Done';
    public static final String QC_CHECK_CASE_DISCARDED = 'QC_Check_Case_Discarded';
    public static final String QC_CHECK_DEALER_CHANGED = 'QC_Check_Dealer_Changed';
    public static final String CASE_NUMBER_REPLACEMENT = '{caseNumber}';
    public static final String CASE_TYPE_REPLACEMENT = '{caseType}';
    public static final String DURATION_REPLACEMENT = '{duration}';
    public static final String CUSTOMER_NAME_REPLACEMENT = '{customerName}';
    public static final String CUSTOMER_PHONE_NUMBER_REPLACEMENT = '{customerPhoneNo}';
    public static final String PRIMARY_CATEGORY_REPLACEMENT = '{primaryCategory}';
    public static final String VARIANT_REPLACEMENT = '{Variant}';
    public static final String DEALER_NAME_REPLACEMENT = '{dealerName}';
    public static final String DEALER_CODE_REPLACEMENT = '{dealerCode}';
    public static final String FOR_CODE_REPLACEMENT = '{forCode}';
    public static final String CITY_REPLACEMENT = '{City}';
    public static final String REGION_REPLACEMENT = '{Region}';
    public static final String LEVEL_OF_ESCALATION_REPLACEMENT = '{LevelofEscalation}';
    public static final String CASE_SUB_TYPE_REPLACEMENT = '{CaseSubType}';
    public static final String CHANNEL_REPLACEMENT = '{Channel}';
    public static final String BUSINESS_AREA_REPLACEMENT = '{BusinessArea}';
    public static final String CASE_STAGE_REPLACEMENT = '{CaseStage}';

    // Chatter notifications msg
    public static final String CASE_CCP_CHATTER_MSG = 'Complaint Not Contacted – {duration} {caseNumber}, {customerName} - {customerPhoneNo}, {primaryCategory}, {Variant}, {dealerName} {dealerCode}-{forCode}, {City}, {Region}';
    public static final String CASE_CASE_RESOLUTION_CHATTER_MSG = '{LevelofEscalation} Escalation - {CaseSubType} {Channel} {BusinessArea} {CaseStage} {caseType}  registered - ref. no. {caseNumber} for Dealer code {dealerCode}';
    public static final String CCP_NOT_RESPONDED_CHATTER_MSG = 'This case has been marked "Contacted by RO and not by CCA, CCP incomplete", Plesae trigger the CCP not responded approval process';

    public static final String CASE_ACTIONS_CCP_NOT_RESPONDED_FLOW = 'CCP Not Responded Flow';
    public static final String CCP_NUMBER_IF_UNSUCCESSFUL_CONNECTS_NOTIFICATION_NAME = 'CCP_Number_of_Unsuccessful_connects';
    public static final String CCP_OUTBOUND_CALL_TO_DEALERSHIP = 'Call To Dealership';
    public static final String CCP_OUTBOUND_CALL_TO_CUSTOMER = 'Call To Customer';

    public static final String ESCALATION_TYPE_CCP_INITIATION = 'CCP Initiation';
    public static final String CCP_STATUS_NOT_CONTACTED_INCOMPLETE = 'Not Contacted - Incomplete';
    public static final String CCP_STATUS_CONTACTED_COMPLETED = 'Contacted - Complete';
    public static final String CCP_STATUS_CONTACTED_BY_RO_NOT_CCA_INCOMPLETE = 'Contacted by RO & Not By CCA - Incomplete';
    public static final String CCP_STATUS_CONTACTED_BY_RO_NOT_CCA_COMPLETE = 'Contacted by RO & Not By CCA - Complete';
    public static final String WRAP_UP_CODE_DLR_CONTACTED = 'Dlr Contacted';
    public static final String WRAP_UP_CODE_NEXT_CALL_COMPLAINT = 'Next Call_Complaint';
    public static final String WRAP_UP_CODE_NEXT_CALL = 'Next Call';
    public static final String CALL_TYPE_OUTBOUND = 'Outbound';
    public static final String CASE_READ_ACCESS = 'Read';
    public static final String CASE_PREFIX = '500';
    public static final String TASK_QUERY_COMPLAINTS_CALL_DECOMPOSITIONS_RECORD_TYPE_ID = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Query_Complaints_Call_Dispositions').getRecordTypeId();
    public static final String CAMPAIGN_CALL_CAMPAIGN_RECORD_TYPE_ID = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Call_Campaign').getRecordTypeId();

    public static final String CASE_ASSIGNMENT_ERROR_MESSAGE_RECIPIENT_QUEUE_ON_MASTER = 'Queue is defined in the Recipient Master';
    public static final String CASE_ASSIGNMENT_ERROR_MESSAGE_RECIPIENT_MASTER_NOT_FOUND = 'Recipient Master Not Found';
    public static final String CASE_ASSIGNMENT_ERROR_MESSAGE_JSON_NOT_FOUND_ON_RECIPIENT_MASTER = 'Json hierarchy not found on Recipient Master';
    public static final String CASE_ASSIGNMENT_ERROR_MESSAGE_JSON_NOT_FOUND_ON_DEALER = 'Json hierarchy not found on dealer master';
    public static final String CASE_ASSIGNMENT_ERROR_MESSAGE_RECIPIENT_MASTER_ERROR = 'Error in related Recipient Master';
    public static final String REGION_ALL = 'All';
    // Case Assignment hierarchy types
    public static final String SALES_HIERARCHY = 'sales';

    public static final String SERVICE_HIERARCHY = 'service'; // NOT IN USE
    
    public static final String SERVICE_NEXA_HIERARCHY = 'serviceNexa';
    public static final String SERVICE_ARENA_HIERARCHY = 'serviceArena';
    public static final String FINANCE_HIERARCHY = 'finance';
    public static final String ACCESSORIES_HIERARCHY = 'accessories';
    public static final String TRUEVALUE_HIERARCHY = 'trueValue';
    public static final String MSDS_HIERARCHY = 'msds';
    public static final String MSGP_HIERARCHY = 'msgp';
    public static final String MSIL_QUERY_HIERARCHY = 'msilQuery';
    public static final String MS_CORPORATE_HIERARCHY = 'msCorporate';
    public static final String LOYALTY_PROGRAM_HIERARCHY = 'loyaltyProgram';

    public static final String CASE_MILESTONE_FIRST_RESPONSE = 'First Response';
    public static final String CASE_MILESTONE_SUBSEQUENT_RESPONSE = 'Subsequent Response';
    public static final String CASE_MILESTONE_CASE_CLOSURE_TIME = 'Case Closure Time';
    public static final String RM_OWNER_TYPE_USER = 'User';
    public static final String RM_OWNER_TYPE_QUEUE = 'Queue';
    // Variables used in CaseAssignmentService class

    // Case Business Area Values
    public static final String SALES_CASE_BUSINESS_AREA = 'Sales';
    public static final String SERVICE_CASE_BUSINESS_AREA = 'Service';
    public static final String ACCESSORIES_CASE_BUSINESS_AREA = 'Accessories';
    public static final String LOYALTY_PROGRAM_CASE_BUSINESS_AREA = 'Loyalty Program';
    public static final String FINANCE_CASE_BUSINESS_AREA = 'Finance';
    public static final String SERVICE_WORKSHOP_CASE_BUSINESS_AREA = 'Service-Workshop';
    public static final String SERVICE_BODYSHOP_CASE_BUSINESS_AREA = 'Service-Bodyshop';
    public static final String INTERNATIONAL_MARKETING_EXPORTS_CASE_BUSINESS_AREA = 'International Marketing/ Exports';
    public static final String DOMESTIC_CASE_BUSINESS_AREA = 'Domestic';
    public static final String MIBPL_CASE_BUSINESS_AREA = 'MIBPL (Insurance)';
    public static final String SUZUKI_MOTORCYCLES_CASE_BUSINESS_AREA = 'Suzuki Motorcycles (2W)';
    public static final String INTERNAL_CASE_BUSINESS_AREA = 'Internal';
    public static final String DRIVING_SCHOOL_CASE_BUSINESS_AREA = 'Driving School';
    public static final String BUYER_CASE_BUSINESS_AREA = 'Buyer';
    public static final String SELLER_EXCHANGE_CASE_BUSINESS_AREA = 'Seller/ Exchange';
    public static final String TV_SALES_CASE_BUSINESS_AREA = 'TV Sales';
    public static final String DISTRIBUTOR_CASE_BUSINESS_AREA = 'Distributor';
    public static final String WORKSHOPS_CASE_BUSINESS_AREA = 'Workshops';
    public static final String MSDS_LOB = 'MSDS';
    public static final String NONE_CASE_BUSINESS_AREA = 'None';

    // Case Type Values
    public static final String COMPLAINT_CASE_TYPE = 'Complaint';
    public static final String DEALER_QUERY_CASE_TYPE = 'Dealer Query';
    public static final String DEALER_FEEDBACK_CASE_TYPE = 'Dealer Feedback';
    public static final String MSIL_QUERY_CASE_TYPE = 'MSIL Query';
    public static final String INTERNAL_CASE_TYPE = 'Internal';
    public static final String QUERY_FEEDBACK_CASE_TYPE = 'Query/Feedback';


    // Case Channel Values

    public static final String NEXA_CASE_CHANNEL = 'Nexa';
    public static final String ARENA_CASE_CHANNEL = 'Arena';
    public static final String COMMERCIAL_CASE_CHANNEL = 'Commercial';
    public static final String MS_CORPORATE_CASE_CHANNEL = 'MS Corporate';
    public static final String MSDS_CASE_CHANNEL = 'MSDS';
    public static final String MSGP_CASE_CHANNEL = 'MSGP';
    public static final String TRUEVALUE_CASE_CHANNEL = 'TrueValue';


    public static final String UNASSIGNED_QUEUE = 'UNA';
    public static final String SPAM_PRIMARY_CATEGORY ='Spam';
    public static final String Closure = 'Closure';
    public static final String EXCLUDED_STATUS = 'Duplicate;Transferred;Legal';
    public static final String COMPLAINT_DEALER_Closure = 'Case_Closure;Dealer_Query_Closure';
    public static final String Closure_Mode = 'Closure Mode';
    public static final String Others = 'Others';
    public static final String Resolved = 'Resolved';
    public static final String EVENT_RELATION_STATUS_NEW = 'New';
    public static final String EVENT_DELEGATION_REQUEST_STATUS_PENDING = 'Pending';
    public static final String EVENT_DELEGATION_REQUEST_STATUS_ACCEPTED = 'Accepted';
    public static final String CASEACTIONS_OBJECT = 'Case_Actions__c';
    public static final String CASE_OBJECT = 'Case';
    public static final String USER_ACCOUNT = 'User Account';
    public static final String BulkHold_OBJECT = 'Bulk_Hold_Cases__c';
    public static final String Bulk_Hold = 'Bulk Hold';
    public static final String On_Hold = 'On Hold';
    public static final String LEGAL = 'Legal';
    public static final String Recordtype_Bulk_Hold = 'Bulk_Hold';
    public static final String Recordtype_On_Hold = 'On_Hold';
    public static final String Recordtype_On_Hold_Service = 'On_Hold_Service';
    public static final String QUERY_FEEDBACK = 'Query/Feedback';
    public static final String In_Progress = 'In Progress';
    public static final String Approved = 'Approved';
    public static final String Rejected = 'Rejected';
    public static final String CASE_CLOSED = 'Closed';
    public static final String CASE_NEW_RESPONSE = 'New Response';
    public static final String CASE_CUSTOMER_RESPONSE_RECEIVED = 'Customer Response Received';
    public static final String CASE_PENDING_CUSTOMER_RESPONSE = 'Pending Customer Response';
    public static final String CASE_PENDING_MSIL_RESPONSE = 'Pending MSIL Response';
    public static final String CASE_OPEN_STAKEHOLDER_RESPONDED = 'Open - Stakeholder Responded';
    public static final String CASE_MSIL_QUERY = 'MSIL Query';
    public static final String CASE_CLOSED_REPLY_RECEIVED = 'Closed - Reply Received';
    public static final String Delay_in_RC_due_to_RTO_Issue = 'Delay in RC due to RTO Issue';
    public static final String CASE_ACTION_DUP_ERROR_MSG = ' request cannot be initiated, as it has been done already';
    public static final String Pending_Ringi_Approval = 'Pending Ringi Approval';
    public static final String SEND_BACK_TO_QUERY_MANAGEMENT_TEAM = 'Send back to Query Management Team';
    public static final String RESPONDED_VIA_SF = 'Responded Via SF';
    public static final String RESPONDED_VIA_OUTLOOK = 'Responded via Outlook/Text';
    public static final String MSIL = 'MSIL';
    public static final String QUEUE = 'Queue';
    public static final String ASSIGNMENT_QUEUE = 'Assignment_Queue';
    public static final String PENDING_CUSTOMER_RESPONSE_EMAIL_TEAM ='Pending_Customer_Response_Email_Team';
    public static final String PENDING_CUSTOMER_RESPONSE ='Pending_Customer_Response';
    public static final String PENDING_MSIL_RESPONSE ='Pending_MSIL_Response';
    public static final String NEW_LINE = '\n';
    public static final String CCP = 'CCP Escalation';
    public static final String CASE_RESOLUTION = 'Case Resolution';
    public static final String CCP_REMINDER = 'CCP Reminder';
    public static final String DEALER_RESOLUTION_ESCALATION = 'Dealer Resolution Escalation';
    public static final String CANCELLED = 'Cancelled';
    public static final String OOG = '00G';
    public static final String OO5 = '005';
    public static final String ABCDE = 'ABCDE';
    public static final String EMAIL = 'Email';
    // Feed Variables
    public static final String TEXT_POST = 'TextPost';
    public static final String AllUsers = 'AllUsers';
    public static final String CONTENT_POST = 'ContentPost';
    public static final String MSIL_BUSINESS_HOURS='MSIL Business Hours';
    //Week days
    public static final string SUNDAY='Sunday';
    public static final string MONDAY='Monday';
    public static final string TUESDAY='Tuesday';
    public static final string WEDNESDAY='Wednesday';
    public static final string ThURSDAY='Thursday';
    public static final string FRIDAY='Friday';
    public static final string SATURDAY='Saturday';

    public static final string CREATE='Create';
    public static final string MOBILE_NUMBER_CASE_FIELD='Mobile_Number__c';
    public static final string STAKEHOLDER = 'stakeHolder';
    public static final string REFNAME = 'refName';
    public static final string TSM = 'TSM';

    public static final string CRM_1_SPOCs_QUEUE ='CRM_1_SPOCs';
    
    public static final string OTP_VERIFICATION_MC_COM_TYPE = 'OTP - Verification Confirmed';

    public static final String  L3_STAKEHOLDER ='L3_Stakeholder__c';
    public static final String  L1_STAKEHOLDER ='L1_Stakeholder__c';

    public static final String  L2A ='L2A';
    public static final String  L2B ='L2B';
    public static final String  L3A ='L3A';
    

    /* MC Communication fIelds */
    public static final String  L3A_Email_FIELD ='L3A_Email__c';
    public static final String  PHONE_2_FIELD ='Phone_2__c';
    public static final String  PHONE_3_FIELD ='Phone_3__c';
    public static final String  PHONE_4_FIELD ='Phone_4__c';
    public static final String  DEALER_1_FIELD ='Dealer_Field_1__c';
    public static final String  DEALER_2_FIELD ='Dealer_Field_2__c';
    public static final String  DEALER_3_FIELD ='Dealer_Field_3__c';

    public static map<string, string> mapOfStakeholderJSONWithCaseActionFields = new map<string, string>{
            'L1' => 'L1_Stakeholder__c',
            'L1B' => 'L1B_Stakeholder__c',
            'L2A' => 'L2A_Stakeholder__c',
            'L2B' => 'L2B_Stakeholder__c',
            'L3A' => 'L3A_Stakeholder__c',
            'L4' => 'L4_Stakeholder__c',
            'L5' => 'L5_Stakeholder__c',
            'L6A' => 'L6A_Stakeholder__c',
            'L6B' => 'L6B_Stakeholder__c',
            'L7A' => 'L7A_Stakeholder__c',
            'L8A' => 'L8A_Stakeholder__c',
            'L8B' => 'L8B_Stakeholder__c',
            'L8C' => 'L8C_Stakeholder__c',
            'L8D' => 'L8D_Stakeholder__c',
            'L8E' => 'L8E_Stakeholder__c',
            'L9' => 'L9_Stakeholder__c',
            'L10' => 'L10_Stakeholder__c'
    };
    public static map<string, string> mapOfLevelWithRecipentMasterLevelFields = new map<string, string>{
            'Level 1' => 'Level_1_Cc__c;Level_1_To__c',
            'Level 2' => 'Level_2_Cc__c;Level_2_To__c',
            'Level 3' => 'Level_3_Cc__c;Level_3_To__c',
            'Level 4' => 'Level_4_Cc__c;Level_4_To__c',
            'Level 5' => 'Level_5_Cc__c;Level_5_To__c',
            'Level 6' => 'Level_6_Cc__c;Level_6_To__c'
    };
    public static map<string, string> mapOfStakeholderJSONWithBulkHoldFields = new map<string, string>{
            'L3A' => 'L3_Stakeholder__c',
            'L4' => 'L4_Stakeholder__c',
            'L5' => 'L5_Stakeholder__c',
            'L6A' => 'L6_Stakeholder__c',
            'L6B' => 'LB_Stakeholder__c',
            'L7A' => 'L7_Stakeholder__c'
    };
    public static map<string, string> mapOfStakeholderJSONWithMCComFields = new map<string, string>{
        'L3A' => 'L3A_Email__c',
        'L3B' => 'L3B_Email__c',
        'L4' => 'L4_Email__c',
        'L5' => 'L5_Email__c',
        'L6A' => 'L6A_Email__c',
        'L6B' => 'L6B_Email__c',
        'L6C' => 'L6C_Email__c',
        'L6D' => 'L6D_Email__c',
        'L6E' => 'L6E_Email__c',
        'L7A' => 'L7A_Email__c',
        'L7B' => 'L7B_Email__c',
        'L8A' => 'L8A_Email__c',
        'L8B' => 'L8B_Email__c',
        'L8C' => 'L8C_Email__c',
        'L8D' => 'L8D_Email__c',
        'L8E' => 'L8E_Email__c',
        'L9' => 'L9_Email__c',
        'L10' => 'L10_Email__c'
};

public static map<string, string> ccMap = new map<string, string>{
    'L4_Stakeholder__c' => 'L4_Stakeholder__c,L3A_Stakeholder__c',
    'L5_Stakeholder__c' => 'L5_Stakeholder__c,L4_Stakeholder__c,L3A_Stakeholder__c',
    'L6A_Stakeholder__c' => 'L6A_Stakeholder__c,L5_Stakeholder__c,L4_Stakeholder__c,L3A_Stakeholder__c',
    'L7A_Stakeholder__c' => 'L7A_Stakeholder__c,L6A_Stakeholder__c,L5_Stakeholder__c,L4_Stakeholder__c,L3A_Stakeholder__c',
    'L8A_Stakeholder__c' => 'L8A_Stakeholder__c,L7A_Stakeholder__c,L6A_Stakeholder__c,L5_Stakeholder__c,L4_Stakeholder__c,L3A_Stakeholder__c',
    'L9_Stakeholder__c' => 'L9_Stakeholder__c,L8A_Stakeholder__c,L7A_Stakeholder__c,L6A_Stakeholder__c,L5_Stakeholder__c,L4_Stakeholder__c,L3A_Stakeholder__c'
};
public static map<string, string> recordtypeNameWithMCtYPE = new map<string, string>{
    'Bulk_Hold' => 'Bulk Hold Initiation',
    'Case_Closure' => 'Complaint Closure Initiation',
    'DNE' => 'DNE Initiation',
    'Dealer_Query_Closure' => 'Dealer Query Closure Initiation',
    'Duplicate' => 'Duplicate Request Initiation',
    'Legal' => 'Legal Request Initiation',
    'MSIL_Query_Closure' => 'MSIL Query No Response Initiation',
    'MSIL_Query_Legal' => 'MSIL Query Legal Vetting Initiation',
    'NCH' => 'NCH Legal Initiation',
    'On_Hold' => 'Single Hold Service Initiation',
    'On_Hold_Service' => 'Single Hold Service Initiation',
    'Revalidation' => 'Revalidation Initiation',
    'Revalidation_Service_Product' => 'Revalidation Service Product Initiation',
    'Revalidation_Service_Unjustified' => 'Revalidation Service Unjustified SMS Initiation',
    'Service_Complaint_Closure' => 'Complaint Closure Initiation',
    'Transfer'=> 'Transfer Request Initiation'
    
};

    public static final String CASE_OWNER = 'CaseOwner';
    public static final String CALL_CENTER_MANAGER='CallCenterManager';
    public static final String MSIL_NON_SF_STAKEHOLDER='MSILNonSFStakeholder';
    public static final String CUSTOMER='Customer';

    /* MC COMMUNICATION TYPES */
    public static final String VOC_UPDATE = 'VOC Update';
    public static final String VOC_NOTIFICATION_DEALER='VOC Notification - Dealer';
    public static final String COMPLAINT_CLOSURE_DEALER='Complaint Closure - Dealer';
    public static final String COMPLAINT_CLOSURE_CUSTOMER='Complaint Closure - Customer';
    public static final String COMPLAINT_ON_HOLD_DEALER='Complaint On Hold - Dealer';
    public static final String COMPLAINT_REGISTRATION_DEALER = 'Complaint Registration - Dealer';
    public static final String COMPLAINT_REGISTRATION_CUSTOMER = 'Complaint Registration - Customer';
    public static final String FEEDBACK_REGISTRATION_DEALER = 'Feedback Registration - Dealer';
    public static final String QUERY_CLOSURE_DEALER = 'Query Closure - Dealer';
    public static final String QUERY_ASSIGNMENT_OWNER = 'Query Assignment - Owner';
    public static final String QUERY_REGISTRATION_CUSTOMER = 'Query Registration - Customer';
    public static final String QUERY_REGISTRATION_DEALER = 'Query Registration - Dealer';
    public static final String QUERY_CLOSURE_CUSTOMER = 'Query Closure - Customer';
    public static final String MSIL_QUERY_REGISTRATION_CUSTOMER = 'MSIL Query Registration - Customer';
    public static final String MSIL_QUERY_REGISTRATION_SF_STAKEHOLDER = 'MSIL Query Registration - MSIL SF';
    public static final String MSIL_QUERY_REGISTRATION_NON_SF_STAKEHOLDER = 'MSIL Query Registration - MSIL Non-SF';
    public static final String MSIL_QUERY_CLOSURE_NON_SF_STAKEHOLDER = 'MSIL Query Closure - Non SF Stakeholder';
    public static final String MSIL_QUERY_SPAM_CCM = 'MSIL Query Spam - CCM';
    public static final String RESOLUTION_CODE = 'Resolution Code';
    public static final String BULK_HOLD_UN_HOLD = 'Bulk Hold Un-hold';
     /** Spam Phone Emails record Type Ids */
    public static final Id EMAIL_SPAM_RECORD_TYPE_ID = Schema.SObjectType.Spam_Phone_Emails__c.getRecordTypeInfosByDeveloperName().get('Email').getRecordTypeId();
    public static final Id PHONE_SPAM_RECORD_TYPE_ID = Schema.SObjectType.Spam_Phone_Emails__c.getRecordTypeInfosByDeveloperName().get('Phone').getRecordTypeId();

    /** Below variables are used in CaseActionsTriggerHandler class */
    /** Case Action record Type Ids */
    public static final Id ON_HOLD_CASE_ACTION_RECORD_TYPE_ID = Schema.SObjectType.Case_Actions__c.getRecordTypeInfosByDeveloperName().get('On_Hold').getRecordTypeId();
    public static final Id TRANSFER_CASE_ACTION_RECORD_TYPE_ID = Schema.SObjectType.Case_Actions__c.getRecordTypeInfosByDeveloperName().get('Transfer').getRecordTypeId();
    public static final Id REVALIDATION_CASE_ACTION_RECORD_TYPE_ID = Schema.SObjectType.Case_Actions__c.getRecordTypeInfosByDeveloperName().get('Revalidation').getRecordTypeId();
    public static final Id CASE_CLOSURE_CASE_ACTION_RECORD_TYPE_ID = Schema.SObjectType.Case_Actions__c.getRecordTypeInfosByDeveloperName().get('Case_Closure').getRecordTypeId();
    public static final Id DUPLICATE_CASE_ACTION_RECORD_TYPE_ID = Schema.SObjectType.Case_Actions__c.getRecordTypeInfosByDeveloperName().get('Duplicate').getRecordTypeId();
    public static final Id DNE_CASE_ACTION_RECORD_TYPE_ID = Schema.SObjectType.Case_Actions__c.getRecordTypeInfosByDeveloperName().get('DNE').getRecordTypeId();
    public static final Id DEALER_QUERY_CLOSURE_CASE_ACTION_RECORD_TYPE_ID = Schema.SObjectType.Case_Actions__c.getRecordTypeInfosByDeveloperName().get('Dealer_Query_Closure').getRecordTypeId();
    public static final Id MSIL_QUERY_CLOSURE_CASE_ACTION_RECORD_TYPE_ID = Schema.SObjectType.Case_Actions__c.getRecordTypeInfosByDeveloperName().get('MSIL_Query_Closure').getRecordTypeId();
    public static final Id BULK_HOLD_CLOSURE_ACTION_RECORD_TYPE_ID = Schema.SObjectType.Case_Actions__c.getRecordTypeInfosByDeveloperName().get('Bulk_Hold').getRecordTypeId();
    public static final Id LEGAL_CASE_ACTION_RECORD_TYPE_ID = Schema.SObjectType.Case_Actions__c.getRecordTypeInfosByDeveloperName().get('Legal').getRecordTypeId();
    public static final Id NCH_CASE_ACTION_RECORD_TYPE_ID = Schema.SObjectType.Case_Actions__c.getRecordTypeInfosByDeveloperName().get('NCH').getRecordTypeId();
    public static final Id SPAM_CASE_ACTION_RECORD_TYPE_ID = Schema.SObjectType.Case_Actions__c.getRecordTypeInfosByDeveloperName().get('Spam').getRecordTypeId();
    public static final Id CCP_NOT_RESPONDED_CASE_ACTION_RECORD_TYPE_ID = Schema.SObjectType.Case_Actions__c.getRecordTypeInfosByDeveloperName().get('CCP_Not_Responded').getRecordTypeId();
    public static final Id Service_Complaint_Closure_CASE_ACTION_RECORD_TYPE_ID = Schema.SObjectType.Case_Actions__c.getRecordTypeInfosByDeveloperName().get('Service_Complaint_Closure').getRecordTypeId();
    public static final Id MSIL_QUERY_LEGAL_CASE_ACTION_RECORD_TYPE_ID = Schema.SObjectType.Case_Actions__c.getRecordTypeInfosByDeveloperName().get('MSIL_Query_Legal').getRecordTypeId();
    public static final Id REVALIDATION_SERVICE_PRODUCT_CASE_ACTION_RECORD_TYPE_ID   = Schema.SObjectType.Case_Actions__c.getRecordTypeInfosByDeveloperName().get('Revalidation_Service_Product').getRecordTypeId();
    public static final Id REVALIDATION_SERVICE_UNJUSTIFIED_CASE_ACTION_RECORD_TYPE_ID = Schema.SObjectType.Case_Actions__c.getRecordTypeInfosByDeveloperName().get('Revalidation_Service_Unjustified').getRecordTypeId();
    public static final Id ON_HOLD_SERVICE_CASE_ACTION_RECORD_TYPE_ID = Schema.SObjectType.Case_Actions__c.getRecordTypeInfosByDeveloperName().get('On_Hold_Service').getRecordTypeId();

 
    /** Case record Type Ids */ 
    public static final Id COMPLAINT_CASE_RECORD_TYPE_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Complaint').getRecordTypeId();
    public static final Id QUERY_FEEDBACK_CASE_RECORD_TYPE_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Query_Feedback').getRecordTypeId();
    public static final Id MSIL_QUERY_CASE_RECORD_TYPE_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('MSIL_Query_Internal').getRecordTypeId();
    public static final Id REPEAT_COMPLAINT_CASE_RECORD_TYPE_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Repeat_Complaint').getRecordTypeId();
    public static final Id EMAIL_CASE_CASE_RECORD_TYPE_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Email_Cases').getRecordTypeId();
    public static final Id DEALER_QUERY_FEEDBACK_CASE_RECORD_TYPE_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Query_Feedback').getRecordTypeId();

    //Added by Anas Yar Khan on 12th July
    public static final Id MOS_COMPLAINT_CASE_RECORD_TYPE_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('MOS_Complaints').getRecordTypeId();
    //*************
    public static final Id USER_ACCOUNT_RECORDTYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('User_Account').getRecordTypeId();

    public static final String CASE_ACTION_APPROVAL_STATUS_APPROVED = 'Approved';
    public static final String CASE_STATUS_TRANSFERRED = 'Transferred';
    public static final String CASE_STATUS_ON_HOLD = 'On Hold';
    public static final String CASE_STATUS_ON_DUPLICATE = 'Duplicate';
    public static final String CASE_STATUS_ON_DISCARDED = 'Discarded';

    public static final String CASE_TYPE_SERVICE = 'Service';
    public static final String ESCALATION_TYPE_TRANSFER = 'Transfer';

    public static final String NOTIFIER_L1A = 'L1A';
    public static final String NOTIFIER_L1B = 'L1B';
    public static final String NOTIFIER_L2A = 'L2A';
    public static final String NOTIFIER_L2B = 'L2B';
    public static final String NOTIFIER_L3A = 'L3A';
    public static final String NOTIFIER_L4 = 'L4';
    public static final String NOTIFIER_L5 = 'L5';
    public static final String NOTIFIER_L6A = 'L6A';
    public static final String NOTIFIER_L7 = 'L7';
    public static final String NOTIFIER_L8A = 'L8A';
    public static final String NOTIFIER_L8B = 'L8B';
    public static final String NOTIFIER_L8C = 'L8C';
    public static final String NOTIFIER_L8D = 'L8D';
    public static final String NOTIFIER_L8E = 'L8E';
    public static final String NOTIFIER_L9 = 'L9';
    public static final String NOTIFIER_L10 = 'L10';

    public static final String CASE_STATUS_RESOLVED = 'Resolved';

    /**
* Mulesoft API Headers and Keys to be used during api callouts
**/
    public static final String DEALERMAP_CODE_CONST = 'DealerMapCode';

    public static final String LOCATION_CODE_CONST = 'LocationCode';

    public static final String USER_TYPE_CONST = 'UserType';

    public static final String CHANNEL_ID_CONST = 'x-channel_id';

    public static final String CHANNEL_TOKEN_CONST = 'x-channel_token';

    //Added By-: Nishant Prajapati    7/31/2019
    public static final String CHANNEL_TRANSACTION_ID_CONST = 'x-transaction_id';

    public static final Integer DEFAULT_TIMEOUT_CONST = 40;

    public static final String API_STATUS_CONST = 'status';

    public static final String API_RESPONSE_CONST = 'Success';

    public static final String POST_REQUEST = 'POST';
    public static final String PUT_REQUEST = 'PUT';
    public static final String GET_REQUEST = 'GET';
    public static final String GET_TEST_DRIVE_SLOTS = 'Get Test Drive Slots';
    public static final String CREATE_DRIVE_SLOTS = 'Test Drive';
    public static final String CREATE_BOOKING = 'Create Booking';
    public static final String STOCK_CHECK = 'StockCheck';
    public static final String ASSET_PURCHASED = 'P';


    public static final String PROCESS_CALLBACK = 'processResponse';
    public static final String MOCK_CALLBACK = 'mockResponse';
    public static final String FORWARD_SLASH = '/';
    public static final String QUESTION_MARK = '?';
    public static final String ACCEPT_HEADER_LABEL = 'Accept';
    public static final String ACCEPT_HEADER_VALUE = 'application/json';
    public static final String AUTH_HEADER_LABEL = 'Authorization';
    public static final String CONTENT_TYPE_HEADER_LABEL = 'Content-Type';
    public static final String POWER_PARTNER = 'PowerPartner';

    public static final String VIN_NO = 'vin';
    public static final String DATE_RANGE = 'dateRange';
    public static final String MSPIN = 'mspin';
    public static final String ENQUIRY_ID = 'enquiryId';
    public static final String ORG_ID = 'orgId';
    public static final String EQUALS = '=';
    public static final String AMPERSAND = '&';
    public static final String M_ALPHABET = 'M';
    public static final String CONTACT_OBJ = 'Contact';
    public static final String IGNORE_CASE = '__TD__';
    public static final String A_ALPHABET = 'A';
    public static final String I_ALPHABET = 'I';
    public static final String IS_CHECKED = 'isChecked';
    public static final String LABEL = 'label';


    public static final String PROFILE_NAME = 'Dealer Team Leads/Managers';
    public static final String DSE_PROFILE_NAME = 'Dealer Sales Executive';

    // This variable is used in Change Owner Functionality to check restricted profile
    public static final String OWNER_CHANGE_RESTRICTED_PROFILE_NAME = 'Dealer Sales Executive';


    public static final String API_TYPE = 'apiType';
    public static final String VARIANT_CODE = 'variantCode';
    public static final String COLOR_CODE = 'colorCode';
    public static final String DEALER_MAP_CODE = 'dealerMapCode';
    public static final String LOCATION_CODE = 'locationCode';
    public static final String PARENT_CODE = 'parentCode';
    public static final String PRODUCT_TYPE = 'productType';
    public static final String CONSINGNEE_CODE = 'consingneeCode';
    public static final String USER_TYPE = 'userType';
    public static final String PRODUCT_OBJ = 'Product2';
    public static final String FUEL_TYPE_FIELD = 'fuel_type__c';
    public static final String SCHEME_MASTER = 'Scheme_Master__c';
    public static final String FAMILY = 'family';
    public static final String DISCOUNT_AMT_FIELD = 'discount_amount__c';


    //Added By-: Anuj    7/31/2019  
    /*******     START HERE     *******/

    public static String IsAccessible = 'isAccessible';
    public static String IsCreateable = 'isCreateable';
    public static String IsUpdateable = 'isUpdateable';

    public static final String YES = 'Yes';
    public static final String DEALER_QUERY = 'Dealer Query';

    public static final String GENERAL_FOLLOW_UP_TASK_REC_TYPE = 'General Follow-up';

    public static final String PRE_BOOKING_FOLLOWUP = 'Pre Booking Follow-up';
    public static final String POST_BOOKING_FOLLOWUP = 'Post Booking Follow-up';

    public static final String SALES_EXECUTIVE = 'Sales Executive';
    public static final String TEAM_LEADER = 'Team Leader';
    public static final String SHOWROOM_MANAGER = 'Showroom Manager';
    public static final String CEO = 'CEO';
    public static final String GM = 'GM';

    public static final String BLANK_VALUE = '';
    public static final String DOUBLE_BACK_SLASH = '\\';
    public static final String BACK_SLASH_DOUBLE_QUOTE = '\"';

    public static final String OPEN_DOUBLE_QUOTE_CURLY_BRACES = '"{';
    public static final String OPEN_CURLY_BRACES = '{';

    public static final String CLOSE_DOUBLE_QUOTE_CURLY_BRACES = '}"';
    public static final String CLOSE_CURLY_BRACES = '}';

    public static final String OPEN_DOUBLE_QUOTE_SQUARE_BRACKET = '"[';
    public static final String OPEN_SQUARE_BRACKET = '[';

    public static final String CLOSE_DOUBLE_QUOTE_SQUARE_BRACKET = ']"';
    public static final String CLOSE_SQUARE_BRACKET = ']';

    public static final String STDPRICEBOOK = 'Standard Price Book';

    public static final String CLOSED_FOLLOW_UP_METADATA = 'Closed_Follow_Up_Field_Label_Info';

    public static final String ACCESSORIES_SALES_CONST = 'Accessories Sales';

    public static final String ACCESSORIES_DISCOUNT_CONST = 'Accessory Discount';

    public static final String DEALER_RECORDTYPE = 'Dealer';
    public static final String OPPORTUNITY_VEHICLE_SALES_RECORDTYPE = 'Vehicle Sales';
    public static final String RETAIL_NAME = 'Retail';
    public static final String DEL_CLOSED_WON_NAME = 'Delivery/Closed Won';

    public static final String STAGE_NEW = 'New';
    public static final String STAGE_CLOSELOST = 'Closed Lost';
    public static final String STAGE_PREBOOKING = 'Pre-Booking';

    public static final String OPPORTUNITY = 'Opportunity';
    public static final String CASE_ACTIONS = 'Case_Actions__c';
    public static final String QUOTE = 'Quote';
    public static final String TEST_DRIVE = 'Test_Drive__c';
    public static final String TEST_DRIVE_SUCCESS_MESSAGE = 'Test Drive created Successfully';
    public static final String LINE_ITEM_SUMMARY_FIELD = 'Line_Item_Summary__c';

    public static final String STATUS_OPEN = 'Open';
    public static final String STATUS_COMPLETED = 'Completed';
    public static final String STATUS_APPROVED = 'Approved';
    public static final String STATUS_PENDING = 'Pending';
    public static final String STATUS_REJECTED = 'Rejected';

    public static final String FIELD_ENQUIRYSCORING = 'Enquiry_Scoring__c';
    public static final String FIELD_REASON = 'Reason__c';
    public static final String FIELD_SUBREASON = 'SubReason__c';

    public static final String FIELD_DEALERSHIP_CHANNEL = 'Dealership_Channel__c';
    public static final String FIELD_ENQ_MODEL = 'Model_Code__c';

    public static final String FIELD_VALUE_REQUESTTOLOST = 'F';
    public static final String FIELD_VALUE_ORDERBOOKING = 'Order booking';

    public static final String APPROVAR_COMMENTS = 'Submitting request for approval';

    public static final String TASK_SUBJECT = 'Request to Lost Rejected - Contact the Customer';

    public static final set<String> portalUserTitleSet = new set<String>{
            SALES_EXECUTIVE, TEAM_LEADER, SHOWROOM_MANAGER
    };
    public static final set<String> userTitleCEOGMSet = new set<String>{
            CEO, GM
    };
    public static final set<String> userTitleTSMSet = new set<String>{
            'TSM'
    };
    public static final String TSM_ROLE = 'TSM';

    /**
* Below constants referred in JSON Wrapper Used In Quote/Pre Booking 
**/
    public static final String EX_SHOWROOM_VARIANT_KEY = 'exShowRoomVariant';
    public static final String OPPORTUNITY_ID_KEY = 'opporrtunityId';
    public static final String OPPORTUNITY_INFO_KEY = 'opportunityInfo';
    public static final String SELECTED_VARIANT_KEY = 'selectedVariant';
    public static final String ADD_SCHEMES_KEY = 'addSchemes';
    public static final String EXCHANGE_BONUS_KEY = 'exchangeBonusValue';
    public static final String EXCHANGE_BONUS_DATA_KEY = 'exchangeBonusData';

    public static final String CORPORATE_DIS_VALUE_KEY = 'corporateDiscountValue';
    public static final String CORPORATE_DIS_DATA_KEY = 'corporateDiscountData';

    public static final String RURAL_OFFER_VALUE_KEY = 'ruralOffersValue';
    public static final String RURAL_DIS_DATA_KEY = 'ruralDiscountData';


    public static final String SCHEME_CODE_KEY = 'schemeCode';

    public static final String NAME_CONST = 'Name';
    public static final String PRICEBOOK2_ID_CONST = 'Pricebook2Id';
    public static final String PRICEBOOKENTRY_ID_CONST = 'priceBookEntryId';
    public static final String EMAIL_CONST = 'Email__c';
    public static final String Mobile_CONST = 'Mobile__c';
    public static final String ACCESSORIES_CREATION_CONST = 'Accessories Creation';

    public static final String OPPORTUNITY_KEY_PREFIX = '006';
    public static final String QUOTE_KEY_PREFIX = '0Q0';
    public static final String TASK_KEY_PREFIX = '00T';
    /*******     END HERE     *******/


    public static final string MARUTI_MANAGEMENT = 'Maruti_Management';
    
    /**
    * Below MAP referred in AddLineItemHelper And StockCheckCtrl cls
    **/
    public static set<String> getChannelSet(String channel){

        Set<String> channelSet = new Set<String>();

        Map<String, Set<String>> channelMap = new Map<String, Set<String>>();
        channelMap.put('Arena', new Set<String> {'NRC', 'NRM'});
        channelMap.put('Nexa', new Set<String> {'EXC'});
        channelMap.put('Commercial', new Set<String> {'NRC', 'COM'});
        channelMap.put('Maruti', new Set<String> {'EXC', 'NRM', 'COM', 'MDS', 'NRE', 'NRC'});

        if(channelMap.containsKey(channel)){
            channelSet = channelMap.get(channel);
        }

        return channelSet;
    }
    

    /**
* Below constants referred in Opportunity Trigger Handler
**/

    public static final String RESIDENCE = 'Residence';
    public static final String OFFICE = 'Office';
    public static final String BILL_TO = 'Bill To';
    public static final String SHIP_TO = 'Ship To';


    public static final String USER_ACCT_RECORDTYPE = 'User_Account';
    public static final String OPPSHARE_CONST = 'Read';
    public static final String DOUBLE_QUOTES = '"';
    public static final String COLON = ':';
    public static final String COMMA = ',';
    public static final map<string, String> channelModelMap = new map<string, String>{
            'EXC' => 'Nexa', 'NRM' => 'Arena'
    };


    /**
* Below constants referred in Signature LWC 
**/
    public static final String SIGNATURE_LABEL = 'Signature';

    /**
* Below constants referred in Generate OTP LWC 
**/
    public static final String OTPBASEVALUE_CONST = 'OTP_Base_Value__c';
    public static final String OTPGENERATED_CONST = 'OTP_Generated_Time__c';
    public static final String RECORDID_CONST = 'Id';
    public static final String TASKSUBJ_CONST = 'OTP Generated is ';
    public static final String TASKSTATUS_CONST = 'Completed';
    public static final String OTP_MC_TYPE = 'PRE-BOOKING OTP';


    /**
* Below constants referred in Customer Profile Trigger Handler
**/
    public static final String PICKLIST_DEFAULT_VALUE = 'Please Select';
    public static final String ID_CONST = 'Id';
    public static final String GENDER_CONST = 'Gender__pc';
    public static final String AADHAR_CONST = 'Aadhaar__pc';
    public static final String PAN_CONST = 'PAN__pc';
    public static final String BIRTHDATE_CONST = 'PersonBirthdate';

    //Customer Profile object fields
    public static final String CUSTOMER_FIELDCONST = 'Customer__c';
    public static final String GENDER_FIELDCONST = 'Gender__c';
    public static final String AADHAR_FIELDCONST = 'Aadhaar__c';
    public static final String PAN_FIELDCONST = 'PAN__c';
    public static final String BIRTHDATE_FIELDCONST = 'date_of_birth__c';


    public static final String OPPSTAGECHECKPREBOOKING_CONST = 'Pre-Booking';// This variable is used to check if Opp stage is Pre booking or not


    /**
* Below constants referred in Opportunity Trigger Handler in SVOC Search logic
**/
    public static final String CUSTOMER_RECORDTYPE = 'Customer';
    public static final String PROSPECT_CUSTOMER = 'Prospect';
    public static final String DUPLICATE_CUSTOMER = 'Duplicate';
    public static final String DOT_OPERATOR = '.';
    public static final String DMS_USER = 'DMS Admin';

    /**
* Below constants referred in Opportunity Trigger Handler to set Last Modified Details in setStageTime Method
**/
    public static final String STAGE_LABEL = 'Stage';
    public static final String DEALERMAPCODE_LABEL = 'Dealer_Map_Code';
    public static final String DEALERPARENTGROUP_LABEL = 'Parent_Group';
    public static final String FORCODE_LABEL = 'For_Code';
    public static final String TIMESTAMP_LABEL = 'Time_Stamp';
    public static final String PRE_BOOKING_LABEL = 'Pre_Booking_Number';
    public static final String COLOR_LABEL = 'Color_Code';
    public static final String DEALER_CODE = 'Mul_Dealer_Code';
    public static final String DMS_ENQUIRY_NUM = 'DMS_Enquiry_Name';
    public static final String RECORD_TYPE_CONST = 'Record_Type';
    public static final String DEALERLOCATIONCODE_LABEL = 'Dealer_Location_Code';
    public static final String DEALER_COMP_FA = 'Dealer_COMP_FA';
    public static final String BOOKING_NUMBER = 'Booking_Number';
    public static final String IS_FOLLOW_UP_UPDATE = 'Is_FollowUP_Update';
    public static final String DEALER_FIELD = 'Dealership__c';

    /**
* Below constants referred in Opportunity Trigger Handler while create Pre Booking Follow Ups
**/
    public static final String PREBOOKING_FOLLOWUP_PRIORITY = 'Normal';
    public static final Integer PREBOOKING_REMINDER_TIME = 30;
    public static final String PREBOOKING_FOLLOWUP_TYPE = 'T'; //Changes by Rahul to update the type field 
    public static final String GENERAL_FOLLOWUP_TYPE = 'E';


    /**
* Below constants referred in Opportunity Trigger Handler 
**/
    public static final String NEXA_LINEOFBUSINESS = 'Nexa';
    public static final String ARENA_LINEOFBUSINESS = 'Arena';
    public static final String COMMERCIAL_LINEOFBUSINESS = 'Commercial';
    public static final String ISL_LINEOFBUSINESS = 'ISL';
    public static final String RURAL_LINEOFBUSINESS = 'Rural';
    public static final String ACCESSORIES_LINEOFBUSINESS = 'Accessories';
    public static final string STAGE_BOOKING = 'Booking';
    public static final string DSE_ALLOCATION = 'DSE Allocation';
    public static final string DSE_UNTAGGED = 'DSE Untagged';
    public static final string SPOC_TO_ALLOT_DSE = 'SPOC To Allot DSE';
    public static final string TD_SURVEY_FEEDBACK = 'Test Drive Feedback';

    public static final string BILL_To_ADDRESS_LINE_FIELD = 'BillTo_Address_Line__c';
    public static final string ADDRESS_LINE_FIELD = 'Address_Line__c';

    //TEST DRIVE AND DELIVERY CHECKLIST CHECKLIST   
    public static final String SCHEDULE_START = 'Scheduled_Start__c';
    public static final String SCHEDULE_END = 'Old_Scheduled_Start_Date_Time__c';
    public static final String INVOICE_DATE = 'Invoice_Date__c';

    public static final Integer ZERO = 0;
    public static final Integer THIRTY = 30;
    public static final Integer FIFTY = 50;
    public static final Integer SIXTY = 60;

    public static final String CORP_GRP_LINE_ITEM_FIELD = 'Corporate_Group_Line_Items__c';

    //Primary TSM field API Name from Account
    public static final String PRIMARY_TSM = 'Territory_Sales_Manager__c';
    public static final String FINANCE_MANAGER = 'Finance_Manager__c';
    public static final String TSM_ISL = 'TSM_ISL__c';
    public static final String TSM_RURAL = 'TSM_Rural__c';
    public static final String TSM_MGA = 'TSM_MGA__c';
    public static final String ACCESSORIES_SPOC_1 = 'Accessories_SPOC_1__c';
    public static final String ACCESSORIES_SPOC_2 = 'Accessories_SPOC_2__c';

    //Field to add Enquiry Team Member
    public static final String ACCESSORIES_DSE = 'Accessories_DSE1__c';
    public static final String ACCESSORIES_DSE_DESIGNATION = 'MSE';

    /*
* Below constants referred in Booking BCR PDF 
**/
    public static final String BCR_FORM = 'Booking Confirmation Report';
    public static final String TERMS_N_CONDITIONS = 'Terms & Conditions';
    public static final String CUSTOMER_UNDERTAKING = 'Customer Undertaking';
    public static final String UNDER_SCORE = '_';

    public static final String VARIANT_CONST = 'Variants';
    public static final String ACCESSORIES_CONST = 'Accessories';
    public static final String COMPONENT_CONST = 'Component';
    public static final String OFFER_CONST = 'Offer';

    public static final String REGISTRATION_CONST = 'Registration';

    public static final String REGISTRATION_AMOUNT_CONST = 'Registration Amount';

    public static final String EX_WARRANTY_CONST = 'Extended Warranty';
    public static final String MCP_CONST = 'MCP';
    public static final String INSURANCE_CONST = 'Maruti Insurance';
    public static final String EX_WARRANTY_1_YR = 'Extended_Warranty_1_year__c';
    public static final String EX_WARRANTY_2_YR = 'Extended_Warranty_2_year__c';
    public static final String EX_WARRANTY_3_YR = 'Extended_Warranty_3_year__c';
    public static final String LOYALTY_AMT = 'Loyalty_Amount__c';
    public static final String ADD_COMPONENT = 'addComponent';
    public static final String YEAR_CONST = 'year';
    public static final String ADD_ACCESSORIES = 'addAccessories';


    public static final String LOYALTY_CONST = 'Loyalty';
    public static final String INSURANCE_CONT = 'Insurance';

    public static final String MUNICIPAL_CH_CONST = 'Municipal Charges';
    public static final String NUM_PLATE_CONST = 'Number Plate Charges';
    public static final String SCHEMES_CONST = 'Schemes';
    public static final String CORP_SCHEME = ';0.0';
    public static final String SEMI_COLON = ';';


    public static final String CORPORATE_DISCOUNT_CONST = 'Corporate Discount';
    public static final String EXCH_BONUS_CONST = 'Exchange Bonus';
    public static final String EXCH_VALUE_CONST = 'Exchange Value';
    public static final String OTHER_DISCOUNT_CONST = 'Other Discount';
    public static final String RURAL_OFFER_CONST = 'Rural Offers';
    public static final String EXCH_MODEL = 'Exchange_Model__c';
    public static final String EXCH_FUEL_TYPE = 'Exchange_Fuel_Type__c';
    public static final String FOR_CODE = 'For_Code__c';
    public static final String REGION_CODE = 'Region_Code__c';
    public static final String OTHER_VALUE = 'OTHERS';


    public static final String OTH_DISC_CONST = 'Other Discounts';
    public static final String ROAD_TAX_CONST = 'Road Tax';
    public static final String BTN_LABEL_CONST = 'Save & Send';
    public static final String BCR_CONST = 'BCR';
    public static final String BCR_SENT = 'Y';

    public static final String OTHER_CHARGES_CONST = 'Other Charges';

    /*
* Below contants are used in TestDriveFunctionality Class
* */
    public static final String TESTDRIVE_RECORDTYPE = 'Test Drive';
    public static final String TESTDRIVE_DEFAULT_STATUS = 'RESERVED';
    public static final String TD_RESCHEDULE = 'TD Reschedule';
    public static final String TD_PRODUCT_VARIANT_RECORDTYPE = 'Variants';


    /*
* Below contants are used in Account Trigger Handler
**/
    public static final String SVOCID_CONST = 'SVOCID';
    public static final String TIMESTAMP_CONST = 'ModifedTimeStamp';
    public static final String COUNTRY_CODE = '91';
    public static final String DEALER_ADMIN = 'Dealer Admin';
    public static final String EDIT_ACCESS = 'Edit';
    public static final String ACCOUNT_OBJ = 'Account';
    public static final String SPOC_FIELDS = 'spoc';
    public static final String BUSINESS_HRS = 'business_hours__c';
    public static final String SVOC_LSTMODIFIED = 'lastmodified_svoc_time_stamp__c';
    public static final String PERMISSION_SET_NAME = 'Dealer Manage SPOC';
    public static final String ERROR_MSG = 'Dealer admin is allowed to update only SPOC and business hours fields';

    /*
* Below contants are used in Delivery Checklist pdf
**/
    public static final String DELIVERY_PAGE_CONST = 'DeliveryChecklistPDF';
    public static final String FILE_NAME_CONST = 'Delivery Checklist';
    public static final String FIELD_CONST = 'Delivery_Checklist_Time__c';
    public static final String DELIVERY_CONST = 'Delivery';

    public static final String BLANK_SPACE = ' ';
    public static final String OPEN_BRACKET = '(';
    public static final String CLOSE_BRACKET = ')';
    public static final String NEWCAR_ENQ = 'Car';
    public static final String ACCESSORIES_ENQ = 'MSGA';

    /*
*Added By-: NISHANT
* Below contants are used in Task Trigger Handler Class
**/
    public static final String PROFILE_SYSTEM_ADMIN = 'System Administrator';
    public static final String PROFILE_INTEGRATION_USER = 'Integrations';


    /*
* Below contants are used in Delivery Checklist pdf
**/
    public static final String CLOSED_FOLLOWUP_APIKEY = 'EnquirynumberFollowupsList';

    /*
* Below contants are used in customer vehicle history
**/
    public static final String CUSTOMER_VEHICLE_HISTORY = 'Car_Details';
    /*
* Below contant IS used in UserTriggerHandler
**/
    public static final string ASYNC_APEX_BATCH = 'MapProfileToGroupBatch';
    public static final string ASYNC_APEX_BATCH1 = 'inActiveTVEvaluator';
    public static final Set<String> TSM_RURAL_DESIGNATION = new Set<String>{
            'RCS', 'RTL'
    };
    public static final Set<String> TSM_MGA_DESIGNATION = new Set<String>{
            'ACM', 'MSE', 'SMA', 'SSA'
    };
    public static final Set<String> TSM_ISL_DESIGNATION = new Set<String>{
            'CSE', 'CTL', 'NCM', 'NSC'
    };

    /*
* Below contants are used in Opportunity Trigger Handler
**/
    public static final string ACCOUNT_MASTERLABEL = 'AccountFields';


    /*
* Below contants are used in Escalation Service Class
**/
    public static final string ESCALATION_MC_TYPE = 'Escalation';
    public static final string TRANSFER_ESCALATION_MC_TYPE = 'Transfer Escalation';
    public static final string DEALER_ENQUIRY = 'Dealer';
    public static final string MARUTI_ENQUIRY = 'Maruti';
    public static final string FIRST_LEVEL_ESCALATION = 'Level 1';
    public static final string DSE_TYPE_ESCALATION = 'DSE Allocation Time';
    public static final string FOLLOWUP_ESCALATION = 'Last Follow Up Update Time';
    public static final string FOLLOWUP_CONST = 'Follow Up';
    public static final string SE_DESIGNATION = 'SAE';

    public static final string LEVEL_1 = 'Level 1';
    public static final string LEVEL_2 = 'Level 2';
    public static final string LEVEL_3 = 'Level 3';
    public static final string LEVEL_4 = 'Level 4';
    public static final string LEVEL_5 = 'Level 5';
    public static final string LEVEL_6 = 'Level 5';
    public static final string LEVEL_7 = 'Level 5';
    public static final string LEVEL_8 = 'Level 5';
    public static final string LEVEL_9 = 'Level 5';
    public static final string LEVEL_10 = 'Level 5';
    public static final String ESCALATION_TIME = 'Time_for_Next_Escalation__c';
    public static final String ESCALATION_DATE_TIME = 'Escalation_Date_Time__c';


    //Below contents are used in DefaultProductCreationScript class
    public static final String FUEL_TYPE = 'Petrol';
    public static final String CHANNEL_TYPE = 'EXC';
    public static final DATE START_DATE = System.today();
    public static final DATE END_DATE = System.today();
    public static final String MODEL = 'Nexa';


    //Below contents are used in DefaultProductCreationScript
    public static final map<string, Integer> FromAgeMap = new map<string, Integer>{
            'A' => 0, 'B' => 1, 'C' => 2, 'D' => 3
    };
    public static final map<string, Integer> ToAgeMap = new map<string, Integer>{
            'A' => 1, 'B' => 2, 'C' => 3, 'D' => 100
    };
    public static final decimal OFFER_DISCOUNT_AMT = 100000.00;
    public static final decimal ACCESSORIES_DISCOUNT_AMT = 100000.00;
    public static final String QUESTION = 'How was your experience of Test Drive';
    public static final String RESPONSE = 'No';
    public static final String SURVEY_NAME = 'Test Drive Feedback';

    //Below contents are used in Task Trigger Handler
    public static final String BANK_APPOINTMENT = 'Bank_Appointment';
    Public static final String SEND_BROCHURE = 'Brochure_Request';
    public static final String SEND_BROCHURE_METADATA = 'Send Brochure';

    //Below Contents are used in UserTrigger Handler
    public static final String USER_OBJECT = 'User';

    //used in SFMC Real Time API Integration class
    public static final String SUBSCRIBER_KEY = 'TEST-SUB-001';

    public static final String Post_Booking_Feedback = 'postBookingFeedback';

    public static final String SHOWROOM_WELCOME = 'Showroom Welcome';

    //Added by Anas Yar Khan on 12th July
    public static final Decimal ENTERED_DISTANCE = 15;
    public static final String CASE_TYPE_MOS = 'MOS';
    public static final String CASE_TYPE_NON_MOS = 'Non MOS';
    public static final String MOS_STAGE_Pending_for_Out_for_Service = 'Pending for Out for Service';
    public static final String MOS_STAGE_Out_for_Service = 'Out for Service';
    public static final String MOS_STAGE_Reached = 'Reached';
    public static final String MOS_STAGE_Resolved = 'Resolved';
    public static final String TOWING_SUB_STAGE_Pending_for_Out_for_Service = 'Pending for Out for Service';
    public static final String PRIORITY_MEDIUM = 'Medium';
    public static final String MOS_STAGE_TOWING_REQUIRED = 'Towing required';
    public static final String TOWING_SUB_STAGE_Pending_for_Allocation = 'Pending for Allocation';
    public static final String JOB_TYPE_Accidental = 'Accidental';
    public static final String MOS_CASE_STAGE_Pending_for_Allocation = 'Pending for Allocation';
    public static final String MOS_CASE_STAGE_Towing_required = 'Towing required';

    public static final Id TASK_MOS_Follow_Up_RecordType_Id = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('MOS_Follow_Up').getRecordTypeId();
    public static final String CaseObjectName = 'Case';
    public static final Integer oneMinute = 1;
    public static final String Technician_Assistance = 'Technician Assistance';
    public static final String Towing_Assistance = 'Towing Assistance';
    public static final String Job_Type_Breakdown = 'Breakdown';
    public static final String MOS_MASTER_MS_ALLIANZ = 'MS Allianz';
    public static final String Integration_User = 'DMS Admin';
    public static final String keySeparator = '#';
    public static final Id MOS_TASK_RecordType_Id = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('MOS_Task').getRecordTypeId();
    public static final String Call_Origin_Customer = 'Customer';
    public static final String Call_Direction_Outbound = 'Outbound';
    public static final String MOS_TASK_Status_Open = 'Open';
    public static final String MOS_Task_Status_Closed = 'Closed';
    public static final String MOS_Task_Status_Completed = 'Completed';
    public static final String MOS_Task_Completed = 'Completed';
    public static final String Case_Action_Escalation_Status_Active = 'Active';
    public static final String Case_Action_Escalation_Level_Amber = 'Amber';
    public static final String Case_Action_Type_MOS_followUp = 'MOS-FollowUp';
    public static final String Case_Action_Type_MOS_Allocation = 'MOS-Stage Change';

    public static final Id Case_Action_MOS_Escalation_RecordType_Id = Schema.SObjectType.Case_Actions__c.getRecordTypeInfosByDeveloperName().get('MOS_Escalations').getRecordTypeId();
    public static final String MC_Communication_Type_MOS_Escalation = 'MOS Escalations';
    public static final String MC_Communication_Status_Queued = 'Queued';
    public static final String FollowUp = 'Follow-up';
    public static final String Allocation = 'Allocation';
    public static final String Reached = 'Reach';
    public static final String Case_Action_Escalation_Status_Inactive = 'Inactive';
    public static final String MC_Communication_Status_Cancelled = 'Cancelled';
    public static final String MC_Communication_Status_Picked = 'Picked';
    public static final String Response_message_Task_Id_Missing = 'Please provide Task ID';
    public static final String Response_message_No_Task_Found = 'No Task is found with provided Task Id';
    public static final String Response_message_Success = 'Success';
    public static final String Case_Action_Type_MOS_Reach = 'MOS-Reach';
    public static final String Hypen = '-';
    public static final String MOS_FollowUp_Escalation = 'Follow Up Escalation';
    public static final String Allocation_Escalation = 'Stage Change Escalation';
    public static final String Reach_Escalation = 'Reach Escalation';
    public static final Integer Fifteen_Minutes = 15;
    public static final String mosStageValidationError = 'Only the following stages are allowed to change ';
    public static final String MOSCaseSourceMCall = 'M-Call';
    public static final String JobTypeValidationError = 'You cannot change the Job Type now. Please create a new case if a different Job Type is required';
    public static final String CustomerConsentValidationError = 'You cannot change the Customer Consent now, please change stage to Pending for Allocation';
    public static final String AllocatedDealerValidationError = 'Please change stage to Pending for Allocation before changing Allocated Dealer';
    public static final String CustomerConsentTechnicianAssistance = 'Technician Assistance';
    public static final String CustomerConsentTowingAssistance = 'Towing Assistance';   
    public static final String CaseStatusClosed = 'Closed';
    public static final String TaskCallOriginTechnician = 'Technician';
    public static final String TaskCallOriginTowingAgency = 'Towing Agency';
    public static final Integer SixtyMinutes = 60;
    public static final String PendingForAllocationQueue = 'Pending For Allocation Queue';
    public static final String OriginSalesforce = 'Salesforce';
    public static final String PRIORITY_HIGH = 'High';
    public static final String Red = 'Red';
    public static final String RedPlus = 'Red+';
    public static final String StageChanged1 = 'Stage Changed1';
    public static final String StageChanged2 = 'Stage Changed2';
    public static final String UserPrefix = '005';
    public static final String Breakdown_Case_Allocated_Customer = 'Breakdown Case Allocated: Customer';
    public static final String Breakdown_Case_Allocated_to_Technician_MCall_Dealer = 'Breakdown Case Allocated to Technician (MCall): Dealer';
    public static final String Breakdown_Case_Allocated_to_Technician_Dealer = 'Breakdown Case Allocated to Technician: Dealer';
    public static final String MOS_Case_Stage_Resolved = 'Resolved';
    public static final String MOS_Case_Stage_Resolved_On_Call = 'Resolved on Call';
    public static final String Case_Closure_Customer = 'Case Closure: Customer';
    public static final String Towing_Destination_Dealer_Customer = 'Towing Destination Dealer: Customer';
    public static final String Towing_Destination_Dealer_MCall_Dealer = 'Towing Destination Dealer (MCall): Dealer';
    public static final String Towing_Destination_Dealer_Dealer = 'Towing Destination Dealer: Dealer';
    public static final String Towing_Case_Allocated_to_Dealer_Customer = 'Towing Case Allocated to Dealer: Customer';
    public static final String Towing_Case_Allocated_to_Dealer_MCall_Dealer = 'Towing Case Allocated to Dealer (MCall): Dealer';
    public static final String Towing_Case_Allocated_to_Dealer_Dealer = 'Towing Case Allocated to Dealer: Dealer';
    public static final String Breakdown_OFS_Reminder_Technician = 'Breakdown OFS Reminder: Technician';
    public static final String Breakdown_OFS_Reminder_Mcall_Technician = 'Breakdown OFS Reminder (MCall): Technician';
    public static final String MOSCaseSourceNOTMCall = 'Not M-Call';
    public static final String SendSMSYes = 'Yes';
    public static final String Breakdown_Follow_Up_MCall_before_Allocation = 'Breakdown Follow Up (MCall) before Allocation';
    public static final String Breakdown_Follow_Up_before_Allocation = 'Breakdown Follow Up before Allocation';
    public static final String Breakdown_Follow_Up_MCall_after_Allocation = 'Breakdown Follow Up (MCall) after Allocation';
    public static final String Breakdown_Follow_Up_after_Allocation = 'Breakdown Follow Up after Allocation';
    public static final String Accidental_Follow_Up_MCall_before_Allocation = 'Accidental Follow Up (MCall) before Allocation';
    public static final String Accidental_Follow_Up_before_Allocation = 'Accidental Follow Up before Allocation';
    public static final String Accidental_Follow_Up_MCall_after_Allocation = 'Accidental Follow Up (MCall) after Allocation';
    public static final String Accidental_Follow_Up_after_Allocation = 'Accidental Follow Up after Allocation';
    public static final String Poor_Feedback = 'Poor Feedback';
    public static final String Customer_Cancelled = 'Customer Cancelled';
    public static final String Case_Cancelled_MCall = 'Case Cancelled (MCall)';
    public static final String Towing_ETA_Breach_MS_Allianz = 'Towing ETA Breach: MS Allianz';
    public static final String Towing_ETA_Breach_MCall_MS_Allianz = 'Towing ETA Breach(MCall): MS Allianz';
    public static final String Towing_ETA_Breach_MCall_Dealer = 'Towing ETA Breach (MCall): Dealer';
    public static final String Towing_ETA_Breach_Dealer = 'Towing ETA Breach: Dealer';
    public static final String Poor = 'Poor';
    public static final String Average = 'Average';
    public static final Set<String> setCancelledReason = new Set<String>{'High Charges','Delay in arrival of technician','No Response from Technician','Technician refused to attend','RO instruction (Services not available)','Not able to provide towing services','Delay in providing towing services','Towing, online payment issue','Not able to provide hydra services'};
    public static final Set<String> setPFOFS = new Set<String>{'Breakdown OFS Reminder: Technician','Breakdown OFS Reminder (MCall): Technician','Breakdown OFS  Escalation','Breakdown OFS (MCall)  Escalation','Accidental OFS Reminder: Technician','Accidental OFS Reminder (MCall): Technician','Accidental OFS Escalation (MCall) (MS Allianz)','Accidental OFS Escalation MS Allianz','Accidental OFS  Escalation','Accidental OFS (MCall) Escalation'};
    public static final Set<String> setReached = new Set<String>{'Towing ETA Breach: MS Allianz','Towing ETA Breach(MCall): MS Allianz','Towing ETA Breach (MCall): Dealer','Towing ETA Breach: Dealer'};
    public static final String FarEyeObject = 'MOS';
    public static final String sObjectTaskAPIName = 'Task';
    public static final String callOriginFieldAPIName = 'Call_Origin__c';
    public static final String callPurposeFieldAPIName = 'Call_Purpose__c';
    public static final String sendSMSFieldAPIName = 'Send_SMS__c';
    public static final String BreakdownAllocatedDealerMSAllianz = 'You cannot assign a Breakdown case to MS Allianz';
    public static final String CanNotEditClosedCase = 'You cannot edit a Closed case';
    public static final String CannotEnterETATimeInPast = 'Enter future time in ETA time';
    public static final String EscalationErrorMOS = ' are not configured correctly. Please contact your system administrator';
    public static final String RoleHOMOS = 'HO MOS';
    public static final String MSAllianzTeamLeader = 'Team Leader';
    public static final String Service = 'service';
    public static final String MOSROC = 'MOSROC';
    public static final String ChannelHead = 'Channel Head- ';
    public static final String Hierarchy = 'Hierarchy';
    public static final String Account = 'Account';
    public static final String Role = 'Role';
    public static final String Contact = 'Contact';
    public static final Set<String> setCaseTeamRoleMOS = new Set<String>{'MOS TSM','MOS ROC'};
    public static final String MOSTSMCTR = 'MOS TSM' ;
    public static final String MOSROCCTR = 'MOS ROC';
    public static final Integer Five_Minutes = 5;
    public static final Set<String> setCancelledReasonEmail = new Set<String>{'High Charges','Delay in arrival of technician','No Response from Technician','Technician refused to attend','Require services later','Customer refused to pay any kind of charges','RO instruction (Services not available)','Not able to provide towing services','Delay in providing towing services','Towing, online payment issue','Towing, NOC not available hence towing request cancelled','Not able to provide hydra services'};
    public static final String DPM_WPDCS_Role = 'DPM- WPDCS';
    public static final String TowingIsRequired = 'Towing is required';
    public static final String primaryMOSTechnician = 'PrimaryMOSTechnician';
    public static final String Level = 'level';
    public static final String SFID = 'SFID';
    public static final String BALENO = 'BALENO';
    public static final String CIAZ = 'CIAZ';
    public static final String IGNIS = 'IGNIS';
    public static final String SCROSS = 'S-CROSS';
    public static final String XL6  = 'XL6';
    public static final String CustomActivity = 'Custom_Activity__c';
    public static final String CustomActivityMOSFollowUpRecordTypeId = Schema.SObjectType.Custom_Activity__c.getRecordTypeInfosByDeveloperName().get('MOS_Follow_Up').getRecordTypeId();
    public static final String CustomActivityStatusOpen = 'Open';
    public static final String CustomActivityMOSTaskRecordTypeId = Schema.SObjectType.Custom_Activity__c.getRecordTypeInfosByDeveloperName().get('MOS_Task').getRecordTypeId();
 }