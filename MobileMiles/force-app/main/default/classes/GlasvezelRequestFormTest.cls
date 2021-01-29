@isTest
public class GlasvezelRequestFormTest {
    @testSetup
    private static void setup(){
        Account objAccount = new Account();
        objAccount.Name = 'Test';
        objAccount.KvK_nummer__c = '200';
        objAccount.Straat__c = 'Washington';
        objAccount.Huisnummer__c = '100';
        objAccount.Huisnummer_toevoeging__c = '55';
        objAccount.ShippingCity = 'DC';
        insert objAccount;
        
           
    }
    @isTest
    private static void testGlasvezelForm(){
         test.startTest();
        String signUrl = 'iVBORw0KGgoAAAANSUhEUgAAASwAAACWCAYAAABkW7XSAAAQqUlEQVR4Xu2dd6wVxRfHD2JB7AVRQSKKPXaiUbFgYgPsAaPRqEQRsTdQVOyAomDB3kssKDbEHrBC+ANQNMYasSN2wQr6zHeSze/+9L1399635Z7dzyQmT7139+znzP3uzJkzZ9o1NTU1GQ0CEICAAwLtECwHXsJECEAgEECw6AgQgIAbAgiWG1dhKAQggGDRByAAATcEECw3rsJQCEAAwaIPQAACbgggWG5chaEQgACCRR+AAATcEECw3LgKQyEAAQSLPgABCLghgGC5cRWGQgACCBZ9AAIQcEMAwXLjKgyFAAQQLPoABCDghgCC5cZVGAoBCCBY9AEIQMANAQTLjaswFAIQQLDoAxCAgBsCCJYbV2EoBCCAYNEHIAABNwQQLDeuwlAIQADBog9AAAJuCCBYblyFoRCAAIJFH4AABNwQQLDcuApDIQABBIs+AAEIuCGAYLlxFYZCAAIIFn0AAhBwQwDBcuMqDIUABBAs+gAEIOCGAILlxlUYCgEIIFj0AQhAwA0BBMuNqzAUAhBAsOgDEICAGwIIlhtXYSgEIIBg0QcgAAE3BBAsN67CUAhAAMGiD0AAAm4IIFhuXIWhEIAAgkUfgAAE3BBAsNy4CkMhAAEEiz4AAQi4IYBguXEVhkIAAggWfQACEHBDAMFy4yoMhQAEchWss846y7777jv76KOPmvVEjx49bNlll7Xx48fjKQhAAAKWm2Ddc889dvTRR9vff//dqhs6d+5s8+bNw1UQgAAE8hOsNdZYw3755Re7//77bdGiRc26Ytq0aTZu3Dh74403bMstt8RdKREYPny4ffDBBzZ//nzbYIMNbL311rMFCxbYqFGjUrojl4VAfQRyGWGde+65NnLkSFt99dXtm2++adHyL774wrp27WqnnHKKXX311fU9Id9qkcBVV11lL7/8sk2aNKnZz2y99da26aab2tprr21XXHEFJCGQO4FMBUs/EI2oZs2aZYMHD7axY8eGGFVrbdVVV7V27dqFWBctOQLyxdChQ23JJZe0k08+2fr16xdeHmuuuWb457bbbguxQ42C1bp06WL77ruvrbvuujZs2LDkDOFKEKiBQGaC9fzzz9s+++xjyyyzjN19993Wv3//WGbutNNOtvTSS9vUqVNjfZ4PtU7glVdeCS+KJ554wvQy0HR7nXXWafZLH374oS1cuNBee+010/cmTpwYPvfMM8/YnnvuCWoIZE4gE8FSLGTEiBG2+eabh07fvXv32A+666672o8//mhvvvlm7O/wwf8SUCxQ7F9//XVT/PD000+3Qw891Lp16xYb19y5c61Pnz4h3jV58mREKzY5PpgUgdQFKxpZLbfccjZnzpwwpYjb/vjjD1trrbWCYI0ZM8bOOOOMuF/lc2ZhweKtt94y+UDxwI4dO4YXh8RqqaWWqovRV199ZX379g3XHT16ND6piyJfqpdAqoKlH4o6t0ZWd9xxh2211VY126kfyEYbbWQSPP1Ni0cgWthYYoklwvRb0/GDDz7Yll9++XgXaOVT8sNmm21mP/zwg2mF8bLLLmvzNbkABOIQSE2wlBSqlT2JlaYPGinV20444QS79dZb7c8//6z3EqX5nmJNGkHNnDnTBgwYYLfccouttNJKiT//xx9/HFYOb7rpJtt2223Di+miiy5K/D5cEAKVBFIRLE3lOnXqZE1NTfb++++3Saxk7IMPPhjiLfoRbrPNNniwBQLRqEoxQgXWDzjggNRZPf7448E3Wm385JNPQiCfBoG0CKQiWFouV8zp0UcftQMPPLDNtkv0NC3UKOuYY45p8/WKdoHrrrsupCEoRhg3XSRJBq+++qrtsssuduSRR9pdd92V5KVdX+vfCbl6GMVjlZxLUm59rk1csDQK6tmzpw0ZMsSuv/76+qxq5lurrLKK9erVq8Ukx8Ru5OxC0ahKsal77703k1FVc4guvfRSO//88+3UU08Nwf4yN71ANPKcMmVKixh233334KuTTjqpzKhqfvbEBUvL3jNmzAhL30lOD1ZbbbUQw9KWEZqFvKgoVqVRlQLfSfKuh7FeKgryK39Lf5elaSS1wgor2M8//2zPPfeczZ492zp06BB2aGixI0rIFY/Fixfbs88+a9dee6399ttvpt0Ee++9d9gO9e6779qVV15ZFmx1PWeignX88ceHIKxGVhphJdkuueSSsCT//fffl+rH0BzDPGJVcXyphRb94Mqy97O5kZRWsxUSOfPMM0MaSUvt119/Day0cBHtJpDY699J32m5tyUmWFrqXn/99UNWuubpSTftedttt93CUHv//fdP+vIurlfP1qYsHyza+3n44YeH6WlRW+VugWgkpdiqFpu0k0NlkeI2jUb1PYmWRlpKFdEWKCVMI1z/pZiYYKlUjAKuGmEdd9xxcf0V+3NacVTn2Hnnne3FF1+M/b2ifLDerU1ZPr9+eNoorR+dpj1F275TOaLSbgGl21QbSdXC/7PPPjOVXbr44ovD1JEtUCkJ1mmnnRZyrjRtO++882rxUU2fVYzm999/Nw2ny9QqE3Br3dqUNSetVB511FEhE/7ss88OfcJ7+/eI6sILL2zTboFqPD799FPbb7/9TIF5pafQ/kegzSMsddDtttsuDIV/+umnVNkqTULZ2jfccIMpXlaGVilWbU3AzYpXtDtBI2LV2PLarrnmmrCt6emnnw77L5MeUbXGRQzbkmztlXk1u9ssWHvttVeoqXTnnXeGBMK0m946GjprFbLoTTErjVKS2C2QNSvVO9PigNcA/I033hgWjvQiVgZ/W/ZfZs2+yPdrk2BpOVcJcIpdKWkwi/bUU0+FoGSRR1mVUxClc2h65e1tGwXgtY9xwoQJWXSNxO6hdASlHaifaQ+sCk3SGoNA3YIVLWEr8U3OzbIVdZRVKVT1loDJ0g/V7iWxVflr5Sd5aJqGafFIuVQa2ZKN3nheq1uw9NbRSkYaKQzVMEWjrLSD/NXsSOr/a/XpySefDKufkVAVYQqiH7xG4R6mhcrOV4BbI0OFN7KaMSTVh8pynboES8X0VComz9IiyqRWztfXX3/t1ldaDVJ8RNMOBajTXn3KGpSXaaFihUpPULb6Cy+8YNtvv33WqLhfTAJ1CZaC66qg8Pnnn4da33k0lTRZccUV3ZZO1uhQYvXXX3+FH8sFF1yQSK2qPHzR2j0beVqobV7a1qRzBg477LCQZZ5Xf240vzWqPTULlvY7adVKWxDymA5GIJX1/u2339rbb7/dqGybtStKDNThsfqRSKg23HBDV89Qi7GNOi3UthhV/1AlEP1NVnktXs3vszUL1g477BA2aSqOpAMi8mpKIlVA18tmaMWptFqmAx123HHHIFRFywRvri9E00IVE3zooYfy6i7/d99o14Cm4drqtcceezSEXRhRnUBNgqUMZp1489hjj+VWxiR6JG2wPvHEE10EdKPNyjrSTDsCBg0aVN0zBfrEyiuvHHYnaDRTS03/NBBUJuJKQFWbiuaHQGzB0oED55xzTljq1ZJv3s1DQLeyBIz2V15++eWplCvO2xfV7v/SSy+Fjb3a0KuUgbyax10DebFq1PvGEiwFJm+++eaGqyjZyAHdaFSlOkdahcqiXHGjdjLZpZG5Ruh66SkLPuuGWGVNPJ37xRIsDelVLSHtvYK1PmIjBnTzLldcK8MsP68TpsVH2170EsyqKaguofS4xSkrRl7uU1Wwoj1VWXeyOACjaaE2RD/yyCNxvpLaZ1RFQj8KxajyLlec2kMmcGGd4CM+8l0WLdrTqJfuO++8426LUxaMPN2jqmAdcsghoRyvYjBKbGy0pgRSlZr98ssvcysR/MADDwSx0qkxqmmuyqhlKhFcS59QZQ+lxEydOrWWr9X8WR1DpkUZVVrQVFRlj1RgkuabQFXB0uOpKJtWthpRsFQoTnWz8zixRblUEqqHH344pCpoiqrTY2gtE+jdu3d4ubz33nupYbrvvvtCKRgVFBw/fjwnLaVGOvsLxxKs7M2q7Y7RiS2qX6Q4SRYtiovoXhIqZavTqhPQyFNCkkYRRu0akFBpgUgb5CVWm2yySXWj+IQbAoUQLNFWjEJ5TopTpDkdU9BYK146zkylUyRWTDXi9/do4/qxxx4bTqVOqmnzss5mlP913JjKDNOKR6AwgqW9hQsXLkxtqqHTevRDUB0uxWC0rSOLgoXF63IWYo1adVbt9ySatjspJCC/qCptGXYQJMHN4zUKI1hpTjUkUhIriZbqgCnHSqtdtPoIJHkcWLQKqMq3GmF17dq1PqP4lgsChRGsaKpx0EEHmfY7JhFT0vRP1VRnzZoVAvuqsKCRHK1tBKJ0lL59+4Y9qfU2lTBWus3AgQPt9ttvr/cyfM8RgcIIlph3797d5s6da507d7Z58+bV7QYVcNPbetq0aSFnSMFbCrrVjbPZL2paGJ3HV+uVdYafKl2o6KFSSFSmh1YOAoUSLKUXKJirkrwKjB9xxBGxvahiehIpxaYkdjpCXNfSNSRatGQJKPVAbGutGqt0CImVRr0K2stHtPIQKJRgyW2qy639e+3btw/TNx3e0LNnzxaniKpHryqT0dREWfM6xVebdWnpEqi1auywYcPCFF0jMyXrappOKxeBwgmW3NetW7dwFFjUNEJSxn7UevXqFVYTVTlg9uzZodSy8rf0ti5yMb1G69q1VI2VSHXq1ClUaJ0+fbptscUWjfY42JMBgUIKluJYKt+sqZ1O9WkpnqVlcG2lUW36jh07ZoCbW1QSqCXrfejQoTZmzBibNGmS9evXD5AlJVBIwar0ZSRelf9NS98K3OqQzB49epTU9fk/dtxUFCXpalqvVUEVbqSVl0DhBau8rm38J49SUaqdbdmnTx+bMWNGOO1bq4u08hJAsMrr+9yfXHEpLYroMJOWVnWj08U1stIIi1ZuAghWuf2f+9NPnjzZdECFjmzTCm9lUylulZVWsH3+/Pm524oB+RNAsPL3Qekt0IKHVv+UlxWt4OrcS8UfVZlUuxc42ab03SQAQLDoB7kTiHYoVBqigLxOxC57LfzcndNgBiBYDeaQMppTuZIbbV5WyemNN964jDh45lYIIFh0DwhAwA0BBMuNqzAUAhBAsOgDEICAGwIIlhtXYSgEIIBg0QcgAAE3BBAsN67CUAhAAMGiD0AAAm4IIFhuXIWhEIAAgkUfgAAE3BBAsNy4CkMhAAEEiz4AAQi4IYBguXEVhkIAAggWfQACEHBDAMFy4yoMhQAEECz6AAQg4IYAguXGVRgKAQggWPQBCEDADQEEy42rMBQCEECw6AMQgIAbAgiWG1dhKAQggGDRByAAATcEECw3rsJQCEAAwaIPQAACbgggWG5chaEQgACCRR+AAATcEECw3LgKQyEAAQSLPgABCLghgGC5cRWGQgACCBZ9AAIQcEMAwXLjKgyFAAQQLPoABCDghgCC5cZVGAoBCCBY9AEIQMANAQTLjaswFAIQQLDoAxCAgBsCCJYbV2EoBCCAYNEHIAABNwQQLDeuwlAIQADBog9AAAJuCCBYblyFoRCAAIJFH4AABNwQQLDcuApDIQABBIs+AAEIuCGAYLlxFYZCAAIIFn0AAhBwQwDBcuMqDIUABBAs+gAEIOCGAILlxlUYCgEIIFj0AQhAwA0BBMuNqzAUAhBAsOgDEICAGwIIlhtXYSgEIIBg0QcgAAE3BP4BTYYmt+EN1XQAAAAASUVORK5CYII=';
        List<Account> lstAccounts=[SELECT Name, KvK_nummer__c, Straat__c, Huisnummer__c, Huisnummer_toevoeging__c, Postcode__c, ShippingCity,
                     				Voornaam_CP__c, Achternaam_CP__c, E_mailadres_bedrijf__c, Phone, Bankrekeningnummer__c
                     				FROM Account                    				
                   					];
        	Account objAccount = lstAccounts[0]; 
        	Glasvezel_Request__c objGlasvezelRequest=new Glasvezel_Request__c();
            objGlasvezelRequest.Bedrijfsnaam__c = objAccount.Name;
            objGlasvezelRequest.KvK_nummer__c = objAccount.KvK_nummer__c;
            objGlasvezelRequest.Straat__c = objAccount.Straat__c;
            objGlasvezelRequest.Huisnummer__c = objAccount.Huisnummer__c;
            objGlasvezelRequest.Huisnummer_toevoeging__c = objAccount.Huisnummer_toevoeging__c;
            objGlasvezelRequest.ShippingCity__c = objAccount.ShippingCity;
            objGlasvezelRequest.Phone__c='90909090909';
            objGlasvezelRequest.Voornaam_CP__c = 'Testname';
            objGlasvezelRequest.Achternaam_CP__c = 'TestAchternaam';
            objGlasvezelRequest.Postcode__c = '123456';
            objGlasvezelRequest.E_mailadres_bedrijf__c = 'kaushik.rajrishi@gmail.com';
            objGlasvezelRequest.Bankrekeningnummer__c = '10';        
            objGlasvezelRequest.Cources__c = 'SNEL';
            objGlasvezelRequest.Fox_Sports__c = true;
           	objGlasvezelRequest.Ziggo_Sports__c = true;            
            objGlasvezelRequest.Aantal__c = 2;
            objGlasvezelRequest.Account__c=objAccount.id;
                   
       
      	
       
        ServerGlasvezelRequestFormController.getAccount(objAccount.id);
        String id = ServerGlasvezelRequestFormController.createRecord(objGlasvezelRequest,signUrl);
        //ServerGlasvezelRequestFormController.sendPdf(id,objGlasvezelRequest.E_mailadres_bedrijf__c);
        test.stopTest();
    }
    
   
}