/**
 * @File Name          : ClosedFollowUps_JSON_STRUCTURE.cls
 * @Description        : This class is used to hold JSON structrue for Closed Task of General Follow Up.
 * @Author             : Anuj Kumar
 * @Group              : 
 * @Last Modified By   : Anuj Kumar
 * @Last Modified On   : 25-10-2019
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                Modification
 *==============================================================================
 * 1.0    25-10-2019 01:20 PM          Anuj Kumar            Initial Version
**/

Public WithOut Sharing Class ClosedFollowUps_JSON_STRUCTURE{
    
    
    // FollowUp Remarks
    public String Remarks;
    
    // ENQUIRY DMS Number
    public String EnquiryNumber;
    
    // Task ReminderDatetime
    public String ReminderDatetime;
    
    // Task DueDate
    public String DueDate;
    
    // ENQUIRY Stage
    public String EnquiryStage;
    
    // FollowUp Type
    public String Type;
    
    // Followup Status 
    public String FollowupStatus;
    
    // Task AssignedTo
    public String AssignedTo;
    
}