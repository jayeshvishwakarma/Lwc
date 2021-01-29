/*
        Name        :    ContactUsControllerTest
        Date        :
        Author      :
        Descriptio  :    This Test class is used for ContactUsController
*/
@isTest
public class ContactUsControllerTest{
    @isTest
    public static void test1(){
        Case c = new Case();
        c.Subject = 'TestSubject';
        c.SuppliedCompany = 'TestCompany';
        c.SuppliedName = 'TestName';
        c.SuppliedEmail = 'Test@gmail.com';
        c.SuppliedPhone = '12345';
        c.description = 'TestDescription';
        c.recordtypeid = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Contactformulier').getRecordTypeId();
        insert c;
        ContactUsController cuc = new ContactUsController();
        cuc.saveLead();
    }
    
}