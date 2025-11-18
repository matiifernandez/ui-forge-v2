class ComponentsController < ApplicationController
  def index
    @project = Project.find(params[:project_id])
    @components = @project.components
  end
end
