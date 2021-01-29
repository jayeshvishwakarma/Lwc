public with sharing class WizardComponent {
    public class Step {
        public Integer step {get;set;}    
        public String   Name {get;set;}    
        public String   Description {get;set;}    
        public Boolean  Ready {get;set;}    

        
        public Step() {
        }   
            

        public Step (integer step, string name, string descr) {
            this.Name = name;
            this.Description = descr;
            this.Step = step; 
            this.Ready = false;
        }   
    }
    
    public Step current  {get;set;} 

    public list<Step> steps {get;set;}
    
      
    public WizardComponent() {
        this.steps = new list<step>();
    }

    
    public void setCurrent(integer i) {
        this.current = steps[i-1];
    }

    public Step getCurrentstep() {
        return this.current;
    } 

    public void Next() {
        system.debug('currentindex: ' + this.current.step);
        this.current.ready=true;
        integer i = this.current.step+1;
        if (this.current.step < steps.size())
            this.current = steps[i-1];
        system.debug('currentindex: ' + this.current.step);
    }

    public void Prev() {
        system.debug('currentindex: ' + this.current.step);
        integer i = this.current.step-1;
        if (this.current.step > 0)
            this.current = steps[i-1];
        system.debug('currentindex: ' + this.current.step);
    }
    
    
    public Integer newStep {get;set;}
    
    public PageReference wizardStepClicked() {
        System.debug('STAP='+newStep);
        //System.assert(false, 'stap = ' + newStep);
        setCurrent(newStep);
        return null;
    }
      
}