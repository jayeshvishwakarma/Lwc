import { LightningElement, track, wire } from 'lwc';
import getAccounts from "@salesforce/apex/AddProductsControllerClone.getAccounts";
import changeAccount from "@salesforce/apex/AddProductsControllerClone.changeAccount";
import createRecord from "@salesforce/apex/AddProductsControllerClone.createRecord";
import getProducts from "@salesforce/apex/AddProductsControllerClone.getProducts";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const VAT_PERCENTAGE = 21;

export default class PlaceOrder extends LightningElement {
    selectedProducts;
    accountOptions;
    @track totalAmounts = { amount: 0, vat: 0, paidAmount: 0 };
    error;
    @track selectedAccount;
    inkoopnummer;
    responseWrapper;
    productsFromCookie;

    @track isSpinner = false;

    get applianceInsurancOptions() {
        return [
            { label: "--None--", value: "none" },
            { label: "Totaal", value: "Totaal" },
            { label: "Schade", value: "Schade" }
        ];
    }

    @wire(getAccounts)
    Accounts({ data, error }) {
        if (data) {
            this.accountOptions = data;
            this.selectedAccount = data[0].value;
        } else if (error) {
            this.error = error;
        }
    }

    @wire(changeAccount, { selectedAccount: '$selectedAccount' })
    responses({ data, error }) {
        if (data) {
            this.responseWrapper = data;
        } else if (error) {
            this.error = error;
        }
    }

    async connectedCallback() {
        try {
            let products = {};
            let productQuantity = await this.getCookie("product_info");
            if (productQuantity) {
                productQuantity.split("@").forEach(pro => {
                    products[pro.split("#")[0]] = pro.split("#")[1];
                })
            }
            if (Object.keys(products).length) {
                this.productsFromCookie = JSON.parse(JSON.stringify(products));
                this.getSelectedProducts(Object.keys(products));
            }
        } catch (error) {
            console.log('error : ', error);
        }
    }

