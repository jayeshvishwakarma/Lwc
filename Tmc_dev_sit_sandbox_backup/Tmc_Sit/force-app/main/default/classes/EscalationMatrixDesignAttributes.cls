/**
 * @File Name          : EscalationMatrixDesignAttributes.cls
 * @Description        : This class is to leverage variables to passed from Lightning App Builder for EscalationMatrix Component for ATM.
 * @Author             : Deepak
 * @Group              :
 * @Last Modified By   : Deepak
 * @Last Modified On   : 26/11/2020
 * @Modification Log   :
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
* 1.0    26/11/2020                   Deepak                Initial Version
**/

public with sharing class EscalationMatrixDesignAttributes extends VisualEditor.DynamicPickList {

    //Default method to be called and to set default values in the picklist
    public override VisualEditor.DataRow getDefaultValue() {
        VisualEditor.DataRow defaultValue = new VisualEditor.DataRow('sales', 'sales');
        return defaultValue;
    }

    //Method to add more options in the dropdown. The data will be fetched from custom metadata
    public override VisualEditor.DynamicPickListRows getValues() {
        VisualEditor.DynamicPickListRows myValues = new VisualEditor.DynamicPickListRows();
        List<String> lobList = new List<String>();
        lobList = String.valueOf(System.Label.Escalation_Matrix_Business_Areas).split(ConstantsUtility.COMMA);
        for (String lob : lobList) {
            VisualEditor.DataRow lobvalue = new VisualEditor.DataRow(lob, lob);
            myValues.addRow(lobvalue);
        }
        return myValues;
    }
}