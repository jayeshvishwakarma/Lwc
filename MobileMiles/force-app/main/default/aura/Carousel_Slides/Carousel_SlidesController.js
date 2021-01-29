({
    doInt : function(component, event, helper) {
        var carouselMap = component.get("c.CarouselImage");
        carouselMap.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                var storeResponse = response.getReturnValue();            
                var countSlider = [];
                var carouselSliderMap = [];
                
                if (storeResponse == null) {
                    
                } else {
                    for (var key in storeResponse ) {
                        console.log('--' + key + '=' + storeResponse[key].Title__c);
                        carouselSliderMap.push({value:storeResponse[key], key:key});
                        countSlider.push(key);
                    }
                    component.set("v.carouselMap", carouselSliderMap);
                    component.set("v.countSlider", countSlider);
                    
                }
            }
        });
        $A.enqueueAction(carouselMap);
        
        $('#carouselExample').on('slide.bs.carousel', function (e) {
            
            
            var $e = $(e.relatedTarget);
            var idx = $e.index();
            var itemsPerSlide = 3;
            var totalItems = $('.carousel-item').length;
            
            if (idx >= totalItems-(itemsPerSlide-1)) {
                var it = itemsPerSlide - (totalItems - idx);
                console.log('--'+ totalItems + '---' + idx);
                for (var i=0; i<it; i++) {
                    console.log('--'+i + '===' + it);
                    // append slides to end
                    if (e.direction=="left") {
                        $('.carousel-item').eq(i).appendTo('.carousel-inner');
                    }
                    else {
                        $('.carousel-item').eq(0).appendTo('.carousel-inner');
                    }
                }
            }
        });
        
        
        $('#carouselExample').carousel({ 
            interval: 6000
        });
        
        
        $(document).ready(function() {
            /* show lightbox when clicking a thumbnail */
            $('a.thumb').click(function(event){
                event.preventDefault();
                var content = $('.modal-body');
                content.empty();
                var title = $(this).attr("title");
                $('.modal-title').html(title);        
                content.html($(this).html());
                $(".modal-profile").modal({show:true});
            });
            
        });
    },
    
})