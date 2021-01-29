trigger LeadAsyncTriggerEvent on LeadChangeEvent (after insert) {
    system.debug('*******=>' + Trigger.New);
	// Iterate through each event message.
    for (LeadChangeEvent event : Trigger.New) {
        // Get some event header fields
        EventBus.ChangeEventHeader header = event.ChangeEventHeader;
        // For update operations, we can get a list of changed fields
        if (header.changetype == 'UPDATE') {
            if (event.Name != null) {
                System.debug('Name: ' + event.Name);
            }
        }
    }
}