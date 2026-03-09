# ML4W Dotfiles Settings

A powerful, interactive Bash utility to manage and toggle dotfile configurations. Built with [Gum](https://github.com/charmbracelet/gum), it provides a beautiful terminal UI to easily configure your system settings by overwriting files or safely replacing specific values.

## ✨ Features

* **Interactive UI**: Navigate through configuration groups and settings using a sleek terminal interface.
* **Direct CLI Manipulation**: Quickly `get` or `set` values directly from the command line for easy integration into other scripts or keybindings.
* **Smart Replacements**: Supports complete file overwriting, regex-based string replacement, and targeted replacements after specific checkpoints in a file.
* **Dynamic File/Folder Selection**: Automatically read directories to populate selection menus with available files or folders.
* **Test Mode**: Run the script in a dry-run mode (`--test`) to see exactly what changes would be made without modifying any files.
* **Profile Support**: Keep multiple configuration profiles isolated in parallel.

## 📦 Prerequisites

Ensure you have the following installed on your system:

* `bash`
* `jq` (Command-line JSON processor)
* `gum` (A tool for glamorous shell scripts)
* `awk`

## 🚀 Installation

Clone the repository and install it globally using `make`:

```bash
git clone https://github.com/yourusername/ml4w-dotfiles-settings.git
cd ml4w-dotfiles-settings
sudo make install

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
                "name": "Toggle Dock",
                "id": "toggle_dock",
                "instructions": "Do you want to enable or disable the dock?",
                "file": "~/.config/ml4w/settings/dock",
                "type": "toggle",
                "mode": "overwrite",
                "default": "true"
            },
            {
                "name": "Select Decoration Variant",
                "id": "variant_decoration",
                "instructions": "Choose your preferred variant:",
                "folder": "~/.config/hypr/conf/decorations",
                "file": "~/.config/hypr/conf/decorations.conf",
                "type": "files",
                "mode": "replace",
                "match": "source = ~/.config/hypr/conf/decorations/.*",
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
                "default": "glass-theme"
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

* `toggle`: Prompts the user with a Yes/No choice (maps to `true`/`false`).
* `textfield`: Prompts the user to type a string.
* `choose`: Prompts the user to select from an array provided in the `"options"` key.
* `files`: Dynamically reads and lists all files from a specified directory. **Requires the `"folder"` key in the JSON object** to define where to look.
* `folders`: Dynamically reads and lists all subdirectories from a specified directory. **Requires the `"folder"` key in the JSON object** to define where to look.

### 📝 Operation Modes

* `overwrite`: Completely replaces the contents of the target file with the new value.
* `replace`: Searches for the `"match"` string (as a regular expression) and replaces the wildcard `.*` with the new value.
* **replace with checkpoint**: If a `"checkpoint"` string is provided alongside `"mode": "replace"`, the script will first locate the checkpoint line, and *then* replace the very next occurrence of the `"match"` string.
