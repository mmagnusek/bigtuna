class BuildsController < ApplicationController
  before_filter :locate_build, :only => [:show, :destroy, :cucumber_output]
  respond_to :js, :only => :show

  def show
    render :file => @build.output_path(params[:output]), :layout => false if params[:output]
  end

  def destroy
    project = @build.project
    @build.destroy
    redirect_to project_path(project)
  end

  private
  def locate_build
    @build = Build.find(params[:id])
  end
end
