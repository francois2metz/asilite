FROM bitwalker/alpine-elixir-phoenix:latest as builder

ENV MIX_ENV=prod

COPY mix.exs mix.lock ./
RUN mix do deps.get, deps.compile

COPY assets/package.json assets/
RUN cd assets && \
    npm install

RUN npm install -g raml2html

COPY . .


RUN raml2html api.raml > assets/static/api.html

RUN cd assets/ && \
    npm run deploy && \
    cd - && \
    mix do compile, phx.digest, release

FROM alpine:3.7

EXPOSE 4000
ENV PORT=4000

WORKDIR /app

RUN apk add --no-cache bash openssl && \
    adduser -s /bin/sh -u 1001 -G root -h /app -S -D default

COPY --from=builder /opt/app/_build/prod/rel/asitext /app

USER default

RUN mkdir elixir_tzdata_data

CMD [ "/app/bin/asitext", "foreground" ]
