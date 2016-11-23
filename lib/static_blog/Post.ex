defmodule StaticBlog.Post do
	defstruct slug: "", title: "", date: "", intro: "", content: "", img: ""

	def compile(file) do
		post = %StaticBlog.Post{
			slug: file_to_slug(file)
		}

		Path.join(["priv/posts", file])
		|> File.read!
		|> split
		|> extract(post)
	end

	defp file_to_slug(file) do
    	String.replace(file, ~r/\.md$/, "")
  	end

	defp split(data) do
		[frontmatter, markdown] = String.split(data, "\n---", parts: 2) #TODO: figure out the regex to do this.
		{parse_yaml(frontmatter), Earmark.to_html(markdown)}
	end

	defp parse_yaml(yaml) do
		[parsed] = :yamerl_constr.string(yaml)
		parsed
	end

	defp extract({props, content}, post) do
	    %{post |
	      title: get_prop(props, "title"),
	      date: Timex.parse!(get_prop(props, "date"), "{ISOdate}"),
	      intro: get_prop(props, "intro"),
	      content: content,
		  img: get_prop(props,"img")}
  	end

  	defp get_prop(props, key) do
  		case :proplists.get_value(String.to_char_list(key), props) do
  			:undefined -> nil
  			x -> to_string(x)
  		end
  	end
end