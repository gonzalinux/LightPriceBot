defmodule Scheduler do
    use GenServer

    def start_link({pidHoras,pidsubs}) do
        {:ok,spawn(fn ()->
            time=Time.utc_now()
            result =getActual(time,pidHoras)
            #scheduler(pidsubs,3000, pidHoras, result)

            scheduler(pidsubs, (60-time.minute)*60*1000, pidHoras,result)
          end)}
    end




    defp scheduler(pid, time, pidHoras, anterior) do
        Process.sleep(time)
        time=Time.utc_now()
        result=getActual(time,pidHoras)


        GenServer.cast(pid, {:check,result,anterior})

        scheduler(pid,(60-time.minute)*60*1000, pidHoras, result)
        #scheduler(pid,3000, pidHoras, result)

      end
      defp getActual(time, pidHoras) do
        hora =rem(time.hour+2,24)

        if hora == 0 do
          GenServer.cast(pidHoras,:actualizaHoras)
        end

        IO.puts("AAAAAA2")
        IO.puts(GenServer.call(pidHoras,{:percenActual,to_string(hora)<>":00"}))

        GenServer.call(pidHoras,{:percenActual,to_string(hora)<>":00"})

      end

end
