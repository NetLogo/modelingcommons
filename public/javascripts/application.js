// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(document).ready(function () {
                    $('#people-table').dataTable();

                    $(document).ready(function(){
                      $("input.autocomplete").autocomplete({ list: ["hello", "hello person", "goodbye"]})
                        .bind("activate.autocomplete", function(e,d) { alert(d) })
                          });

                  });
