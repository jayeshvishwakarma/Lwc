/**
 * @File Name          : SVOCDesignAttributes.cls
 * @Description        : This class is to leverage variables to passed from Lightning App Builder for SVOC Detail Component.
 * @Author             : Prabhat Sharma
 * @Group              : 
 * @Last Modified By   : Prabhat Sharma
 * @Last Modified On   : 7/05/2019, 10:43:33 PM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
* 1.0    7/05/2019, 9:14:54 PM      Prabhat Sharma                Initial Version
**/

public with sharing class SVOCDesignAttributes extends VisualEditor.DynamicPickList{
    
    //Default method to be called and to set default values in the picklist
    public override VisualEditor.DataRow getDefaultValue(){
        VisualEditor.DataRow defaultValue = new VisualEditor.DataRow('Loyalty', 'Loyalty');
        return defaultValue;
    }

    //Method to add more options in the dropdown. The data will be fetched from custom metadata
    public override VisualEditor.DynamicPickListRows getValues() {
        VisualEditor.DynamicPickListRows  myValues = new VisualEditor.DynamicPickListRows();
        for(SVOC_Details__mdt svoc : [SELECT MasterLabel,DeveloperName FROM SVOC_Details__mdt]){
            VisualEditor.DataRow svocvalue = new VisualEditor.DataRow(svoc.DeveloperName, svoc.MasterLabel);
            myValues.addRow(svocvalue); 
        }   

        return myValues;
    }
}