({
    validateLookupField: function(component,event){
        let errorList = [];
        let selectedSessionType = component.find('selectSession').get("v.value");
        
        if(selectedSessionType === 'Community'){
            let selectedprogramId = component.get("v.selectedPrograms").Id;
            let selectedCommunityId = component.get("v.selectedCommunity").Id;
            if(selectedprogramId == undefined){
                errorList.push('Program');
            }
            if(selectedCommunityId == undefined){
                errorList.push('Community');
            }
        }
        if(selectedSessionType === 'Institution'){
            let selectedprogramId = component.get("v.selectedPrograms").Id;
            let selectedInstitutionId = component.get("v.selectedInstitution").Id;
          
            if(selectedprogramId == undefined){
                errorList.push('Program');
            }
            if(selectedInstitutionId == undefined){
                errorList.push('Institution');
            }
            
        }
        if(selectedSessionType === 'Programs'){
            let selectedprogramId = component.get("v.selectedPrograms").Id;
            if(selectedprogramId == undefined){
                errorList.push('Program');
            } 
            
        }
        if(selectedSessionType === 'Program Cohort'){
            let selectedprogramId = component.get("v.selectedPrograms").Id;
            let selectedProgramCohortId = component.get("v.selectedProgramCohort").Id;
            if(selectedprogramId == undefined){
                errorList.push('Program');
            }
            if(selectedProgramCohortId == undefined){
                errorList.push('ProgramCohort');
            }
            
        }
        return errorList;
    },
    validateSessionField: function(component,event) {
        let fieldName;
        let dateField = component.get("v.sessionField.sessionDate");
        if(dateField == undefined) {
            fieldName = 'Date'
            return fieldName;
        }
        /*
        let primarySubject = component.get("v.sessionField.primarySubject");
        let showPrimarySubject = component.get("v.sessionField.showPrimarySubject");
        if(showPrimarySubject == true) {
            if(primarySubject == undefined) {
                fieldName = 'Primary Subject';
                return fieldName;
            }
        }
        */
        let staff = component.get("v.sessionField.staff");
        let submittedByOther = component.get("v.sessionField.submittedByOther");
        if(staff == undefined && submittedByOther == undefined) {
            fieldName = 'Staff or Submitted By Other'
            return fieldName;
        }
    },
    
    createParticipations : function(component,event,selectedContacts){
        let sessionAndContact = {}; 
        sessionAndContact = component.get("v.sessionField");
        sessionAndContact.conlist = selectedContacts;
        sessionAndContact.programId = component.get("v.selectedPrograms").Id;
        sessionAndContact.communityId = component.get("v.selectedCommunity").Id;
        sessionAndContact.schoolId = component.get("v.selectedInstitution").Id;
        sessionAndContact.primarySubject = sessionAndContact.hasOwnProperty('primarySubject') ? 
            sessionAndContact.primarySubject.Id : undefined;
        sessionAndContact.secondarySubject = sessionAndContact.hasOwnProperty('secondarySubject') ? 
            sessionAndContact.secondarySubject.Id : undefined;
        sessionAndContact.programCohortId = component.get("v.selectedProgramCohort").Id;
        
        console.log('after setting value in the wrap object');
        console.log(sessionAndContact);
        
        var action = component.get("c.createParticipation");
        action.setParams({
            'sessionConatct' : JSON.stringify(sessionAndContact)
        });
        action.setCallback(this, function(result){
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS"){
                console.log('Session Successfully created');
                let recordId = result.getReturnValue();
                let theme = component.get("v.objectIconList").theme;
                console.log('theme '+theme);
                if(theme === 'Theme3' ||'Theme2'){
                    location.href = `/${recordId}`;
                }
                if(theme === 'Theme4d' || 'Theme4t') {
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": recordId,
                        "slideDevName": "related"
                    });
                    navEvt.fire();
                }
            }
        });
        $A.enqueueAction(action);
    }
})