defmodule KVServer do
  require Logger

  @moduledoc """
  server that hangs on socket.
  """

  def start_recv(port) do
    # should this be a process laucnhed by supervisor or like, should it loop? or do we only loop on the socket?
    spawn fn ->
      case :gen_tcp.listen(port, [:binary, packet: :line, active: false, reuseaddr: true]) do
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
    {:ok, pid} = Task.Supervisor.start_child(KVServer.Supervisor, fn -> serve(client) end)
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
    data
  end

  defp write_line(line, socket) do
    :gen_tcp.send(socket, line)
  end
end
