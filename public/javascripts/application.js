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
                  });

$('#people-table').ready(function () {
                           $('#people-table').dataTable();
                         });
