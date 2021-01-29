@isTest
global class RSSFeedsMockHttpResponseGenerator implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        System.assertEquals('https://cspreporter.nl/feed/?post_type=storingen', req.getEndpoint());
        System.assertEquals('GET', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('<?xml version="1.0" encoding="UTF-8"?><rss version="2.0" xmlns:content="http://purl.org/rss/1.0/modules/content/" xmlns:wfw="http://wellformedweb.org/CommentAPI/" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:atom="http://www.w3.org/2005/Atom" xmlns:sy="http://purl.org/rss/1.0/modules/syndication/" xmlns:slash="http://purl.org/rss/1.0/modules/slash/"><channel><title>storingen – CSP Reporter</title><atom:link href="https://cspreporter.nl/feed/?post_type=storingen" rel="self" type="application/rss+xml" /><link>https://cspreporter.nl</link><description>Storingen en onderhoudswerkzaamheden</description><lastBuildDate>Thu, 28 May 2020 16:26:55 +0000</lastBuildDate><language>en-US</language><sy:updatePeriod>hourly</sy:updatePeriod><sy:updateFrequency>1</sy:updateFrequency><generator>https://wordpress.org/?v=5.1</generator><item><title>Fiber regio Noord Holland</title><link>https://cspreporter.nl/storingen/fiber-regio-alkmaar/</link><pubDate>Fri, 15 May 2020 10:45:59 +0000</pubDate><dc:creator><![CDATA[CSP Reporter]]></dc:creator><category><![CDATA[KPN Fiber (FTTO, WEAS)]]></category><category><![CDATA[KPN WOK]]></category><guid isPermaLink="false">http://cspreporter.nl/?post_type=storingen&amp;p=15542</guid><description><![CDATA[— afmelding 15-05-2020 18:15 uu -->]]></description><content:encoded><![CDATA[<p>— afmelding 15-05-2020 18:15 uur —</p>]]></content:encoded></item></channel></rss>');
        res.setStatusCode(200);
        return res;
    }
}