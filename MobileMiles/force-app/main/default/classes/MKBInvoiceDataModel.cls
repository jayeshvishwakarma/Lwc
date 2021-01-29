public class MKBInvoiceDataModel {
    public MKBAccountModel klant {get;set;}
    public MKBBestellingModel factuur {get;set;}
    public List<MKBProductModel> product {get;set;}
    
    public class MKBAccountModel{
        public String kvk_nummer;
        public String verzendpostcode;
        public String voornaam_cp;
        public String telefoonnummer;
        public String verzendadres;
        public String achternaam_cp;
        public String verzendplaats;
        public String klantnummer_afas;
        public String bedrijfsnaam;
        public String factuurplaats;
        public String verzendhuisnummer;
        public String e_mailadres;
        public String factuurpostcode;
        public String verzendhuisnummertoevoeging;
        public String verzendstraat;
        public String aanhef_cp;
        public String factuuradres;
        public String iban;
        
    }
    
    public class MKBBestellingModel{
        public String betalingscondities;
        public String factuurnummer;
        public String reference;
    }
    
    public class MKBProductModel{
        public Decimal btw_21_bedrag;
        public Decimal btw_0_bedrag;
        public Decimal prijs_excl_btw;
        public Decimal btw_9_bedrag;
        public String productid;
        public String name;
        public Integer quantity;        
    }
}