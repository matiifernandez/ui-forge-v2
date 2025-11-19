class ComponentsController < ApplicationController
  def index
    @project = Project.find(params[:project_id])
    @components = @project.components
  end

  def preview
    @component = Component.find(params[:id])
    render layout: false
  end

  def show
    @component = Component.find(params[:id])
    @project = Project.find(params[:project_id])
    @formatted_html = HtmlBeautifier.beautify(@component.html_code)
    @formatted_css = CssBeautify.beautify(@component.css_code)
  end
end
