@istest
public class twod_TerritoryMangerTest {
    
    public static void init(){
        County_Codes__c county=new County_Codes__c();
        county.County_Code__c=100;
        county.Zip_code__c='36003';
        county.State__c='AL';
        insert county;
        
        Region__c reg=new Region__c();
        reg.Name='Canada';
        insert reg;
        
        Territory__c ter=new Territory__c();
        ter.Territory_Code__c='123';
        ter.Region__c=reg.Id;
        insert ter;
        
        county=new County_Codes__c();
        county.County_Code__c=0;
        county.Zip_code__c='A1A1A1';
        county.State__c='AB';
        insert county;
        
        FIPS_Codes__c fips=new FIPS_Codes__c();
        fips.FIPS_Code__c=10100;
        fips.Residential_territory_code__c='123';
        fips.State_Codes__c='AL';
        insert fips;
    }
    public static testmethod void testOne(){
        init(); 
        string sc = '(AL)';
        string zc = '36003-36003';
        string pt = 'Residential';
        string cn = 'United States';
        twod_TerritoryManger tm = new twod_TerritoryManger();
        tm.populateTM(sc, zc, pt, cn);
    }
    
    public static testmethod void testTwo(){
        init();
        string sc = 'AB';
        string zc = 'A1A1A1-A1A1A1';
        string pt = 'Residential';
        string cn = 'Canada';
        twod_TerritoryManger tm = new twod_TerritoryManger();
        tm.populateTM(sc, zc, pt, cn);
    }
    
    public static testmethod void testThree(){
        init();
        string sc = 'AB';
        string zc = 'A1A1A1-A1A1A1';
        string pt = 'Commercial';
        string cn = 'Canada';
        twod_TerritoryManger tm = new twod_TerritoryManger();
        tm.populateTM(sc, zc, pt, cn);
        id tid = 'a0hd0000005SzX6';
        twod_TerritoryManger.returnTM(tid);
    }
    
    /*public static testmethod void testFour(){
        string sc = 'AL';
        string zc = '36003';
        string pt = 'Commercial';
        string cn = 'United States';
        twod_TerritoryManger tm = new twod_TerritoryManger();
        tm.populateTM(sc, zc, pt, cn);
    }*/
}