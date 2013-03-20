module WillPaginate::Liquidized
  module ViewHelpers

    include WillPaginate::ViewHelpers

    alias_method :will_paginate_original, :will_paginate

    def pagination_links(collection, anchor = nil, prev_label = nil, next_label = nil)
      opts = {}
      opts[:previous_label] = "&laquo;"
      opts[:next_label]     = "&raquo;"
      opts[:params]         = {:anchor => anchor} if anchor
      opts[:controller]     = @context.registers[:controller]

      with_renderer 'WillPaginate::Liquidized::LinkRenderer' do
        will_paginate_original *[collection, opts].compact
      end
    end

    def pagination_links_remote(collection, anchor = nil, prev_label = nil, next_label = nil)
      opts = {}
      opts[:previous_label] = "&laquo;"
      opts[:next_label]     = "&raquo;"
      opts[:params]         = {:anchor => anchor} if anchor
      opts[:controller]     = @context.registers[:controller]
      opts[:remote]     = true

      with_renderer 'WillPaginate::Liquidized::LinkRenderer' do
        will_paginate_original *[collection, opts].compact
      end
    end

    def with_renderer(renderer)
      old_renderer, options[:renderer] = options[:renderer], renderer
      result = yield
      options[:renderer] = old_renderer
      result
    end

    def options
      WillPaginate::ViewHelpers.pagination_options
    end
  end

  class LinkRenderer < WillPaginate::ViewHelpers::LinkRenderer

    include ActionView::Helpers::UrlHelper
    include ActionView::Helpers::TagHelper

    def tag(name, value, attributes = {})
      string_attributes = attributes.inject('') do |attrs, pair|
        unless pair.last.nil?
          attrs << %( #{pair.first}="#{CGI::escapeHTML(pair.last.to_s)}")
        end
        attrs
      end
      "<#{name}#{string_attributes}>#{value}</#{name}>"
    end

    def link(text, target, attributes = {})
      if target.is_a? Fixnum
        attributes[:rel] = rel_value(target)
        target = url(target)
      end
      attributes[:href] = target
      attributes[:'data-remote'] = true if @options[:remote].present? && @options[:remote]
      tag(:a, text, attributes)
    end

    alias_method :to_html_original, :to_html

    def url(page)
      @base_url_params ||= begin
        url_params = base_url_params
        merge_optional_params(url_params)
        url_params
      end

      url_params = @base_url_params.dup
      add_current_page_param(url_params, page)

      @options[:controller].current_app.url_for(url_params)
    end

    def base_url_params
      url_params = default_url_params
      # page links should preserve GET parameters
      symbolized_update(url_params, @options[:controller].params) if @options[:controller].request.get?
      url_params
    end

    def to_html
      return "<p><strong style=\"color:red;\">(Will Paginate Liquidized) Error:</strong> you must pass a controller in Liquid render call; <br/>
              e.g. Liquid::Template.parse(\"{{ movies | will_paginate }}\").render({'movies' => @movies}, :registers => {:controller => @controller})</p>" unless @options[:controller]

      to_html_original
    end

    #
    # Missing methods in the fork of tronfu
    #

    def merge_optional_params(url_params)
      symbolized_update(url_params, @options[:controller].params) if @options[:controller].params
      url_params
    end

    def add_current_page_param(url_params, page)
      url_params[param_name.to_sym] = page
    end

    def merge_get_params(url_params)
      if @template.respond_to? :request and @template.request and @template.request.get?
        symbolized_update(url_params, @template.params)
      end
      url_params
    end

    def default_url_params
      {}
    end

  end
end

Liquid::Template.register_filter(WillPaginate::Liquidized::ViewHelpers)