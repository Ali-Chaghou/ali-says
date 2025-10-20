> _Made by Ali C._
# ali-says

`ali-says` is a lightweight terminal utility that prints short engineering-related quotes on login or on demand.  
It also includes a manual mode to display all quotes sequentially.

---

## Features

- Random quote on each run (`ali-says`)
- Manual sequential mode with pause between lines (`ali-says-manual`)
- Optional cowsay + lolcat integration (if available)
- Install script for quick setup
- Shell auto-startup support (bash / zsh / fish)

---

## Installation

Clone the repository and run the installer:

```bash
git clone https://github.com/Ali-Chaghou/ali-says.git
cd ali-says
./install.sh
```
This will:

- install both scripts to `/usr/local/bin/`
- try to install dependencies (`cowsay`, `lolcat`) if possible
- configure auto-run on shell startup

---
## Usage

Show one random quote:

```bash
ali-says
```
Show all quotes manually:
```bash
ali-says-manual
```
After installation, quotes will also appear automatically on shell startup if autorun was enabled.

---

## Requirements

- Linux / macOS terminal environment
- bash or similar shell
- Optional: `python3`, `cowsay`, `lolcat` for formatted output

---

## License

This project is provided without warranty.  
Use at your own discretion.
