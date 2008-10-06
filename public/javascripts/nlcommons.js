var browse_sections =
  $A(['model-div', 'modify-div', 'history-div',
      'discuss-div', 'tags-div']);

var model_sections =
  $A(['associated-docs-div', 'applet-div', 'info-div',
      'procedures-div', 'gui-div']);

function hide_all_sections_except(divs_array, to_show) {
  divs_array.each(function(item) {
                    if (item == to_show) {
                      $(item).show();
                    } else {
                      $(item).hide();
                    }
                  });
}

// Event.addBehavior({
//                     '#add_tag_field_button:click': function() { alert('adding_tag'); },
//                     '#model-tab:click': function() { hide_all_sections_except(browse_sections, 'model-div'); hide_all_sections_except(model_sections, 'info-div'); },
//                     '#modify-tab:click': function() { hide_all_sections_except(browse_sections, 'modify-div'); },
//                     '#history-tab:click': function() { hide_all_sections_except(browse_sections, 'history-div'); },
//                     '#discuss-tab:click': function() { hide_all_sections_except(browse_sections, 'discuss-div'); },
//                     '#tags-tab:click': function() { hide_all_sections_except(browse_sections, 'tags-div'); },

//                     '#associated-docs-tab:click': function() { hide_all_sections_except(model_sections, 'associated-docs-div'); },
//                     '#applet-tab:click': function() { hide_all_sections_except(model_sections, 'applet-div'); },
//                     '#info-tab:click': function() { hide_all_sections_except(model_sections, 'info-div'); },
//                     '#procedures-tab:click': function() { hide_all_sections_except(model_sections, 'procedures-div'); },
//                     '#gui-tab:click': function() { hide_all_sections_except(model_sections, 'gui-div'); },

//                     '.empty-on-click:click': function() {
//                     if (!this.hasClassName('clicked'))
//                     {
//                       this.value = '';
//                       this.addClassName('clicked');
//                     }
//                     }
//                   });



document.observe('dom:loaded', function() {
                   new Control.Tabs('navigation_tabs');
                   new Control.Tabs('model_tabs');
                 });
