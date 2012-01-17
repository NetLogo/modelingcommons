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
					left: "0px"
				},
				600
			).delay(
				5000
			).animate(
				{
					left: width + "px"
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
		flash_element = $(".flash_notice");
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
		'aaSorting': [ [1, 'asc']],
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
	
	$(".empty-on-click").livequery('click', function() {
	   if ($(this).attr("has_been_clicked_on") != "yes")
	   {
	       $(this).attr("value", "");
	       $(this).attr("has_been_clicked_on", "yes");
	   }
	});
	
	// !!!
	// This is clearly the wrong way to do this
	// !!!
	$(".menu-option").click(
	    function () {
		window.location = $(this).children()[0];
	    });
	    
	// Search result tabs
	// Not done with ajax
	
	//Disable tabs with no search results
	var disabledTabsList = [];
	$("#search_tabs ul li").each(function(index, element) {
		if($(element).hasClass("empty")) {
			disabledTabsList.push(index);
		}
	});
	$("#search_tabs").tabs({disabled: disabledTabsList});
	
	
	// Handle tabs for models (and groups, for that matter)
	$("#model-tabs").tabs( {

	   spinner: '',
	   load: function () {
	       $(".complete").autocomplete('/tags/complete_tags', {} );
	   },
	   ajaxOptions: {
	       success: function(data, textStatus) { },
	       error: function(xhr, status, index, anchor) {
		   $(anchor.hash).html("Couldn't load this tab.");
	       },
	       data: {}
	   }
	});


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
			password: "Enter password",
			email_address: {
				required: "Enter email address",
				email: "Invalid email address"
			}
		},
		onkeyup: false,
		onclick: false,
		onfocusout: false,
		errorPlacement: function(error, element) {
			$().flash_notice(error.text());
		},
		
		
	});
	
	$('#header_login').keypress(function(e) {
		if(e.keyCode == 13) {
			$(this).submit();
		}
	});
	$('#header_login_submit').click(function(e) {
		$(this).parent().submit();
	});
});


