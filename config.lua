Config = {}

Config.Framework = 'esx' -- can use esx or qbx for functionality 

Config.TicketMachine = {
    model = "prop_park_ticket_01", -- can change to prop that is more suitable 
    coords = vec4(172.826370, -1001.274720, 29.330444, 342.0)
}

Config.Blip = {
    enable = true, -- true/false if you want to blip to appear or not.

    sprite = 408, 
    display = 4, -- main map
    scale = 0.8, -- size of the blip
    colour = 0, -- colour of the blip

    label = "Vote for Mayor" -- label of the blip on the map
}

Config.WebhookURL = ""