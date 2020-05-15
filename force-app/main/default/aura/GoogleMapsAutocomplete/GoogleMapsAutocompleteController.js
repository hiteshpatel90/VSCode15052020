/**
 * Created by Sonal_Chaudhary on 9/22/2017.
 */
({
    keyPressController: function (component, event, helper) {

        var searchKey = component.get("v.searchKey");

        helper.openListbox(component, searchKey);
        helper.displayOptionsLocation(component, searchKey);
    },

    selectOption: function (component, event, helper) {
        var selectedItem = event.currentTarget.dataset.record;
        console.log(selectedItem);
        var selectedValue = event.currentTarget.dataset.value;
        console.log(selectedValue);

        component.set("v.selectedOption", selectedItem);

        var searchLookup = component.find("searchLookup");
        $A.util.removeClass(searchLookup, 'slds-is-open');

        var iconDirection = component.find("iconDirection");
        $A.util.removeClass(iconDirection, 'slds-input-has-icon_left');
        $A.util.addClass(iconDirection, 'slds-input-has-icon_right');

        component.set("v.searchKey", selectedItem);
        
        if(selectedItem){            
            var locationAll = selectedItem.split(',');
            if(component.get("v.AddressType").indexOf("Mailing") != -1){
                if(locationAll.length == 1){
                    component.set("v.MailingCountry", locationAll[0]);
                }
                if(locationAll.length == 2){
                    component.set("v.MailingState", locationAll[0]);
                    component.set("v.MailingCountry", locationAll[1]);
                }
                if(locationAll.length == 3){               
                    component.set("v.MailingCity", locationAll[0]);
                    component.set("v.MailingState", locationAll[1]);
                    component.set("v.MailingCountry", locationAll[2]);
                }
            }
            if(component.get("v.AddressType").indexOf("Other") != -1){
                if(locationAll.length == 1){
                    component.set("v.OtherCountry", locationAll[0]);
                }
                if(locationAll.length == 2){
                    component.set("v.OtherState", locationAll[0]);
                    component.set("v.OtherCountry", locationAll[1]);
                }
                if(locationAll.length == 3){               
                    component.set("v.OtherCity", locationAll[0]);
                    component.set("v.OtherState", locationAll[1]);
                    component.set("v.OtherCountry", locationAll[2]);
                }
            }
        }

    },

    clear: function (component, event, helper) {
        helper.clearComponentConfig(component);
    }

})