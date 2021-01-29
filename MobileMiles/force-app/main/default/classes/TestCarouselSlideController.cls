@isTest
public class TestCarouselSlideController {
	@testSetup
    private static void createRecords(){
        List<Carousel_Slides__c> listOfCarouselSlides = new list<Carousel_Slides__c>();
   		listOfCarouselSlides.add(new Carousel_Slides__c(Image_Url__c='https://brandmark.io/logo-rank/random/pepsi.png',
                                                        Description__c ='test', Title__c='test'));
        listOfCarouselSlides.add(new Carousel_Slides__c(Image_Url__c='https://brandmark.io/logo-rank/random/pepsi.png',
                                                        Description__c ='test', Title__c='test'));
        insert listOfCarouselSlides;
    }
    @isTest
    public static void testCarouselImage(){
        CarouselSlideController.CarouselImage();
    }
}