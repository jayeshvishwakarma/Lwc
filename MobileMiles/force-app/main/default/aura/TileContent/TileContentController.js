({
	doInit : function(component, event, helper) {
		helper.fetchData(component, helper);
	},
    handleComponentEvent : function(cmp, event) {
        var message = event.getParam("keywords");
		console.log('--' + message);
        var contentList = cmp.get("v.contentsList");
        contentList.forEach(function(element) {
            console.log(element.tileContent.Name.indexOf(message));
            if(element.tileContent.Name.toLowerCase().indexOf(message.toLowerCase()) >= 0){
                element.isVisible = true;
            }else{
                element.isVisible = false;
            }
            
        });
        cmp.set("v.contentsList", contentList);
        // set the handler attributes based on event data
        /*cmp.set("v.messageFromEvent", message);
        var numEventsHandled = parseInt(cmp.get("v.numEvents")) + 1;
        cmp.set("v.numEvents", numEventsHandled);*/
    }
})