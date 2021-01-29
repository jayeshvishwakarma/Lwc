/**
* @File Name          : FinanceChecklistPDFController.cls
* @Description        : This class is to generate pdf for Finance Checklist 
* @Author             : 
* @Group              : 
* @Created By         : Rohit Gupta
* @Created Date       : 25/04/2020, 2:33:16 PM
*/
public class FinanceChecklistPDFController{
    String recId = '';
    public String renderAs{get;set;}
    public Boolean isValid{get;set;}
    public MC_Communication__c objMC{get;set;}
    
    //constructor
    public FinanceChecklistPDFController(){
        isValid = false;
        renderAs= 'pdf';
        objMC = new MC_Communication__c();
        
        recId = apexpages.currentpage().getparameters().get('id');
        
        if(String.isNotBlank(recId)){ 
            try{
                // A and Z is removed from the id in order to decrypt properly
                String string1 = recId.removeStart('A');
                String string2 = string1.removeEnd('Z');
                recId = createDecryptedData(string2); 
            }catch(Exception ex){
                isValid = false;
            }            
        }  
        
        if(String.isNotBlank(recId) ){
            List<MC_Communication__c> listOfMC = [SELECT Id, Customer_Field_1__c, Internal_User_1__c, 
                                                  General_Field_1__c, Checklist_Type__c 
                                                  FROM MC_Communication__c
                                                  WHERE Id =: recId 
                                                  LIMIT 1];            
            if(listOfMC != null && listOfMC.size() > 0){   
                objMC = listOfMC[0];
                isValid = True;
            }
        }else{
            isValid = False;
        }
        system.debug('@@##isValid '+isValid );
    }
    
    /**
	Author: Navin Soni
	Company: Techmatrix
	Description: This method is use to convert SFDC Id into encrypt format.
	Inputs: 
	Returns: String
	History:
	====================================================
	1.0  28/04/2020, 9:30:16 AM  Navin Soni  Initial Version
	**/
    
    public String createDecryptedData(String objMCId){
        String decryptedString = '';
        if(String.isNotBlank(objMCId)){                       
            Blob encodedEncryptedBlob = EncodingUtil.base64Decode(objMCId);                        
            decryptedString = encodedEncryptedBlob.toString();                        
        }
        return decryptedString;
    } 
    
}