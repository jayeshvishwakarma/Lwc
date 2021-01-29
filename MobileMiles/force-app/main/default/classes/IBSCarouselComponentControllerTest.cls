@isTest
public class IBSCarouselComponentControllerTest {
    @isTest static void testFetchFeedDataFromApexClass() {
        Test.setMock(HttpCalloutMock.class, new RSSFeedsMockHttpResponseGenerator());
        IBSCarouselComponentController.fetchFeedDataFromApexClass('RSSFeedsController', 'title', 'link', 'description', 'creator', 'pubDate', 'category', 'image');
    }
}