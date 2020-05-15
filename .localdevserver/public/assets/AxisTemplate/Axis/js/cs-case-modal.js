(function ( $ ) {

    window.caseModal = function( options ) {
        // This plugin initializes all the javascript required to run the case modal
        // This is the easiest way to have default options.

        var defaultOptions = {

            listProvidersMethod: "CS_ARCCExtension.retrieveProviders",
            listPractitionersMethod: "CS_ARCCExtension.retrievePractitioners",
            listPrefCardProductsMethod : "CS_ARCCExtension.retrievePreferenceCardProducts",
            listPrefCardsMethod : "CS_ARCCExtension.retrievePreferenceCards",
            listCaseProceduresMethod: "CS_ARCCExtension.retrieveCaseProcedures",
            searchUsersMethod : "CS_ARCCExtension.searchUsers",
            searchProductsMethod : "CS_ARCCExtension.searchProducts",
            listCasePrefCardsMethod: "CS_ARCCExtension.retrieveCasePrefCards",
            listCaseProductsMethod: "CS_ARCCExtension.retrieveCaseProducts",
            listCaseParticipantsMethod: "CS_ARCCExtension.retrieveCaseParticipants",            
            deleteCaseMethod : "CS_ARCCExtension.deleteCase",
            saveCaseMethod : "CS_ARCCExtension.saveCase",    
            searchProvidersMethod : "CS_ARCCExtension.searchProviders",
            searchPractitionersMethod : "CS_ARCCExtension.searchPractitioners",
            searchProceduresMethod : "CS_ARCCExtension.searchProcedures",
            resolvePractitionerProcedureProductsMethod : "CS_ARCCExtension.resolvePractitionerProcedureProducts"

        };

        var settings = $.extend( defaultOptions, options );

        // safelt decodes HTML Encoded text
        // see http://stackoverflow.com/questions/1147359/how-to-decode-html-entities-using-jquery
        var decodeEntities = function decodeEntities(encodedString) {

            if ( encodedString ) {
                var div = document.createElement('div');
                div.innerHTML = encodedString;
                return div.textContent;
            } else {
                return encodedString;
            }
        };

        // setting we're expecting to be set
        /*
        settings.currentUserId; 
        settings.calendar ( optional )
        settings.namespace (optional)
        */

        // append a period on namespace if it exists, make it an empty string otherwise
        if ( settings.namespace ) {
            settings.namespace += ".";
        } else {
            settings.namespace = "";
        }

        // load picklist options on plugin load            
        $("#case-prop-modal i.status-busy").show();
        Visualforce.remoting.Manager.invokeAction(settings.namespace+"CS_ARCCExtension.retrieveCase_CaseStatus_Picklist",
        function(result, event) {        
            if ( event.status ) {
                for ( var i=0; i < result.length; i++) {
                    $("#case-prop-modal select.status").append("<option value='"+result[i]+"'>"+result[i]+"</option>");
                }
            } else {
                console.error("Unable to load case status picklist values");
            }
            $("#case-prop-modal i.status-busy").hide();
        
        });

        // start/end dates on create event modal
        $("#case-prop-modal div.start-date-container").datetimepicker({ 
            stepping:30,
            useCurrent: true,
            showClose: true,
            ignoreReadonly: true
        });

        $("#case-prop-modal div.end-date-container").datetimepicker({ 
            stepping:30,
            useCurrent: false,
            showClose: true,
            ignoreReadonly: true
        });

        $("#case-prop-modal div.start-date-container").on("dp.change", function (e) {

            // default the end date to start date + 1 hrs
            $("#case-prop-modal div.end-date-container").data("DateTimePicker").date( e.date.add(1, 'h') );

            // end date can't be before the start date            
            $("#case-prop-modal div.end-date-container").data("DateTimePicker").minDate(e.date);
        });        

        // converts an object into a ctag ( the little blue tags that show below multi-select inputs )
        function obj2ctag(obj) {
            var label = decodeEntities(obj.Name);
            var id = obj.Id;

            var ctag = '<span class="ctag alert alert-info" data-record-id="'+id+'">';
            ctag += label
            ctag += '&nbsp;<span data-role="remove-tag"></span></span>';
            
            return ctag;
        }

        $("#case-prop-modal .ctag-list").on("click","[data-role=remove-tag]", function() {
            // removes tags from a tag-list
            $(this).parent().remove();
        });        

        function search(q, controllerMethod, successCallback, errorCallback) {
            // calls a search method on the controller, method passed in as a param

            Visualforce.remoting.Manager.invokeAction(controllerMethod,
            q,
            function(result, event) {
                if (event.status) {
                    successCallback(result);
                } else {
                    if ( typeof errorCallback === 'function' ) {
                        errorCallback(event);
                    } else {
                        console.log("Errors returned but no error handler found");
                    }
                }
            });
        
        }


        $("#case-prop-modal .case-participants-typeahead").typeahead({
            // typeahead setup for case participants
            minLength: 3,
            items: 50,
            source: function(query, onSuccess) {
                search(query, settings.searchUsersMethod, onSuccess);                                    
            },
            displayText: function(item) {
                return decodeEntities(item.Name);
            },
            afterSelect: function(item) {

                if ( (item.Id != settings.currentUserId) && ($("#case-prop-modal span[data-record-id="+item.Id+"].ctag").length === 0) ) {
                    // no duplicates and can't add yourself
                    $("#case-prop-modal div.ctag-list.participants").append(obj2ctag(item));
                }
                $("#case-prop-modal .case-participants-typeahead").val("");

            }
        });

        $("#case-prop-modal input.case-products-typeahead").typeahead({
            // typeahead setup for case products
            minLength: 3,
            items: 50,
            source: function(query, onSuccess) {
                search(query, settings.searchProductsMethod, onSuccess);                                    
            },
            displayText: function(item) {
                return decodeEntities(item.Name+" "+item.Material_Number__c);
            },
            afterSelect: function(item) {

                if ( $("#case-prop-modal span[data-record-id="+item.Id+"].ctag").length === 0 ) {
                    // no duplicates
                    item.Name += " "+item.Material_Number__c;

                    $("#case-prop-modal div.ctag-list.products").append(obj2ctag(item));
                }
                $("#case-prop-modal .case-products-typeahead").val("");

            }
        });                        

        // when a pref card is selected, add it as a ctag and then change the first option
        // from "Select" to "Select Another"
        $("#case-prop-modal select.prefcards").on("change", function() {

            for ( var i=0; i < settings.prefCardList.length; i++ ) {
                var item = settings.prefCardList[i];
                if ( item.Id === $(this).val() ) {
                    // this is the selected preference card

                    if ( $("#case-prop-modal span[data-record-id="+item.Id+"].ctag").length === 0) {
                        // no duplicates found

                        // adds a tag marking this pref card as selected
                        $("#case-prop-modal div.ctag-list.pref-cards").append(obj2ctag({
                            Id: item.Id,
                            Name: item.Pref_Card_Name__c+" - "+item.Procedure__r.Name
                        }));

                        // resolve products given the prefCard id
                        
                        // save the original placeholder text, we'll put it back when the ajax call is complete
                        var placeHolderTxt = $("#case-prop-modal input.case-products-typeahead").attr("placeholder");
                        $("#case-prop-modal input.case-products-typeahead").attr("placeholder","Retrieving products...");

                        Visualforce.remoting.Manager.invokeAction(settings.listPrefCardProductsMethod, item.Id,
                        function(result, event) {
                            
                            $("#case-prop-modal input.case-products-typeahead").attr("placeholder",placeHolderTxt);
                            
                            if (event.status) {
                                for ( var i=0; i < result.length; i++) {
                                    
                                    $("#case-prop-modal div.ctag-list.products").append(obj2ctag({
                                        Id : result[i].Id,
                                        Name : result[i].Name
                                    }));

                                }
                            
                            } else {
                                // errors will show up on the console
                            }
                        }); 

                        // add to the list of procedures
                        var procId = item.Procedure__r.Id;
                        var procName = decodeEntities(item.Procedure__r.Name);
                        if ( $("#case-prop-modal span[data-record-id="+procId+"].ctag").length === 0 ) {
                            // no duplicates
                            $("#case-prop-modal div.ctag-list.procedures").append(obj2ctag({
                                Id: procId,
                                Name: procName
                            }));
                        }
                        
                        // change the text to "Select Another";
                        $("#case-prop-modal select.prefcards option:first").text("Select Another");

                    }
                }
            }

            // reset the picklist back to "select" or "select another"
            $("#case-prop-modal select.prefcards option").removeAttr("selected");

        });

        $("#case-prop-modal input.procedure-typeahead").typeahead({
            // typeahead setup for prefcards
            minLength: 0,
            items: 50,
            source: function(query, onSuccess) {
                search(query, settings.searchProceduresMethod, onSuccess);
            },
            displayText: function(item) {
                return decodeEntities(item.Name);
            },
            afterSelect: function(item) {                
                if ( $("#case-prop-modal span[data-record-id="+item.Id+"].ctag").length === 0 ) {
                    // no duplicates
                    $("#case-prop-modal div.ctag-list.procedures").append(obj2ctag(item));
                }
                $("#case-prop-modal .procedure-typeahead").val("");
              
            }
        });

        $("#case-prop-modal button.case-delete-btn").on("click", function() {
            // deletes a calendar event

            var caseId = $("#case-prop-modal").attr("data-record-id");
            var calEventId = $("#case-prop-modal").attr("data-calevent-id");

            var buttonTxt = $(this).text();
            $(this).text("Deleting...");
            $("#case-prop-modal button").attr("disabled","true");
            Visualforce.remoting.Manager.invokeAction(settings.deleteCaseMethod, caseId,
                function(result, event) {

                    $("#case-prop-modal button").removeAttr("disabled");
                    $("#case-prop-modal button.case-delete-btn").text(buttonTxt);

                    if (event.status) {

                        // remove the event from the map and calendar

                        var parentDeletedEvent = null;
                        $(""+settings.calendar).fullCalendar('removeEvents', function(calE) {

                            // remove the one clicked on and all events with parentId = calEventId ( root cal event has parentId=id in other words
                            // its parent is itself
                            
                            // don't use === there's some string to number type inference going on but should be ok - Chad
                            var deleteEvent = calE.id == calEventId || calE.parentId == calEventId;                            
                            if ( deleteEvent ) {
                                calE.mapHide();
                            }

                            if ( deleteEvent && calE.id == calEventId ) {
                                // we return the parent/root calendar event with the custom case:deleted event
                                parentDeletedEvent = calE;
                            }

                            return deleteEvent;

                        });

                        // close the modal
                        $("#case-prop-modal").modal("hide")
                        
                        // trigger case:deleted
                        $(document).trigger("case:deleted",parentDeletedEvent);

                    } else {
                        // errors will show up on the console
                    }
                });
        });
        
        $("#case-prop-modal input.has-dependents").on("keyup", function() {
            // when the input is empty clears the data-record-id and triggers 
            // an record-id-unset event
            
            if ( $(this).val() == "" ) {
                $(this).attr("data-record-id","");
                $(this).trigger("record-id-unset");
            }

        });

        $("#case-prop-modal input[data-depends-on].form-control").each(function() {
           // manages disabling/enabling dependent form controls

            var that = this;

            // default state is disabled
            $(this).attr("disabled", true);

            var dependsOn = $(this).attr("data-depends-on");
            $("#case-prop-modal input.form-control."+dependsOn).on("record-id-set", function(e) {
                // setup an event handler on the control this one depends on for
                // the custom event record-id-set

                // when a record id is set, the control should reset its value, data-record-id,
                // become enabled and then get focus
                e.stopPropagation();
                $(that).val("");
                $(that).attr("data-record-id","");
                $(that).trigger("record-id-unset");
                $(that).removeAttr("disabled");
                window.setTimeout(function() {
                  $(that).focus();  
                },100);
                
            });

            $("#case-prop-modal input.form-control."+dependsOn).on("record-id-unset", function(e) {
                // setup an event handler on the control this one depends on for
                // the custom event record-id-unset

                // when the parent record id is unset, the control should reset its value,
                // reset it's data-record-id, become disabled and trigger a record-id-unset
                // event for anyhting that may dependend on this one
                e.stopPropagation();
                $(that).val("");
                $(that).attr("data-record-id","");
                $(that).trigger("record-id-unset");
                $(that).attr("disabled",true);
                
                if ( $(that).next().hasClass("ctag-list") ) {
                    $(that).next().empty();
                }
                
                
            });
        
        });
        

        $("#case-prop-modal button.case-save-btn").on("click", function() {
            // saves or updates a calendar event

            // gather up all the params and validate
            
            // caseId - set to null if this is a new case ( no ID exists )
            var caseId = $("#case-prop-modal").attr("data-record-id");
            if ( typeof caseId === "undefined" ) { 
                caseId = null; 
            } else {
                $("#case-prop-modal span.modal-title-txt").text("Edit Case");
            }

            var providerId = $("#case-prop-modal input.provider").attr("data-record-id");
            var provider = $("#case-prop-modal input.provider").val();
            
            // set to blank so the user doesn't get confused in case they typedsomething that doesn't havea record id
            $("#case-prop-modal input.pref-card").val("");

            var practitionerId = $("#case-prop-modal input.practitioner").attr("data-record-id");
            var practitioner = $("#case-prop-modal input.practitioner").val(); 

            var procedureIds = [];
            $("#case-prop-modal div.procedures").children().each(function() {
                procedureIds.push($(this).attr("data-record-id"));
            });             

            var status = $("#case-prop-modal select.status").val();
            
            //var notes = $("#case-prop-modal textarea.notes").val();
            var notes = null;
            
            var startDateStr = $("#case-prop-modal input.start-date").val();
            var endDateStr = $("#case-prop-modal input.end-date").val();

            var prefCardIds = [];
            $("#case-prop-modal div.pref-cards").children().each(function() {
                prefCardIds.push($(this).attr("data-record-id"));
            });

            var productIds = [];
            $("#case-prop-modal div.products").children().each(function() {
                productIds.push($(this).attr("data-record-id"));
            });

            var participantIds = [];
            $("#case-prop-modal div.participants").children().each(function() {
                participantIds.push($(this).attr("data-record-id"));
            });

            var localStartDate = moment(startDateStr, "MM/DD/YYYY h:mm A");
            var localEndDate = moment(endDateStr, "MM/DD/YYYY h:mm A");

            var startDate = localStartDate.utc().valueOf();
            var endDate = localEndDate.utc().valueOf();
            
            // validate what the user has entered
            var valid = true;
            valid = valid && typeof startDateStr != "undefined" && startDateStr.length > 0;
            valid = valid && typeof endDateStr != "undefined" && endDateStr.length > 0;
            valid = valid && typeof providerId != "undefined" && providerId.length > 0;
            valid = valid && typeof practitionerId != "undefined" && practitionerId.length > 0;
            valid = valid && typeof procedureIds != "undefined" && procedureIds.length > 0;
            if ( !valid ) {
                $("#case-prop-modal .save-error").text("Missing required fields");

                // if there's no record id in provider, practitioner, or procedure clear the input value, it's garbage
                if ( typeof providerId === "undefined" || providerId.length == 0 ) {$("#case-prop-modal input.provider").val(""); }
                if ( typeof procedureIds === "undefined" || procedureIds.length == 0 ) {$("#case-prop-modal input.procedure").val(""); }
                if ( typeof practitionerId === "undefined" || practitionerId.length == 0 ) {$("#case-prop-modal input.practitioner").val(""); }

                return false;
            } else {
                // no errors, clear the error text in case there was one previously
                $("#case-prop-modal .save-error").text("");
            }

            // use VF remoting to send the case to the controller
            var buttonTxt = $(this).text();
            $(this).text("Saving...");
            $("#case-prop-modal button").attr("disabled","true");

            Visualforce.remoting.Manager.invokeAction(settings.namespace+"CS_ARCCExtension.saveCase",
                caseId, providerId, practitionerId, prefCardIds, notes, startDate, endDate, productIds, 
                participantIds, status, procedureIds,
                function(result, event) {

                    $("#case-prop-modal button").removeAttr("disabled");
                    $("#case-prop-modal button.case-save-btn").text(buttonTxt);

                    if (event.status && settings.calendar) {
                        // on success and a calendar element exists

                        // remove the event if it already exists, we're going to replace it with
                        // what is returned from the call to CS_ARCasesCC.csave. 
                        $(""+settings.calendar).fullCalendar('removeEvents', function(calE) {

                            // not worried about parent/child events here, we want every event mapped to
                            // this caseId to be removed regardless of if it's a parent or child
                            if ( calE.url === caseId ) {
                                return true;
                            } else {
                                return false;
                            }

                        });
                    

                        // need to copy the startDate and endDate fields to 
                        // start, end since end is keywork in apex and can't be used
                        result.start = result.startDate;
                        result.end = result.endDate;                        

                        // default color for the originator of the event
                        result.color = "#427cbb";


                        // set the id to EPOCH time in ms ( pretty much guaranteed to be unique ) and add it to the calendar
                        var date = new Date();
                        result.id = date.getTime();
                        result.parentId = result.id;
                        

                        // closure that displays a marker for this event on the map
                        result.mapShow = function() {
                            if ( !map ) {
                                // no map global variable, nothing to do
                                return;
                            }

                            // only show on the map if it's for today
                            var today = moment().format("YYYY-MM-DD");
                            var eventDay = moment(this.start).format("YYYY-MM-DD");
                            
                            if ( this.marker && today == eventDay ) {
                                // note map is a global variable
                                this.marker.setMap(map);

                            } else if ( today == eventDay ) {

                                var pos = {
                                    "lat": this.providerLatitude,
                                    "lng": this.providerLongitude
                                };

                                var providerName = this.provider || "N/A";
                                var surgeonName = this.practitioner || "N/A";
                                var procedureName = this.procedure || "N/A";

                                // bounds is a global variable
                                bounds.extend(new google.maps.LatLng(pos.lat, pos.lng));

                                this.marker = new google.maps.Marker({
                                    position: pos,
                                    map: map,
                                    title: providerName
                                });

                                var that = this;
                                // Allow each marker to have an info window (infoWindow is a global variable)
                                google.maps.event.addListener(this.marker, 'click', (function(marker) {
                                    return function() {
                                        var content = providerName+"<br/>"+surgeonName+"<br/>"+procedureName;
                                        infoWindow.setContent(content);
                                        infoWindow.open(map, that.marker);
                                    }
                                })(that.marker));

                                map.fitBounds(bounds);
                            }

                        };

                        // closure that removes the marker from the map
                        result.mapHide = function() {
                            if ( this.marker ) {
                                this.marker.setMap(null);
                            }
                        }

                        // add to the calendar and show on the map
                        $(""+settings.calendar).fullCalendar( 'renderEvent', result);
                        result.mapShow();

                        // flatten the event if it has participants ( create a separate event for each particpant ) 
                        if ( result.participants.length > 0 ) {
                            for ( var k=0; k < result.participants.length; k++) {
                         
                                // shouldn't happen but if a participant is the same as the owner then skip it
                                if( result.participants[k].Id === result.ownerId ) { 
                                    continue; 
                                }

                                var childEvent = $.extend(true, {}, result);
                                childEvent.id = result.id+"-"+k;
                                childEvent.parentId = result.id;
                                childEvent.owner = result.participants[k].Name;
                                childEvent.ownerId = result.participants[k].Id;

                                // find the color for this user
                                var userRow = $("table.calendar-users tbody tr[data-user-id="+childEvent.ownerId+"]")
                                var bgColor = $(userRow).attr("data-user-color");
                                childEvent.color = bgColor;

                                // if this user is not currently checked then hide the event
                                if ( ! $(userRow).find("input[type=checkbox]").is(":checked") ) {
                                    childEvent.start = moment(childEvent.start).subtract(100,'y');
                                    childEvent.end = moment(childEvent.end).subtract(100,'y');
                                }
                                

                                // add the event to the calendar
                                $(""+settings.calendar).fullCalendar( 'renderEvent', childEvent);
                                childEvent.mapShow();

                            }
                        }

                        if ( settings.reloadOnSave === true ) {
                            location.reload(true);
                        }

                    } else if ( !event.status ) {
                        // errors will show up on the console
                    } else {
                        // no error but no calendar view, do nothing
                    }

                    // close the modal
                    $("#case-prop-modal").modal("hide");

                    // if this is a new case trigger case saved
                    $(document).trigger("case:saved", result);
                
                });
        
        });



        $("#case-prop-modal").on("hidden.bs.modal"  , function (e) {
            // whenever the modal closes, clear all the user entered data, make sure the inputs
            // are enabled and hidethe delete button

            // reset the pref card list, it will be set when a practitioner is chosen
            settings.prefCardList = [];
            $("#case-prop-modal select.prefcards").empty();
            $("#case-prop-modal select.prefcards").attr("disabled",true);
            
            $("#case-prop-modal span.save-error").text("");
            
            $("#case-prop-modal").removeAttr("data-record-id");

            $("#case-prop-modal input.clear-on-close").val("");
            $("#case-prop-modal input.clear-on-close").removeAttr("data-record-id");
            
            $("#case-prop-modal textarea.clear-on-close").val("");
            $("#case-prop-modal textarea.clear-on-close").removeAttr("data-record-id");
            
            $("#case-prop-modal div.clear-on-close").empty();
            $("#case-prop-modal span.clear-on-close").empty();
                                        
            $("#case-prop-modal input").removeAttr("readonly");
            $("#case-prop-modal textarea").removeAttr("readonly");
            $("#case-prop-modal button").not(".case-delete").show();

            // make sure all the remove links for ctags are shown
            $("#case-prop-modal span[data-role=remove-tag]").show();

            // delete and export button is hidden by default
            $("#case-prop-modal button.case-delete-btn").hide();
            $("#case-prop-modal button.case-export-btn").hide();

            
        });  

        $("#case-prop-modal").on("shown.bs.modal", function (e) {
            
            var caseId = $("#case-prop-modal").attr("data-record-id");
            if ( caseId ) {
                // opening an existing case, resolve the data we can
                
                // resolve pref cards
                $("#case-prop-modal i.pref-card-busy").show();
                Visualforce.remoting.Manager.invokeAction(settings.listCasePrefCardsMethod,
                caseId,
                function(result, event) {   

                    for ( var i=0; i < result.length; i++) {

                        var card = result[i];
                        if ( card.Practitioner_Procedure__r && card.Practitioner_Procedure__r.Pref_Card_Name__c ) {

                            $("#case-prop-modal div.ctag-list.pref-cards").append(obj2ctag({
                                Name: card.Practitioner_Procedure__r.Pref_Card_Name__c,
                                Id: card.Practitioner_Procedure__r.Id
                            }));     
                        }
                       
                    }                    

                    $("#case-prop-modal i.pref-card-busy").hide();
                });

                // resolve procedures
                $("#case-prop-modal i.procedures-busy").show();
                Visualforce.remoting.Manager.invokeAction(settings.listCaseProceduresMethod,
                caseId,
                function(result, event) {   

                    for ( var i=0; i < result.length; i++) {

                        var caseProc = result[i];
                        $("#case-prop-modal div.ctag-list.procedures").append(obj2ctag({
                            Name: caseProc.Procedure__r.Name,
                            Id: caseProc.Procedure__r.Id
                        }));     
                        
                       
                    }                    

                    $("#case-prop-modal i.procedures-busy").hide();
                });                

                // resolve products
                $("#case-prop-modal i.products-busy").show();
                Visualforce.remoting.Manager.invokeAction(settings.listCaseProductsMethod,
                caseId,
                function(result2, event) {
                    for ( var j=0; j < result2.length; j++) {
                        var product = result2[j];
                        $("#case-prop-modal div.ctag-list.products").append(obj2ctag({
                            Name: product.Product__r.Name,
                            Id: product.Product__r.Id
                        }));                            
                    }
                    $("#case-prop-modal i.products-busy").hide();
                });

                // resolve participants
                $("#case-prop-modal i.participants-busy").show();
                Visualforce.remoting.Manager.invokeAction(settings.listCaseParticipantsMethod,
                caseId,
                function(result3, event) {
                    for ( var i=0; i < result3.length; i++) {
                        var participant = result3[i];
                        $("#case-prop-modal div.ctag-list.participants").append(obj2ctag({
                            Name: participant.Participant__r.Name,
                            Id: participant.Participant__r.Id
                        }));                            
                    }
                    $("#case-prop-modal i.participants-busy").hide();          
                });                        

            }

            var practId = $("#case-prop-modal input.practitioner").attr("data-record-id");
            if ( practId ) {
                // resolve the pref card list, may be possible to have a practId but not caseid
                $("#case-prop-modal i.pref-card-busy").show();
                Visualforce.remoting.Manager.invokeAction(settings.listPrefCardsMethod,
                practId,
                function(result4, event) {

                    settings.prefCardList = result4;


                    // populate the prefcard picklist
                    $("#case-prop-modal select.prefcards").empty();
                    if (settings.prefCardList.length > 0 ) {
                        $("#case-prop-modal select.prefcards").append("<option value=''>Select</option>");
                    }
                    
                    for ( var i=0; i < settings.prefCardList.length; i++) {
                        var item = settings.prefCardList[i];
                        var id = item.Id;
                        var name = decodeEntities(item.Pref_Card_Name__c+" - "+item.Procedure__r.Name);
                        $("#case-prop-modal select.prefcards").append("<option value='"+id+"'>"+name+"</option>");                        
                    }

                    if ( $("#case-prop-modal select.prefcards option").length > 1 ) {
                        // enable the picklist, we have pref cards to display (item 1 is "Select")
                        $("#case-prop-modal select.prefcards").removeAttr("disabled");
                    }                    
                    
                    $("#case-prop-modal i.pref-card-busy").hide();
                });            
            }

            // resolve providers
            $("#case-prop-modal i.provider-busy").show();
            Visualforce.remoting.Manager.invokeAction(settings.listProvidersMethod,
            function(result, event) {
                settings.providerList = result;
                
                // setup the provider type ahead options object
                var providerTypeAheadOptions = {
                    minLength: 0,
                    items: 50,
                    source: settings.providerList,
                    showHintOnFocus: false,
                    displayText: function(item) {
                        return decodeEntities(item.Preferred_Name__c);
                    },
                    afterSelect: function(item) {
                        $("#case-prop-modal input.provider").val(decodeEntities(item.Preferred_Name__c));
                        $("#case-prop-modal input.provider").attr("data-record-id", item.Id);
                        // tell whoever is listening the provider record id has been set
                        $("#case-prop-modal input.provider").trigger("record-id-set");
                        

                        // lose focus and then close the popup 100ms after select
                        /*
                        setTimeout(function() {
                            $("#case-prop-modal input.provider").blur();
                            $("#case-prop-modal input.provider").parent().find("ul.typeahead").css("display","none");
                        },100);
                        */
                        
                    }
                };
                // init the provider type ahead
                $("#case-prop-modal input.case-provider-typeahead").typeahead(providerTypeAheadOptions);    

                $("#case-prop-modal i.provider-busy").hide();
            });             

            // resolve practitioners
            $("#case-prop-modal i.practitioner-busy").show();
            Visualforce.remoting.Manager.invokeAction(settings.listPractitionersMethod,
            function(result, event) {
                settings.practitionerList = result;

                // setup the practitioner type ahead options
                var practTypeAheadOptions = {
                    minLength: 0,
                    items: 50,
                    source: settings.practitionerList,
                    showHintOnFocus: false,                    
                    displayText: function(item) {
                        return decodeEntities(item.Name);
                    },
                    afterSelect: function(item) {
                        
                        var practId = item.Id;
                        console.log("pract selected");

                        $("#case-prop-modal input.practitioner").val(decodeEntities(item.Name));
                        $("#case-prop-modal input.practitioner").attr("data-record-id", practId);
                        
                        // pull in the preference cards for this practitioner and add them to settings
                        Visualforce.remoting.Manager.invokeAction(settings.listPrefCardsMethod,
                        practId,
                        function(result, event) {

                            console.log(result);
                            settings.prefCardList = result;

                            // populate the prefcard picklist
                            $("#case-prop-modal select.prefcards").empty();
                            if ( settings.prefCardList.length > 0 ) {
                              $("#case-prop-modal select.prefcards").append("<option value=''>Select</option>");  
                            }
                            
                            for ( var i=0; i < settings.prefCardList.length; i++ ) {
                                var item = settings.prefCardList[i];
                                var id = item.Id;
                                var name = decodeEntities(item.Pref_Card_Name__c+" - "+item.Procedure__r.Name);
                                $("#case-prop-modal select.prefcards").append("<option value='"+id+"'>"+name+"</option>");                        
                            }
                            if ( $("#case-prop-modal select.prefcards option").length > 1 ) {
                                // we have items to display, enable the pick list (item 1 is 'Select')
                                $("#case-prop-modal select.prefcards").removeAttr("disabled");
                            }

                            // tell whoever is listening the practitioner record id has been set
                            $("#case-prop-modal input.practitioner").trigger("record-id-set"); 

                            // lose focus and then close the popup 100ms after select
                            /*
                            setTimeout(function() {
                                $("#case-prop-modal input.practitioner").blur();
                                $("#case-prop-modal input.practitioner").parent().find("ul.typeahead").css("display","none");
                            },100);
                            */
                            
                        });

                        
                        
                    }            

                };

                // init the type ahead
                $("#case-prop-modal input.case-practitioner-typeahead").typeahead(practTypeAheadOptions);
            
                $("#case-prop-modal i.practitioner-busy").hide();
            });             


            
        });

        $("#case-prop-modal button.case-export-btn").on("click", function(e) {
            var calEventId = $("#case-prop-modal").attr("data-calevent-id");
            
            if ( settings.calendar ) {
                
                var calEvent = $(""+settings.calendar).fullCalendar('clientEvents', calEventId)[0];
                var subject = decodeEntities(calEvent.practitioner);
                var description = decodeEntities(calEvent.procedure);
                var location = decodeEntities(calEvent.provider);
                var begin = calEvent.start.format("M/D/YYYY h:mm a");
                var end = calEvent.end.format("M/D/YYYY h:mm a");
                var cal = ics();
                cal.addEvent(subject, description, location, begin, end);
                
                cal.download("case");
                
            }

        });

        return this;
 
    };
 
}( jQuery ));