class ComponentsController < ApplicationController

  before_action :set_project, only: %i[new create]

  def index
    @project = Project.find(params[:project_id])
    @components = @project.components
    @component = Component.new
    @message = Message.new
  end

  def show
    @component = Component.find(params[:id])
    @project = Project.find(params[:project_id])
    @formatted_html = HtmlBeautifier.beautify(@component.html_code)
    @formatted_css = CssBeautify.beautify(@component.css_code)
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

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def component_params
    params.require(:component).permit(:name)
  end
end
