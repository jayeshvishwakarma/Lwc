import { api, LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import USER_ID from '@salesforce/user/Id';

export default class ProductsOnMobileMode extends LightningElement {

    @api brands = [];

    @track allProducts;
    @track filteredProducts;
    @track userSelectedProducts = new Map();
    @track selectedProductCount = 0;
    sortDirection = 'asc';

    @api get products() {
        return this.products;
    }
    set products(value) {
        if (value) {
            this.allProducts = JSON.parse(JSON.stringify(value));
            this.filteredProducts = JSON.parse(JSON.stringify(value));
        }
    }

    handleProductSelection(event) {
        let selectedProductId = event.currentTarget.dataset.productId;
        if (!this.userSelectedProducts.has(selectedProductId)) {
            let filterProduct = this.allProducts.filter(el => el.Product2Id === selectedProductId);
            this.userSelectedProducts.set(selectedProductId, { ...filterProduct[0] });
        }
        this.selectedProductCount = this.userSelectedProducts.size;
    }

    handleSubmit() {
        if (!this.selectedProductCount) {
            this.showNotification('Select minimaal één product', 'error');
            return;
        }

        let selectedProduct = [...this.userSelectedProducts.values()].map(item => {
            return `${item.Product2Id}#1`;
        });
        document.cookie = "product_info=" + selectedProduct.join('@') + ";path=/";

        if (!USER_ID) {
            window.location.href = 'https://www.cloudeen.nl/s/login';
        } else {
            window.location.href = '/kpneen/s/cart';
        }
        /*  this.dispatchEvent(new CustomEvent('selectedproducts', {
             detail:  [...this.userSelectedProducts.values()]
         })); */
    }

    handleBrandChange(event) {
        this.dispatchEvent(new CustomEvent('selectbrand', {
            detail: event.target.value
        }));
    }

    sortData(fieldName, sortDirection) {
        let sortResult = Object.assign([], this.filteredProducts);
        this.filteredProducts = sortResult.sort(function (a, b) {
            if (a[fieldName].Name < b[fieldName].Name)
                return sortDirection === 'asc' ? -1 : 1;
            else if (a[fieldName].Name > b[fieldName].Name)
                return sortDirection === 'asc' ? 1 : -1;
            else
                return 0;
        })
    }

    handleDataSorting() {
        this.sortDirection = this.sortDirection == 'asc' ? 'desc' : 'asc';
        this.sortData('Product2', this.sortDirection);
    }

    handleProductSearching(event) {
        let searchTerm = event.target.value;
        if (searchTerm.length && searchTerm.trim().length) {
            let filterProduct = this.allProducts.filter(el => el.Product2.Name.toLowerCase().includes(searchTerm.trim().toLowerCase()));
            this.filteredProducts = [...filterProduct];
        } else {
            this.filteredProducts = [...this.allProducts];
        }
    }

    openFilterPanel() {
        this.template.querySelector('.filterPanel').style.width = "80%";
        this.template.querySelector('.sidepanel_backdrop').style.display = "block";
    }

    closeFilterPanel() {
        this.template.querySelector('.filterPanel').style.width = "0";
        this.template.querySelector('.sidepanel_backdrop').style.display = "none";
    }

    showNotification(m, v) {
        this.dispatchEvent(new ShowToastEvent({
            message: m,
            variant: v
        }));
    }

}