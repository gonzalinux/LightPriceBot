

defmodule Bot.LightPriceBot do
  @bot :bot

  @pidGetHoras :pidHoras

  @pidSubs :pidSubs

  #Subs.createSub(@pidGetHoras,@pidSubs)

  use ExGram.Bot,
    name: @bot,
    setup_commands: true

  command("start")
  command("help", description: "Prints LightPrice instructions")
  command("pricenow",description: "Returns the current price of the light")
  command("prices",description: "Returns all the prices per hour")
  command("priceat",description: "Returns the price of the hour specified as argument. The format must be HH:MM")
  command("sub",description: "Automatically notifies you when the prices reach the price threshold specified as argument. This subscription lasts for 24 hours. You can also use > to execute this command.")
  command("desub",description: "Eliminates all subscriptions in your account. You can also use < to execute this command.")

  middleware(ExGram.Middleware.IgnoreUsername)



  def bot(), do: @bot



  def handle({:command, :start, _msg}, context) do
    time=Time.utc_now()
    answer(context, to_string(time.hour+2))
  end

  def handle({:command, :help, _msg}, context) do

    answer(context, "COMMANDS AVAILABLE:\n\n /pricenow  :  Returns the current price of the light.\n /prices  :  Returns all the prices per hour\n /priceat HOUR  :  Returns the price of the hour specified as argument. The format must be HH:MM.\n /sub PERCENTAGE  :  Automatically notify you when the prices reach the price threshold specified as argument. This subscription lasts for 24 hours. You can also use > to execute this command.\n /desub  :  Eliminates all subscriptions in your account. You can also use < to execute this command.")
  end

  def handle({:command, :prices, _msg}, context) do

    x=GenServer.call(@pidGetHoras,:getTodasHoras)
    answer(context,x)


  end
  def handle({:command, :pricenow, _msg}, context) do
    time=Time.utc_now()
    x=GenServer.call(@pidGetHoras,{:horaActual,to_string(time.hour+2)<>":00"})
    answer(context, to_string(x)<>" €/ kWh")

  end

  def handle({:command, :priceat, msg}, context) do

    match = Regex.named_captures(~r"(?<Hora>^\d\d):\d\d$", msg.text)

    if match != nil do

      {hora, resto} = Integer.parse(match["Hora"])

      if hora<24 && hora>0 do

        x=GenServer.call(@pidGetHoras, {:horaActual, to_string(hora)<>":00"})
        answer(context, to_string(x)<>" €/ Wh")

      else
        answer(context, "You must introduce an hour between 00:00 and 24:00 ")
      end

    else
      answer(context, "You must specify an hour with HH:MM format")
    end

  end


  def handle({:command, :desub,msg}, _context) do

    handledesub(msg.chat.id)
  end

  def handle({:command, :sub, msg}, context) do

    handleSub(msg.text,msg,context)
  end

  def handle({:text, ">"<>texto, msg}, context) do

    handleSub(texto,msg,context)

  end
  def handle({:text, "<"<>_texto, msg}, _context) do

    handledesub(msg.chat.id)

  end

  def handle({:text, _text, msg}, context) do
    answer(context, "Use /help to see the commands list.")

  end

  def handle({:command, command, _msg}, context) do
    answer(context, "Command not recognised :"<>command<>". Use /help to see the commands list.")
  end

  defp handledesub(id) do
    GenServer.cast(@pidSubs,{:removeSub,id})
  end

  defp handleSub(text,msg,context) do

    if text=="" do
      answer(context,"Introduce a threshold for the notifications. Example: 60%")
    else
      text=String.replace(text,"%","")

      result=Integer.parse(text)
      if result==:error do
        answer(context,"You must introduce a valid number between 0 and 100")
      else
        {num,_otr}=result
        if num<0 || num>100 do

          answer(context,"You must introduce a valid number between 0 and 100")
        else
          GenServer.cast(@pidSubs,{:addSub,msg.chat.id, num})
          answer(context,"You will be notified when the price excedes or goes below "<>to_string(num)<>"%")
        end


      end
    end
  end


end
