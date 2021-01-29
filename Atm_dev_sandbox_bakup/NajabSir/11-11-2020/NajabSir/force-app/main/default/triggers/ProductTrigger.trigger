/**
 * @File Name          : ProductTrigger.trigger
 * @Description        : 
 * @Author             : Rajesh Ramachandran
 * @Group              : 
 * @Last Modified By   : Rajesh Ramachandran
 * @Last Modified On   : 12/28/2019, 9:58:30 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    12/28/2019   Rajesh Ramachandran     Initial Version
**/
trigger ProductTrigger on Product2 (after insert, after update) {
    new ProductTriggerHandler().run(); 
}