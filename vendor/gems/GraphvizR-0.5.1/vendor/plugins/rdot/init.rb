require 'rdot'
require 'rdot_template'

ActionView::Base.register_template_handler 'rdot', RdotTemplate
