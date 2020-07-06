({
	closeToast : function(component, event, helper) {
		console.log('Hello Raju how are you');
        component.set("v.isError",false); 
        console.log(component.get("v.isError"));
	},
    
    doInit : function(component, event, helper) {
        window.setTimeout(
            $A.getCallback(function() {
                 component.set("v.isError",false);
            }), 10000
        );
    }
})