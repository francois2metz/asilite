# ASI Lite

This is designed as a fast and simple alternative to https://beta.arretsurimages.net/ for mobile devices.

Minimal javascript is used.

It use the public API to fetch the content. **Nothing is stored on the server**.

## Status

It's currently a proof of concept.

What's working:

- Login
- Listing and pagination of the content
- Showing content
- Displaying video

Planned features:

- RSS feed for all formats
- Better navigation
- Option to display the cover images
- Support for inline video

## Usage

You will need docker to run asitext.

On development, run:

    ./script/server

It will run the server and expose it on the 4000 port: http://localhost:4000

## API bugs

Here is the list of unexpected behavior of the API:

- The `Range` header on search results only accept `0 9`, `10 19` and not arbitrary range.
- The search endpoint ignore parameters if invalid.

## Acknowledgement

Thanks to the team at arretsurimages for the API. I disagree with the choice of using javascript on the client side, but the API is very simple to use.

## License

(c) 2018 François de Metz

MIT
