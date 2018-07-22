# ASI Lite

This is designed as a fast and simple alternative to https://www.arretsurimages.net/ for mobile devices.

Minimal javascript is used.

It use the public API to fetch the content. **Nothing is stored on the server**.

## Status

It's currently working and usable.

What's working:

- Login, logout
- List and paginate content
- Display content
- Display video
- Display inline video
- Navigate content, authors
- Search
- RSS/Atom feeds

Planned features:

- Option to display the cover images
- Fix layout of old articles

## Usage

You will need docker to run asilite.

On development, run:

    ./script/server

It will run the server and expose it on the 4000 port: http://localhost:4000

On production:

1. Create the `config/prod.secret.exs` file with the following content

```elixir
use Mix.Config
config :asitext, AsitextWeb.Endpoint,
  secret_key_base: "YOURSECRETKEYBASE"
```

1. Build the image: `docker build --tag asi .`
1. Run it: `docker run --publish 4000:4000 asi`

## API bugs

Here is the list of unexpected behavior of the API:

- The `Range` header on search results only accept `0 9`, `10 19` and not arbitrary range.
- The search endpoint ignore parameters if invalid.
- Some date are not formatted correctly

## Acknowledgement

Thanks to the team at arretsurimages for the API. I disagree with the choice of using javascript on the client side, but the API is very simple to use.

## License

(c) 2018 François de Metz

MIT
