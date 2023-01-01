defmodule TextServerWeb.Subdomain.PageController do
  use TextServerWeb, :controller

  alias TextServer.Projects
  alias TextServerWeb.Helpers.Markdown

  def index(conn, _params) do
    project = Projects.get_project_by_domain!(conn.private[:subdomain])
    html = Markdown.sanitize_and_parse_markdown(project.homepage_copy)
    featured_commentaries = Projects.get_project_versions(project.id)

    render(conn, "index.html", %{
      featured_commentaries: featured_commentaries,
      homepage_copy: html,
      project: project
    })
  end
end
