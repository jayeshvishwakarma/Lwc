/*********************************************************************************
* Test Class: {TestNewNote}
* Created by {DateCreated 12/02/2014}
----------------------------------------------------------------------------------
* Purpose/Methods:
* - {Code coverage of NewNote.cls}
----------------------------------------------------------------------------------
* Utility Test Data: {TestClassUtility.cls}
----------------------------------------------------------------------------------
* History:
* - VERSION DEVELOPER NAME DATE DETAIL FEATURES
1.0 Madan 12/02/2014 INITIAL DEVELOPMENT
2.0 Name MM/DD/YYYY UDAC WIRE FRAME CHANGES
*********************************************************************************/

@isTest
private class TestNewNote {

    static testMethod void myUnitTest() {
        NewNote noteObj = new NewNote();
        
        PageReference pr = noteObj.createNewRecord();
        pr = noteObj.deleteRecord();
        pr = noteObj.doSave();
        
        Apexpages.currentPage().getParameters().put('fromPCR','testMv');
        Apexpages.currentPage().getParameters().put('parentid','testParentId');
        Apexpages.currentPage().getParameters().put('parentName','test');
        Apexpages.currentPage().getParameters().put('retURL','testUrl');
        
        NewNote noteObj2 = new NewNote();
        noteObj2.selectedRecordId = 'test';
        noteObj2.isNewNote = true;
        Note noteOb = new Note();
        noteOb.body = 'test';
        noteObj2.noteOb = noteOb;

        pr = noteObj2.doSave();
        pr = noteObj2.createNewRecord();
        pr = noteObj2.deleteRecord();
        pr = noteObj2.doSave();
    }
}