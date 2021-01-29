public class DeleteLineItems{

@future
public static void process(Set<Id> ids)
{
List<Order> orderstoupdate = new List<Order>();
list<Id> orderids=new list<Id>();
for(Order o: [Select Id, delete_all_details__c from Order where Id in :ids])
{
o.delete_all_details__c = false;
orderstoupdate.add(o);
orderids.add(o.Id);
}

if(orderstoupdate.size() >0)
{
delete [select id from orderitem where orderId in :orderids];
update orderstoupdate;
}
}

}