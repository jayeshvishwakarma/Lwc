/**
 * Created by Deepak on 14/10/20.
 *
 * DUMMY CLASS TO CREATE CASE IN BULK
 */

public with sharing class CreateDummyCases {

    @future
    public static void createCase(String casesString)
    {
        List<Case> cases = (List<Case>)System.JSON.deserialize(casesString, List<Case>.class);
        insert cases;

    }
}