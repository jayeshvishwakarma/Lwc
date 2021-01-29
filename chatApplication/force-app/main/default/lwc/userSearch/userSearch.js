/* eslint-disable eqeqeq */
/* eslint-disable no-unused-vars */
/* eslint-disable no-undef */
import { LightningElement ,wire,api} from 'lwc';
import getTasksById from '@salesforce/apex/UserDetails.getTasksById';
import setTaskCompleted from '@salesforce/apex/UserDetails.setTaskCompleted';
import getAllUserWithTask from '@salesforce/apex/UserDetails.getAllUserWithTask';
import deleteTask from '@salesforce/apex/UserDetails.deleteTask';
import addTask from '@salesforce/apex/UserDetails.addTask';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class UserSearch extends LightningElement {

    searchUser;
    isCompleted =false;
    wrapper;
    isLoading = false;
    tempLst;
    error;
    tasks = [];
    openmodel = false; 
    searchTask = '';
    id;
    color = '';
    value;
    wiredResult;
    wiredResultTask;

    handleCheckboxChange(event){
        const recordId = event.currentTarget.dataset.taskId;
        this.isCompleted = event.target.value;
        console.log(this.isCompleted);
       
       
        setTaskCompleted({status :'Completed' ,taskId : recordId }).then(res=>{  
            this.isCompleted = false;                          
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Task is Completed',
                        variant: 'success',
                    }),

            ); return refreshApex(this.wrapper);               
        }).catch(error => {
                this.error = error;
                
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Task status is not changed',
                        variant: 'error',
                    }),
            );
            });        
    
            this.tasks.forEach(element => {
                if(element.Id == recordId){
                    element.styleClass = 'blue slds-box slds-grid';
                    element.hidden = true;
                }else{
                    element.styleClass = 'slds-box slds-grid';
                }
            });
        }


    handleChange(event){
        this.searchUser = event.target.value;

        const filterItems = (searchUser, tempLst) => {
            let query = searchUser.toLowerCase();
            return tempLst.filter(item => item.objUser.Name.toLowerCase().indexOf(query) >= 0);
          }
          this.wrapper = filterItems(this.searchUser,this.tempLst);         
    }

    handleOpenModel(event){
        this.isLoading = true;
        this.openmodel = true;
        this.searchTask = '';  
       const userId = event.currentTarget.dataset.userId;
       this.id = userId;
       getTasksById({userId : userId})
        .then( result => {
            console.log("===============Result"+result);
            if(result != null){
            this.tasks = result;
            this.wiredResultTask = result;
            console.log('handle Open modal lst of tasks : '+this.tasks);
            this.tasks.forEach(element => {
                if(element.Status == "Completed"){
                    element.styleClass = 'blue slds-box slds-grid';
                    element.hidden = true;
                }else{
                    element.styleClass = 'slds-box slds-grid';
                }
            });
            }
            else {
                this.isLoading = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Record not found',
                        variant: 'error',
                    }),
            );
            }
            this.isLoading = false;
        })
        .catch(error => {
            this.wiredResultTask = error;
            this.error = error;
        })
    }

    handleCloseModal(){
        this.openmodel = false;
    }

    handleAddSubject(event){
        this.searchTask = event.target.value; 

    }

    keycheck(component, event, helper){
        console.log("KeyCheck Chala")
        if (component.which == 13){
            this.handleAddTask();
        }
    }

    handleDelete(event){
        this.isLoading = true;
        const recordId = event.currentTarget.dataset.taskId;
            deleteTask({taskId : recordId})
                .then(result  => { 
                    this.isLoading = false;
                                this.tasks=this.tasks.filter((a) => {
                                                                return a.Id != recordId
                                                            }, this);
                
                                this.dispatchEvent(
                                        new ShowToastEvent({
                                            title: 'Success',
                                            message: 'Record Is  Deleted',
                                            variant: 'success',
                                        }),
                                );
                                return refreshApex(this.wiredResult);
                })
                .catch(error => {
                    console.log("Error : : " +JSON.stringify(error));
                                this.dispatchEvent(
                                    new ShowToastEvent({
                                        title: 'Error While Deleting record',
                                        message: error.message,
                                        variant: 'error',
                                    }),
                                );
                });

    }


    handleAddTask(){
        const createTaskBySubject = this.searchTask;
        console.log(createTaskBySubject);
                this.isLoading = true;
                const newDate = new Date(); 
                this.dateValue = newDate.toISOString();
                console.log(createTaskBySubject);
                if(createTaskBySubject != ''){
                addTask({subject : createTaskBySubject,
                        userId : this.id,
                        recDate : this.dateValue,
                        priority : 'Normal',
                        status : 'In progress'})
                .then(result  => {
                    this.searchTask = '';
                    const object  = result;
                    console.log("-----------Object Result : "+JSON.stringify(result));
                    this.tasks.push(object);
                    this.isLoading = false;
                    this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Success',
                                message: 'Task is added',
                                variant: 'success',
                            }),
                    );
                    this.tasks.forEach(element => {
                        if(element.Status == "Completed"){
                            element.styleClass = 'blue slds-box slds-grid';
                            element.hidden = true;
                        }else{
                            element.styleClass = 'slds-box slds-grid';
                        }
                    });
                    return refreshApex(this.wiredResult,this.wiredResultTask);
                })
                .catch(error => {
                    console.log("Error : : " +JSON.stringify(error));
                });

            }else{
                this.isLoading = false;
                        this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'Please enter the subject',
                            variant: 'error',
                        }),
                    );
                }
        }

        handleChangeSubject(event) {
            this.value = event.detail.value;
        }
    
        handleChangeStatus(event){
            this.status = event.detail.value;
        }
    
        handleChangePriority(event){
            this.priority = event.detail.value;
        }
    

    @wire(getAllUserWithTask,)
    getWrapper(result){
        this.wiredResult = result;
        if(result.data){
          
            this.wrapper = result.data;
            this.tempLst = result.data;
        }else if(result.error){
            this.error = result.error;
            console.log(this.error);
        }
    }


}