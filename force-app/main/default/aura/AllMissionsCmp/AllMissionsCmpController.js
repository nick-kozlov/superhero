({
    doInit : function(component, event, helper) {
        var action = component.get("c.getAllMissions");

        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.allMissions", response.getReturnValue());
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {

                        var resultsToast = $A.get("e.force:showToast");
                        resultsToast.setParams({
                            title : "Missions",
                            type : "error",
                            message :" Error message: " + errors[0].message
                        });
                        resultsToast.fire();
                    }
                    else {
                        console.log("Unknown error");
                    }
                }
                else {
                    console.log("Unknown error");
                }
            }
            else {
                console.log("Unknown problem, response state: " + state);
            }
        });

        $A.enqueueAction(action);
    },

    selectMission : function(component, event, helper) {
        var selectedItem = event.currentTarget;
        var id = selectedItem.dataset.id;

        var allMissions = component.get('v.allMissions');
        var mission = allMissions.find(item => item.Id == id);
        var elements = document.getElementsByClassName("table-row")

        for (var i = 0; i < elements.length; i++) {
            var val = elements[i].getAttribute('data-id');

            if(val != id){
                $A.util.removeClass(elements[i], "selected-row");
            } else {
                $A.util.addClass(elements[i], "selected-row");
            }
        }

        var payload = {
            recordId: id,
            recordData: {
                value: mission
            }
        };

        component.find("missionSelected").publish(payload);
    }
})
