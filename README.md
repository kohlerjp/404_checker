
#  404 Checker
Crawls a website searching for invalid links.

```elixir
mix crawl <base_url>
```

#### Options
`--max-depth`: Maximum depth the scraper will travel. Defaults to 3.

`--num-workers:` Maximum amount of concurrent workers making requests to the provided URL. Defaults to 20.


```elixir
def deps do
   [{:crawler, git: "https://github.com/kohlerjp/404_checker"}]
end
```

## Output
If no links are found to be invalid, the task exits with status code 0,
otherwise, exits with status code 1.

If any invalid links are found, they are printed out, along with parent link and depth


Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/link](https://hexdocs.pm/link).

