# ML4W Dotfiles Settings

A powerful, interactive Bash utility to manage and toggle dotfile configurations. Built with [Gum](https://github.com/charmbracelet/gum), it provides a beautiful terminal UI to easily configure your system settings by overwriting files or safely replacing specific values.

## ✨ Features

* **Interactive UI**: Navigate through configuration groups and settings using a sleek terminal interface.
* **Smart Pre-selection**: Automatically detects your current configuration and pre-fills text fields or highlights the active option in menus.
* **Direct CLI Manipulation**: Quickly `get` or `set` values directly from the command line for easy integration into other scripts or keybindings.
* **Dynamic File/Folder Selection**: Automatically reads directories to populate selection menus with available files or folders.
* **Post-Execution Commands**: Run background commands (like restarting Waybar or Hyprland) automatically after a setting is changed.
* **Safe Execution**: Warns you in the UI if a target configuration file doesn't exist yet and prevents accidental ghost-file creation.
* **Smart Replacements**: Supports complete file overwriting, regex-based string replacement, and targeted replacements after specific checkpoints in a file.
* **Profile Support**: Keep multiple configuration profiles isolated in parallel.

## 📦 Prerequisites

Ensure you have the following installed on your system:

* `bash`
* `jq` (Command-line JSON processor)
* `gum` (A tool for glamorous shell scripts)
* `awk`

## 🚀 Installation

Clone the repository and install it globally using `make` (all distros):

```bash
git clone https://github.com/yourusername/ml4w-dotfiles-settings.git
cd ml4w-dotfiles-settings
sudo make install
```

Or copy the following command into your terminal to install all dependencies and the ML4W Dotfiles Settings in one step (supporting Arch, Fedora & openSuse Tumbleweed):

```bash
bash <(curl -s https://raw.githubusercontent.com/mylinuxforwork/ml4w-dotfiles-settings/main/setup.sh)
```

To uninstall:

```bash
sudo make uninstall
```

## 🛠️ Usage

The application requires a profile to run. Settings for the profile are stored in `~/.config/ml4w-dotfiles-settings/<profile_name>/settings.json`.

```bash
# Start the interactive menu for a specific profile
ml4w-dotfiles-settings myprofile

# Create a new profile with the demo configuration
ml4w-dotfiles-settings --create myprofile

# Run in test mode (simulates changes without modifying files)
ml4w-dotfiles-settings --test myprofile

# Set a value directly via CLI (bypasses the UI)
ml4w-dotfiles-settings --set --id toggle_dock --value false myprofile

# Get a current value directly via CLI (Outputs raw string, perfect for piping/variables)
ml4w-dotfiles-settings --get --id toggle_dock myprofile

# Show help menu
ml4w-dotfiles-settings --help

```

## ⚙️ Configuration (`settings.json`)

The UI and logic are entirely driven by a `settings.json` file located in your profile directory. Settings are organized into **Groups**.

### Example `settings.json`

```json
[
    {
        "group": "Desktop",
        "description": "General desktop environment settings",
        "settings": [
            {
                "name": "Show App Menu",
                "id": "show_app_menu",
                "instructions": "Do you want to show the app menu in the status bar?",
                "file": "~/.config/waybar/config",
                "type": "toggle",
                "mode": "replace",
                "match": ".*\"wlr/taskbar\"",
                "default": "    ",
                "true_value": "    ",
                "false_value": "    //",
                "post_command": "killall waybar; waybar > /dev/null 2>&1 &"
            },
            {
                "name": "Select Animation",
                "id": "variant_animation",
                "instructions": "Choose your preferred animation variant:",
                "folder": "~/.config/hypr/conf/animations",
                "file": "~/.config/hypr/conf/animations.conf",
                "type": "files",
                "mode": "replace",
                "match": "source = ~/.config/hypr/conf/animations/.*",
                "default": "default.conf"
            },
            {
                "name": "Select Waybar Theme",
                "id": "theme_folder",
                "instructions": "Choose your theme folder:",
                "folder": "~/.config/ml4w/settings/waybar_themes",
                "file": "~/.config/ml4w/settings/waybar_theme",
                "type": "folders",
                "mode": "overwrite",
                "default": "glass-theme",
                "post_command": "~/.config/waybar/launch.sh > /dev/null 2>&1 &"
            }
        ]
    },
    {
        "group": "Terminal",
        "description": "Alacritty terminal configuration",
        "settings": [
            {
                "name": "Terminal Font Size",
                "id": "term_font_size",
                "instructions": "Enter the font size for your terminal:",
                "file": "~/.config/alacritty/alacritty.toml",
                "type": "textfield",
                "mode": "replace",
                "match": "size = .*",
                "default": "12"
            },
            {
                "name": "Terminal Font Color",
                "id": "term_font_color",
                "instructions": "Enter the font color for your terminal:",
                "file": "~/.config/alacritty/alacritty.toml",
                "type": "textfield",
                "mode": "replace",
                "match": "fontcolor = .*",
                "default": "#FFFFFF",
                "checkpoint": "#Comment"
            }
        ]
    }
]

```

### 🎛️ Setting Types

* `toggle`: Prompts the user with a Yes/No choice.
* Defaults to writing `"true"` or `"false"`.
* *Optional:* You can map Yes/No to custom strings by providing `"true_value"` and `"false_value"` keys.


* `textfield`: Prompts the user to type a string. It will pre-fill with the currently active value if one is detected.
* `choose`: Prompts the user to select from an array provided in the `"options"` key.
* `files`: Dynamically reads and lists all files from a specified directory. **Requires the `"folder"` key in the JSON object** to define where to look.
* `folders`: Dynamically reads and lists all subdirectories from a specified directory. **Requires the `"folder"` key in the JSON object** to define where to look.

### 📝 Operation Modes

* `overwrite`: Completely replaces the contents of the target file with the new value.
* `replace`: Searches for the `"match"` string (as a regular expression) and replaces the wildcard `.*` with the new value. (e.g., `size = .*` becomes `size = 14`).
* **replace with checkpoint**: If a `"checkpoint"` string is provided alongside `"mode": "replace"`, the script will first locate the checkpoint line, and *then* replace the very next occurrence of the `"match"` string.

### ⚡ Additional Keys

* `post_command`: An optional shell command to execute in the background after successfully applying a setting (e.g., `"killall waybar; waybar > /dev/null 2>&1 &"`).
* `folder`: The target directory path required when using `files` or `folders` types.
