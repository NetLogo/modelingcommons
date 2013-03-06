module ProjectsHelper
  def create_project_button
    link_to "<button>Create a new project</button>", :controller => :projects, :action => :new
  end
end
