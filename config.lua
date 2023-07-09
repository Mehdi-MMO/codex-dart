Config = {}

-- Dart settings
Config.DartCooldown = 300 -- Cooldown in seconds for the /removedart command
Config.DartTimer = 10 -- Timer in minutes for the dart attachment
Config.UseKeybind = false -- Set to true to use the keybind, false to use the command only
Config.CommandName = 'firedart' -- Command name to fire the dart
Config.Keybind = 'G' -- Keybind to fire the dart
Config.useNDCore = false
Config.PoliceJobs = {'LSPD', 'BCSO'} -- For NDCore

-- Blip settings
Config.Blip = {
    Color = {
        LongDuration = 26, -- Blip color for durations over 20% of the time left
        MediumDuration = 47, -- Blip color for durations between 10% and 20% of the time left
        ShortDuration = 1 -- Blip color for durations less than 10% of the time left
    },
    Sprite = 794
}
