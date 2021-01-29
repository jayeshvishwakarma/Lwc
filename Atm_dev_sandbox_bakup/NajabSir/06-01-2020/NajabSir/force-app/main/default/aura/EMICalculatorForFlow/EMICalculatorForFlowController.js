({
    handleEmiCalc: function(component, event) {
        var premium = event.getParam('premium');
        var financeAmt = event.getParam('financeAmt');
        component.set('v.emiPremium', premium);
        component.set('v.financeAmt', financeAmt);
    },
    
    selectFinancier: function(component, event) {
        console.log('== On Financier Select');
        
        var financierName = event.getParam('financireName');
        var financierId = event.getParam('financireId');
        component.set('v.financierName', financierName);
        component.set('v.financierId', financierId);
    },
    
    handlePrevious: function(component, event, helper) {
        console.log('== On handlePrevious');
        helper.navigate(component, "BACK");
    },
    
    handleNext: function(component, event, helper) {
        console.log('== On handleNext');
        console.log('== On financeAmt', event.getParam('financeAmt'));
        component.set('v.financeAmt', event.getParam('financeAmt'));
        component.set('v.emiRate', event.getParam('emiRate'));
        component.set('v.emiTenure', event.getParam('emiTenure'));
        component.set('v.downpayment', event.getParam('downpayment'));
        helper.navigate(component, "NEXT");
    },
});