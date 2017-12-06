require 'active_support'
require 'active_support/core_ext'
require 'erb'
require_relative './session'
require 'byebug'
class ControllerBase
  attr_reader :req, :res, :params

  # Setup the controller
  def initialize(req, res)
    @req = req
    @res = res
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    @already_built_response ||=false
    
    # raise "already built response"
  end

  # Set the response status code and header
  def redirect_to(url)
    unless already_built_response?
      @res.status = 302
      @res['Location'] = url
      @session.store_session(@res)
      @already_built_response = true
    else 
      raise 'already built response'
    end
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    unless already_built_response?
      @res['Content-Type'] = content_type
      @res.write(content)
      @session.store_session(@res)
      @already_built_response = true
    else 
      raise 'already built response'
    end
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    unless already_built_response?
      path = "views/#{self.class.to_s.underscore}/#{template_name}.html.erb"
      file_string = File.read(path)
      smart_string = ERB.new(file_string)
      content = smart_string.result(binding)
      render_content(content, 'text/html')
    else 
      raise 'already built response'
    end
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(@req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
  end
end

