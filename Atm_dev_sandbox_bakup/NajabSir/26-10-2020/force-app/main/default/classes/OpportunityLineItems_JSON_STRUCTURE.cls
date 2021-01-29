/**
 * @File Name          : OpportunityLineItems_JSON_STRUCTURE.cls
 * @Description        : This class is used to hold JSON structrue used in creating Line Item Records.
 * @Author             : Anuj Kumar
 * @Group              : 
 * @Last Modified By   : Anuj Kumar
 * @Last Modified On   : 06/10/2019 10:15 AM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                Modification
 *==============================================================================
 * 1.0    06/10/2019 10:15 AM          Anuj Kumar            Initial Version
**/

Public WithOut Sharing Class OpportunityLineItems_JSON_STRUCTURE{
    
    // ENQUIRY RECORD TYPE NAME
    public String enquiryRecordType;
    
    // ACCESSORIES DISCOUNT VALIDATION AMOUNT 
    public Decimal accessoriesValidAmount;
    
    // OTHER DISCOUNT VALIDATION AMOUNT
    public Decimal otherValidAmount;
    
    // HEADER VALUES USED IN COMPONENT
    public List<String> headerValue;
    
    // ADD COMPONENT RELATED INFO
    public List<AddComponent> addComponent;
    
    // ADD ACCESSORIES RELATED INFO
    public List<AddAccessories> addAccessories;
    
    // OPPORTUNITY RELATED INFO
    public OpportunityInfo opportunityInfo;
    
    // OTHER ACCESSORIES DISCOUNT RELATED INFO
    public OtherAccessoriesDiscount otherAccessoriesDiscount;
    
    // SELECTED VARIANT RELATED INFO
    public SelectedVariant selectedVariant;
    
    // SELECTED COLOR VARIANT RELATED INFO
    public SelectedColorVariant selectedColorVariant;
    
    // OTHER COMPONENT CHARGE RELATED INFO
    public OtherCharge otherCharge;
    
    // EX SHOWROOM RELATED INFO
    public ExShowRoomVariant exShowRoomVariant;
    
    // REGISTRATION AMOUNT RELATED INFO
    public RegistrationAmountVariant registrationAmountVariant;
    
    // SCHEMES AND OFFERS RELATED INFO
    public AddSchemes addSchemes;
    
    
    // ADD COMPONENT STRUCTURE
    public class AddComponent {
        public Boolean showCheckBox;
        public String year;
        public Boolean isDisabled;
        public Boolean showLabel;
        public Boolean isExchangedWarrenty;
        public Boolean isChecked;
        public Decimal value;
        public String label;
        public Integer amount;
        public String validityValue;
        public String packageValue;
        public Boolean isMCP;
    }
    
    // ADD ACCESSORIES STRUCTURE
    public class AddAccessories {
        public String priceBookEntryId;
        public Double unitPrice;
        public Double price;
        public Decimal Maximum_Quantity_toReplace;
        public Decimal Minimum_Quantity_toReplace;
        public String quantity;
        public String Name;
        public String Id;
    }
    
    // OPPORTUNITY STRUCTURE
    public class OpportunityInfo {
        public Decimal Amount;
        public String StageName;
        public String Mobile_toReplace;
        public String Email_toReplace;
        public String Pricebook2Id;
        public String Name;
    }
    
    // OTHER ACCESSORIES DISCOUNT STRUCTURE
    public class OtherAccessoriesDiscount {
        public Object priceBookEntryId;
        public String UnitPrice;
        public Decimal Quantity;
        public Object opporrtunityId;
    }
    
    // OTHER COMPONENT CHARGE STRUCTURE
    public class OtherCharge {
        public Object priceBookEntryId;
        public Decimal UnitPrice;
        public Decimal Quantity;
        public Object opporrtunityId;
    }
    
    // SELECTED VARIANT STRUCTURE
    public class SelectedVariant {
        public String Family;
        public String Fuel_Type_toReplace;
        public Double Loyalty_Amount_toReplace;
        public Double Extended_Warranty_3_year_toReplace;
        public Double Extended_Warranty_2_year_toReplace;
        public Double Extended_Warranty_1_year_toReplace;
        public String Name;
        public String Id;
    }
    
    public class Variant_toReplace_R {
        public String Id;
        public String ProductCode;
    }
    
    // SELECTED COLOR VARIANT STRUCTURE
    public class SelectedColorVariant {
        public Variant_toReplace_R Variant_toReplace_R;
        public String Color_Type_toReplace;
        public String Variant_toReplace;
        public String Color_Code_toReplace;
        public String Name;
        public String Id;
    }
    
    // EX SHOWROOM STRUCTURE
    public class ExShowRoomVariant {
        public String priceBookEntryId;
        public String UnitPrice;
        public Decimal Quantity;
        public String opporrtunityId;
    }
    
    // REGISTRATION STRUCTURE
    public class RegistrationAmountVariant {
        public String priceBookEntryId;
        public String UnitPrice;
        public Decimal Quantity;
        public String opporrtunityId;
    }
    
    // SCHEMES AND OFFERS STRUCTURE
    public class AddSchemes {
        public String objOtherId;
        public Object offersText;
        public Object schemeCode;
        public Decimal cashPaymentData = 0;
        public String financeAmountData;
        public Decimal otherDiscountData = 0;
        public Decimal ruralDiscountData = 0;
        public Decimal corporateDiscountData = 0;
        public Double exchangeBonusData = 0;
        public Decimal exchangeData = 0;
        public Decimal OfferData = 0;
        public Boolean otherDiscountValue = false;
        public Boolean ruralOffersValue = false;
        public Boolean exchangeValue = false;
        public Boolean exchangeBonusValue = false;
        public Boolean corporateDiscountValue = false;
        public Object employerName;
    }
    
}