defmodule Asi do
  use HTTPotion.Base

  def process_url(url) do
    "https://api.arretsurimages.net/api/public/" <> url
  end

  def process_request_headers(headers) do
    Dict.put headers, :"User-Agent", "asitext - be nice don't block me"
  end

  def process_response_body(body) do
    body |> IO.iodata_to_binary |> Poison.decode!()
  end

  def oauth_default_params do
    # Dear @si, As soon as you open the API with another grant_type, I'll remove these stolen credentials
    # from your javascript client. For javascript client, the implicit grant flow is much better.
    %{"client_id" => "1_1e3dazertyukilygfos7ldzertyuof7pfd",
      "client_secret" => "2r8yd4a8un0fn45d93acfr3efrgthzdheifhrehihidg4dk5kds7ds23"}
  end

  def get_token(%{"email" => email, "password" => password}) do
    body = Poison.encode!(Map.merge(%{"username" => email,
                                      "password" => password,
                                      "grant_type" => "password"}, oauth_default_params()))


    HTTPotion.post "https://api.arretsurimages.net/oauth/v2/token", [
      body: body,
      headers: ["User-Agent": "asitext - be nice don't block me", "Content-Type": "application/json"]]
  end

  def refresh_token(access_token, refresh_token) do
    body = Poison.encode!(Map.merge(%{"refresh_token" => refresh_token,
                                      "grant_type" => "refresh_token"}, oauth_default_params()))

    HTTPotion.post "https://api.arretsurimages.net/oauth/v2/token", [
      body: body,
      query: %{"access_token" => access_token},
      headers: ["User-Agent": "asitext - be nice don't block me", "Content-Type": "application/json"]]
  end
end
