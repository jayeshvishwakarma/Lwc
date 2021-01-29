public class LeadExtension {
    public List<Lead> lstLeads{get;set;}
    Lead objLead=new Lead();
    public LeadExtension(ApexPages.StandardController st)
    {
        lstLeads=new List<Lead>();
        lstLeads.add(objLead);
        this.objLead=(Lead) st.getRecord();
        objLead=(Lead)st.getRecord();
        lstLeads=new List<Lead>();
    }
    public void addRow()
    {
        Lead objLead=new Lead();
        lstLeads.add(objLead);
    }
    public PageReference saveRecords()
    {
        Lead objLead = new Lead();
        for(Lead objLeadTemp : lstLeads)
        {
            objLead.LastName=objLeadTemp.lastName;
             objLead.Email=objLeadTemp.Email;
             objLead.Company=objLeadTemp.Company;
            insert objLead;
        }
        return null;
    }
    
}