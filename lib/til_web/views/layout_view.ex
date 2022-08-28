defmodule TilWeb.LayoutView do
  use TilWeb, :view

  alias Makeup.Styles.HTML.Style

  @jr_style Style.make_style(
              short_name: "Jr",
              long_name: "Jr Style",
              background_color: "#000000",
              highlight_color: "#222222",
              styles: %{
                :error => "border:#FF0000",
                :keyword => "#569cd6",
                :keyword_declaration => "#646695",
                :keyword_namespace => "#569cd6",
                :keyword_type => "#6a9955",
                :name_builtin => "#cd00cd",
                :name => "#9cdcfe",
                :name_function => "#dcdcaa",
                :name_class => "#6a9955",
                :name_exception => "bold #666699",
                :name_variable => "#00cdcd",
                :string => "#ce9178",
                :number => "#cd00cd",
                :operator => "#3399cc",
                :operator_word => "#cdcd00",
                :punctuation => "#fff",
                :comment => "#c0c0c0",
                :comment_special => "bold #cd0000",
                :generic_deleted => "#cd0000",
                :generic_emph => "italic",
                :generic_error => "#FF0000",
                :generic_heading => "bold #000080",
                :generic_inserted => "#00cd00",
                :generic_output => "#888",
                :generic_prompt => "bold #000080",
                :generic_strong => "bold",
                :generic_subheading => "bold #800080",
                :generic_traceback => "#04D"
              }
            )

  def stylesheet() do
    Style.stylesheet(@jr_style, "makeup")
  end

  # Phoenix LiveDashboard is available only in development by default,
  # so we instruct Elixir to not warn if the dashboard route is missing.
  @compile {:no_warn_undefined, {Routes, :live_dashboard_path, 2}}
end
