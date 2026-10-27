Config = {}

-- Available UI languages: 'en' (English), 'sl' (Slovenian), 'de' (German), 'hr' (Croatian).
-- English is the default.
Config.Locale = 'en'

-- Access is checked server-side. Job names must match your ESX jobs exactly.
Config.AllowedJobs = {
    police = true,
    sheriff = true
}

-- Officers cannot select or jail themselves.
Config.AllowSelfJail = false

-- Maximum distance for nearby-player selection.
Config.NearbyDistance = 5.0

-- The number entered in the UI is called "months", but each month equals one real minute.
Config.MinMonths = 1
Config.MaxMonths = 120

-- Change these coordinates to match your server map.
Config.JailSpawn = vector4(1690.15, 2565.90, 45.56, 180.0)
Config.ReleaseSpawn = vector4(1848.75, 2585.90, 45.67, 270.0)

-- Circular prison boundary. Players are returned to JailSpawn if they leave this radius.
-- Adjust the center/radius to fit your prison area.
Config.JailZoneCenter = vector3(1690.15, 2565.90, 45.56)
Config.JailZoneRadius = 150.0
Config.JailZoneCheckInterval = 750 -- milliseconds

-- If true, jailed players are teleported to the configured jail spawn on resource start/reconnect.
Config.TeleportOnJailLoad = true

-- Optional: set true to disable player controls while jailed (movement and camera remain available).
Config.RestrictControls = false

-- Database table used for persistent jail time.
Config.DatabaseTable = 'smrkec_jail_records'

-- UI labels
Config.ServerName = 'SMRKEC POLICE'
Config.MenuTitle = 'Jail System'
