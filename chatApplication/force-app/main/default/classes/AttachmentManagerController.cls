public class AttachmentManagerController {
    
    public List<ContentDocument> lstContentDocuments{get;set;}
    public List<ContentDocumentLink> lstContentDocumentlinks{get;set;}
    
    //public Contact objContact{get;set;}
    //public OpportunityContactRole objOpportunityContactRole{get;set;}
    
    public Boolean tableView{get;set;}
    public Boolean tableView2 {get;set;}
    
    public String sentIdToCopy{get;set;}
    public String sentId{get;set;}
    public String sentIdToDelete{get;set;}
    public String SentIdContact{get;set;}
    
    public INTEGER search{get;set;}
    
    Private Map<INTEGER,STRING> mapOfSelectOption{get;set;}
    
    private static String strquery='SELECT Id,Title,FileType,ContentSize,ParentId,OwnerId FROM ContentDocument';
    private static String strQuery2='SELECT ContentDocument.Id,ContentDocument.Title,ContentDocument.FileType,LinkedEntityId FROM ContentDocumentLink';
    
    public AttachmentManagerController()
    {
        search=0;
        System.debug('Constructor chala');
        lstContentDocuments=Database.query(strQuery);
        tableView=true;
        tableView2=False;
        mapOfSelectOption = new Map<Integer,String>();
        
        mapOfSelectOption.put(1, 'ACCOUNT');
        mapOfSelectOption.put(2, 'CONTACT');
        mapOfSelectOption.put(3, 'OPPORTUNITY');
        mapOfSelectOption.put(4,'LEAD');
        
       // objContact=new Contact();
        //objOpportunityContactRole=new OpportunityContactRole();
    }
    
    public List<SelectOption> getAccountNames()
    {
        List<SelectOption> AccountNames=new List<SelectOption>();
        AccountNames.add(new SelectOption('','Accounts'));
        for(Account acc : [SELECT id, Name FROM Account])
        {
            AccountNames.add(new SelectOption(acc.id,acc.Name));
        }
        return AccountNames;
    }
    
    public List<SelectOption> getContacts()
    {
        List<SelectOption> Contacts=new List<SelectOption>();
        Contacts.add(new SelectOption('','Contacts'));
        for(Contact objCon : [SELECT id,Name FROM Contact])
        {
            Contacts.add(new SelectOption(objCon.id,objCon.Name));
        }
        return Contacts;
    }
    
    public void copyTo()
    {
            System.debug('Copy To Chala');
            System.debug('CheckBox Wali ids'+sentIdToCopy);
            System.debug('Account wali id '+sentId);
            System.debug('Contact Wali id :'+SentIdContact);
            
            List<Id> strOfIds2=sentIdToCopy.split(' ');
            
            System.debug('Ids '+strOfids2);
            
            lstContentDocuments=[SELECT id,FileType,ParentId,Title FROM ContentDocument WHERE id IN :strOfIds2];
            
            Set<Id> SetIdsOfContentDocument=new Set<ID>();
            
            System.debug('List ' +lstContentDocuments);
            
            List<ContentDocument> lstContentDocumentClone=lstContentDocuments.clone();
            
            for(ContentDocument Cd: lstContentDocuments)
            {
                SetIdsOfContentDocument.add(cd.id);
            }
            List<ContentVersion> lstContentVersionsNew=new List<ContentVersion>();
            
            for(ContentDocument objCd : lstContentDocumentClone)
            {
                
                objCd.id=null;
                ContentVersion objContentVersion=new ContentVersion(PathOnClient=objCd.Title,VersionData=Blob.valueOf(ObjCd.FileType),ContentLocation='S',Title=objCd.Title);
                lstContentVersionsNew.add(objContentVersion);
            }
            DataBase.insert(lstContentVersionsNew);
            
            System.debug('New Content Version '+lstContentVersionsNew);
            
            Set<Id> contentVersionIds=new Set<ID>();
            
            for(ContentVersion obj : lstContentVersionsNew)
            {
                contentVersionIds.add(obj.id);
            }
            
            List<ContentVersion> lstContentDocumentIdsFromContentVersion=[SELECT ContentDocumentId FROM ContentVersion WHERE id IN :contentVersionIds];
            
            System.debug('Content Version Id '+lstContentDocumentIdsFromContentVersion);
            
            List<ContentDocumentLink> lstContentDocumentLinksNew=new List<ContentDocumentLink>();
            
            if(sentId!=null)
            {
                for(ContentVersion objCV : lstContentDocumentIdsFromContentVersion)
                {
                    ContentDocumentLink cDocLink = new ContentDocumentLink();
                    cDocLink.ContentDocumentId = objCV.ContentDocumentId;//Add ContentDocumentId
                    cDocLink.LinkedEntityId =sentId;//Add attachment parentId
                    lstContentDocumentLinksNew.add(cDocLink);
                }
                Database.insert(lstContentDocumentLinksNew);
                System.debug('Inserted : '+lstContentDocumentLinksNew);
            }
            
            if(SentIdContact!=null)
            {
                for(ContentVersion objCV : lstContentDocumentIdsFromContentVersion)
                {
                    ContentDocumentLink cDocLink = new ContentDocumentLink();
                    cDocLink.ContentDocumentId = objCV.ContentDocumentId;//Add ContentDocumentId
                    cDocLink.LinkedEntityId =SentIdContact;//Add attachment parentId
                    lstContentDocumentLinksNew.add(cDocLink);
                }
                Database.insert(lstContentDocumentLinksNew);
                System.debug('Inserted : '+lstContentDocumentLinksNew);
                
            }
            List<ContentDocument> lstContentDocument=[SELECT Id,Title,FileType,ContentSize,ParentId
                                                      FROM ContentDocument
                                                     ];
            
            //System.debug(lstContentDocument.size());
            
            System.debug('INserted');
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Your Attachment Copied')); 
        
    }
    
    public void searchByOption()
    {
        System.debug(search);
        if(search==0)
        {
            lstContentDocuments=Database.query(strquery);
            TableView=True;
            TableView2=False;
            return;
        }
        lstContentDocumentLinks=Database.query(strquery2+' WHERE LinkedEntityID IN (SELECT ID FROM '+mapOfSelectOption.get(search)+')');
        
        if(lstContentDocumentLinks.size()>0)
        {
            tableView2=True;
            tableView=false;
        }else
        {
            tableView=false;
            tableView2=false;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'NO Record Found'));
        }
    }    
    
    public void deleteAttachment()
    {
        //System.debug('Id:' +sentIdToDelete);
        List<Id> lstIds=sentIdToDelete.split(' ');
        Database.Delete(lstIds);
       ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Record Deleted'));
    }
}