// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(document).ready(function () {

	// Create the datatable
	$(".datatable").dataTable({
		'aaSorting': [ [1, 'asc']],
		"aoColumns": [
			{
				"bSortable": false
			},
			{
				"sType": "html"
			},
			{
				"sType": "html"
			},
			{
				"sType": "html"
			},
			{
				"sType": "html"
			},
			{
				"sType": "html"
			}
		]
	});
	
	// Clear 'search' from search input field on focus
	$('#navbar-search-form-text').focus(function() {
		if ($(this).val() == 'Search')
		{
		    $(this).val("");
		    $(this).removeClass("blank");
		}
	// Restore 'search' on blur
	}).blur(function() {
		if($(this).val().length == 0) {
			$(this).val("Search");
			$(this).addClass("blank");
		}
	});
	// Clicking anywhere in the navbar for the search field focuses on the search field
	$("#header_search_form_box").click(function() {
		$("#navbar-search-form-text").trigger("focus");
	});
	
	// !!!
	// This does not appear to be used anywhere
	// !!!
	// Function to handle clicks
	handle_menu_click = function() {

	    if (this.hash == '')
	    {
		return false;
	    }

	    $('.one-model-div').hide();     // Hide all of the divs
	    $('a').removeClass('current');  // Remove "current" class

	    $(this).addClass('current');
	    $(this.hash).show(); // Show the one for what was clicked on
	    return false;
	}

	$(".empty-on-click").livequery('click', function() {
	   if ($(this).attr("has_been_clicked_on") != "yes")
	   {
	       $(this).attr("value", "");
	       $(this).attr("has_been_clicked_on", "yes");
	   }
	});
	// !!!
	// This is clearly the wrong way to do this
	//!!!
	$(".menu-option").click(
	    function () {
		window.location = $(this).children()[0];
	    });
	    
	//Search result tabs
	//Not done with ajax
	$("#searchTabs").tabs();
	
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
				       
	$("#email_address").focus();
	
	
});	
