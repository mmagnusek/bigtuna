class BuildsController < ApplicationController
  before_filter :locate_build, :only => [:show, :destroy, :cucumber_output]
  respond_to :js, :only => :show

  def show
    render :file => @build.cucumber_output_path, :layout => false if params[:output] == 'cucumber'
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
