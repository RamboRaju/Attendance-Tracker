({
    //get Contact List from apex controller
    doInit : function(component, event, helper) {
        
        var action = component.get("c.getIconList");
        action.setParams({
        });
        action.setCallback(this, function(result){
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS"){
                component.set("v.objectIconList",result.getReturnValue());   
            }
        });
        $A.enqueueAction(action);
        
    },
     
    //Select all contacts
    handleSelectAllContact: function(component, event, helper) {
        var getID = component.get("v.contactList");
        var checkvalue = component.find("selectAll").get("v.value");        
        var checkContact = component.find("checkContact");
        if(!Array.isArray(checkContact)){
            checkContact = [checkContact];
        }
        if(checkvalue == true){
            for(var i=0; i<checkContact.length; i++){
                checkContact[i].set("v.value",true);
            }
        }
        else{ 
            for(var i=0; i<checkContact.length; i++){
                checkContact[i].set("v.value",false);
            }
        }
    },
     
    //Process the selected contacts
    handleSelectedContacts: function(component, event, helper) {
        let wrapContact = component.get("v.contactList");
        let selectAllDec = true;   
        wrapContact.some(element => element.selected == false) ? 
            selectAllDec = false : selectAllDec = true;
        
        component.set("v.isSelectAll",selectAllDec);
    },
    
    showSession: function(component, event, helper) {
       
        let selectedSessionType = component.find('selectSession').get("v.value");
        component.set("v.selectedSessionType", selectedSessionType);
        component.set("v.showSessionAndConact", false);
        //Reseting value to null
        component.set("v.selectedCommunity", {});
        component.set("v.selectedPrograms", {});
        component.set("v.selectedInstitution", {});
        component.set("v.selectedProgramCohort", {});
        
        if(selectedSessionType === 'Community'){
           component.set("v.isCommunity", true);
           component.set("v.isInstitution", false);
           component.set("v.isPrograms", false);
           component.set("v.isProgramCohort", false);
        }
        
        if(selectedSessionType === 'Institution'){
           component.set("v.isCommunity", false);
           component.set("v.isInstitution", true);
           component.set("v.isPrograms", false);
           component.set("v.isProgramCohort", false);
        }
        
        if(selectedSessionType === 'Programs'){
           component.set("v.isCommunity", false);
           component.set("v.isInstitution", false);
           component.set("v.isPrograms", true);
           component.set("v.isProgramCohort", false);
        } 
        
        if(selectedSessionType === 'Program Cohort'){
           component.set("v.isCommunity", false);
           component.set("v.isInstitution", false);
           component.set("v.isPrograms", false);
           component.set("v.isProgramCohort", true);
        } 
        console.log('Hello ');
       

    },
    
    handleAddContacts: function(component, event, helper) {
        console.log('clicked add contact');
        let errorList = helper.validateLookupField(component,event);
        if(errorList.length == 0) {
            component.set("v.showSessionAndConact", true);
            var action = component.get("c.getSessionAndContact");
            console.log('communityRecordId', JSON.stringify(component.get("v.selectedCommunity")));
            console.log('programsRecordId', JSON.stringify(component.get("v.selectedPrograms")));
            console.log('schoolRecordId', JSON.stringify(component.get("v.selectedInstitution")));
            console.log('programCohortRecordId', JSON.stringify(component.get("v.selectedProgramCohort")));
            action.setParams({
                'communityRecordId' : component.get("v.selectedCommunity").Id,
                'programsRecordId' : component.get("v.selectedPrograms").Id,
                'schoolRecordId' : component.get("v.selectedInstitution").Id,
                'programCohortRecordId' : component.get("v.selectedProgramCohort").Id
            });
            action.setCallback(this, function(result){
                var state = result.getState();
                if (component.isValid() && state === "SUCCESS"){
                    let wrapData = result.getReturnValue();
                    console.log('result ',wrapData);
                    component.set("v.sessionField",wrapData); 
                    component.set("v.contactList",wrapData.conlist);   
                }
            });
            $A.enqueueAction(action)
        } else {
            let errorMsg = '';
           
            errorList.length == 2 ? errorMsg = `${errorList[0]} and ${errorList[1]}` :
            errorMsg = `${errorList[0]}`;
            component.set("v.isError",true); 
            component.set("v.errorMsg",errorMsg); 
          
        }  
    },
    
    handleSubmit: function(component, event, helper){
        let validateValue = helper.validateSessionField(component,event);
        if(validateValue == undefined){
             helper.createParticipations(component, event, component.get("v.contactList"));
        } else {
            console.log('validateValue else '+validateValue);
            component.set("v.isError",true); 
            component.set("v.errorMsg",validateValue); 
        }
       
    }
    
})