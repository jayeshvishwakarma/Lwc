@isTest(seeAlldata=False)
public class SVOCDesignAttributesTest {

    static testmethod void testsvocdesign(){
        SVOCDesignAttributes designAttr = new SVOCDesignAttributes();
        VisualEditor.DataRow firstValue = designAttr.getDefaultValue();
        System.assertEquals('Loyalty', firstValue.getLabel());
        designAttr.getValues();
        System.assertNotEquals('Referral', firstValue.getLabel());
        
    }
}