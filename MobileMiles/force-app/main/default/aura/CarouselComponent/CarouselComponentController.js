({
    doInt : function(component, event, helper) {
        
        var sliderMap = component.get("v.sliderMap");
        
        var titles = sliderMap.value[0].Title__c.split(',');
        if(titles.length > 1){
            sliderMap.value[0].Title1__c = titles[0];
        	sliderMap.value[0].Title2__c = ', '+ titles[1];
        } else
            sliderMap.value[0].Title1__c = titles[0];
        
        console.log(sliderMap.value[0].Title1__c);
        component.set("v.sliderlist", sliderMap.value);
       /* var countDiv = [];
        for(var index = sliderMap.value.length; index < 3; index++ ){
            countDiv.push(index);
        }
        component.set("v.slideCount",countDiv); 
        if(sliderMap.value.length < 3)
            component.set("v.slideMinThree",true);*/
    }
})