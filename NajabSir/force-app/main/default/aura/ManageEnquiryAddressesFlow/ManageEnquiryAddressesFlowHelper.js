({
  validate: function(cmp) {
    return cmp
      .find("content")
      .validate()
      .then(result => {
        if (result.isValid) {
          cmp.set(
            "v.record",
            Object.assign(cmp.get("v.record"), result.record)
          );
          cmp.set("v.outCity", result.outCity);
          cmp.set("v.outPincode", result.outPincode);
          cmp.set("v.outVillage", result.outVillage);
          cmp.set("v.outTehsil", result.outTehsil);
        } else {
          cmp.set("v.errorMessage", result.errorMessage);
        }
        return result.isValid;
      });
  },
  navigate: function(cmp, type) {
    cmp.get("v.navigateFlow")(type);
  }
});