/**
* @File Name          : RedirectingPage.cls
* @Description        : This class is used to redirect to car configurator
* @Author             : Sunit Kumar Chand
* @Group              : 
* @Last Modified By   : Sunit Kumar Chand
* @Last Modified On   : 11/20/2019, 03:37:23 PM
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0    8/02/2019, 03:37:23 AM   Sunit Kumar Chand     Initial Version
* 1.1    11/20/2019, 03:37:23 AM  Sunit Kumar Chand     Add check on basic of user's Channel field
* 1.1A   03/08/2020, 03:37:23 AM  Sunit Kumar Chand     Added a profile check for Service and Insurance profile
*/ 
public  with sharing class RedirectingPage {
    public static boolean showError{get;set;}
    Public static string rtnUrl;
    
    public RedirectingPage(){
        
        User user=[Select Id,Channel__c from User where Id=:UserInfo.getUserId()];
        
        if(user.Channel__c=='Nexa'){
            rtnUrl = System.Label.Car_Configurator_URL_Nexa;
        }else{
            rtnUrl = System.Label.Car_Configurator_URL_Except_Nexa;
        }
        String profileName=StockCheckCtrl.isHostessProfile();
        System.debug(profileName);
        for(String prof:system.label.Service_and_Insurance_Profiles.split(';'))
        {
            System.debug(prof);
          if(prof==profileName || profileName == system.label.Hostess_Profile_Name || profileName==system.label.Finance_Profile_Name)
            {
                System.debug('Check'+ prof==profileName);
                showError = true;
                break;
            }else{
                showError = false;
            }  
        }
        if(user.Channel__c == 'Commercial'){
            showError = true;
        }
        
    }
    
    public static Object redirect(){
        system.debug('== showError '+showError);
        if(showError == false){
            PageReference page=new PageReference(rtnUrl);
            //page=ApexPages.currentPage();
            page.setRedirect(true);
            return page;
        }else{
            system.debug('== IN else case');
            return null;
        }
    }
    
 
}