public class TestController {
    
    public String imageurl{get;set;}
    public TestController(){
   // each time we create unique code for barcode to generate unique barcode each time.
        string data = uniquecode();
        System.debug(data);
        imageurl = 'https://barcode.tec-it.com/barcode.ashx?data='+data+'&code=Code39&multiplebarcodes=false&translate-esc=false&unit=Fit&dpi=96&imagetype=Gif&rotation=0&color=%23000000&bgcolor=%23ffffff&qunit=Mm&quiet=0';
}
   public static string uniquecode()
    {
       final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
       String guid = '';
       while (guid.length() < 5) {
       Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
       guid += chars.substring(idx, idx+1);
      }
    return guid;
   }
}