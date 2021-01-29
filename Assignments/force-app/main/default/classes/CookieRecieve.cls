public class CookieRecieve {
    public string data { get; set;}
    
    public CookieRecieve(){
        data = apexpages.currentPage().getCookies().get('value').getValue();
        system.debug(data);
    }
}