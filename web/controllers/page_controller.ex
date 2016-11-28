defmodule StaticBlog.PageController do
	use StaticBlog.Web, :controller

  	def index(conn, _params) do
		{:ok, posts} = StaticBlog.Repo.list()
		render conn, "index.html", posts: posts
	end

  	def archives(conn, _params) do
		{:ok, posts} = StaticBlog.Repo.list()		
		render conn, "archives.html", posts: posts
	end

	def about(conn, _params) do
		render conn, "about.html"
	end
end
