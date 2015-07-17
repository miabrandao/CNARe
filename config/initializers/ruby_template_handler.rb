handler = ->(template) { template.source }
ActionView::Template.register_template_handler(:rb, handler)
