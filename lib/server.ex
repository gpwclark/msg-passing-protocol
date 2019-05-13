defmodule KV.Server do
  require Logger

  @moduledoc """
  server that hangs on socket.
  """

  def start_recv(port) do
    # should this be a process laucnhed by supervisor or like, should it loop? or do we only loop on the socket?
    spawn fn ->
      Logger.info("start")
      case :gen_tcp.listen(port, [:binary, active: false, packet: :line, reuseaddr: true]) do
        {:ok, socket} ->
          Logger.info("Connected")
          accept_conn(socket)
        {:error, reason} ->
          Logger.error("failed to listen on socket: #{reason}")
      end
    end
  end

  defp accept_conn(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    {:ok, pid} = Task.Supervisor.start_child(KV.ServerSupervisor, fn -> serve(client) end)
    :ok = :gen_tcp.controlling_process(client, pid)
    accept_conn(socket)
  end

  defp serve(socket) do
    socket
    |> read_line()
    |> write_line(socket)

    serve(socket)
  end

  defp read_line(socket) do
    {ok, data} = :gen_tcp.recv(socket, 0)
    {json, payload} = parse(data)
    Logger.info "json " <> json
    Logger.info "payload " <> payload
    data
  end

  defp parse(data) do
    {json, payload} = parse(hd(data), tl(data), <<>>)
    json = Poison.decode!(json)
  end

  defp parse(head, tail, buf) do
    Logger.info("buf as w eknow it #{inspect buf}")
    case head do
      {?{} ->
        Logger.info("the head! #{inspect head}")
        parse(hd(tail), tl(tail), buf <> head)
      {?}} ->
        Logger.info("the tail! #{inspect head}")
      _ ->
        Logger.info("everyday I'm bufferin' #{inspect head}")
    end
  end

  defp write_line(line, socket) do
    :gen_tcp.send(socket, line)
  end
end
