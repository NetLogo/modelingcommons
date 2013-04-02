// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

(function($) {
    var queue = [];
    var flash_element, width;
    var running = false;
    var display_next = function() {
	if(queue.length >= 1) {
	    running = true;
	    flash_element.text(queue[0]);
	    flash_element.animate(
		{
		    right: "0px"
		},
		600
	    ).delay(
		5000
	    ).animate(
		{
		    right: "-" + width + "px"
		},
		{
		    duration: 600,
		    complete: function() {
			queue.shift();
			display_next();
		    }
		}
	    );
	} else {
	    running = false;
	}
    };

    $.fn.flash_notice = function(text) {
	flash_element = $("#flash_notice");
	width = flash_element.innerWidth();
	queue.push(text);
	if(!running) {
	    display_next();
	}
    };
})(jQuery);

// Datatable sort for date modified column
// Numerical sort where the number to sort by is enclosed in the first span tag with class "hidden_elapsed_time"
jQuery.fn.dataTableExt.oSort['num-first-span-asc']  = function(a,b) {
    var x = a.replace(/<span class="hidden_elapsed_time">/,"").replace(/<\/span>.*/, "" );
    var y = b.replace(/<span class="hidden_elapsed_time">/,"").replace(/<\/span>.*/, "" );
    x = parseFloat( x );
    y = parseFloat( y );
    return ((x < y) ? -1 : ((x > y) ?  1 : 0));
};

jQuery.fn.dataTableExt.oSort['num-first-span-desc'] = function(a,b) {
    var x = a.replace(/<span class="hidden_elapsed_time">/,"").replace(/<\/span>.*/, "" );
    var y = b.replace(/<span class="hidden_elapsed_time">/,"").replace(/<\/span>.*/, "" );
    x = parseFloat( x );
    y = parseFloat( y );
    return ((x < y) ?  1 : ((x > y) ? -1 : 0));
};

jQuery.fn.dataTableExt.oPagination.two_button_full_text = {
    
    "fnInit": function ( oSettings, nPaging, fnCallbackDraw )
    {
	var nPrevious, nNext, nPreviousInner, nNextInner;
	
	nPrevious = document.createElement( 'button' );
	nNext = document.createElement( 'button' );
	
	nPreviousInner = document.createElement('div');
	nPreviousInner.className = 'ui-icon';
	nPrevious.appendChild(nPreviousInner);
	
	nPreviousInner = document.createTextNode('Previous');
	nPrevious.appendChild(nPreviousInner);
	
	nNextInner = document.createTextNode('Next');
	nNext.appendChild(nNextInner);
	
	nNextInner = document.createElement('div');
	nNextInner.className = 'ui-icon';
	nNext.appendChild(nNextInner);
	
	nPrevious.className = oSettings.oClasses.sPagePrevDisabled;
	nNext.className = oSettings.oClasses.sPageNextDisabled;
	
	nPrevious.title = oSettings.oLanguage.oPaginate.sPrevious;
	nNext.title = oSettings.oLanguage.oPaginate.sNext;
	
	nPaging.appendChild( nPrevious );
	nPaging.appendChild( nNext );
	
	$(nPrevious).bind( 'click.DT', function() {
	    if ( oSettings.oApi._fnPageChange( oSettings, "previous" ) )
	    {
		/* Only draw when the page has actually changed */
		fnCallbackDraw( oSettings );
	    }
	} );
	
	$(nNext).bind( 'click.DT', function() {
	    if ( oSettings.oApi._fnPageChange( oSettings, "next" ) )
	    {
		fnCallbackDraw( oSettings );
	    }
	} );
	
	/* Take the brutal approach to cancelling text selection */
	$(nPrevious).bind( 'selectstart.DT', function () { return false; } );
	$(nNext).bind( 'selectstart.DT', function () { return false; } );
	
	/* ID the first elements only */
	if ( oSettings.sTableId !== '' && typeof oSettings.aanFeatures.p == "undefined" )
	{
	    nPaging.setAttribute( 'id', oSettings.sTableId+'_paginate' );
	    nPrevious.setAttribute( 'id', oSettings.sTableId+'_previous' );
	    nNext.setAttribute( 'id', oSettings.sTableId+'_next' );
	}
    },
    
    /*
     * Function: oPagination.two_button.fnUpdate
     * Purpose:  Update the two button pagination at the end of the draw
     * Returns:  -
     * Inputs:   object:oSettings - dataTables settings object
     *           function:fnCallbackDraw - draw function to call on page change
     */
    "fnUpdate": function ( oSettings, fnCallbackDraw )
    {
	if ( !oSettings.aanFeatures.p )
	{
	    return;
	}
	
	/* Loop over each instance of the pager */
	var an = oSettings.aanFeatures.p;
	for ( var i=0, iLen=an.length ; i<iLen ; i++ )
	{
	    if ( an[i].childNodes.length !== 0 )
	    {
		an[i].childNodes[0].className = 
		    ( oSettings._iDisplayStart === 0 ) ? 
		    oSettings.oClasses.sPagePrevDisabled : oSettings.oClasses.sPagePrevEnabled;
		
		an[i].childNodes[1].className = 
		    ( oSettings.fnDisplayEnd() == oSettings.fnRecordsDisplay() ) ? 
		    oSettings.oClasses.sPageNextDisabled : oSettings.oClasses.sPageNextEnabled;
	    }
	}
    }
};


