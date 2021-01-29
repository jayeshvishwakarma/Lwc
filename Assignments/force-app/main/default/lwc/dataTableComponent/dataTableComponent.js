import { LightningElement, wire } from 'lwc';
import getContacts from '@salesforce/apex/DataTableController.getContacts';


export default class DataTableComponent extends LightningElement {
    lstContacts;
    tempLstContacts;
    error;
    search;
    optionsEntries;
    recordsPerPage = '5';
    page = 1;
    countOfAllRecords;
    countRecords = 5;
    isPrevButton = true;
    isNextButton = false;
    totalPages; 
    mapOfContacts;  
    sortedColumn; 
    sortedDirection;
    pageButtons = [];
    mapOfButtons;
    get options(){ 
        return [
                    {label : '5', value : '5'},
                    {label : '10', value : '10'},
                    {label : '15', value : '15'}
               ];
    }


    handleSearch(event){
        this.search = event.target.value;

        const filterItems = (search, tempLstContacts) => {
            let query = search.toLowerCase();
            return tempLstContacts.filter(item => item.Name.toLowerCase().indexOf(query) >= 0);
          }
          this.lstContacts = filterItems(this.search,this.tempLstContacts);  
          this.countRecords = this.lstContacts.length;       
    }

    handleChangeOptionEntries(event){
        this.recordsPerPage = event.target.value;
        this.countRecords = this.recordsPerPage;
        this.isNextButton = false;
        this.isPrevButton = true;
        this.createMapofContacts();
        this.createPagesByNumber();
    }

    createMapofContacts(){
        this.totalPages = Math.ceil(this.countOfAllRecords / this.recordsPerPage);
        let tempMapOfContacts = new Map();
        let tempArray = [];
        let i = 1;
        let j = 1;
        let k = 1;
        console.log('Map created......');
        this.tempLstContacts.forEach(e => {
            let obj = Object.assign({}, e);
            tempArray.push(obj);     
            if((i == this.recordsPerPage || k == this.countOfAllRecords) && j <= this.totalPages ){  
                console.log("temp list" + tempArray);
                tempMapOfContacts.set(j,tempArray);
                i = 0;
                j++;
                tempArray = [];
            }
            i++;    
            k++;    
            
        })
        this.mapOfContacts = tempMapOfContacts;
        this.lstContacts = this.mapOfContacts.get(1);
    }

    nextPage(){
        this.isPrevButton = false;
        this.page ++;
        if(this.page  == this.totalPages) this.isNextButton = true;
        this.lstContacts = this.mapOfContacts.get(this.page);
        this.countRecords = this.lstContacts.length;
    } 
    
    
    prevPage(){
        this.page --;
        this.isNextButton = false;
        if(this.page == 1) this.isPrevButton = true;
        if(this.page >= 1){
            this.lstContacts = this.mapOfContacts.get(this.page);
            this.countRecords = this.lstContacts.length;
        }
    }

    createPagesByNumber(){
        console.log('create by page number called');
        this.pageButtons = [];
        let totalPagesCount = Math.ceil(this.countOfAllRecords / this.recordsPerPage);
        console.log(totalPagesCount);
        for(let i = 1; i <= totalPagesCount; i++){
            console.log('inside loop');
            let temp = {
                label : i,
                value : i
               };
               console.log(temp);
               this.pageButtons.push(temp);
        }

        let x = 1;
        let map = new Map();
        let tempArray = [];

        for(let i = 0; i < this.pageButtons.length; i++){
            console.log('inside loop for creating map of buttons');
            tempArray.push(this.pageButtons[i]);
            if(x == 3){
               if(i == 2) {
                map.set(i-1,tempArray);
                map.set(i,tempArray);
               }
               if(i > 2){
                map.set(i,tempArray); 
               }

                tempArray = [];
                x = 0;   
                i = i - 2;             
            }
            x++;
        }
        this.mapOfButtons = map;
        console.log(this.mapOfButtons);
        this.pageButtons = this.mapOfButtons.get(1);
    }

    handleSort(e){

        if(this.sortedColumn === e.currentTarget.dataset.id){
            this.sortedDirection = this.sortedDirection === 'asc' ? 'desc' : 'asc';
        }else{
            this.sortedDirection = 'asc';
        }        
        var reverse = this.sortedDirection === 'asc' ? 1 : -1;
        let table = JSON.parse(JSON.stringify(this.lstContacts));
        table.sort((a,b) => {return a[e.currentTarget.dataset.id] > b[e.currentTarget.dataset.id] ? 1 * reverse : -1 * reverse});
        this.sortedColumn = e.currentTarget.dataset.id;        
        this.lstContacts = table;
    }

    getPage(event){
        const singlePage = event.currentTarget.dataset.pageNumber;
        console.log(singlePage);
        this.lstContacts = this.mapOfContacts.get(parseInt(singlePage));
        this.countRecords = this.lstContacts.length;
        if(this.mapOfButtons.get(parseInt(singlePage)) != null){
            this.pageButtons = this.mapOfButtons.get(parseInt(singlePage));
        }
    }



    @wire(getContacts,)
    getContacts(result){
        if(result.data){
            this.lstContacts = result.data;
            this.tempLstContacts = result.data;
            this.countOfAllRecords = this.lstContacts.length;
            this.createMapofContacts();
            this.createPagesByNumber();
            console.log(this.lstContacts);
        }else if(result.error){
            this.error = result.error;
            console.log(this.error);
        }
    }
}