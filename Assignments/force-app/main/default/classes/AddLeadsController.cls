/* Name : AddLeadsController
* Author : Jayesh Vishwakarma
* Date : 24 march 2020
* Description : This controller is used take list of Leads from page and add the Leads.
* */


public class AddLeadsController {
    
    public List<Lead> lstLeads{get;set;}
    //Lead objLead=new Lead();
    public addLeadsController()
    {
        lstLeads=new List<Lead>();
        lstLeads.add(new Lead());
    }
    public void addRow()
    {
        //Lead objLead=new Lead();
        lstLeads.add(new Lead());
    }
    public PageReference saveRecords()
    {
        try{
            Set<String> setEmails= new Set<String>();                
            for(Lead objLead : lstLeads)
            {
                setEmails.add(objLead.Email);
            }
            List<Lead> lstUpdateLeads=new List<Lead>();
            List<Lead> lstInsertLeads=new List<Lead>();
            List<Lead> lstDuplicateEmails=[SELECT Email,lastName,company 
                                           FROM Lead 
                                           WHERE Email IN : setEmails
                                          ];
            
            if(lstDuplicateEmails.size()>0){
                for(Lead objLead1 : lstLeads){
                    for(Lead objLead2 : lstDuplicateEmails){
                        if(objLead1.Email==objLead2.Email){
                            objLead2.lastName=objLead1.LastName;
                            objLead2.company=objLead1.Company;
                            lstUpdateLeads.add(objLead2);
                        }else{                      
                            lstInsertLeads.add(objLead1);
                        }
                    }
                }
                if(lstUpdateLeads.size()>0)
                {
                    database.update(lstUpdateLeads);
                    ApexPages.Message myMsg1 = new  ApexPages.Message(ApexPages.Severity.INFO,'Your Records Are Updated and Saved');
                    ApexPages.addMessage(myMsg1);
                }
                if(lstInsertLeads.size()>0)
                {
                    database.Insert(lstInsertLeads);
                    ApexPages.Message myMsg = new  ApexPages.Message(ApexPages.Severity.INFO,'Your Records Are Saved');
                    ApexPages.addMessage(myMsg);
                }
            }else{
                database.insert(lstLeads);
                ApexPages.Message myMsg3 = new  ApexPages.Message(ApexPages.Severity.INFO,'Your New Records Are Saved');
                ApexPages.addMessage(myMsg3);
            } 
            return null;
        }
        catch(Exception objException)
        {
            ApexPages.Message myMsg = new  ApexPages.Message(ApexPages.Severity.ERROR,'Your Records Are Not Saved');
            ApexPages.addMessage(myMsg);
            System.debug(objException);
            return null;
        }
    }
    
    public void clearPage()
    {
        Lead objLead=new Lead();
        objLead.LastName='';
        objLead.Email='';
        objLead.Company='';
    }
}