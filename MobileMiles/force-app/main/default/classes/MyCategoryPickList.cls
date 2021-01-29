global class MyCategoryPickList extends VisualEditor.DynamicPickList{
    
    global override VisualEditor.DataRow getDefaultValue(){
        VisualEditor.DataRow defaultValue = new VisualEditor.DataRow('All', 'All');
        return defaultValue;
    }
    
    global override VisualEditor.DynamicPickListRows getValues() {
        VisualEditor.DataRow value1 = new VisualEditor.DataRow('All', 'All');
        VisualEditor.DataRow value2 = new VisualEditor.DataRow('Manuals', 'Manuals');
        VisualEditor.DataRow value3 = new VisualEditor.DataRow('Terms & Conditions', 'Terms & Conditions');
        VisualEditor.DataRow value4 = new VisualEditor.DataRow('Instructions', 'Instructions');
        
        VisualEditor.DynamicPickListRows  myValues = new VisualEditor.DynamicPickListRows();
        myValues.addRow(value1);
        myValues.addRow(value2);
        myValues.addRow(value3);
        myValues.addRow(value4);
        return myValues;
    }
}