/**
 * Created by deepaksingh on 16/09/20.
 */
({
    openFile : function(component, event) {
       console.log(event.getParam('value'));
       let ids = [];
       ids.push(event.getParam('value'));
        $A.get('e.lightning:openFiles').fire({
            recordIds:  ids
        });
    }
});