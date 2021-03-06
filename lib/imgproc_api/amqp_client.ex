defmodule ImgprocApi.AmqpClient do
	def send(exchange, key, bytes, headers) do
		env_host = System.get_env("AMQP_HOSTNAME")
		conn_options = [host: env_host || "localhost", port: 5672, virtual_host: "/", username: "guest", password: "guest"]
		{:ok, conn} = AMQP.Connection.open(conn_options)
		{:ok, chan} = AMQP.Channel.open(conn)

		{:ok, %{queue: callback_queue}} = AMQP.Queue.declare(chan, "", exclusive: true)

		AMQP.Basic.consume(chan, callback_queue, nil, no_ack: true)

		correlation_id =
			:erlang.unique_integer
			|> :erlang.integer_to_binary
			|> Base.encode64

		AMQP.Basic.publish(chan, 
		exchange,
		key,
		bytes, 
		headers: headers,
		reply_to: callback_queue,
		correlation_id: correlation_id)

		wait_for_messages(chan)
	end

	defp wait_for_messages(channel) do
		receive do
			{:basic_deliver, payload, meta} -> consume_response(channel, meta.consumer_tag, payload)
		end
	end

	defp consume_response(_channel, _tag, payload) do
		# :ok = AMQP.Basic.ack channel, tag
		payload
	end
end