//Enclose everything in a function so that local variables don't use the global namespace
(function() {
    var createAJAXFormReturningHTMLHandler = function(callback) {
	return function(e) {
	    var form = $(this);
	    $.ajax({
		url: form.attr("action"),
		dataType: "html",  
		type: "post", 
		data: form.serialize(), 
		success: callback,
		error: function(jqXHR, textStatus, errorThrown) {
		    $().flash_notice(textStatus + ": " + errorThrown);
		}
	    });
	    return false;
	};
    };
    
    var initializeModelListDataTable = function() {
	// Create the datatable
	$(".model_list_datatable").dataTable({
	    'aaSorting': [ [0, 'asc']],
	    "bAutoWidth": false,
	    "aoColumns": [
		{
		    //Model
		    "sType": "html",
		    "sWidth": "38%"
		},
		{
		    //Owners
		    "sType": "html",
		    "sWidth": "15%"
		},
		{
		    //Tags
		    "sType": "html",
		    "sWidth": "20%"
		},
		{
		    //Group
		    "sType": "html",
		    "sWidth": "15%"
		},
		{
		    //Modified
		    "sType": "num-first-span",
		    "sWidth": "12%"
		}
	    ],
	    "sDom": '<"left-right top"<"left"p><"right"ilf>>t<"left-right bottom"<"left"p><"right">>',
	    "sPaginationType": "two_button_full_text"
	});
	$(".dataTables_filter input").attr("placeholder", "Search Results");
    };
    
    //Allows styling input type="file" by wrapping the file input in a styled label.  To style, change the file_label
    //class style
    //Should run before tabs are created
    var initializeStyledFileInput = (function() {
	var initialized = false;
	return function() {
	    if(initialized) {
		return;
	    }
	    initialized = true;
	    $('input[type="file"]').each(function() {
		var fileInput = $(this);
		var name = fileInput.attr("name");
		if($.trim(name).length == 0) {
		    return;
		}
		
		fileInput.wrap('<label for="' + name + '" class="file_label">Choose File</label>')
		var wrapper = fileInput.parent();
		var fileNameLabel = $('<label for="' + name + '" class="file_name_label"></label>');
		fileNameLabel.insertAfter(wrapper);
		var updateFileName = function() {
		    var fileName = fileInput.val();
		    if(fileName) {
			fileName = fileName.split('\\').pop();
		    }
		    fileNameLabel.text(fileName);
		};
		updateFileName();
		fileInput.bind("change", function(e) {
		    updateFileName();
		});
	    })				
	}
    })();
    
    var initializeProjectsTable = function() {
	var getSortCol = function(select) {
	    var sortStr = select.find("option:selected").attr("value");
	    var sort = [[1, 'asc']];
	    if(sortStr == "pn") {
		
	    } else if(sortStr == "on") {
		sort = [[2, 'asc']];
	    } else if(sortStr == "mc") {
		sort = [[3, 'desc']];
	    }
	    return sort;
	    
	};
	var table = $("#projects_table").dataTable({
	    "aoColumns": [
		{
		    "bSortable": false
		    
		}, 
		{
		    "sType": "string", 
		    "bVisible": false
		}, 
		{
		    "sType": "string", 
		    "bVisible": false
		}, 
		{
		    "sType": "numeric", 
		    "bVisible": false
		}, 
		{
		    "sType": "string",
		    "bVisible": false, 
		    "bSortable": false
		}
	    ], 
	    'aaSorting': getSortCol($("#project_sort_by")),
	    "sDom": '<"left-right top"<"left"><"right"f>>t', 
	    "bPaginate": false, 
	    "bAutoWidth": false
	});
	table.parents(".dataTables_wrapper").find("input").attr("placeholder", "Search Projects");
	$("#project_sort_by").bind('change', function(e) {
	    table.fnSort(getSortCol($(this)));
	});
	$("#project_show_you").bind("change", function(e) {
	    if(this.checked) {
		table.fnFilter("true", 4);
	    } else {
		table.fnFilter("", 4);
	    }
	});
	$(".project_more button").bind("click", function(e) {
	    
	    var list = $(this).parents(".project").find(".project_model_list");
	    
	    list.toggleClass("hidden");
	    if(list.hasClass("hidden")) {
		$(this).text($(this).text().replace("Hide", "Show"));
	    } else {
		$(this).text($(this).text().replace("Show", "Hide"));
	    }
	});
	
	$("#custom_filters").contents().detach().prependTo($("#projects_table_wrapper .top .left"));
	$("#custom_filters").remove();
    };

    
    //Tab loader loads tabs on the element selected by elementId and switches to the tab selected in the hash
    var initializeTabsOnElement = function(elementId) {
	
	//Checks URL hash to see if the user wants to go to a specific tab
	var getURLTabIndex = function() {
	    var tab_index = 0;
	    if(window.location.hash.indexOf(elementId + "_") != -1) {
		var startIndex = window.location.hash.indexOf(elementId + "_") + (elementId + "_").length;
		var endIndex = window.location.hash.indexOf("&", startIndex);
		endIndex = endIndex == -1 ? window.location.hash.length : endIndex;
		var tab_id = window.location.hash.substring(startIndex, endIndex);
		$("#" + elementId + ">div").each(function(index, element) {
		    if(tab_id == element.id) {
			tab_index = index;
		    }
		});
	    }
	    return tab_index;
	};
	
	//Create the tabs
	var tab = $("#" + elementId).tabs({
	    //Select the correct tab
	    selected: getURLTabIndex(),
	    //When the tab changes, update the URL hash 
	    show: function(event, ui) {
		window.location.hash = elementId + "_" + ui.panel.id;
	    }
	});
	
	//Change tabs on back/forward by monitoring URL hash
	$(window).bind("hashchange", function() {
	    tab.tabs("select", getURLTabIndex());
	});
    };
    
    
    //Person selector for group invitation tab
    var initializeGroupInvitationPersonSelector = function() {
	var selectedList = $("#selected_people");
	var unselectedList = $("#unselected_people");
	var groupSelector = $("#group_id");
	var personSearchInput = $("#search_people_to_invite");
	
	groupSelector.bind("change", function(e) {
	    updateSelectedListIndicatorState();
	});
	
	var personAdded = function(idToCheck) {
	    var isAdded = false;
	    selectedList.find(".selectable_person input#person_id").each(function(index, element) {
		if(parseInt($(element).attr("value")) == idToCheck) {
		    isAdded = true;
		    return false;
		}
	    });
	    return isAdded;
	};
	var submit = $("#submit_selected_people");
	var updateSelectedListIndicatorState = function() {
	    if(selectedList.children(".selectable_person").length > 0 && groupSelector.children("option:selected").attr("value").length > 0) {
		submit.removeAttr("disabled");
	    } else {
		submit.attr("disabled", "disabled");
	    }
	    if(selectedList.children(".selectable_person").length > 0) {
		selectedList.find(".no_people").addClass("hidden");
	    } else {
		selectedList.find(".no_people").removeClass("hidden");
	    }
	};
	var updateUnselectedListIndicatorState = function() {
	    if(unselectedList.children(".selectable_person").length > 0) {
		unselectedList.find(".no_people").addClass("hidden");
	    } else {
		unselectedList.find(".no_people").removeClass("hidden");
	    }
	};
	var clearUnselectedList = function() {
	    unselectedList.children(".selectable_person").remove();
	};
	unselectedList.on("click", "button.person_add", function(e) {
	    $(this).parents(".selectable_person").detach().appendTo(selectedList);
	    updateSelectedListIndicatorState();
	    updateUnselectedListIndicatorState();
	    return false;
	});
	selectedList.on("click", "button.person_remove", function(e) {
	    $(this).parents(".selectable_person").detach().appendTo(unselectedList);
	    updateSelectedListIndicatorState();
	    updateUnselectedListIndicatorState();
	    return false;
	});
	var fetchNewPeopleFromInput = function() {
	    if(personSearchInput.attr("value")) {
		$.ajax({
		    url: unselectedList.parents("form").attr("action"),
		    dataType: "json",  
		    type: "post", 
		    data: $.param({
			query: personSearchInput.attr("value")
		    }), 
		    success: function(data, textStatus, jqXHR) {
			clearUnselectedList();
			for(var i = 0; i < data.length; i++) {
			    if(!personAdded(data[i].id)) {
				unselectedList.append(data[i].html);
			    }
			}
			updateUnselectedListIndicatorState();
			
		    }
		});
	    }
	    
	};
	personSearchInput.bind("keypress", fetchNewPeopleFromInput);
	
	//Call in case the user hit back and left something in the input field
	fetchNewPeopleFromInput();
    };
    
    
    //Makes the placeholder attribute work in internet explorer 8, 9
    //Should be initialized last
    var initializeIEPlaceholder = (function() {
	//Private static variables:
	var ie_placeholder_initialized = false;
	
	return function() {
	    if(ie_placeholder_initialized) {
		return;
	    }
	    ie_placeholder_initialized = true;
	    var test = document.createElement("input");
	    if("placeholder" in test) {
		return;
	    }
	    $("input[placeholder][type=password]").each(function() {
		var passwordInput = $(this);
		passwordInput.addClass("password_placeholder");
		var textInput = $('<input type="text" />');
		textInput.attr("placeholder", passwordInput.attr("placeholder"));
		passwordInput.removeAttr("placeholder");
		passwordInput.after(textInput);
		passwordInput.hide();
		textInput.on("focus", function() {
		    textInput.hide();
		    passwordInput.show();
		    passwordInput.focus();
		});
		passwordInput.on("blur", function() {
		    if(passwordInput.val().length == 0) {
			passwordInput.hide();
			textInput.show();
			textInput.blur();
		    }
		});
	    });
	    
	    
	    var blur = function() {
		var input = $(this);
		if(input.val().length == 0) {
		    input.val(input.attr("placeholder"));
		    input.addClass("placeholder");
		}
	    };
	    var focus = function() {
		var input = $(this);
		if(input.hasClass("placeholder")) {
		    input.val("");
		    input.removeClass("placeholder");
		}
	    };
	    $("[placeholder]").blur(blur).focus(focus).each(blur).parents("form").bind("submit", function() {
		$(this).find("input.placeholder").val("");
	    });	
	};
    })();
    
    
    var initializeSearchTabs = function() {
	//Disable tabs with no search results
	var disabledTabsList = [];
	var selectedSearchTab = -1;
	$("#search_tabs>ul>li").each(function(index, element) {
	    if($(element).hasClass("empty")) {
		disabledTabsList.push(index);
		
	    } else if(selectedSearchTab == -1) {
		selectedSearchTab = index;
	    }
	});
	if($("#search_tabs>ul>li").length == $("#search_tabs>ul>li.empty").length) {
	    $("#search_tabs").tabs({
		disabled: disabledTabsList,
		selected: -1
	    });
	    $("#ifEmpty").css("display", "inline");
	} else {
	    $("#search_tabs").tabs({
		disabled: disabledTabsList,
		selected: selectedSearchTab
	    });
	}
    };
    
    var initializeModelClickToLoad = function() {
	$("#model_click_to_load").click(function(e) {
	    
	    var tab = $("div#browse_applet");
	    var applet = $("#model_applet");
	    var clickToLoad = $(this);
	    var body = $("body");
	    var container = $("#model_container");
	    if(applet.innerWidth() > tab.innerWidth()) {
		clickToLoad.css("visibility", "hidden");
		clickToLoad.css("height", (applet.innerHeight() + 10) + "px");
		applet.css("display", "block");
		container.addClass("wide_model");
		container.css("top", (tab.offset().top + 24) + "px");
		if(applet.innerWidth() < body.outerWidth()) {
		    container.css("left", ((body.outerWidth() - container.outerWidth())/2 - container.offsetParent().offset().left) + "px");
		} else {
		    container.css("left", "0px");
		}
		
		applet.before($("div#browse_applet p").detach());
	    } else {
		clickToLoad.css("display", "none");
		applet.css("display", "block");
	    }
	    
	});
    };
    
    var initializeModelPermissionsChanger = function() {
	var select_no_group_enable = function(enable) {
	    if(enable) {
		$('#group_select option[value=""]').removeAttr('disabled');
	    } else {
		$('#group_select option[value=""]').attr('disabled', 'disabled');
	    }
	}
	var group_permissions_enable = function(enable) {
	    if(enable) {
		$('#read_permission_select option[value="g"]').removeAttr("disabled");
		$('#write_permission_select option[value="g"]').removeAttr("disabled");
	    } else {
		$('#read_permission_select option[value="g"]').attr("disabled", "disabled");
		$('#write_permission_select option[value="g"]').attr("disabled", "disabled");
	    }
	}
	var submitPermissionChange = function() {
	    var form = $("#group_permission_form");
	    $.ajax({
		url: form.attr("action"), 
		type: "post", 
		data: form.serialize(), 
		success: function(data, textStatus, jqXHR) {
		    data;
		    $().flash_notice(data.message);
		},
		error: function(jqXHR, textStatus, errorThrown) {
		    $().flash_notice(textStatus + ": " + errorThrown);
		}, 
		dataType: "json"
	    })
	};
	//One model permissions/group selectors behavior
	if($('#group_select option:selected').attr('value') == "") {
	    group_permissions_enable(false);
	}
	if($('#read_permission_select option:selected').attr('value') == 'g' || $('#write_permission_select option:selected').attr('value') == 'g') {
	    select_no_group_enable(false);
	}
	
	$('#group_select').bind('change', function(e) {
	    if(e.currentTarget.value == "") {
		group_permissions_enable(false);
	    } else {
		group_permissions_enable(true);
	    }
	    submitPermissionChange();
	});
	$('#read_permission_select').bind('change', function(e) {
	    if(e.currentTarget.value != "g" && $('#write_permission_select option:selected').attr('value') != 'g') {
		select_no_group_enable(true);
	    } else {
		select_no_group_enable(false);
	    }
	    submitPermissionChange();
	});
	$('#write_permission_select').bind('change', function(e) {
	    if(e.currentTarget.value != "g" && $('#read_permission_select option:selected').attr('value') != 'g') {
		select_no_group_enable(true);
	    } else {
		select_no_group_enable(false);
	    }
	    submitPermissionChange();
	});
    };
    
    var initializeHeaderLoginForm = function() {
	
	//Validate header login form
	$("#header_login").validate({
	    rules: {
		password: {
		    required: ":not(.placeholder)", 
		},
		email_address: {
		    required: true,
		    email: true
		}
	    },
	    messages: {
		password: {
		    required: function(rules, element) {
			console.log($(element).parent().children(".placeholder").addClass("error"));
			return "Password Required"
		    }
		},
		email_address: {
		    required: "Email Required",
		    email: "Invalid Email Address"
		}
	    },
	    //onkeyup: false,
	    //onclick: false,
	    onfocusout: false,
	    errorPlacement: function(error, element) {
		element.parents("tr").next("tr").children("td").eq(element.parents("td").index()).append(error);
	    }
	});
	
	$('#header_login').keypress(function(e) {
	    if(e.keyCode == 13) {
		$(this).submit();
	    }
	});
	$('#header_login button').click(function(e) {
	    $(this).parents('form').submit();
	});
	
    };
    
    var initializeTagEditor = function() {
	
	$(".complete").autocomplete('/tags/complete_tags', {} );
	
	//Add new tag
	$('#add_tag_form').submit(createAJAXFormReturningHTMLHandler(function(data, textStatus, jqXHR) {
	    $(data).appendTo("#existing_tags");
	    $('#existing_tags').removeClass('hidden');
	    $('#no_tags').addClass('hidden');
	    $('#new_tags input').each(function(index, element) {
		element.value = "";
		
	    });
	    $('#new_tags .file').each(function(index, element) {
		if(index != 0) {
		    $(element).remove();
		}
	    });
	}));
	
	
	$("#existing_tags").on("click", ".tag_delete_form a", function(e) {
	    $(this).parents("form").submit();
	    return false;
	});
	
	//Delete existing tag
	$("#existing_tags").on("submit", ".tag_delete_form", function(e) {
	    var form = $(this);
	    $.ajax({
		url: form.attr("action"),
		dataType: "json",  
		type: "post", 
		data: form.serialize(), 
		success: function(data, textStatus, jqXHR) {
		    $().flash_notice(data.message);
		    form.parents("tr").remove();
		    if($('#existing_tags tbody tr').length <= 0) {
			$('#existing_tags').addClass('hidden');
			$('#no_tags').removeClass('hidden');
		    }
		},
		error: function(jqXHR, textStatus, errorThrown) {
		    $().flash_notice(textStatus + ": " + errorThrown);
		}
	    });
	    return false;
	});
    };
    
    var initializeNewCommentForm = function() {
	
	$('#new_discussion_comment').submit(function() {
	    var form = $("#new_discussion_comment");
	    $.ajax({
		url: form.attr("action"),
		dataType: "json",  
		type: "post", 
		data: form.serialize(), 
		success: function(data, textStatus, jqXHR) {
		    $().flash_notice(data.message);
		    if(data.success) {
			var commentsList = $(".comments_list");
			if(commentsList.find(".comments").length == 0) {
			    commentsList.empty();
			}
			$(data.html).appendTo(commentsList)
			form.find('input:not([type="submit"], [type="button"], [type="hidden"]), textarea').removeAttr('value').removeAttr('checked');
		    }
		},
		error: function(jqXHR, textStatus, errorThrown) {
		    $().flash_notice(textStatus + ": " + errorThrown);
		}, 
	    });
	    return false;
	});
    }
    
    var initializeModelUpdater = function() {
	var form = $("#upload-model-form");
	form.validate({
	    rules: {
		"new_version[uploaded_body]": {
		    "required": true
		},
		"new_version[description]": "required", 
		"new_version[name_of_new_child]": {
		    "required": "#fork_child:checked"
		}
	    }, 
	    

	});
	
	
	
	
	form.find('input[type="file"]').bind("change", function() {
	    form.validate().element(this);
	})
	
	$("#fork_overwrite").bind("change", function(e) {
	    form.validate().element("#new_version_name_of_new_child");
	});
    };
    
    var initializeCollaboration = function() {

	var collaboration_options;
	$.get('/collaborator_types.json', function(data) {
	    collaboration_options = data.map(function(o) { 
		return "<option value='" + o.collaborator_type.id + "'>"+ o.collaborator_type.name  + "</option>"  ;
	    }).join("\n");
	});


	$("li#add-collaborator").bind("click", function(e) {

            $('<li class="added-collaborator"><input type="text" placeholder="Collaborator name" name="name" /><select><option></option>\n' + collaboration_options + '</select></li>').insertBefore('#add-collaborator');

	    if ($("li#save-collaborators").length == 0)
	    {
		$('<li id="save-collaborators"><input type="button" value="Save new collaborators" /></li>').insertAfter('#add-collaborator');
	    }
	});
    };

    function initialize() {
	initializeModelListDataTable();
	initializeProjectsTable();
	initializeStyledFileInput();
	initializeTabsOnElement("model_tabs");
	initializeTabsOnElement("group_tabs");
	initializeSearchTabs();
	initializeGroupInvitationPersonSelector();
	initializeModelClickToLoad();
	initializeModelPermissionsChanger();
	initializeHeaderLoginForm();
	initializeNewCommentForm();
	initializeTagEditor();
	initializeModelUpdater();
	initializeIEPlaceholder();
	initializeCollaboration();
    };

    $(document).ready(initialize);
})();
