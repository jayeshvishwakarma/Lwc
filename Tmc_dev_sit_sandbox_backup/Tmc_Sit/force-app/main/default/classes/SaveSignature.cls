/**
* @File Name          : SaveSignature.cls
* @Description        : This class saves the signature as a file under a record
* @Author             : 
* @Group              : 
* @Last Modified By   : Prabhat Sharma
* @Last Modified On   : 06-Aug-2019, 10:05:33 AM
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                    Modification
*==============================================================================
*  1.0    8/06/2019, 9:14:54 PM      Prabhat Sharma              Initial Version
**/

//CODE REVIEWED BY: Prabhat Sharma

public with sharing class SaveSignature {
    
    /**
        Author: Prabhat Sharma
        Company: Techmatrix
        Description: This method will save the signature as a file under the record  
        Inputs: Signature body as base64 encoded and record Id under which the Signature will be saved as a file
        Returns: void
        History:
        ================
        1.0     06 Aug 2019      Prabhat     Initial Version
	**/
    @AuraEnabled
    public static void saveSignatureMethod(String signatureBody , string recordId){
        try{ 
            //Creating Salesforce File
            ContentVersion content = new ContentVersion();
            content.title = ConstantsUtility.SIGNATURE_LABEL;  //File Name
            content.VersionData = EncodingUtil.base64Decode(signatureBody);  //File body
            content.PathOnclient = ConstantsUtility.SIGNATURE_LABEL+'.png';  //File extension   
            insert content;
            
            //Content document for linking the file to parent entity
            ContentDocumentLink docLink = new ContentDocumentLink();
            //Fetch ContentdocumentId from Content Version 
            docLink.ContentDocumentId = [select Id,ContentDocumentId from ContentVersion WHERE Id =:content.Id].ContentDocumentId;
            docLink.LinkedEntityId = recordId; //Id of the parent record
            docLink.ShareType = 'I'; //Inferred Permission. Determined by the user's access to parent record.
            insert docLink;
        }catch(System.DmlException ex){  
            ExceptionHandler.LogError('SaveSignature', 
                                      ex.getMessage(),
                                      'Opportunity', 
                                      recordId, null);
            throw new dmlException('Error: '+ex.getMessage());
        }
        
    }
    
}