({  validate: function(component, event) {
        var isValid = true;
        var allAccountRows = component.get("v.SampleProductParent");
        for (var indexVar = 0; indexVar < allAccountRows.length; indexVar++) {
            if (allAccountRows[indexVar].Name == '') {
                isValid = false;
                
            }
        }
        return isValid;
    },

})