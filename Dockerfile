FROM elixir:1.13

RUN mkdir app
WORKDIR /app

COPY . /app

ENV MIX_ENV=dev

RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix deps.get
RUN mix deps.compile
EXPOSE 4000

CMD ["mix", "phx.server"]

