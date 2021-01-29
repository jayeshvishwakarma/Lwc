public class PVOaanmaken{

    public Opportunity opp{ get; set; }    

    public PVOaanmaken(apexpages.StandardController controller) {
        opp = (Opportunity) controller.getRecord();        
    }
    public PageReference updatePVOAanmaken(){
        opp.PVO_aanmaken__c = true;
        update opp;
        
        PageReference reference=new PageReference('/'+opp.id);
        reference.setRedirect(false);
        return reference;
    }
}