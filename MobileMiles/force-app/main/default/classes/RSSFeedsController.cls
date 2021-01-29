/**
* Name				: RSSFeedsController
* Description		: This Controller is use to fetch the RSS Feeds from the cspreporter.
* Author			: Aslam Bari (iBirds Services)
* Date				: 29 May, 2020
**/
public class RSSFeedsController implements IBSCarouselClassInterface{
    public static List<Map<String, String>> getDataListMap(){
        
        String url = Label.RSSFeedsURL;
        List<Map<String, String>> mapOfItemsOfRSSFeed = new List<Map<String, String>>();
        Map<String, String> mapOfItems = new Map<String, String>();
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        // url that returns the XML in the response body  
        
        req.setEndpoint(url);
        req.setMethod('GET');
        HttpResponse res = h.send(req);
        
        String xml = res.getBody();
        
        //Commented on 10/26/2020 due to issue in XML parsing due to change in XML body
        //Convert the CDATA to the normal nodes so that parsing can read the node.        
        /*String encoded = EncodingUtil.urlEncode(xml,'UTF-8');
        encoded = encoded.replaceAll('%3C%21%5BCDATA%5B',''); // i.e. '<![CDATA['
        encoded = encoded.replaceAll('%5D%5D%3E',''); // i.e. ']]>'
        xml = EncodingUtil.urlDecode(encoded,'UTF-8');*/
        
        Dom.Document doc = new Dom.Document();
        doc.load(replaceCDATA(res.getBody()));
        //doc.load(xml);
        
        Dom.XMLNode rss = doc.getRootElement();
        for(Dom.XMLNode child : rss.getChildren()) {
            for(Dom.XMLNode channel : child.getChildren()) {
                if(channel.getName() == 'item') {
                    mapOfItems = new Map<String, String>();
                    for(Dom.XMLNode items : channel.getChildren()){
                        
                        if(String.isNotBlank(items.getName()) && (items.getName() != 'category' && items.getName() != 'pubDate')){
                            mapOfItems.put(items.getName(), String.isNotBlank(items.getText()) ? items.getText() : ' ');
                        }else if(items.getName() == 'category' && items.getName() != 'pubDate'){
                            
                            if(mapOfItems.containsKey('category')){
                                String value = mapOfItems.get('category') + ','+ items.getText();
                                mapOfItems.put(items.getName(), value);
                            }else{
                                mapOfItems.put(items.getName(), items.getText());
                            }
                            
                        }else if(items.getName() == 'pubDate' && String.isNotBlank(items.getText())){
                            
                           	String pubDate = items.getText().contains('+') ? items.getText().substring(0, items.getText().indexOf('+')) : items.getText();
                        	mapOfItems.put(items.getName(), pubDate);
                        }
                        
                    }
                    mapOfItemsOfRSSFeed.add(mapOfItems);
                }
            }
        }
        return mapOfItemsOfRSSFeed;
    }
    
    Private static String replaceCDATA(String str) {
        Pattern p = Pattern.compile('<!\\[CDATA\\[(.*?)\\]\\]>');
        Matcher m = p.matcher(str);
        while(m.find()) {
            str = str.replace(m.group(), m.group(1).escapeXml());
        }
        return str;
    }
}