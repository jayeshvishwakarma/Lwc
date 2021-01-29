import { LightningElement ,api} from 'lwc';

export default class CreateCaseLookUpPopUp extends LightningElement {
   @api modelTitle;
   @api searchKey;
   @api sObjectList
   @api fieldLabel;
   @api isRequired;
   @api isSearching = false;
   @api recordsLength = 0;
   @api sectionHeader;
   @api sObjectName;
   isAccountObject = false;
  
  
  
   connectedCallback(){
      if(this.sObjectName === 'Account'){
         this.isAccountObject = true;
      }
   }

   handleChange(event){
      //console.log(event.target.value);
      const searchEvent = new CustomEvent('search',{detail : event.target.value});
      this.dispatchEvent(searchEvent);
   }
   handleSelect(event){
     // console.log(JSON.stringify(event.target.id));
      let id = event.target.id;
      if(id.includes('-')){
         id = id.split('-')[0];
      }
      const obj = this.sObjectList.find(obj => obj.Id === id);
      const searchEvent = new CustomEvent('select',{detail : obj});
      this.dispatchEvent(searchEvent);
   }
   handleCloseModal(){
      this.dispatchEvent(new CustomEvent('close'));
   }
}