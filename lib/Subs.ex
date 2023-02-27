defmodule Subs do


  use GenServer;


    def start_link(nombre) do

      GenServer.start_link(__MODULE__,%{},name: nombre);
    end

    @impl true
    def init(subs) do
      {:ok, subs}
    end

    @impl true
    def handle_cast( {:addSub,idChat,umbral}, subs) do
      map =if Map.has_key?(subs,idChat) do
        lista= subs[idChat]
        %{subs | idChat=> [{idChat,umbral, 24}|lista]}
      else
        Map.put(subs, idChat, [{idChat,umbral, 24}])
      end
      {:noreply, map}
    end
    @impl true
    def handle_cast( {:check, valor, valorAnterior} , subs) do
      {:noreply, checkTodos(Map.keys(subs),valor, valorAnterior, subs)}
    end
    @impl true
    def handle_cast( {:removeSub, idChat} , subs) do
      map =if Map.has_key?(subs, idChat) do
        ExGram.send_message(idChat,"Se cancelan todas las subscripciones de este usuario.")
          Map.delete(subs,idChat)
      else
        ExGram.send_message(idChat,"No había ninguna subscripción para este usuario.")
        subs
      end
      {:noreply, map}
    end






    defp checkTodos( [], _valor, _valorAnterior, map) do
      map
    end
    defp checkTodos([idchat|resto],valor, valorAnterior, map) do
      lista =map[idchat]
      nuevalista=checkIdSubs(lista, valor,valorAnterior)

      map=if nuevalista == [] do
        Map.delete(map, idchat)
      end
      checkTodos(resto,valor, valorAnterior,map)

    end

    defp checkIdSubs([], _valor, _valorAnterior)do
      []
    end
    defp checkIdSubs([{idchat,umbral, caducidad}|l], valor, valorAnterior)do
      if  valorAnterior<umbral && valor>umbral do
        ExGram.send_message(idchat,"Alerta de precio. \n\n Se ha superado el umbral proporcionado(#{umbral}%).")
      else if valorAnterior>umbral && valor<umbral do
        ExGram.send_message(idchat,"Alerta de precio. \n\n El precio ha bajado del umbral proporcionado(#{umbral}%).")
        end
      end
      if caducidad==0 do
        [[]|checkIdSubs(l,valor, valorAnterior)]
      else
        [{idchat,umbral, caducidad-1}|checkIdSubs(l,valor, valorAnterior)]
      end


    end



end
