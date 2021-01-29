/***************************************************************** 
Purpose: get Carousel_Slides__c object data for show Carousel .
Parameters:None
Returns: Map < Integer, list<Carousel_Slides__c>> 
Throws [Exceptions]: None                                                          
*******************************************************************/
public class CarouselSlideController {
 @AuraEnabled   
    public static Map < Integer, list<Carousel_Slides__c>> CarouselImage(){
        Map < Integer, List<Carousel_Slides__c> > mapofCarouselSlide = new  Map < Integer, list<Carousel_Slides__c> > ();
        integer index=0;
        integer sliderCount=0;
        for(Carousel_Slides__c slider: [SELECT id,Description__c,Image_Url__c,Title__c,Website_URL__c from Carousel_Slides__c order by Sort_Order__c]){
            List<Carousel_Slides__c> listOfCarouselSlides = new list<Carousel_Slides__c>();
            if(mapofCarouselSlide.containsKey(index)){
                listOfCarouselSlides = mapofCarouselSlide.get(sliderCount);
            }
              listOfCarouselSlides.add(slider);
               mapofCarouselSlide.put(index, listOfCarouselSlides);
               index++;
        }
        return mapofCarouselSlide;
    }
}