// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(document).ready(function () {

        // create the datatable
        $(".datatable").dataTable({'aaSorting': [ [1, 'asc']] });

        $('#navbar-search-form-text').click(function() {
                if ($(this).attr('value') == 'Search')
                {
                    $(this).attr({'value': ''});
                }
            });

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

        $(".menu-option").click(function () {
                window.location = $(this).children()[0];
            });

    });

$("#model-tabs").ready(function () {
        $("#model-tabs").tabs( {

            load: function () {
                $(".complete").autocomplete('/tags/complete_tags', {} );
             }});
    });


$("#email_address").ready(function () {
        $("#email_address").focus();
    });
