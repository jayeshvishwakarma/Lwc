import { LightningElement, wire, track, api } from 'lwc';
import getUsers from '@salesforce/apex/ChatApplicationController.getUsers';
import getLoginedUser from '@salesforce/apex/ChatApplicationController.getLoginedUser';
export default class ChatUsers extends LightningElement {
    lstUsers;
    user;
    lstUserTemp;
    lstTask;   
    isLoading = false;
    error;
    currentUser;
    @track wiredResult;
    @wire(getUsers)
    lstUser(result){
        this.wiredResult = result;
        if(result.data){
            this.lstUsers = result.data;        
            this.lstUserTemp = result.data;           
        }else if(result.error){
            this.error = result.error;
        }
    }
    @wire(getLoginedUser)
    User({data,error}){
        if(data){
            this.currentUser = data;           
        }else if(error){
            this.error = error;
        }
    };
    handleOpenSettings(event){
        
    }

    searchChange(event){      
        this.user = event.target.value;                    
        const filterItems = (name, userList) => {
            let query = name.toLowerCase();
            return userList.filter(item => item.Name.toLowerCase().indexOf(query) >= 0);
          }
          this.lstUsers = filterItems(this.user,this.lstUserTemp);         
    }
    
    handleclick(event){  
      //  console.log("div clicked");
        const userId = event.currentTarget.dataset.userId;
       // console.log(userId);    
        const objUser = {
                        'userValue' : this.lstUsers.find(e => e.Id == userId),
                        'currentUserId' : this.currentUser[0].Id
                        }              
       // console.log('current user id in js', objUser.currentUserId);
      //  console.log(objUser);
        const selectedEvent = new CustomEvent('chat',{detail : objUser});
        this.dispatchEvent(selectedEvent);

    }
}