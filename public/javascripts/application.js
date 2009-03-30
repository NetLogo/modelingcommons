// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(document).ready(function () {

                    $('#search_term_search_term').click(function() {
                                                          if ($(this).attr('value') == 'Search')
                                                          {
                                                            $(this).attr({'value': ''});
                                                          }
                                                        });

                    $('#new_comment_').click(function() {
                                               if ($(this).attr('value') == '(Optional) comment about why this tag is relevant to this model')
                                               {
                                                 $(this).attr({'value': ''});
                                               }
                                             });
                    // Start Superfish menu
                    jQuery('ul.sf-menu').superfish({ pathClass: 'current' });

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

                    $('ul.sf-menu li a').click(handle_menu_click);
                    $('ul.sf-menu li ul li a').click(handle_menu_click);

                    $(".empty-on-click").livequery('click', function() {
                                                     if (this.hash == '') ($(this).attr('value') == 'Tag name')
                                                     {
                                                       $(this).attr({'value': ''});
                                                     }
                                                   });

                    $(".complete").autocomplete('/tags/complete_tags',
                                                {extraParams: {foo: 5 } });


                  });

$('#people-table').ready(function () {
                           $('#people-table').dataTable();
                         });

$("#model-tabs").ready(function () {
  $("#model-tabs").tabs();
                       });

