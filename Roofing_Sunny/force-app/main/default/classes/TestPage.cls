public with sharing class TestPage {
	public String emailType {get; set;}
	public String ljqId {get; set;}
	public String renderAs {get; set;}
	
	public List<UtilityClass.ProgressBarSteps> progress {get; set;}
	
	public TestPage(){
		if(Apexpages.currentPage().getParameters().containsKey('Type')){
  		emailType = Apexpages.currentPage().getParameters().get('Type');	
  	}
  	
  	if(Apexpages.currentPage().getParameters().containsKey('ljqId')){
  		ljqId = Apexpages.currentPage().getParameters().get('ljqId');	
  	}
  	
  	if(Apexpages.currentPage().getParameters().containsKey('renderAs')){
  		renderAs = Apexpages.currentPage().getParameters().get('renderAs');	
  	}
  	Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.ERROR, Constants.ONLY_TM_CAN_CREATE_LJQ));
  	
  	progress = new List<UtilityClass.ProgressBarSteps>();
  	progress.add(new UtilityClass.ProgressBarSteps(1, 'LJQ Info', 'completed'));
  	progress.add(new UtilityClass.ProgressBarSteps(2, 'Customer info', 'completed'));
  	progress.add(new UtilityClass.ProgressBarSteps(3, 'Product Info', 'in-progress'));
  	progress.add(new UtilityClass.ProgressBarSteps(4, 'Competitor Info', 'pending'));
  	progress.add(new UtilityClass.ProgressBarSteps(5, 'Notes Info', 'pending'));
	}
}