class ActionView::Helpers::FormBuilder

    puts 'FormBuilder methods injected' unless Rails.env.production?

    # Tried to do this as a module mixin in lib, it would load fine but by runtime our stuff was stomped by the metaprogramming magic
    # doing this in an initializer seems to be the ticket


    #
    # def label(method, text = nil, options = {})
    #   # required = object.class.validators_on(method).any? { |v| v.kind_of? ActiveModel::Validations::PresenceValidator }
    #   # options[:class] = 'required ' + options[:class].to_s if required
    #   @template.label(@object_name, method, text, objectify_options(options))
    # end

    def text_field(method, options = {})
     restrictions=field_restriction(method)
     options.delete(:class) if restrictions[:readonly] && options.has_key?(:class) && ['datepicker','datetimepicker'].include?(options[:class])
     @template.text_field(@object_name, method, objectify_options(restrictions.merge!(options)))
    end

    def text_area( method, options = {})
      restrictions=field_restriction(method)
      if options.has_key?(:class) && options[:class] == "texteditor" && ENV["RAILS_ENV"] != "test"
       if restrictions[:readonly]
         return @template.raw("#{@object.send(method)}")
       else
         return @template.text_area(@object_name, method, objectify_options(restrictions.merge!(options)))  +
           @template.raw('<script type="text/javascript">  CKEDITOR.replace(' + "\'#{@object_name}" + '[' + method.to_s + ']\'); </script>')
       end
      end
      @template.text_area(@object_name, method, objectify_options(restrictions.merge!(options)))
    end

    def number_field(method, options = {})
      @template.number_field(@object_name, method,  objectify_options(field_restriction(method).merge!(options)))
    end

    def email_field( method, options = {})
      @template.email_field(@object_name, method, objectify_options(field_restriction(method).merge!(options)))
    end

    def telephone_field(method, options = {})
      @template.telephone_field(@object_name, method, objectify_options(field_restriction(method).merge!(options)))
    end

    def check_box(method, options = {}, checked_value = "1", unchecked_value = "0")
      if field_restriction(method)[:readonly]
        options[:disabled] = true
      end
      @template.check_box(@object_name, method,  options, checked_value, unchecked_value)
    end

    def url_field( method, options = {})       # deny is only thing that would work on this one
      @template.url_field(@object_name, method, objectify_options(field_restriction(method).merge!(options)))
    end

    def select(method, choices, options = {}, html_options = {})
      if field_restriction(method)[:readonly]
        html_options[:disabled] = true
      end
      @template.select(@object_name, method, choices, options, html_options)
    end

    def radio_button(method, tag_value, options = {})
      if field_restriction(method)[:readonly]
        options[:disabled] = true
      end
      @template.select(@object_name, method, tag_value, options)
    end

    def submit(value=nil, options={})
      value, options = nil, value if value.is_a?(Hash)
      value ||= submit_default_value
      options[:disabled] = true if !(action_restriction(:save))
      @template.submit_tag(value, options)
    end

    private

    def action_restriction(action)
      return {} unless @object.methods.include?(:acl)
      return {} if @object.acl.nil? # no acl present
      permission = @object.action_allowed?(action)
    end

    def field_restriction(field)
      # we don't have an implementation for :deny yet
      return {} unless @object.methods.include?(:acl)
      return {} if @object.acl.nil? # no acl present
      permission = @object.field_access(field.to_sym)
      return {readonly: true} if permission == :read_only
      {}
    end

end

