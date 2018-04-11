defmodule Asi do
  defmodule NotFound do
    @moduledoc """
    Exception raised when a 404 is returned
    """
    defexception plug_status: 404, message: "Not found", conn: nil, router: nil

    def exception(_opts) do
      %NotFound{message: "not found"}
    end
  end
  defmodule Error do
    @moduledoc """
    Exception raised when a 404 is returned
    """
    defexception plug_status: 500, message: "Error", conn: nil, router: nil

    def exception(_opts) do
      %NotFound{message: "not found"}
    end
  end
  use HTTPotion.Base

  def process_url(url) do
    "https://api.arretsurimages.net/api/public/" <> url
  end

  def process_request_headers(headers) do
    Keyword.put headers, :"User-Agent", "asitext - be nice don't block me"
  end

  def process_response_body(body) do
    body |> IO.iodata_to_binary |> Poison.decode!()
  end

  def oauth_default_params do
    # Dear @si, As soon as you open the API with another grant_type, I'll remove these stolen credentials
    # from your javascript client. For javascript client, the implicit grant flow is much better.
    %{
      "client_id" => "1_1e3dazertyukilygfos7ldzertyuof7pfd",
      "client_secret" => "2r8yd4a8un0fn45d93acfr3efrgthzdheifhrehihidg4dk5kds7ds23"
    }
  end

  def oauth_default_headers do
    [
      "User-Agent": "asilite - be nice don't block me",
      "Content-Type": "application/json",
      "Referer": "https://www.arretsurimages.net/",
    ]
  end

  def get_token(%{"email" => email, "password" => password}) do
    body = Poison.encode!(Map.merge(%{"username" => email,
                                      "password" => password,
                                      "grant_type" => "password"}, oauth_default_params()))

    HTTPotion.post "https://api.arretsurimages.net/oauth/v2/token", [
      body: body,
      headers: oauth_default_headers()]
  end

  def refresh_token(access_token, refresh_token) do
    body = Poison.encode!(Map.merge(%{"refresh_token" => refresh_token,
                                      "grant_type" => "refresh_token"}, oauth_default_params()))

    HTTPotion.post "https://api.arretsurimages.net/oauth/v2/token", [
      body: body,
      query: %{"access_token" => access_token},
      headers: oauth_default_headers()]
  end
end
