public class CookieController {
    public string toPassData { get; set;}
	
    public pagereference setData(){
        Pagereference pr = new Pagereference('/apex/cookie_recieve');
        Cookie cook = new Cookie('value1', toPassData, null, -1, false);
        pr.setCookies(new Cookie[] {cook});
        return pr;
    }
}