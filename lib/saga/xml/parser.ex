defmodule Saga.Xml.Parser do
  defp decode_tag(data) do
    case String.split(data, " ", parts: 2, trim: true) do
      [tagname, rest] -> {tagname, decode_args(rest)}
      [data] ->
          case String.split(data, "/>", parts: 2) do
            [tagname, ""] -> {:element, tagname, []}
            []

  def decode(_pid, ""), do: :ok
  def decode(pid, <<"</", rest::binary>>) do
    [tag, rest] = String.split(rest, [">"], parts: 2, trim: true)
    send(pid, {:endelement, tag})
    decode(pid, rest)
  end
  def decode(pid, <<"<", rest::binary>>) do
    [whole_tag, rest] = String.split(rest, [">"], parts: 2, trim: true)
    send(pid, decode_tag(String.trim(whole_tag) <> ">"))
    decode(pid, rest)
  end
  def decode(pid, <<"<![CDATA[", rest::binary>>) do
    [cdata, rest] = String.split(rest, "]]>", parts: 2)
    send(pid, {:cdata, cdata})
    decode(pid, rest)
  end
  def decode(pid, data) do
    [tag, rest] = String.split(data, "<", parts: 2)

end
