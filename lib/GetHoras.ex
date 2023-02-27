defmodule GetHoras do

    use GenServer
    use Tesla

    plug Tesla.Middleware.BaseUrl, "https://gonzalo-leon.site:3000"
    plug Tesla.Middleware.Headers, []
    plug Tesla.Middleware.JSON

    def receiveHoras() do

      {:ok,respuesta}=get("/horas")

      respuesta.body
    end

    def start_link(nombre) do
      #pid=spawn(fn ()->loop(receiveHoras())end)

      {:ok,pid}=GenServer.start_link(__MODULE__,receiveHoras(),name: nombre)

    end

    @impl true
    def init(horas) do
      {:ok, horas}
    end

    @impl true
    def handle_call(:getTodasHoras, _from, horas) do
      values=Map.get(horas,"values",false)
      {:reply, "Precio por horas: \n"<>goodFormat(values, horas["min"],horas["max"]), horas}
    end

    @impl true
    def handle_call({:horaActual,hora}, _from, horas) do
      values=Map.get(horas,"values",false)
      {:reply,Float.ceil( getHourFromValues(values,hora)/1000,5), horas}
    end




    @impl true
    def handle_call({:percenActual,hora}, _from, horas) do
      values=Map.get(horas,"values",false)
      {:reply, getPercent(getHourFromValues(values,hora),horas["min"],horas["max"]), horas}
    end
    @impl true

    def handle_cast(:actualizaHoras, _horas) do

      {:noreply, receiveHoras()}
    end




    # defp loop(horas) do
    #   receive do
    #     {:horaActual,hora, parent} ->
    #       values=Map.get(horas,"values",false)
    #       send(parent,getHourFromValues(values,hora))
    #       loop(horas)
    #     {:actualizaHoras, parent}->
    #       send(parent,:ok)
    #       loop(receiveHoras())
    #     {:max, parent} ->
    #       max=Map.get(horas,"max",false)
    #       send(parent,max)
    #       loop(horas)
    #     {:min, parent} ->
    #       min=Map.get(horas,"min",false)
    #       send(parent,min)
    #       loop(horas)
    #     {:getTodasHoras,parent} ->
    #       values=Map.get(horas,"values",false)
    #       send(parent,"Precio por horas: \n"<>goodFormat(values, horas["min"],horas["max"]))
    #       loop(horas)
    #     {:percenActual,hora, parent} ->
    #       values=Map.get(horas,"values",false)
    #       send(parent,getPercent(getHourFromValues(values,hora),horas["min"],horas["max"]))
    #       loop(horas)



    #   end


    # end

    defp goodFormat([],_1,_2) do

      ""
    end

    defp goodFormat([%{"time" => hora, "value" => valor}|l], min,max) do
      percent=getPercent(valor,min,max)

      emoji=if percent > 80 do
        "​🟥"
      else if percent >60 do
        "​🟧"
        else if percent >40 do
          "🟨"

        else if percent >20 do
          "​​🟩"
        else
          "​🟦"
        end
        end
          end

      end



      " #{emoji} #{hora}   ->   #{Float.ceil(valor/1000,5)} €/ kWh   #{percent}% \n\n"<>goodFormat(l,min,max)

    end


    defp getHourFromValues([%{"time" => hora, "value" => valor}|_l], hora2) when hora==hora2 do
      valor
    end

    defp getHourFromValues([%{"time" => _hora, "value" => _valor}|l], hora2)  do
      getHourFromValues(l,hora2)
    end
    defp getHourFromValues([], _a)  do
      false
    end



    defp getPercent(value,min,max) do
        (value-min)/(max-min)*100
        |> Float.ceil(2)

    end
end
