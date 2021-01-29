public class BusinessHoursCalculation {
    
    
    public static DateTime getEscalationDateTime(DateTime startDateTime, Integer minutesToBeAdded, String businessHourId){
        List<Boolean> businessDay = new Boolean[7];
        List<Time> startHours = new Time [7];
        List<Time> endHours = new Time [7];
        Date knownSunday = date.newInstance(2013, 1, 6);
        DateTime escalationDateTime;
        DateTime nextValidDateTime;
        Time tempTime;
        BusinessHours businessHour = [
            SELECT Id, SundayStartTime, SundayEndTime,
            MondayStartTime, MondayEndTime,
            TuesdayStartTime, TuesdayEndTime,
            WednesdayStartTime, WednesdayEndTime,
            ThursdayStartTime, ThursdayEndTime,
            FridayStartTime, FridayEndTime,
            SaturdayStartTime, SaturdayEndTime
            FROM BusinessHours
            where id = :businessHourId
        ];
        system.debug('businessHour----->'+businessHour);
        /*Long milliSeconds = minutesToBeAdded * 60 * 1000;
		system.debug('milliSeconds------>'+milliSeconds);
		Datetime targetDT = BusinessHours.add(businessHourId,startDateTime,milliSeconds);
		System.debug('target date on local time =' + targetDT.format('MM-dd-yyyy ') + ' ' 
		+ targetDT.format('h:mm a'));*/
        
        businessDay[0] = (businessHour.SundayStartTime != null);
        businessDay[1] = (businessHour.MondayStartTime != null);
        businessDay[2] = (businessHour.TuesdayStartTime != null);
        businessDay[3] = (businessHour.WednesdayStartTime != null);
        businessDay[4] = (businessHour.ThursdayStartTime != null);
        businessDay[5] = (businessHour.FridayStartTime != null);
        businessDay[6] = (businessHour.SaturdayStartTime != null);
        system.debug('businessDay---->'+businessDay);
        startHours[0] = businessHour.SundayStartTime;
        startHours[1] = businessHour.MondayStartTime;
        startHours[2] = businessHour.TuesdayStartTime;
        startHours[3] = businessHour.WednesdayStartTime;
        startHours[4] = businessHour.ThursdayStartTime;
        startHours[5] = businessHour.FridayStartTime;
        startHours[6] = businessHour.SaturdayStartTime;
        system.debug('startHours---->'+startHours);
        endHours[0] = businessHour.SundayEndTime;
        endHours[1] = businessHour.MondayEndTime;
        endHours[2] = businessHour.TuesdayEndTime;
        endHours[3] = businessHour.WednesdayEndTime;
        endHours[4] = businessHour.ThursdayEndTime;
        endHours[5] = businessHour.FridayEndTime;
        endHours[6] = businessHour.SaturdayEndTime;
        system.debug('endHours---->'+endHours);
        system.debug('startDateTime---->'+startDateTime.format());
        Integer dayOfTheWeek = Math.mod(Math.abs(knownSunday.daysBetween(startDateTime.date())),7);
        system.debug('dayOfTheWeek----->'+dayOfTheWeek);
        if(businessDay[dayOfTheWeek]){
            //tempTime=startDateTime.time().addMinutes(minutesToBeAdded);
            //system.debug('tempTime----->'+tempTime);
            //Time timeToAdd = getTimeDifference(endHours[dayOfTheWeek],tempTime);
            Time timeToAdd = Time.newInstance(0,minutesToBeAdded,0,0);
            system.debug('timeToAdd----->'+timeToAdd);
            Time timeRemaining = getTimeDifference(startDateTime.time(),endHours[dayOfTheWeek]);
            system.debug('timeRemaining---->'+timeRemaining);   
            if(timeToAdd<=timeRemaining){
                Time startTime = startDateTime.time();
                Time addedTime = addTimeDifference(startTime,timeToAdd);
                system.debug('addedTime------>'+addedTime);
                Date startDate = startDateTime.date();
                nextValidDateTime = DateTime.newInstance(startDate, addedTime);
                system.debug('nextValidDateTime----->'+nextValidDateTime.format());
            }else{
                Time timeRemainedTobeAssigned = getTimeDifference(timeRemaining,timeToAdd);
                system.debug('timeRemainedTobeAssigned-------->'+timeRemainedTobeAssigned);
                Time totalTimeDurationOfTheDay = getTimeDifference(startHours[dayOfTheWeek+1],endHours[dayOfTheWeek+1]);
                system.debug('totalTimeDurationOfTheDay----->'+totalTimeDurationOfTheDay);
            }
                        
        }else{
            if(dayOfTheWeek==0 || dayOfTheWeek==6){
                dayOfTheWeek =1;
            }else{
                
            }
        }
        
        return escalationDateTime;
    }
    
    public static Time getTimeDifference(Time startTime, Time endTime){
        Integer elapsedHours = endTime.hour() - startTime.hour();
        Integer elapsedMinutes = endTime.minute() - startTime.minute();
        Integer elapsedSeconds = endTime.second() - startTime.second();
        Integer elapsedMiliseconds = endTime.millisecond() - startTime.millisecond();
        Time result = Time.newInstance(elapsedHours, elapsedMinutes, elapsedSeconds, elapsedMiliseconds);
        return result;
    }
    public static Time addTimeDifference(Time startTime, Time timeToAdd){
        Integer elapsedHours = startTime.hour() + timeToAdd.hour();
        Integer elapsedMinutes = startTime.minute() + timeToAdd.minute();
        Integer elapsedSeconds = startTime.second() + timeToAdd.second();
        Integer elapsedMiliseconds = startTime.millisecond() + timeToAdd.millisecond();
        Time result = Time.newInstance(elapsedHours, elapsedMinutes, elapsedSeconds, elapsedMiliseconds);
        return result;
    }
    
}