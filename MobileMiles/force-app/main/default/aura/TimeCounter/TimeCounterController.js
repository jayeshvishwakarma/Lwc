({
    init : function(component, event, helper) {
        
        // Set the date we're counting down to
        var countDownDate = new Date("Aug 31, 2019 23:59:59").getTime();
        

        // Update the count down every 1 second
        var x = setInterval(function() {
            
            // Get todays date and time
            var dt = new Date();
            //dt.setDate(dt.getDate() - 1);
            var now = dt.getTime();
            
            // Find the distance between now and the count down date
            var distance = countDownDate - now;
            
            // Time calculations for days, hours, minutes and seconds
            var days = Math.floor(distance / (1000 * 60 * 60 * 24));
            var hours = Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
            var minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
            var seconds = Math.floor((distance % (1000 * 60)) / 1000);
            
            component.set('v.days',days);
            component.set('v.hours',hours);
            component.set('v.minutes',minutes);
            component.set('v.seconds',seconds);
                          
                          
            
            
            // If the count down is finished, write some text 
            if (distance < 0) {
            }
        }, 1000);
        
    }
})