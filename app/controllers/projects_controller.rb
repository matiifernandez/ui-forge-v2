class ProjectsController < ApplicationController
  def index
    @projects = Project.all
    @project = Project.new
  end

  def create
    @project = Project.new(project_params)
    @project.user = current_user
    if @project.save
      redirect_to project_components_path(@project)
    else
      @projects = Project.all
      render :index, status: :unprocessable_entity
    end
  end

  def project_params
    params.require(:project).permit(:title, :description)
  end
end
