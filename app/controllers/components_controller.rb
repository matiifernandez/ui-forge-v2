class ComponentsController < ApplicationController

  before_action :set_project, only: %i[new create]

  def index
    @project = current_user.projects.find_by(id: params[:project_id])
    unless @project
      flash[:alert] = "You are not authorized to view this component."
      redirect_to projects_path
      return
    end
    @components = @project.components
    @component = Component.new
    @message = Message.new
  end

  def show
    @project = current_user.projects.find_by(id: params[:project_id])
    unless @project
      flash[:alert] = "You are not authorized to view this component."
      redirect_to projects_path
      return
    end
    @component = Component.find(params[:id])
    if @component.html_code && @component.css_code
      @formatted_html = HtmlBeautifier.beautify(@component.html_code)
      @formatted_css = CssBeautify.beautify(@component.css_code)
    end
  end

  def preview
    @component = Component.find(params[:id])
    render layout: false
  end

  def new
    @project = Project.find(params[:project_id])
    @component = Component.new
    @message = Message.new
  end

  def create
    @project.user = current_user
    @project = Project.find(params[:project_id])
    @component = Component.new(component_params)
    @component.project = @project
    if @component.save
      @chat = Chat.new
      @chat.component = @component
      @chat.save
      redirect_to chat_path(@chat)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @component = Component.find(params[:id])
    @component.destroy
    redirect_to component_path, notice: "the component #{@component.name} was deleted"
  end

  def update
    @project = Project.find(params[:project_id])
    @component = Component.find(params[:id])
    new_html = params.dig(:component, :html_code)
    new_css  = params.dig(:component, :css_code)
    @component.html_code = new_html
    @component.css_code = new_css
    if @component.save
      redirect_to project_component_path(@project, @component), notice: "Component updated!"
    else
      redirect_back fallback_location: project_component_path(@project, @component), alert: "Could not update component."
    end
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def component_params
    params.require(:component).permit(:name)
  end
end
