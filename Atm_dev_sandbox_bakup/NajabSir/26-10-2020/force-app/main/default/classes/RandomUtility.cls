/*
    Author: Salesforce Stuff (https://www.sfdcstuff.com/2017/03/generating-random-number-between-two.html)
    Description: Generating random number between two numbers and finding string value from list of values randomly
*/
public class RandomUtility {
    
    //method to return random value between 2 numbers
    public static Integer generateRandomFromRange(integer startNum, integer endNum){
        Integer returnValue;
        //Logic- first we will generate random boolean value which will decide if we want to
        //add the random number from startNum or will subtract random number from endNum
        Integer randomNumber = Integer.valueof((math.random() * 10));
        boolean addSubFlag= math.mod(randomNumber,2) == 0 ? true : false;
        
        integer diffInRange = endNum-startNum;
        //Now find random number staring from 0 to diffInRange
        Integer randomNum = Math.mod(Math.round(Math.random()*diffInRange+1),diffInRange);
        
        //If addSubFlag is true, we will add random number generated between 0 and diffInRange from start number
        //else we will subtract random number from end number
                if(addSubFlag){
            if(diffInRange > 1)
                returnValue =startNum + randomNum;
            else
                returnValue =startNum;
        }else{
            if(diffInRange > 1)
                returnValue = endNum - randomNum;
            else
                returnValue =endNum;
        }
        return returnValue;
    }
    
    //method to return random number between 0 and size-1
    public static Integer generateRandomNumber(Integer size){
        Decimal d = math.random() * size;
        return d.intValue();
    }
    
    //method to return boolean number randomly
    public static Boolean generateRandomBoolean(){
        integer randomNumber = Integer.valueof((math.random() * 10));
        boolean returnValue= math.mod(randomNumber,2) == 0 ? true : false;
        return returnValue;
    }
    //Finding a random string value from list of strings
    public static String findRandomStringFromList(List<String> values){
        Integer randomNumber = generateRandomFromRange(0,values.size()-1);
        return values[randomNumber];
    }
   
}