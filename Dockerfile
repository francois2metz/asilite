FROM bitwalker/alpine-elixir-phoenix:latest

ENV PORT=4000 MIX_ENV=prod
EXPOSE 4000

COPY mix.exs mix.lock ./
RUN mix do deps.get, deps.compile

COPY . .
RUN mix do compile, phx.digest

USER default

CMD ["mix", "phx.server"]
