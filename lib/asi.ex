defmodule Asi do
  use HTTPotion.Base

  def process_url(url) do
    "https://api.arretsurimages.net/api/public/" <> url
  end

  def process_request_headers(headers) do
    Dict.put headers, :"User-Agent", "asi-potion"
  end

  def process_response_body(body) do
    body |> IO.iodata_to_binary |> Poison.decode!()
  end
end
