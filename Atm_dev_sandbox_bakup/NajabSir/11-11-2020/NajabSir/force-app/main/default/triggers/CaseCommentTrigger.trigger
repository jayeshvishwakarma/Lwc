/** ---------------------------------------------------------
    Author:        Deepak Kumar
    Description:   CaseComment Trigger
    History
    Date            Author             Comments
    ----------------------------------------------------------
    24/06/2020       Deepak Kumar      Initial Release
    -----------------------------------------------------------
*/

trigger CaseCommentTrigger on CaseComment (before insert, before update, after insert, after update) {
    new CaseCommentTriggerHandler().run();
}