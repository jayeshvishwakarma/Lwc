({
	openScipt : function(cmp, recId) {
        console.log(">>>>Test1>>>");
        cmp.set('v.showMsg', false);
        cmp.set('v.showScripts', true);
        var flow = cmp.find("flowDataId");
		var inputVariables = [{
                name : 'recordId',
                type : 'String',
                value : recId
        	}];
        	flow.startFlow("Script",inputVariables);
	}
})