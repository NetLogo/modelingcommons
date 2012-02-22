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
	}
	$.fn.flash_notice = function(text) {
		flash_element = $("#flash_notice");
		width = flash_element.innerWidth();
		queue.push(text);
		if(!running) {
			display_next();
		}
		
		
	}
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
 

//Model list dataTable
$(document).ready(function () {
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
	
	/*$(".empty-on-click").livequery('click', function() {
	   if ($(this).attr("has_been_clicked_on") != "yes")
	   {
	       $(this).attr("value", "");
	       $(this).attr("has_been_clicked_on", "yes");
	   }
	});*/
	
	    
	// Search result tabs
	// Not done with ajax
	
	
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
	
	
	
	$(".complete").autocomplete('/tags/complete_tags', {} );
	
	//Tab loader loads tabs on the element selected by elementId and switches to the tab selected in the hash
	var tab_loader = function(elementId) {
		//Checks URL hash to see if the user wants to go to a specific tab
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
		$("#" + elementId).tabs({
			selected: tab_index, 
			show: function(event, ui) {
				window.location.hash = elementId + "_" + ui.panel.id;
			}
		});
	};
	tab_loader("model_tabs");
	tab_loader("group_tabs");

	// Disable inviting people if the group isn't selected
	$('select#group_id').livequery('change', function() {
	   if ($(this).attr('value') == '')
	   {
	       $('#invite_users_submit_button').attr('disabled', 'disabled');
	   }
	   else
	   {
	       $('#invite_users_submit_button').removeAttr('disabled');
	   }
	});
				       
	// Disable setting permissions if no group has been chosen
	if ($('#permission-selections').attr('value') == '') {
	    $('#permission-selections').toggle(false);
	}
	$('select#group_id').livequery('change', function() {
	   if ($(this).attr('value') == '')
	   {
	       $('#permission-selections').toggle(false);
	       $('p#permission-group-reminder').toggle(true);
	   }
	   else
	   {
	       $('#permission-selections').toggle(true);
	       $('p#permission-group-reminder').toggle(false);
	   }
	});
	
	
	//Validate header login form
	$("#header_login").validate({
		rules: {
			password: "required",
			email_address: {
				required: true,
				email: true
			}
		},
		messages: {
			password: "Password Required",
			email_address: {
				required: "Email Required",
				email: "Invalid Email Address"
			}
		},
		//onkeyup: false,
		//onclick: false,
		//onfocusout: false,
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
	
	//Model click to load
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
				container.css("left", ((body.outerWidth() - container.outerWidth())/2) + "px");
			} else {
				container.css("left", "0px");
			}
			
			applet.before($("div#browse_applet p").detach());
		} else {
			clickToLoad.css("display", "none");
			applet.css("display", "block");
		}
		
	});
	$("#header_login").bind('focus', function(e) {
		$().flash_notice("Focus");
	}).bind('blur', function(e) {
		$().flash_notice("Blur"); 
	});
	
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
		console.log(form.serialize());
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
	
	$('#new_discussion_comment').submit(function() {
		var form = $("#new_discussion_comment");
		console.log(form.serialize());
		$.ajax({
			url: form.attr("action"),
			dataType: "json",  
			type: "post", 
			data: form.serialize(), 
			success: function(data, textStatus, jqXHR) {
				$().flash_notice(data.message);
				if(data.success) {
					$(data.html).insertAfter($('#discussion tr:last'));
				}
			},
			error: function(jqXHR, textStatus, errorThrown) {
				$().flash_notice(textStatus + ": " + errorThrown);
			}, 
		});
		return false;
	});
	
	
	
	var createAJAXFormReturningHTMLHandler = function(callback) {
		return function(e) {
			var form = $(this);
			$.ajax({
				url: form.attr("action"),
				dataType: "html",  
				type: "post", 
				data: form.serialize(), 
				success: function(data, textStatus, jqXHR) {
					callback(data);
				},
				error: function(jqXHR, textStatus, errorThrown) {
					$().flash_notice(textStatus + ": " + errorThrown);
				}
			});
			return false;
		};
	};
	
	$('#add_tag_form').submit(createAJAXFormReturningHTMLHandler(function(data) {
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
	/*$("#existing_tags").on("click", ".tag_delete_form a", function(e) {
		$(e.target).parents("form").submit();
		e.preventDefault();
	});
	$("#search_people_to_invite").bind("keypress", function(e) {
		$.ajax({
			url: "/account/find_people", 
			dataType: "json",  
			type: "post", 
			data: $.param({
				query: this.value
			}), 
			success: function(data, textStatus, jqXHR) {
				console.log(data);
				
				var separator = $("#invite_people_separator");
				var list = $("#invite_people_list");
				separator.nextAll("option:selected").each(function(index, element) {
					$(element).detach().insertBefore(separator);
				});
				separator.nextAll("option").remove();
				separator.prevAll("option:not(:selected)").remove();
				
				for(var c = 0; c < data.length; c++) {
					list.append('<option value="' + data[c].id + '">' + data[c].name + '</option>');
				}
			}
		})
	});*/
	(function() {
		var selectedList = $("#selected_people");
		var unselectedList = $("#unselected_people");
		var groupSelector = $("#group_id");
		groupSelector.bind("change", function(e) {
			updateSubmitButtonState();
		});
		var personAdded = function(idToCheck) {
			
			return false;
		}
		var submit = $("#submit_selected_people");
		var updateSubmitButtonState = function() {
			if(selectedList.children(".selectable_person").length > 0 && groupSelector.children("option:selected").attr("value").length > 0) {
				submit.removeAttr("disabled");
			} else {
				submit.attr("disabled", "disabled");
			}
		}
		var clearUnselectedList = function() {
			console.log(unselectedList.children(".selectable_person").length);
			unselectedList.children(".selectable_person").remove();
		}
		unselectedList.on("click", "button.person_add", function(e) {
			$(this).parents(".selectable_person").detach().appendTo(selectedList);
			updateSubmitButtonState();
			return false;
		});
		selectedList.on("click", "button.person_remove", function(e) {
			console.log("yes");
			$(this).parents(".selectable_person").detach().appendTo(unselectedList);
			updateSubmitButtonState();
			return false;
		})
		$("#search_people_to_invite").bind("keypress", function(e) {
			$.ajax({
				url: "/account/find_people", 
				dataType: "json",  
				type: "post", 
				data: $.param({
					query: this.value
				}), 
				success: function(data, textStatus, jqXHR) {
					console.log(data);
					clearUnselectedList();
					for(var i = 0; i < data.length; i++) {
						if(!personAdded(data[i].id)) {
							unselectedList.append(data[i].html);
						}
					}
				}
			});
		});
	})();
	
	
	
});


