<div align="center">

# 🌌 Cybersigilism Dotfiles
### CachyOS • Hyprland • Wayland

![CachyOS](https://img.shields.io/badge/CachyOS-000000?style=for-the-badge&logo=arch-linux&logoColor=white)
![Arch Linux](https://img.shields.io/badge/Arch_Linux-1793D1?style=for-the-badge&logo=arch-linux&logoColor=white)
![Hyprland](https://img.shields.io/badge/Hyprland-00A58B?style=for-the-badge&logo=hyprland&logoColor=white)
![Bash](https://img.shields.io/badge/Bash-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)

[![Insert Screenshot]](./assets/screenshot.png)

*Un entorno de escritorio hiper-optimizado, diseñado para la fluidez absoluta (144Hz) y una estética inmersiva.*

</div>

---

## 🎯 Objetivo Arquitectónico

Este repositorio contiene mi configuración personal (dotfiles) orientada al ecosistema **Wayland**, construida sobre la solidez y el rendimiento del kernel de **CachyOS** con **Hyprland** como Window Manager. 

El ecosistema está diseñado bajo un paradigma modular. Prioriza el rendimiento extremo y despliega una estética cohesiva que fusiona el misticismo del *Cybersigilism* con la suavidad de la paleta *Catppuccin Mocha Mauve*.

---

## ✨ Features Destacadas

- 🎨 **Waybar Modular & Tematización Dinámica:** Arquitectura de barra de estado con múltiples ecosistemas visuales (ej. *Cybersigilism*, *Transparente*). El cambio de temas se gestiona en tiempo real mediante menús de `rofi` y un enrutamiento inteligente de enlaces simbólicos (symlinks).
- ⚡ **Gestión de Energía Inteligente (`hypridle`):** Reglas milimétricas para administrar eventos de inactividad, atenuación progresiva de pantalla y control del DPMS, garantizando un equilibrio perfecto entre la experiencia de usuario y el consumo energético.
- 🖱️ **Cursores Camaleónicos:** Un motor de scripts dinámico (`set_cursor.sh`) que sincroniza matemáticamente el color del cursor del sistema con los acentos de color extraídos por `wallust` del wallpaper activo.
- 🚀 **Rendimiento Visual a 144Hz:** Ajustes de curvas de animación (Bezier overshot) en Hyprland para una sensación táctil y fluida en cada transición de ventana.

---

## 📦 Dependencias (Source of Truth)

Esta sección es la **fuente de la verdad** para futuras automatizaciones (scripts de auto-install). Los paquetes están rigurosamente categorizados.

### 🧠 Core (Paquetes Base)

| Paquete | Repositorio | Descripción |
| :--- | :---: | :--- |
| `hyprland` | Oficial / CachyOS | Compositor Wayland principal. |
| `waybar` | Oficial | Barra de estado altamente personalizable. |
| `rofi-wayland` | AUR | Lanzador de aplicaciones y gestor de menús TUI/GUI. |
| `ghostty` | AUR / CachyOS | Emulador de terminal acelerado por GPU, absurdamente rápido. |
| `zsh` | Oficial | Shell principal del sistema operativo. |

### 🛠️ Utilidades & Scripts

| Paquete | Repositorio | Descripción |
| :--- | :---: | :--- |
| `wallust` | AUR | Generador de paletas de color en tiempo real basado en el wallpaper. |
| `pacman-contrib` | Oficial | Provee utilidades clave como `checkupdates` para los scripts de Waybar. |
| `bc` | Oficial | Motor de cálculo de precisión arbitraria para sincronización matemática. |
| `jq` | Oficial | Parser de JSON por CLI, vital para procesar datos de Waybar/Hyprland. |
| `awww` | AUR | Demonio ultraligero para la gestión y transición de wallpapers. |
| `hypridle` & `hyprlock` | Oficial | Ecosistema nativo para la inactividad y pantalla de bloqueo. |
| `fastfetch` | Oficial | Herramienta de sysinfo moderna y rápida. |
| `catnap` | AUR | Utilidad para inyectar arte ASCII minimalista en fetchers. |
| `networkmanager-dmenu` | AUR | Frontend de dmenu/rofi para `nmtui` (Gestión de red). |

### 🎨 Visuales & Fuentes

| Paquete | Repositorio | Descripción |
| :--- | :---: | :--- |
| `ttf-jetbrains-mono-nerd` | Oficial | Tipografía monospace principal, incluye glifos y Nerd Fonts. |
| `catppuccin-mocha-mauve-cursors`| AUR | Base estética para la manipulación de color de cursores. |
| `zsh-theme-agnoster` | Oficial / AUR | Tema visual para Zsh (requiere `oh-my-zsh`). |

---

## 📂 Estructura de Directorios

La configuración debe desplegarse en `~/.config/` respetando esta topología:

```text
~/.config/
├── fastfetch/
│   ├── boykisser.txt
│   └── minifetch.jsonc
├── ghostty/
│   └── config.ghostty
├── gtk-3.0/
│   ├── bookmarks
│   └── settings.ini
├── hypr/
│   ├── configs/
│   │   ├── animations.conf
│   │   ├── appearance.conf
│   │   ├── env.conf
│   │   ├── exec.conf
│   │   ├── input.conf
│   │   ├── keybinds.conf
│   │   ├── monitors.conf
│   │   └── rules.conf
│   ├── hypridle.conf
│   ├── hyprland.conf
│   ├── hyprlock.conf
│   └── scripts/
│       ├── init_wallpaper.sh
│       ├── refresh_rate.sh
│       ├── set_cursor.sh
│       ├── start_wallpaper.sh
│       └── wallpapers.sh
├── wallust/
│   ├── templates/
│   │   ├── dominant_color
│   │   └── ghostty
│   └── wallust.toml
├── waybar/
│   ├── config.jsonc -> /home/tobito/.config/waybar/themes/Transparente/config.jsonc
│   ├── scripts/
│   │   ├── theme-selector.sh
│   │   └── updates.sh
│   ├── style.css -> /home/tobito/.config/waybar/themes/Transparente/style.css
│   └── themes/
│       ├── Cybersigilism/
│       │   ├── config.jsonc
│       │   └── style.css
│       └── Transparente/
│           ├── config.jsonc
│           └── style.css
└── xfce4/
    └── xfconf/
```
*(Nota: Se han omitido directorios dinámicos de aplicaciones web como `heroic` o `librewolf` para mantener la claridad).*

---

## 🚀 Instalación Manual

Sigue estos pasos para replicar el entorno antes de que el script de automatización esté disponible.

> [!CAUTION]
> Es críticamente recomendado hacer un respaldo de tu carpeta `~/.config/` actual para evitar pérdida de datos.

### 1. Clonar el repositorio
```bash
git clone https://github.com/TU_USUARIO/TU_REPO.git ~/dotfiles
cd ~/dotfiles
```

### 2. Sincronización de Dependencias
Instala los paquetes fundacionales y utilidades desde los repositorios oficiales usando `pacman`:
```bash
sudo pacman -S --needed hyprland waybar zsh pacman-contrib bc jq ttf-jetbrains-mono-nerd hypridle hyprlock fastfetch
```

Instala los componentes del AUR utilizando tu helper preferido (ej. `paru`):
```bash
paru -S --needed rofi-wayland ghostty wallust awww catnap networkmanager-dmenu catppuccin-mocha-mauve-cursors
```

### 3. Migración de Configuraciones
Despliega los dotfiles en tu directorio de configuración local:
```bash
cp -r .config/* ~/.config/
```

### 4. Permisos de Ejecución
Asegúrate de que el motor de scripts tenga los permisos adecuados para operar:
```bash
chmod +x ~/.config/hypr/scripts/*.sh
chmod +x ~/.config/waybar/scripts/*.sh
```

### 5. Post-Instalación
- Instala el framework de shell [Oh My Zsh](https://ohmyz.sh/).
- Asigna el tema `agnoster` en tu `~/.zshrc`.
- Inicia tu sesión en Hyprland y disfruta de la fluidez.

---
<div align="center">
  <i>Construido con precisión quirúrgica en Arch Linux / CachyOS.</i>
</div>
