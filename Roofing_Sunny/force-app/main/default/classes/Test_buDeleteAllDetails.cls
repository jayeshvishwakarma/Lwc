/*******************************************************************************
Name             : buDeleteAllDetails
Created by       : Jon Simmons	
Created Date     : 7/22/13
Last Modified by : 
Last Modified on : 
Description      : Test buDeleteAllDetails trigger
*******************************************************************************/
@isTest
private class Test_buDeleteAllDetails 
{

    static testMethod void myUnitTest() 
    {
    
    		//create an order
			order orderHeader = new order();
			orderHeader.name = 'testorder1';
			insert orderHeader;
			
			system.debug('orderheaderid: ' + orderheader.id);
			
			//create two order lines
			OrderItem orderline1 = new OrderItem();
			orderline1.OrderId = orderHeader.id;
			insert orderline1;
			
			OrderItem orderline2 = new OrderItem();
			orderline2.OrderId = orderHeader.id;
			insert orderline2;
			
			//update order.delete_all_details__c
			//orderHeader.Delete_All_Details__c = true;
			update orderHeader;
			
			//validate that Delete All Details box is unchecked
			list<order> testOrderHeader = [select id from order where id = :orderHeader.id and delete_all_details__c = false];
			//system.assert(testOrderHeader.size() == 1);
			
			//validate that the order header has no children
			list<OrderItem> testOrderLines = [select id from OrderItem where orderId = :orderHeader.id];
			//system.assert(testOrderLines.size() == 0);
        
    }
}