import { LightningElement,api } from "lwc";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import USER_ID from '@salesforce/user/Id';
export default class AddProducts extends LightningElement {
 
  @api brands;
  sortingIcon = "";
  sortedColumn;
  sortedDirection = 'asc';
  allProducts;
  _products;
  error;
  selectedBrandValue = "Alle merken";
  productName;
  selectAllCheckbox = false;
  userSelectedProducts = {};

  @api
  get products() {
      return this.products;
  }

  set products(value) {
      if(value){       
        this.allProducts = JSON.parse(JSON.stringify(value));       
          this.allProducts.map(pro => {
            if(this.userSelectedProducts.hasOwnProperty(pro.Product2Id)){
              pro.selectedProduct = true;
              pro.hoeveelheid = this.userSelectedProducts[pro.Product2Id];
            }
          })       
        this._products = this.allProducts;
      }
  }
 
  handleSortProducts(event) { 
    console.log('idd : ',event.currentTarget.dataset.id);
      this.sortedDirection = this.sortedDirection === "asc" ? "desc" : "asc";
      this.sortingIcon = this.sortedDirection === "desc" ? 'utility:arrowdown' : 'utility:arrowup';
    
    let table = JSON.parse(JSON.stringify(this.allProducts));

    let direction =  this.sortedDirection;
    let fieldName = event.currentTarget.dataset.id;

    let results = table.sort(function(a,b){
      if(fieldName == 'Name' || fieldName == 'Description' ){
          if(a.Product2[fieldName] < b.Product2[fieldName])
            return direction === 'asc' ? -1 : 1;
          else if(a.Product2[fieldName] > b.Product2[fieldName])
            return direction === 'asc' ? 1 : -1;
          else
            return 0;
        }else{
            if(a[fieldName] < b[fieldName])
              return direction === 'asc' ? -1 : 1;
            else if(a[fieldName] > b[fieldName])
              return direction === 'asc' ? 1 : -1;
            else
              return 0;
        }
    })
    
    console.log('OUTPUT : ',results);
    this.allProducts = results;
  }

  handleProductSerach(event) {
    this.productName = event.target.value;
    const filterItems = (key, productsList) => {
      let query = key.toLowerCase();
      return productsList.filter(
        (item) => item.Product2.Name.toLowerCase().indexOf(query) >= 0
      );
    };
    this.allProducts = filterItems(this.productName, this._products);
  }

  handleSelectAllCheckbox(event) {
    this.selectAllCheckbox = event.currentTarget.checked;
    let tempProducts = [];
    let tempProductIds = [];
    this.allProducts.forEach((element) => {
      element.selectedProduct = this.selectAllCheckbox;
      tempProducts.push(element);
      if(this.selectAllCheckbox){
        this.userSelectedProducts[element.Product2Id] = element.hoeveelheid;        
      }       
      else{
        delete this.userSelectedProducts[element.Product2Id];
      }
        
    });
    this.allProducts = tempProducts; 
    this._products = tempProducts; 
  }

  handleProductSelection(event) {
    this.selectAllCheckbox = false;
    let tempProductIds = [];
    let pro = this.allProducts[event.currentTarget.dataset.index];
    this.allProducts[event.currentTarget.dataset.index].selectedProduct = event.currentTarget.checked;
    if(event.currentTarget.checked){
     this.userSelectedProducts[pro.Product2Id] = pro.hoeveelheid;
    }else {
     delete this.userSelectedProducts[pro.Product2Id];
    }

    this.productIds = tempProductIds;
    this._products = JSON.parse(JSON.stringify(this.allProducts));
  }

  handleBrandChange(event) {
    this.selectAllCheckbox = false;
        this.dispatchEvent(new CustomEvent('selectbrand', {
            detail: event.target.value
        }));
  }

  handleHoeveelheidChange(event){ 
    let proId = this.allProducts[event.currentTarget.dataset.index].Product2Id;
    this.allProducts[event.currentTarget.dataset.index].hoeveelheid = event.currentTarget.value;
      if(this.userSelectedProducts.hasOwnProperty(proId)){
        this.userSelectedProducts[proId] = event.currentTarget.value;
      }
    this._products = JSON.parse(JSON.stringify(this.allProducts));
  }

  handleBestellenClick(){
      let products = [];
      for (const key in this.userSelectedProducts) {
          products.push(`${key}#${this.userSelectedProducts[key]}`);      
      }
      if(products.length != 0){
        document.cookie = "product_info=" + products.join('@') + ";path=/";
        if(!USER_ID){
            window.location.href = 'https://www.cloudeen.nl/s/login';  
        }else {
         window.location.href = '/kpneen/s/cart';
        }
      }else{
          const noProductSelected = new ShowToastEvent({
                    title : "No Selected Product",
                    message : 'Select minimaal één product',
                    variant : "error",
                    mode : "dismissable"
                })  
                this.dispatchEvent(noProductSelected);
      }  
  }
}