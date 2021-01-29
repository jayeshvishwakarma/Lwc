/**********************************************************************
 Name:  twod_GenericCrudControllerTest 
 Copyright ? 2015  Tavant Technology Inc
 ==============================================================
===============================================================
Purpose: Test class for twod_GenericCrudController
                                                     
-------                                                             
===============================================================
===============================================================
History                                                            
-------                                                            
VERSION  AUTHOR            DATE            DETAIL                         FEATURES/CSR/TTP
1.0 -    sainath 27/09/2016      INITIAL DEVELOPMENT            
***********************************************************************/
@isTest
global class twod_GenericCrudCntrlTest {



static testmethod void GenericCrudCntrlTest(){


     twod_GenericCrudCntrl GenericController = new twod_GenericCrudCntrl();
     
     String dynaQuery = 'select Id, name, description from report LIMIT 3';


        list<Account> tempAccountRecordsList = new List<Account>();       
        
        Account acc=new Account();
        acc.Name='Burlington';
        acc.BillingCity = 'test';
        acc.BillingStreet = 'test';
        acc.BillingState = 'test';
        acc.BillingPostalCode = 'test';
        insert acc;
        tempAccountRecordsList.add(acc);
        
        twod_GenericCrudCntrl.OutputWrapper crudReadWrapper = new  twod_GenericCrudCntrl.OutputWrapper();
        List<twod_GenericCrudCntrl.DMLOutputWrapper> crudWrapper = new  List<twod_GenericCrudCntrl.DMLOutputWrapper>();
        List<twod_GenericForceCntrl.DMLOutputLockWrapper> crudLockWrapper  = new List<twod_GenericForceCntrl.DMLOutputLockWrapper>();
        crudReadWrapper = twod_GenericCrudCntrl.ReadSObjects(dynaQuery); //pass string value
        crudWrapper =  twod_GenericCrudCntrl.InsertSObjects(tempAccountRecordsList);
        crudWrapper =  twod_GenericCrudCntrl.UpdateSObjects(tempAccountRecordsList);
        crudWrapper =  twod_GenericCrudCntrl.DeleteSObjects(tempAccountRecordsList);
        crudLockWrapper  = twod_GenericCrudCntrl.UpdateForceSObjects(tempAccountRecordsList);
        
 
}

}