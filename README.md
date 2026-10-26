# ✦ Liquid Glass Dotfiles (Arch Linux + Hyprland Lua)

Entorno de escritorio moderno, minimalista y reactivo para **Arch Linux** impulsado por **Hyprland** en modo nativo Lua (`hyprland.lua`), con estética translúcida estilo **Liquid Glass / visionOS** (Dual Kawase blur, biseles rim-light y saturación por refracción), y paleta de colores Material You sincronizada dinámicamente con **Matugen**.

---

## 🎨 Características Principales

- **Compositor:** Hyprland 0.56+ configurado nativamente en Lua (`~/.config/hypr/lua/*.lua`).
- **Estética Liquid Glass:** Difuminado Dual Kawase de 4 pasadas, refracción vibrante, biseles de luz especular a 45° en bordes de ventana y sombras ambientales profundas.
- **Opacidad selectiva:** Ventanas de aplicaciones estándar (Firefox, Spotify, Steam, Vesktop) mantienen 100% de opacidad para máxima legibilidad, mientras que los componentes del shell y terminal adoptan el efecto de vidrio esmerilado.
- **Barra de estado:** [Quickshell](https://quickshell.outfoxxed.me/) (`shell.qml`) con reloj centrado absoluto, toggle de Caffeine, monitoreo de hardware (CPU, Temp, RAM %, Disco), selector de perfiles de energía, estado de batería e integración con System Tray (SNI) y MPRIS.
- **Lanzador de aplicaciones:** [Rofi-Wayland](https://github.com/lbonn/rofi-wayland) con diseño centrado estilo Spotlight, pestañas de categorías (Todas, Juegos, Media, Dev, Sistema, Utils) y soporte completo para cursor/mouse.
- **Centro de Notificaciones:** [SwayNC](https://github.com/ErikReider/SwayNotificationCenter) estilizado con CSS translúcido adaptativo.
- **OSD en pantalla:** [SwayOSD](https://github.com/ErikReider/SwayOSD) para indicadores visuales de volumen y brillo en tiempo real.
- **Terminal:** [Ghostty](https://ghostty.org/) con perfil translúcido e integración con Fastfetch compacto (`minifetch`).
- **Scratchpad:** Terminal desplegable Ghostty accesible instantáneamente mediante `F12`.
- **Motor de color dinámico:** [Matugen](https://github.com/InioX/matugen) extrae la paleta Material You del fondo de pantalla activo y actualiza todos los módulos en tiempo real sin reiniciar la sesión.

---

## 📦 Estructura del Repositorio

El repositorio está centralizado en `~/dotfiles/.config/` y se vincula simbólicamente con `~/.config/`:

```text
~/dotfiles/
├── .config/
│   ├── fastfetch/      # Perfil minimalista (minifetch) y perfil Zero
│   ├── ghostty/        # Configuración de terminal con blur y opacidad
│   ├── hypr/           # Configuración modular en Lua, hyprlock e hypridle
│   ├── matugen/        # Plantillas Material You para todos los módulos
│   ├── quickshell/     # Barra de estado reactiva en QML
│   ├── rofi/           # Tema Spotlight integrado con Matugen
│   ├── swaync/         # Centro de notificaciones y control
│   └── swayosd/        # Popups OSD de brillo y volumen
├── .gitignore
└── README.md
```

---

## 🛠️ Requisitos y Dependencias

### 1. Paquetes Oficiales (Arch Linux)
Instalar mediante `pacman`:

```bash
sudo pacman -S --needed \
    hyprland \
    xdg-desktop-portal-hyprland \
    rofi-wayland \
    swaync \
    swayosd \
    brightnessctl \
    wireplumber \
    pipewire \
    ghostty \
    fastfetch \
    ttf-jetbrains-mono-nerd \
    papirus-icon-theme \
    jq \
    grim \
    slurp \
    wl-copy \
    qt5ct \
    qt6ct \
    breeze \
    thunar \
    thunar-archive-plugin \
    thunar-volman \
    tumbler \
    gvfs
```

### 2. Paquetes de AUR
Instalar con tu asistente preferido (`paru` o `yay`):

```bash
paru -S --needed \
    matugen-bin \
    quickshell
```

### 3. Permisos de Hardware (Control de Brillo)
Para permitir que `brightnessctl` y `swayosd` controlen la retroiluminación sin requerir permisos de superusuario:

```bash
sudo usermod -aG video $USER
```
*(Es necesario cerrar sesión y volver a entrar para aplicar el nuevo grupo).*

---

## 🚀 Instalación y Primer Uso

### Opción Rápida: Script Automatizado (Recomendado)

El repositorio incluye un instalador interactivo que detecta/instala el gestor de AUR (`paru` o `yay`), instala todos los paquetes necesarios, respalda configuraciones previas y enlaza los symlinks automáticamente:

```bash
git clone https://github.com/tu-usuario/dotfiles.git ~/dotfiles
cd ~/dotfiles
chmod +x install.sh
./install.sh
```

---

### Opción Manual

#### 1. Clonar el Repositorio
```bash
git clone https://github.com/tu-usuario/dotfiles.git ~/dotfiles
```

#### 2. Crear los Enlaces Simbólicos
Si ya cuentas con carpetas existentes en `~/.config/`, respalda previamente o enlaza directamente:

```bash
mkdir -p ~/.config
for dir in hypr quickshell rofi swaync swayosd ghostty matugen fastfetch; do
    ln -sfn ~/dotfiles/.config/$dir ~/.config/$dir
done
```

#### 3. Generar la Paleta de Colores Inicial
Aplica los colores dinámicos basados en tu fondo de pantalla favorito:

```bash
matugen image /ruta/hacia/tu/wallpaper.png --source-color-index 0
```

#### 4. Recargar el Entorno
```bash
hyprctl reload
```

---

## ⌨️ Atajos de Teclado Principales

| Combinación | Acción | Componente |
| :--- | :--- | :--- |
| <kbd>Super</kbd> + <kbd>Espacio</kbd> | Lanzador de aplicaciones Spotlight | **Rofi** |
| <kbd>F12</kbd> | Toggle terminal flotante desplegable | **Ghostty Scratchpad** |
| <kbd>Super</kbd> + <kbd>N</kbd> | Abrir/cerrar panel de notificaciones y control | **SwayNC** |
| <kbd>Super</kbd> + <kbd>Return</kbd> | Abrir terminal principal | **Ghostty** |
| <kbd>Super</kbd> + <kbd>B</kbd> | Abrir navegador web | **Firefox** |
| <kbd>Super</kbd> + <kbd>E</kbd> | Abrir explorador de archivos | **Thunar** |
| <kbd>Super</kbd> + <kbd>W</kbd> | Selector de wallpapers con miniaturas | **Script + Rofi + awww** |
| <kbd>Super</kbd> + <kbd>Q</kbd> | Cerrar ventana activa | **Hyprland** |
| <kbd>Super</kbd> + <kbd>F</kbd> | Alternar pantalla completa | **Hyprland** |
| <kbd>Super</kbd> + <kbd>V</kbd> | Alternar estado flotante | **Hyprland** |
| <kbd>Super</kbd> + <kbd>L</kbd> | Bloquear pantalla con blur adaptativo | **Hyprlock** |
| <kbd>Super</kbd> + <kbd>Alt</kbd> + <kbd>Supr</kbd> | Cerrar sesión y volver al greeter | **Hyprland** |
| <kbd>Super</kbd> + <kbd>←</kbd> <kbd>↑</kbd> <kbd>→</kbd> <kbd>↓</kbd> | Mover foco direccional entre ventanas | **Hyprland** |
| <kbd>Super</kbd> + <kbd>1</kbd> .. <kbd>0</kbd> | Cambiar de espacio de trabajo | **Hyprland** |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>1</kbd> .. <kbd>0</kbd> | Mover ventana a espacio de trabajo | **Hyprland** |
| <kbd>Fn</kbd> / Teclas multimedia | Control de volumen y brillo con animación OSD | **SwayOSD** |
| <kbd>Print</kbd> | Captura de pantalla completa | **grim + slurp** |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>S</kbd> | Captura de área seleccionada | **grim + slurp** |
