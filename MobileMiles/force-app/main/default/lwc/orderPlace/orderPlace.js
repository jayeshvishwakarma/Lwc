import { LightningElement, track, wire } from 'lwc';
import FORM_FACTOR from '@salesforce/client/formFactor';
import fetchProducts from "@salesforce/apex/AddProductsControllerClone.fetchProducts";
import getBrandsName from "@salesforce/apex/AddProductsControllerClone.getBrandsName";

export default class OrderPlace extends LightningElement {

    @track selectedBrand = 'Alle merken';
    @track allProducts;
    @track allBrands;
    @track userSelectedProducts;
    @track isSpinner = false;
    @track processOrderScreen = false;

    @wire(fetchProducts, { selectedBrand: '$selectedBrand' })
    lstProduct({ data, error }) {
        if (data) {
            let productsMap = data.map(element => {
                let product = Object.assign({}, element);
                if (element.Product2 && element.Product2.hasOwnProperty('Productfoto__c') && element.Product2.Productfoto__c) {
                    product['imgURL'] = element.Product2.Productfoto__c.split('"')[1].replaceAll(/&amp;/gi, '&');
                    product['selectedProduct'] = false;
                    product['hoeveelheid'] = 1;
                }
                return product;
            });
            this.allProducts = productsMap;
            this.isSpinner = false;
        } else if (error) {
            console.log('OUTPUT : ', error);
            this.isSpinner = false;
        }
    }

    @wire(getBrandsName)
    options({ data, error }) {
        if (data) {
            this.allBrands = data;
            console.log(data);
        } else if (error) {
            console.log('OUTPUT : ', error);
        }
    }

    handleUserSelection(event) {
        this.userSelectedProducts = JSON.parse(JSON.stringify(event.detail));
        this.processOrderScreen = true;
    }

    handleSelectedBrand(event) {
        this.isSpinner = true;
        this.selectedBrand = event.detail;
    }


    get hasMobileDevice() {
        return (FORM_FACTOR == 'Small' || FORM_FACTOR == 'Medium');
    }

}