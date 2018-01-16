FROM bitwalker/alpine-elixir-phoenix:latest

ENV PORT=4000 MIX_ENV=prod
EXPOSE 4000

COPY mix.exs mix.lock ./
RUN mix do deps.get, deps.compile

COPY assets/package.json assets/
RUN cd assets && \
    npm install

COPY . .

RUN cd assets/ && \
    npm run deploy && \
    cd - && \
    mix do compile, phx.digest

RUN chown -R 1001 deps/tzdata/priv

USER default

CMD ["mix", "phx.server"]
