class ProjectsController < ApplicationController
  def index
    @projects = current_user.projects
    @project = Project.new
  end

  def create
    @project = Project.new(project_params)
    @project.user = current_user
    if @project.save
      respond_to do |format|
        format.turbo_stream # renders create.turbo_stream.erb
        format.html { redirect_to project_components_path(@project) }
      end
    else
      respond_to do |format|
        format.html do
          @projects = current_user.projects
          render :index, status: :unprocessable_entity
        end
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "project_form",
            partial: "projects/form"
          ), status: :unprocessable_entity
        end
      end
    end
  end

  def destroy
    @project = Project.find(params[:id])
    @project.destroy
    redirect_to projects_path, notice: "the project #{@project.title} was deleted"
  end

  def project_params
    params.require(:project).permit(:title, :description, :primary_color, :secondary_color, :photo)
  end
end
