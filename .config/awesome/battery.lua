local wibox = require("wibox")

text_widget = wibox.widget.textbox()
text_widget:set_text(" | Battery | ")

batterywidget = wibox.widget.background()
batterywidget:set_widget(text_widget)

flickertimer = timer({ timeout = 0.5 })
switch = 0
flickertimer:connect_signal("timeout",
    function()
        if switch == 0 then
            batterywidget:set_bg()
            batterywidget:set_fg()
            switch = 1
        else
            batterywidget:set_bg("#EB400A")
            batterywidget:set_fg("#000000")
            switch = 0
        end
    end
)


batterywidgettimer = timer({ timeout = 5 })
batterywidgettimer:connect_signal("timeout",
  function()
    fh = assert(io.popen("acpi | cut -d, -f 2 -", "r"))
    output = ''
    total = 0
    for line in fh:lines() do
        total = total + string.match(line, "%d+")
        output = output .. line
    end
    if total < 20 then
        flickertimer:start()
    else
        flickertimer:stop()
        batterywidget:set_bg()
        batterywidget:set_fg()
    end
    text_widget:set_text(" |" .. output .. " | ")
    fh:close()
  end
)
batterywidgettimer:start()
