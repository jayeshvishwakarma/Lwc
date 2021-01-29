({
    
    /* Create method of CRUD */
    insertRaw: function(component, event, helper, input, callbackFunction) {
        // initializations//
        var cleanObjectArray = [];
        var returnableResponse;
        
        //clone the object
        var inputForClean;
        
        if (input !== undefined && input !== null) {
            inputForClean = JSON.parse(JSON.stringify(input));
        } else {
            inputForClean = undefined;
        }
        
        var errorAndClean = this.cleanForInsert(inputForClean);
        
        // if error messages are 0 in input
        if (errorAndClean.errorMessages.length == 0) {
            cleanObjectArray = errorAndClean.cleanArray;
            ///////////////////////////////////////processing if clean object list is returned//////////////////////
            ////////////////////////////////initialization of essential variables////////////
            var errorList = [];
            var statusList = [];
            var returnableObjectList = [];
            /////////////////////////////////////////////////////////////////////////////////
            var insertAction = component.get("c.InsertSObjects");
            insertAction.setParams({
                inputSObjectList: cleanObjectArray
            });
            
            insertAction.setCallback(this, function(response) {
                
                
                
                if (response.getState() == 'SUCCESS') {
                   var responseValue = response.getReturnValue();
                   var errorCount = 0;
                    for (var i = 0; i < cleanObjectArray.length; i++) {
                        
                        if (responseValue[i].success == false) {
                            errorList[errorCount] = {};
                            errorList[errorCount]["errorMesssages"] = responseValue[i].errorCodeList;
                            errorList[errorCount]["index"] = i;
                            errorCount++;
                        } else {
                            cleanObjectArray[i]["Id"] = responseValue[i].sObjID;
                        }
                        statusList[i] = (responseValue[i].success ? "successful" : "unsuccessful");
                        returnableObjectList[i] = {
                            "sObject": cleanObjectArray[i],
                            "status": statusList[i]
                        };
                    }
                    //check errorList length and return result accordingly
                    if(errorList.length==0){
                        returnableResponse = {
                            "sobjectsAndStatus": returnableObjectList,
                            "errorArrays": null,
                            "inputErrors": null,
                            "exception" :null
                        };      
                    }else{
                        returnableResponse = {
                            "sobjectsAndStatus": returnableObjectList,
                            "errorArrays": errorList,
                            "inputErrors": null,
                            "exception" :null
                        };    
                    }
                    
                } else if (response.getState() == 'ERROR') {
                    
                    var exceptionObject=insertAction.getError();
                    
                    returnableResponse = {
                        "sobjectsAndStatus": null,
                        "errorArrays": null,
                        "inputErrors": null,
                        "exception" : exceptionObject
                    }
                    
                }
                returnableResponse = JSON.parse(JSON.stringify(returnableResponse));
                callbackFunction(returnableResponse);
            });
            $A.enqueueAction(insertAction);
        } else {
            returnableResponse = {
                "sobjectsAndStatus": null,
                "errorArrays": null,
                "inputErrors": errorAndClean.errorMessages,
                "exception" :null
            };
            returnableResponse = JSON.parse(JSON.stringify(returnableResponse));
            callbackFunction(returnableResponse);
        }
    },
    
    /* Read method of CRUD */
    readRaw: function(component, event, helper, query, callbackFunction) {
        
        var inputErrorArray = [];
        
        ////////////////////////validate query////////////////
        if (query === undefined || query === null) {
            inputErrorArray.push("query cannot be undefined or null...");
        } else if (typeof(query) != "string") {
            inputErrorArray.push("query should be string...");
        } else if ((typeof(query) == "string") && (query == "")) {
            inputErrorArray.push("query should not be an empty string...");
        }
        
        /////////////////////////////////////////////////////
        var responseValue={};
        
        if (inputErrorArray.length == 0) {
            var readAction = component.get("c.ReadSObjects");
            readAction.setParams({
                query: query
            });
            readAction.setCallback(this, function(response) {
        
                var returnedValue=response.getReturnValue();
                
                if(returnedValue.sObjList==null){
                    
                    var exceptionObject=readAction.getError();
                    responseValue = {
                        "sObjectList": null,
                        "inputErrorArray": null,
                        "sObjectApiName":null,
                        "sObjectLabel":null,
                        "exception": "Something Wrong with query...."
                        
                    };
                    
                    
                }else if (response.getState() == 'SUCCESS') {
                    
                    responseValue = {
                        "sObjectList": returnedValue.sObjList,
                        "inputErrorArray": null,
                        "sObjectApiName":returnedValue.sObjectApiName,
                        "sObjectLabel":returnedValue.sObjectLabel,
                        "exception":null
                    };
                    
                    
                }else if (response.getState() == 'ERROR') {
                    
                    var exceptionObject=readAction.getError();
                    responseValue = {
                        "sObjectList": null,
                        "inputErrorArray": null,
                        "sObjectApiName":null,
                        "sObjectLabel":null,
                        "exception":exceptionObject
                        
                    };
                    
                }
                
                responseValue = JSON.parse(JSON.stringify(responseValue));
                callbackFunction(responseValue);    
            });
            $A.enqueueAction(readAction);
        } else {
            
            responseValue={
                
                "sObjectList": null,
                "inputErrorArray": inputErrorArray,
                "sObjectApiName":null,
                "sObjectLabel":null,
                "exception":null
                
            };
            responseValue = JSON.parse(JSON.stringify(responseValue));
            callbackFunction(responseValue);
        }
        
    },
    
    /* Update method of CRUD */
    updateRaw: function(component, event, helper, input, callbackFunction) {
        // initializations//
        var cleanObjectArray = [];
        var returnableResponse;
        
        //clone the object
        var inputForClean;
        
        if ((input !== undefined) && (input !== null)) {
            inputForClean = JSON.parse(JSON.stringify(input));
        } else {
            inputForClean = undefined;
        }
        var errorAndClean = this.cleanForUpdate(inputForClean);
        
        // if error messages are 0 in input
        if (errorAndClean.errorMessages.length == 0) {
            cleanObjectArray = errorAndClean.cleanArray;
            ///////////////////////////////////////processing if clean object list is returned//////////////////////
            ////////////////////////////////initialization of essential variables////////////
            var updateAction = component.get("c.UpdateSObjects");
            var statusArray = [];
            var errorList = [];
            var returnableObjectList = [];
            
            updateAction.setParams({
                inputSObjectList: cleanObjectArray
            });
            updateAction.setCallback(this, function(response) {
                
                if (response.getState() == 'SUCCESS') {
                    var responseValue = response.getReturnValue();
                    var errorCount = 0;
                    
                    for (var i = 0; i < cleanObjectArray.length; i++) {
                        if (responseValue[i].success == false) {
                            errorList[errorCount] = {};
                            errorList[errorCount]["errorMesssages"] = responseValue[i].errorCodeList;
                            errorList[errorCount]["index"] = i;
                            errorList[errorCount]["id provided"] = cleanObjectArray[i]["Id"];
                            cleanObjectArray[i]["Id"] = null;
                            errorCount++;
                        } else {
                            cleanObjectArray[i]["Id"] = responseValue[i].sObjID;
                        }
                        statusArray[i] = (responseValue[i].success ? "successful" : "unsuccessful");
                        returnableObjectList[i] = {
                            "sObject": cleanObjectArray[i],
                            "status": statusArray[i]
                            
                        };
                        
                    }
                    
                    //check for errorList length and return response accordingly
                    if(errorList.length==0){
                        returnableResponse = {
                            "sobjectsAndStatus": returnableObjectList,
                            "errorList": null,
                            "inputErrors": null,
                            "exception":null
                        };  
                    }else{
                        returnableResponse = {
                            "sobjectsAndStatus": returnableObjectList,
                            "errorList": errorList,
                            "inputErrors": null,
                            "exception":null
                        };  
                    }
                    
                } else if (response.getState() == 'ERROR') {
                    
                    var exceptionObject=updateAction.getError();
                    returnableResponse = {
                        "sobjectsAndStatus": null,
                        "errorList": null,
                        "inputErrors": null,
                        "exception": exceptionObject
                    };
                }
                returnableResponse = JSON.parse(JSON.stringify(returnableResponse));
                callbackFunction(returnableResponse);
            });
            $A.enqueueAction(updateAction);
        } else {
            
            returnableResponse={
                "sobjectsAndStatus": null,
                "errorList": null,
                "inputErrors": errorAndClean.errorMessages,
                "exception":null
            };
            returnableResponse = JSON.parse(JSON.stringify(returnableResponse));
            callbackFunction(returnableResponse);
        }
    },
    
    /* Delete method of CRUD */
    deleteRaw: function(component, event, helper, input, callbackFunction) {
        
        var inputClone;
        var returnableResponse;
        if (input != undefined) {
            inputClone = JSON.parse(JSON.stringify(input));
        }
        
        ////////////////////////////input filter////////////////////////////////////
        var filterResponse = this.inputFilterForDelete(inputClone);
        ///////////////////////////////////////////////////////////////////////////
        
        if (filterResponse.inputErrors == null) {
            
            inputClone = filterResponse.filteredInput;
            var statusArray = [];
            var errorList = [];
            var deleteAction = component.get("c.DeleteSObjects");
            
            deleteAction.setParams({
                inputSObjectList: inputClone
            });
            deleteAction.setCallback(this, function(response) {
                
                if (response.getState() == 'SUCCESS') {
                    var returnedValues = response.getReturnValue();
                    
                    if (returnedValues.length != 0) {
                        var errorCount = 0;
                        for (var i = 0; i < inputClone.length; i++) {
                            
                            statusArray[i] = returnedValues[i].success;
                            if (statusArray[i] == false) {
                                errorList[errorCount] = {};
                                errorList[errorCount]["errorMessages"] = returnedValues[i].errorCodeList;
                                errorList[errorCount]["index"] = i;
                                errorList[errorCount]["sObjectId"] = inputClone[i].Id;
                                errorCount++;
                            }
                        }
                        // check if backend errors are null, asssign errorList to null
                        if (errorList.length == 0) {
                            errorList = null;
                        }
                    }
                    returnableResponse = {
                        "statusArray": statusArray,
                        "errorList": errorList,
                        "inputErrorsArray": null,
                        "exception": null
                    };
                    returnableResponse = JSON.parse(JSON.stringify(returnableResponse));
                    callbackFunction(returnableResponse);
                    
                    
                }else{
                    
                    var exceptionObject=deleteAction.getError();
                    returnableResponse = {
                        "statusArray": null,
                        "errorList": null,
                        "inputErrorsArray": null,
                        "exception": exceptionObject
                    };
                    returnableResponse = JSON.parse(JSON.stringify(returnableResponse));
                    callbackFunction(returnableResponse);
                    
                }
            });
            $A.enqueueAction(deleteAction);
            
        } else {
            returnableResponse = {
                "statusArray": null,
                "errorList": null,
                "inputErrorsArray": filterResponse.inputErrors,
                "exception": null
            };
             returnableResponse = JSON.parse(JSON.stringify(returnableResponse));
             callbackFunction(returnableResponse);
        }
        
    },
    
    /* Report count method */
    totalRecordCountInReport: function(component, event, helper, reportId, callback) {
        var errorArray = [];
        var returnable = {};
        
        if (typeof(reportId) != "string") {
            errorArray.push("element provided should be of string type");
        }
        if ((typeof(reportId) == "string") && (reportId == "")) {
            errorArray.push("element provided should not be empty string");
        }
        
        if (errorArray.length == 0) {
            
            var readCountsAction = component.get("c.totalRecordsCount");
            
            readCountsAction.setParams({
                reportId: reportId
            });
            
            readCountsAction.setCallback(this, function(response) {
                if (response.getState() == "SUCCESS") {
                    
                    returnable.recordCount = response.getReturnValue();
                    returnable.errorsInInput = null;
                    returnable.errorResponse = null;
                    callback(returnable);
                } else {
                    returnable.recordCount = null;
                    returnable.errorResponse = "ERROR OCCURED";
                    returnable.errorsInInput = null;
                    callback(returnable);
                }
            });
            $A.enqueueAction(readCountsAction);
            
        } else {
            returnable.recordCount = null;
            returnable.errorsInInput = errorArray;
            returnable.errorResponse = null;
            callback(returnable);
        }
    },
    
    /* update force method */
    updateForce: function(component, event, helper, input, callbackFunction){
        // initializations//
        var cleanObjectArray = [];
        var returnableResponse;
        
        //clone the object
        var inputForClean;
        
        if ((input !== undefined) && (input !== null)) {
            inputForClean = JSON.parse(JSON.stringify(input));
        } else {
            inputForClean = undefined;
        }
        var errorAndClean = this.cleanForUpdate(inputForClean);
        
        // if error messages are 0 in input
        if (errorAndClean.errorMessages.length == 0) {
            cleanObjectArray = errorAndClean.cleanArray;
            ///////////////////////////////////////processing if clean object list is returned//////////////////////
            ////////////////////////////////initialization of essential variables////////////
            var updateAction = component.get("c.UpdateForceSObjects");
            var statusArray = [];
            var errorList = [];
            var returnableObjectList = [];
            
            updateAction.setParams({
                inputSObjectList: cleanObjectArray
            });
            updateAction.setCallback(this, function(response) {
                
                if (response.getState() == 'SUCCESS') {
                    var responseValue = response.getReturnValue();
                    var errorCount = 0;
                    
                    for (var i = 0; i < cleanObjectArray.length; i++) {
                        if (responseValue[i].success == false) {
                            errorList[errorCount] = {};
                            errorList[errorCount]["errorMesssages"] = responseValue[i].errorCodeList;
                            errorList[errorCount]["index"] = i;
                            errorList[errorCount]["id provided"] = cleanObjectArray[i]["Id"];
                            cleanObjectArray[i]["Id"] = null;
                            errorCount++;
                        } else {
                            cleanObjectArray[i]["Id"] = responseValue[i].sObjID;
                        }
                        
                        
                        
                        statusArray[i] = (responseValue[i].success ? "successful" : "unsuccessful");
                        returnableObjectList[i] = {
                            "sObject": cleanObjectArray[i],
                            "status": statusArray[i]
                        };
                        
                    }
                    
                    //check for errorList length and return response accordingly
                    if(errorList.length==0){
                        returnableResponse = {
                            "sobjectsAndStatus": returnableObjectList,
                            "errorList": null,
                            "inputErrors": null,
                            "exception":null
                        };  
                    }else{
                        returnableResponse = {
                            "sobjectsAndStatus": returnableObjectList,
                            "errorList": errorList,
                            "inputErrors": null,
                            "exception":null
                        };  
                    }
                    
                } else if (response.getState() == 'ERROR') {
                    
                    var exceptionObject=updateAction.getError();
                    returnableResponse = {
                        "sobjectsAndStatus": null,
                        "errorList": null,
                        "inputErrors": null,
                        "exception": exceptionObject
                    };
                }
                returnableResponse = JSON.parse(JSON.stringify(returnableResponse));
                callbackFunction(returnableResponse);
            });
            $A.enqueueAction(updateAction);
        } else {
            
            returnableResponse={
                "sobjectsAndStatus": null,
                "errorList": null,
                "inputErrors": errorAndClean.errorMessages,
                "exception":null
            };
            returnableResponse = JSON.parse(JSON.stringify(returnableResponse));
            callbackFunction(returnableResponse);
        }
    
    },
    
    /* Utility methods */
    cleanForInsert : function(input){
        // initializations//
        var errorArray = [];
        var returnable = {};
        var cleanArray = [];
        
        /////////////////////////////////////////////////for insert operation//////////////////////////////////////////////////////////
        
        
        if ((input !== undefined) && (input !== null) && (Array.isArray(input))) {
            
            if (input.length != 0) {
                
                if (input[0].constructor == Array) {
                    errorArray.push("input element in list cannot be array...");
                } else if (typeof(input[0]) == "object") {
                    
                    // do cleaning
                    for (var i = 0; i < input.length; i++) {
                        var inputObject = input[i];
                        var cleanObject = {};
                        
                        // check for sObjectType key
                        if (inputObject["sobjectType"] != undefined && inputObject["sobjectType"] != null && inputObject["sobjectType"] != "") {
                            cleanObject.sobjectType = inputObject["sobjectType"];
                        } else {
                            errorArray.push("error at input [ " + i + " ] = sObjectType attribute is not given or empty");
                        }
                        // add other attributes in this object
                        for (key in inputObject) {
                            
                            if ((key != "sobjectType") && (!this.strEndsWith(key, "__r")) && (typeof(input[key])!="object") ) {
                                cleanObject[key] = inputObject[key];
                            }
                        }
                        // assign clean object in clean array
                        cleanArray[i] = cleanObject;
                    }
                } else {
                    errorArray.push("input element in list cannot be " + typeof(input[0]) + " type...");
                }
            } else {
                errorArray.push("input element provided is empty javascript array...");
            }
        } else {
            
            
            if (typeof(input) == "object") {
                var cleanObject = {};
                
                // check for sObjectType key
                
                if ((input["sobjectType"] !== undefined) && (input["sobjectType"] !== null) && (input["sobjectType"] !== "")) {
                    cleanObject.sobjectType = input["sobjectType"];
                } else {
                    errorArray.push("error at input, sobjectType attribute is not given or empty");
                }
                
                
                // add other attributes in this object
                for (var key in input) {
                    
                    if ((key != "sobjectType") && (!this.strEndsWith(key, "__r")) && (typeof(input[key]!="object"))) {
                        cleanObject[key] = input[key];
                    }
                }
                
                // assign clean object in clean array
                cleanArray[0] = cleanObject;
            } else {
                errorArray.push("input should be array of javascript objects or a single javascript object in sObject format");
            }
        }
        
        ////////////////////////////////////////make a set of output and return////////////////////////////////////////////////////////////
        returnable.errorMessages = errorArray;
        returnable.cleanArray = cleanArray;
        return returnable;
    },
    cleanForUpdate : function(input){
        
        // initializations//
        var errorArray = [];
        var returnable = {};
        var cleanArray = [];
        
        if ((input !== undefined) && (input !== null) && (Array.isArray(input))) {
            if (input.length != 0) {
                if (input[0].constructor == Array) {
                    errorArray.push("input element in list cannot be array...");
                } else if (typeof(input[0]) == "object") {
                    // do cleaning
                    for (var i = 0; i < input.length; i++) {
                        var inputObject = input[i];
                        var cleanObject = {};
                        
                        // check for Id key
                        if ((inputObject["Id"] !== undefined) && (inputObject["Id"] !== null) && (inputObject["Id"] != "")) {
                            cleanObject.Id = inputObject["Id"];
                        } else {
                            errorArray.push("error at input[ " + i + " ]= Id attribute is not given or empty");
                        }
                        
                        // add other attributes in this object
                        for (var key in inputObject) {
                            if ((key != "sobjectType") && (key != "Id") && (!this.strEndsWith(key, "__r")) && (typeof(inputObject[key])!="object")) {
                                cleanObject[key] = inputObject[key];
                            }
                        }
                        // assign clean object in clean array
                        cleanArray[i] = cleanObject;
                    }
                    
                } else {
                    errorArray.push("input element in list cannot be " + typeof(input[0]) + " type...");
                }
            } else {
                errorArray.push("input element provided is empty javascript array...");
            }
        } else {
            
            
            if (typeof(input) == "object") {
                var cleanObject = {};
                
                // check for Id key
                if ((input["Id"] !== undefined) && (input["Id"] !== null) && (input["Id"] !== "")) {
                    cleanObject.Id = input["Id"];
                } else {
                    errorArray.push("error in input, Id attribute is not given or empty");
                }
                // add other attributes in this object
                for (var key in input) {
                    if ((key != "Id") && (key != "sobject") && (!this.strEndsWith(key, "__r")) && (typeof(input[key])!="object")) {
                        cleanObject[key] = input[key];
                    }
                }
                
                // assign clean object in clean array
                cleanArray[0] = cleanObject;
                
            } else {
                errorArray.push("input should be array of javascript objects or a single javascript object in sobject format...");
            }
        }
        
        ////////////////////////////////////////make a set of output and return////////////////////////////////////////////////////////////
        returnable.errorMessages = errorArray;
        returnable.cleanArray = cleanArray;
        return returnable;
        
    },
    strEndsWith: function(str, suffix) {
        return str.match(suffix + "$") == suffix;
    },
    inputFilterForDelete: function(input) {
        
        var inputErrorArray = [];
        
        if ((input == undefined) || (input == null)) {
            
            inputErrorArray.push("input cannot be undefined or null");
            
        } else {
            var inputClone = JSON.parse(JSON.stringify(input));
            if (Array.isArray(inputClone)) {
                if (inputClone.length != 0 && (typeof(inputClone[0]) == "string")) {
                    var inputUpdated = [];
                    
                    for (var i = 0; i < inputClone.length; i++) {
                        if (inputClone[i] != "") {
                            inputUpdated[i] = {
                                "Id": inputClone[i]
                            }
                        } else {
                            inputErrorArray.push("input element at index [ " + i + " ] is empty string..");
                        }
                        
                    }
                    inputClone = inputUpdated;
                } else if (inputClone.length == 0) {
                    inputErrorArray.push("empty array is not allowed as input");
                } else if ((typeof(inputClone[0]) === "object")) {
                    
                    ///check if Id attribute exist////
                    for (var i = 0; i < inputClone.length; i++) {
                        
                        if (inputClone[i]["Id"] == undefined) {
                            inputErrorArray.push("Id attribute not defined in [ " + i + " ] element of array");
                        }
                        
                    }
                } else {
                    inputErrorArray.push("Array elements should be of string or sObject type...");
                }
            } else {
                
                if (typeof(inputClone) !== "string" && typeof(inputClone) !== "object") {
                    inputErrorArray.push("input can be only of string, string array, sObject or sobject array type");
                } else if (typeof(inputClone) === "string") {
                    
                    if (inputClone != "") {
                        inputClone = [{
                            "Id": inputClone
                        }];
                    } else {
                        inputErrorArray.push("input cannot be empty string..");
                    }
                    
                } else if (typeof(inputClone) === "object") {
                    if (inputClone["Id"] == undefined) {
                        inputErrorArray.push("Id attribute not defined in input object");
                    }else{
                        inputClone=[inputClone];
                    }
                }
                
            }
        }
        
        if (inputErrorArray.length == 0) {
            
            return {
                "filteredInput": inputClone,
                "inputErrors": null
            };
        } else {
            return {
                "filteredInput": null,
                "inputErrors": inputErrorArray
            };
        }
        
    }
})