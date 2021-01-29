({
	navigate: function (component, type) {
        console.log('EMI Button Type ' + type);
        component.get("v.navigateFlow")(type);
    }
})