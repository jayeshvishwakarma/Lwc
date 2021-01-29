({
	doInit : function(component, event, helper) {
		var label = component.get('v.label');
        var value = component.get('v.value');
        
        console.log('label==>' + label);
        console.log('value==>' + value);
        if($A.util.isEmpty(label)){
            helper.callAction( component, 'c.getFieldLabel', {
                    'objectName' : component.get('v.objectName'),
                    'fieldName'  : component.get('v.fieldName')
                }, function( data ) {
                component.set('v.label', data);
            });
        }
        helper.callAction( component, 'c.getPicklistOptions', {
            	'objectName' : component.get('v.objectName'),
            	'fieldName'  : component.get('v.fieldName'),
            'defaultSelected' : component.get('v.defaultSelected'),
            'uppercase' : component.get('v.uppercase'),
        	}, function( data ) {
            component.set('v.options', data);
        });

	}
    
})