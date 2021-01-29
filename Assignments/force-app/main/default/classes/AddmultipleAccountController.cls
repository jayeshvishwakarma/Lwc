public class AddmultipleAccountController {
 public List<Account> ListAccount{get; set;}

  public AddmultipleAccountController(ApexPages.StandardController myController) 

  {
  ListAccount = new List<Account>();
   Account acc= new Account();
  ListAccount.add(acc);
  }

  public void addAccount()
  {
  Account acc= new Account();
  ListAccount.add(acc);
  }

  public PageReference saveAccount()
  {
  for(integer i=0; i<ListAccount.size(); i++)
  {
  insert ListAccount;
  }
  return Page.faltu;
}

}