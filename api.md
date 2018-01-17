# Unofficial API documentation of arretsurimages.net

The base URL of the API is:

    https://api.arretsurimages.net/api/public/

If you are authenticated, add the *access_token* parameter to the query string.

## Pagination

Some endpoints may be paginated. To get another page, use the header `Range`:

     Range: object 10 19

## Authentication

Authentication is done via OAuth2. Only the Resource Owner Password Credentials Grant flow is supported for now.

See [the RFC](https://tools.ietf.org/html/rfc6749#section-4.3).

### Get a token

    POST https://api.arretsurimages.net/oauth/v2/token

**Parameters:**

In the body as json

- *username*: the email of the user
- *password*: the password of the user
- *grant_type*: must set to *password*
- *client_id*: the id of the application
- *client_secret*: the secret key of the application

**Response:**

```
{
   "access_token": "",
   "refresh_token": "",
   "expires_on": "",
   "token_type": ""
}
```

### Refresh the token

    POST https://api.arretsurimages.net/oauth/v2/token

**Parameters:**

In the body as json

- *refresh_token*: the refresh token
- *grant_type*: must set to *refresh_token*
- *client_id*: the id of the application
- *client_secret*: the secret key of the application

In the query string

- *access_token*: the access token

**Response:**

```
{
   "access_token": "",
   "refresh_token": "",
   "expires_on": "",
   "token_type": ""
}
```

## Search

    GET /search

**Parameters:**

- *format*: can be *chronique*, *article* or *emission*
- *q*: the query

*This endpoint is paginated*.

**Response:**

    206

## Get content

    GET /contents/:type/:slug

**Response:**

     200
