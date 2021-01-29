/**
 * Renaming old "Question" to "SFQuestion" class
 * This is to avoid problem with "Question" object which is added by Chatter Answers
 *
 * Class: question
 *  Retrieves the question information and puts it in the question object
 *
 */

public with sharing class SFQuestion { 
    @AuraEnabled
    public String   name                   {get; set;}
    @AuraEnabled
    public String   id                           {get; set;}
    @AuraEnabled
    public String   question               {get; set;}
    @AuraEnabled
    public String   orderNumber            {get; set;}
    @AuraEnabled
    public String   choices                {get; set;}
    @AuraEnabled
    public String   selectedOption         {get;set;}
    @AuraEnabled
    public List<String> selectedOptions {get;set;}
    @AuraEnabled
    public List<SelectOption> singleOptions{get; set;}
    @AuraEnabled
    public List<SelectOption> multiOptions {get; set;}
    @AuraEnabled
    public Boolean  required               {get; set;}
    @AuraEnabled
    public String   questionType           {get; set;}
    @AuraEnabled
    public String   surveyName               {get; set;}
    @AuraEnabled
    public String   renderFreeText             {get; set;}
    @AuraEnabled
    public String   renderSelectRadio      {get; set;}
    @AuraEnabled
    public String   renderSelectCheckboxes {get; set;}
    @AuraEnabled
    public String   renderSelectRow        {get; set;}
    @AuraEnabled
    public List<String> responses              {get; set;}
    @AuraEnabled
    public String   singleOptionsForChart  {get; set;}
    @AuraEnabled
    public String   qResultsForChart         {get; set;}
    @AuraEnabled
    public List<String> strList              {get; set;} // The question's option as a list of string
    @AuraEnabled
    public List<Integer> resultsCounts       {get; set;} // The count of each response to a question's choices
    @AuraEnabled
    public List<SelectOption> rowOptions   {get; set;}
    @AuraEnabled
    public boolean  noData                 {get; set;}
    @AuraEnabled
    public String noOfRowsForTextArea {get; set;}
    @AuraEnabled
    public string type    {get;set;}
      /** Fills up the question object
       *  param:    Survey_Question__c
       */
    public SFQuestion(Survey_Question__c sq) {
        name = sq.Name;
        id = sq.Id;
        question = sq.Question__c;
        orderNumber = String.valueOf(sq.OrderNumber__c+1);
        type= sq.Question_Type__c;
        choices = sq.Choices__c;
        required = sq.Required__c;
        questionType = sq.Type__c;
        singleOptionsForChart = ' ';
        selectedOption = '';
        selectedOptions = new List<String>();
        if (sq.Type__c=='Single Select--Vertical'){
            renderSelectRadio='true';
            singleOptions = stringToSelectOptions(choices);

            renderSelectCheckboxes='false';
            renderFreeText='false';
            renderSelectRow = 'false';
            selectedOption = '';
            selectedOptions = new List<String>();
        }
        else if (sq.Type__c=='Multi-Select--Vertical'){
            renderSelectCheckboxes='true';
            multiOptions = stringToSelectOptions(choices);
            renderSelectRadio='false';
            renderFreeText='false';
            renderSelectRow = 'false';
            selectedOption = '';
            selectedOptions = new List<String>();
        }
        else if (sq.Type__c=='Single Select--Horizontal'){
            renderSelectCheckboxes='false';
            rowOptions = stringToSelectOptions(choices);
            renderSelectRadio='false';
            renderFreeText='false';
            renderSelectRow = 'true';
            selectedOption = '';
            selectedOptions = new List<String>();

        }
        else if (sq.Type__c=='Free Text' || sq.Type__c=='Free Text - Single Row Visible'){
            renderFreeText='true';
            renderSelectRadio='false';
            renderSelectCheckboxes='false';
            renderSelectRow = 'false';
            choices='';
            //If it's text area but for single row then only show single row even though it's stil text area
            if(sq.Type__c == 'Free Text - Single Row Visible'){
                noOfRowsForTextArea = '1';
            }else{
                noOfRowsForTextArea = '5';
            }


        }
        //responses= getResponses();
    }

   /** Splits up the string as given by the user and adds each option
    *  to a list to be displayed as option on the Visualforce page
    *  param: str   String as submitted by the user
    *  returns the List of SelectOption for the visualforce page
    */
    private List<SelectOption> stringToSelectOptions(String str){
        if (str == '')
        {
            return new List<SelectOption>();
        }
        strList = str.split('\n');

        List<SelectOption> returnVal = new List<SelectOption>();
        Integer i = 0;
        for(String s: strList){
            if (s!='') {
                if (s != 'null' && s!= null) {
                    String sBis = s.replace(' ', '%20');
                    singleOptionsForChart += s.trim()+'|';

                /*RSC2012-02-20
                String st = s.replace (' ', '&nbsp;');
                returnVal.add(new SelectOption(String.valueOf(i),st));
                */
                    returnVal.add(new SelectOption(String.valueOf(i),s));
                    System.debug('*****VALUES: ' + s);
                    i++;
                }
            }
        }
        singleOptionsForChart = singleOptionsForChart.substring(0, singleOptionsForChart.length()-1);
        return returnVal;
    }
}