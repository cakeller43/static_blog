defmodule StaticBlog.Crawler do
	def crawl do
		File.ls!("priv/posts")
		|> Enum.map(fn(file) -> Task.async(fn -> StaticBlog.Post.compile(file) end) end)
		|> Enum.map(&Task.await/1)
		|> Enum.sort(&sort/2)
	end

	def sort(a, b) do
		Timex.compare(a.date, b.date) > 0
	end
end