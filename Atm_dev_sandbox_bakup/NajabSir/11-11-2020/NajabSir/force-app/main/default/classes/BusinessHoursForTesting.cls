public class BusinessHoursForTesting {
    //Method to check businessHrs
    public static DateTime checkBusinessHours(Id businessHourId, DateTime tempDateTime, Integer addMinutes){
        DateTime validDateTime;
        if(BusinessHours.isWithin(businessHourId, tempDateTime)){
            dateTime addedTime = tempDateTime.addMinutes(addMinutes);
            system.debug('date compajbchdbhcdb-------'+addedTime);
            if(!BusinessHours.isWithin(businessHourId,addedTime)){
                if(date.newinstance(tempDateTime.year(), tempDateTime.month(), tempDateTime.day()) < date.newinstance(addedTime.year(), addedTime.month(), addedTime.day())){
                    DateTime nextValidDateTime = BusinessHours.nextStartDate(businessHourId, tempDateTime);
                    //Add desired minutes to it
                    validDateTime = nextValidDateTime.addMinutes(addMinutes);
                    test__c to = new test__c(test12__c = validDateTime);
                    insert to;
                    system.debug('to-----------'+to.Id);
                    system.debug('validDateTime'+validDateTime);
                    system.debug('validDateTime'+validDateTime.format('HH:mm a'));  
                }
                else{
                    Long gettime = addMinutes*60000;
                    dateTime addedDateTime = BusinessHours.addGmt(businessHourId, tempDateTime, gettime);
                    DateTime nextValidDateTime = BusinessHours.nextStartDate(businessHourId, addedDateTime);
                    validDateTime = nextValidDateTime;
                    system.debug('gettimegmt---------'+addedDateTime);
                    test__c to = new test__c(test12__c = nextValidDateTime);
                    insert to;
                    system.debug('to-----------'+to.Id);
                }
            }
            else{
                DateTime nextValidDateTime = BusinessHours.nextStartDate(businessHourId, tempDateTime);
                //Add desired minutes to it
                validDateTime = nextValidDateTime.addMinutes(addMinutes);
                test__c to = new test__c(test12__c = validDateTime);
                insert to;
                system.debug('to-----------'+to.Id);
                system.debug('validDateTime'+validDateTime);
                system.debug('validDateTime'+validDateTime.format('HH:mm a'));
            }
        }
        else{
            DateTime nextValidDateTime = BusinessHours.nextStartDate(businessHourId, tempDateTime);
            //Add desired minutes to it
            validDateTime = nextValidDateTime.addMinutes(addMinutes);
            test__c to = new test__c(test12__c = validDateTime);
            insert to;
            system.debug('to-----------'+to.Id);
            system.debug('validDateTime'+validDateTime);
            system.debug('validDateTime'+validDateTime.format('HH:mm a'));
        }
        return validDateTime;
    }    
}