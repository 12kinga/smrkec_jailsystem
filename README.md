# Smrkec Jail System

**Smrkec Jail System** is a simple and user-friendly jail system for FiveM roleplay servers using the ESX framework. It allows authorized police officers and sheriffs to jail nearby players through a clean and modern NUI interface.

## Features

- **Modern NUI Menu** – Clean and easy-to-use interface.
- **Job Permissions** – Access restricted to the `police` and `sheriff` jobs.
- **Nearby Player Selection** – Select a nearby player to send to jail.
- **Custom Jail Reason** – Enter the reason for the sentence.
- **Custom Jail Duration** – Set the sentence duration in minutes.
- **Jail Timer HUD** – Displays the remaining sentence time on the right side of the screen.
- **Jail Zone Enforcement** – Players who leave the configured jail area are teleported back.
- **Configurable Locations** – Set the jail location and release location in the configuration file.
- **Self-Jailing Prevention** – Players cannot send themselves to jail.
- **ESX Integration** – Designed for FiveM servers running ESX.

## Requirements

- FiveM Server
- ESX Framework

## Installation

1. Download or clone this repository.
2. Extract the `smrkec_jailsystem` folder into your server's `resources` directory.
3. Add the following line to your `server.cfg`:

   ```cfg
   ensure smrkec_jailsystem
   ```

4. Open `config.lua` and configure the jail location, release location, permissions, and other available settings.
5. Restart your server or start the resource using the server console.

## How to Use

1. Join the server with a character whose job is `police` or `sheriff`.
2. Stand near the player you want to jail.
3. Open the jail menu using:

   ```text
   /jailmenu
   ```

4. Select the nearby player.
5. Enter the reason for the sentence.
6. Set the jail duration.
7. Confirm the sentence.

The jailed player will be teleported to the configured jail location. Their remaining sentence time will be displayed on the HUD. When the sentence expires, they will be released at the configured release location.

## Configuration

All available settings can be adjusted in `config.lua`, including:

- Jail coordinates
- Release coordinates
- Authorized jobs
- Jail zone boundaries
- Sentence duration settings

Make sure to review the configuration before using the resource on your server.

## Support

If you encounter bugs or have suggestions for improvements, open an issue in this repository.

## Credits

**Created by Smrkec**

Thank you for using Smrkec Jail System!

---

*Made for FiveM roleplay servers.*