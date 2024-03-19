/*
({
	doInit : function(component, event, helper) 
    {
        console.log(component.get("v.recordId"));
        var action = component.get("c.callCreateAttachment");
        action.setParams({
             parentId: component.get("v.recordId")
        });
        action.setCallback(this, function(response) 
        {
            console.log("OK");
           if (response.state === "SUCCESS")
           {
               console.log("SUCCESS: " + response.getReturnValue());
               component.set("v.result",response.getReturnValue());
           }
           else
           {
               console.log("ERROR: " + response.getReturnValue());
               component.set("v.result",response.getReturnValue());
           }   
        });
        $A.enqueueAction(action);
		//component.set("v.result",component.get("v.recordId"));
	}
})*/
({
	handleClick : function(component, event, helper)
    {
        var areYouSure = $A.get("$Label.Are_you_sure_to_confirm");
        component.set('v.Are_you_sure_to_confirm', areYouSure);
        var confirm = $A.get("$Label.Confirm");
        component.set('v.Confirm', confirm);
        component.set('v.isButtonInactive',true);
        console.log(component.get("v.recordId"));
        var action = component.get("c.callCreateAttachment");
        action.setParams({
             parentId: component.get("v.recordId")
        });
        action.setCallback(this, function(response)
        {
            console.log("OK");
           if (response.state === "SUCCESS")
           {
               console.log("SUCCESS: " + response.getReturnValue());
               component.set("v.result",response.getReturnValue());
           }
           else
           {
               console.log("ERROR: " + response.getReturnValue());
               component.set("v.result",response.getReturnValue());
           }
        });
        $A.enqueueAction(action);

		//component.set("v.result",component.get("v.recordId"));
	}
})