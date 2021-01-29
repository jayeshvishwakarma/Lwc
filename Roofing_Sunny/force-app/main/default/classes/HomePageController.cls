public with sharing class HomePageController {
    public User loggedinUserInfo{get;set;}
    public HomePageController(){
        loggedinUserInfo = UtilityClass.userDetail;
    }
    
    public Pagereference redirectToHome(){
        Pagereference pg = new Pagereference('http://htmlz.com/certainteed/index.html');
        return pg;
    }
    
    public void doNothing() {
        
    }
}