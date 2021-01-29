/**
* @File Name          : CaseRedirectController.cls
* @Description        : Controller class of CaseRedirect Aura CMP
* @Author             : Nishant Prajapati
* @Group              : 
* @Last Modified By   : Sunit Kumar Chand
* @Last Modified On   : 24/06/2020
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.1A    30/1/2020 9:32 pm         Nishant              Initial Version
* 1.1A    24/06/2020 11:00 am       Sunit                Add new field on custom metadata and add encryption for
														 policy number
**/  
public class CaseRedirectController {
    @AuraEnabled
    public static string getRedirectURL(string key, string policyNo){
        System.debug('policyNo:-'+policyNo);
        List<Case_Redirect_Quick_Action__mdt> mdt= [select DeveloperName, Redirect_URL__c, 
                                                    Policy_No_Required__c, RType__c, UserNamePwd__c  
                                                    FROM Case_Redirect_Quick_Action__mdt WHERE DeveloperName=: key];
        if(mdt.size() > 0){
            string url= mdt[0].Redirect_URL__c+'?UID='+getEncryptedText(mdt[0].UserNamePwd__c)+'&RTYPE='+mdt[0].RType__c;
            if(mdt[0].Policy_No_Required__c){
                url += '&PNO='+getEncryptedText(policyNo);
            }
            System.debug('Url:-'+url);
            return url;
        }
        return '';    
    }
    /**
Author: Nishant Prajapati
Company: Techmatrix
Description: Encryption Method
Inputs: 
Returns: string
History:
================
1.0     20 FEB 2020      Nishant     Initial Version
*/
    private static string getEncryptedText(String textToEncrypted){
        String clearText = textToEncrypted;
        Blob key = Blob.valueOf('12345678901234567890123456789012');
        Blob cipherText = Crypto.encryptWithManagedIV('AES256', key, Blob.valueOf(clearText));
        String encodedCipherText = EncodingUtil.base64Encode(cipherText);
        System.debug(encodedCipherText);
        String encryptedString= EncodingUtil.urlEncode(encodedCipherText, 'UTF-8');
        return encryptedString;
    }
}