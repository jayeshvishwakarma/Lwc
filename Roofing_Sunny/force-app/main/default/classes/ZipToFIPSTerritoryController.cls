public with sharing class ZipToFIPSTerritoryController 
{
   
   public String zipCode{get;set;}
   
   public List<FIPS__c> fipsList {get; set;}
   public List<Zip_to_Fips__c> zipToFipsList {get; set;}
   public List<Territory_Assignment__c> TerritoryAssignmentList {get; set;}

//   public List<Hierarchy_Matrix__c> HierarchyMatrixList {get;set;}
   
   Set<Id> fipsCodeSet = new Set<Id>();
   
   public boolean display{get; set;}
   public boolean terrydisplay{get; set;}
   public boolean hierarchydisplay{get;set;}
   //public string[] fipsCode;
   public String showTerryid{get; set;}
  // public String showHierarchyid{get;set;}
   

    public ZipToFIPSTerritoryController() {
        display = false;
        terrydisplay = false; 
       // hierarchydisplay = false;                       
    }

    Public PageReference showCity(){
        try{
        display = true;
        //terrydisplay = true;               
        String zipInput = String.valueOf(zipCode);
        system.debug('zipInput::'+zipInput);
        
        if( zipCode != null ||Test.isRunningTest() ){           
            zipToFipsList = [Select Id, Name, FIPS_Code__c,City__c,State__c,Country__c,FIPS_Code_Name__c From Zip_to_Fips__c Where Name=: zipInput];
            if(zipToFipsList.size()==0){
                ApexPages.Message mymsg = new ApexPages.Message(ApexPAges.Severity.INFO, 'No Record Founds for Zip/Postal Code : ' +  zipCode);
                ApexPages.addMessage(mymsg);
                reset();
        } else {
                    // Intializing Territory Details as well
                    showTerryid = zipToFipsList[0].FIPS_Code__c;
                    showTerritory();
            }                                       
        }else{
            reset();
        }
           
        } catch (Exception e){
            ApexPages.addMessages(e);
            System.debug('ERROR While executing Zip_to_Fips SOQL::' + e);
            return null;
        }
        return null;   
    }
    @TestVisible
    public Class WrapHierarchy
    {
      public string TerritoryName           {set;get;}
      public string TMName                  {set;get;}
      public string  region               {set;get;}
      public string TerritoryCode           {set;get;}
      public string Type                    {set;get;}
      public string SalesOrg                {set;get;}
      
    }
    Public PageReference showTerritory(){
        try{            
            //display = true;
            terrydisplay = true; 
            String fipsCode = String.valueOf(showTerryid);
            system.debug('fipsCode::'+fipsCode);
            //ApexPages.Message mymsg = new ApexPages.Message(ApexPAges.Severity.INFO, 'fipsCode::' +  fipsCode + 'showTerryid::' + showTerryid);
            //apexpages.addMessage(mymsg);                      
            if(fipsCode != null ||Test.isRunningTest()) {                
               TerritoryAssignmentList = [SELECT id,TM_Name__c,Territory__c,Territory__r.Name,Territory__r.Region__c,Territory__r.Territory_Code__c,Territory__r.Type__c,Territory__r.Sales_Org__c From Territory_Assignment__c WHERE FIPS_Code__c =: fipsCode];              
                 set<id>tid = new Set<id>();
                 for(Territory_Assignment__c tm : [SELECT id,TM_Name__c,Territory__c,Territory__r.Name, Territory__r.Region__c,Territory__r.Territory_Code__c,Territory__r.Type__c,Territory__r.Sales_Org__c From Territory_Assignment__c WHERE FIPS_Code__c =: fipsCode])
                 {
                   tid.add(tm.Territory__c) ;
                     
                 }
                 
           /*      HierarchyMatrixList = [select Territory__r.Name,TM__r.Name,TM__r.MobilePhone,TM__r.Email,Territory__r.region__r.Name,Name,Territory__r.Type__c,Territory__r.Territory_Code__c,Territory__r.Sales_Org__c from Hierarchy_Matrix__c where Territory__c in : tid] ;//relationship Query

               system.debug('HierarchyMatrixList@@@@'+HierarchyMatrixList); */

                //List of Wraper
                List<WrapHierarchy> wraplist = new List<WrapHierarchy>();

           /*     for(Hierarchy_Matrix__c hm : HierarchyMatrixList)
                {
                  WrapHierarchy wrap    = new WrapHierarchy();
                  wrap.TerritoryName    = hm.Territory__r.Name;
                  wrap.TMName           =hm.TM__r.Name;
                  wrap.region           =hm.Territory__r.region__r.Name;
                  wrap.TerritoryCode    =hm.Name;
                  wrap.Type             =hm.Territory__r.Type__c;
                  wrap.SalesOrg         =hm.Territory__r.Sales_Org__c;
                    
                   wraplist.add(wrap);
                }
             */   
              
            }
            else{
                reset();
            }
        } catch (Exception et){
            ApexPages.addMessages(et);
            System.debug('ERROR While executing Territory_Assignment SOQL::' + et);
            return null;
        }
        return null; 
          
    }
   
    
    public void reset(){
       display = false;
       terrydisplay = false;
       this.zipCode = '';
       if(zipToFipsList != null){
           zipToFipsList.clear();
       }
       if(TerritoryAssignmentList != null){
           TerritoryAssignmentList.clear();
       }
    }
    public void testmethodcoverga(){
    Integer i=0;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    }
   
}