    async getCookie(name) {
        var nameEQ = name + "=";
        var ca = document.cookie.split(';');
        for (var i = 0; i < ca.length; i++) {
            var c = ca[i];
            while (c.charAt(0) == ' ') c = c.substring(1, c.length);
            if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length, c.length);
        }
        return null;
    }

    getSelectedProducts(productIds) {
        getProducts({ productIds })
            .then(result => {
                let data = result.map(pro => {
                    let item = {};
                    item.Product2 = pro;
                    item.Pricebook2 = pro.PricebookEntries[0]
                    item.UnitPrice = pro.PricebookEntries[0].UnitPrice;
                    item.hoeveelheid = parseInt(this.productsFromCookie[pro.Id]);
                    item.applianceInsuranc = 'none';
                    item.totalPerMonth = 0;
                    return item;
                });
                this.selectedProducts = JSON.parse(JSON.stringify(data));
                this.calculateTaOrPayable();
            })
            .catch(error => {
                console.error('Error:', error);
            });
    }

    calculateTaOrPayable() {
        let totalAmount = 0;
        let products = [];
        this.selectedProducts.forEach(item => {
            let pro = Object.assign({}, item), totalPerMonth = 0;
            totalAmount += (pro.UnitPrice * parseInt(pro.hoeveelheid));
            if (pro.applianceInsuranc != 'none') {
                if (pro.UnitPrice < 501 && pro.applianceInsuranc == 'Schade')
                    totalPerMonth = 8.99;
                else if (pro.UnitPrice < 501 && pro.applianceInsuranc == 'Totaal')
                    totalPerMonth = 10.99;
                else if (pro.UnitPrice < 651 && pro.applianceInsuranc == 'Schade')
                    totalPerMonth = 9.99;
                else if (pro.UnitPrice < 651 && pro.applianceInsuranc == 'Totaal')
                    totalPerMonth = 12.99;
                else if (pro.UnitPrice < 901 && pro.applianceInsuranc == 'Schade')
                    totalPerMonth = 11.99;
                else if (pro.UnitPrice < 901 && pro.applianceInsuranc == 'Totaal')
                    totalPerMonth = 13.99;
                else if (pro.UnitPrice > 901 && pro.applianceInsuranc == 'Schade')
                    totalPerMonth = 13.99;
                else if (pro.UnitPrice > 901 && pro.applianceInsuranc == 'Totaal')
                    totalPerMonth = 16.99;
            }
            pro.totalPerMonth = totalPerMonth * pro.hoeveelheid;
            products.push(pro);
        });

        let obj = {
            amount: totalAmount,
            vat: Number(totalAmount * (VAT_PERCENTAGE / 100)).toFixed(2),
            paidAmount: Number(totalAmount + Number(totalAmount * (VAT_PERCENTAGE / 100))).toFixed(2)
        }
        this.totalAmounts = Object.assign({}, obj);
        this.selectedProducts = Object.assign([], products);
    }

    handleAccountOptionChange(event) {
        this.selectedAccount = event.currentTarget.value;
    }

    handlePaymentMethodChnage(event) {
        let response = JSON.parse(JSON.stringify(this.responseWrapper));
        response.objAccount.Betaalwijze_bestelling__c = event.target.value;
        this.responseWrapper = JSON.parse(JSON.stringify(response));;
    }

    handleQuantityChange(event) {
        let value = event.target.value;
        this.selectedProducts[event.currentTarget.dataset.index].hoeveelheid = (value.trim().length ? value : 0);
        this.calculateTaOrPayable();
    }

    handleRemoveProduct(event) {
        if (this.selectedProducts.length > 1) {
            let data = [...this.selectedProducts];
            data.splice(event.currentTarget.dataset.index, 1);
            this.selectedProducts = [...data];

            let products = [...this.selectedProducts].map(item => {
                return `${item.Product2.Id}#${item.hoeveelheid}`;
            });
            console.log('products : ',products);
            document.cookie = "product_info=" + products.join('@') + ";path=/";
            this.calculateTaOrPayable();
        } else {
            this.showNotification("Er moet minimaal één product worden geselecteerd", "error");
        }
    }

    handleChangeApplianceInsuranc(event) {
        this.selectedProducts[event.currentTarget.dataset.index].applianceInsuranc = event.target.value;
        this.calculateTaOrPayable();
    }

    handleBestellingClick() {
        this.isSpinner = true;
        let data = this.selectedProducts.map(pro =>{
            return {
                productId : pro.Product2.Id,
                productName : pro.Product2.Name,
                pricebook2Id : pro.Pricebook2.Pricebook2Id,
                unitPrice : pro.UnitPrice,
                quantity : pro.hoeveelheid,
                applianceInsuranc : pro.applianceInsuranc,
                totalPerMonth : pro.totalPerMonth
            }
        });

        createRecord({
            response: this.responseWrapper,
            products: JSON.stringify(data),
            inkoopnummer: this.inkoopnummer
        }).then(result => {
            if (result == 'success') {
                document.cookie = "product_info= ;path=/";
                window.location.href = '/kpneen/s/add-products-thankyou-page';
            } else if(result != 'success'){
                window.location.href = result;
            }
            this.isSpinner = false;
        }).catch(error => {
            console.log('error : ', error);
            this.isSpinner = false;
            this.showNotification(error.body.message || error.message, 'error');
        })

    }
    showNotification(msg, variant) {
        const noProductSelected = new ShowToastEvent({
            message: msg,
            variant: variant,
        })
        this.dispatchEvent(noProductSelected);
    }

    handleInputChange(event) {
        let response = JSON.parse(JSON.stringify(this.responseWrapper));
        response.objAccount[event.target.name] = event.target.value;
        this.responseWrapper = JSON.parse(JSON.stringify(response));;
    }

    handleInkoopnummerChange(event) {
        this.inkoopnummer = event.currentTarget.value;
    }
}