({
	//Open URL in New Browser Tab
    handleOpenPDF : function(component, event, helper) {
        var type = component.get("v.content.tileContent.Type__c");
        var urlPath = '';
        console.log('00000 ' + type);
        if(type == ' PDF'){
            urlPath = '';
        }
        urlPath = urlPath + component.get("v.content.tileContent.PDF__c");
        //window.open('/resource/TileContent/1.pdf', '_blank');
        window.open(urlPath, '_blank');
    },
})