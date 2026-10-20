#!/usr/bin/env bash

# ==============================================================================
# Liquid Glass Dotfiles Installer for Arch Linux
# ==============================================================================

set -euo pipefail

# Colores para salida de terminal
C_RESET="\033[0m"
C_BOLD="\033[1m"
C_RED="\033[31m"
C_GREEN="\033[32m"
C_YELLOW="\033[33m"
C_BLUE="\033[34m"
C_MAGENTA="\033[35m"
C_CYAN="\033[36m"

info()    { echo -e "${C_BLUE}${C_BOLD}[INFO]${C_RESET} $*"; }
success() { echo -e "${C_GREEN}${C_BOLD}[OK]${C_RESET} $*"; }
warn()    { echo -e "${C_YELLOW}${C_BOLD}[AVISO]${C_RESET} $*"; }
error()   { echo -e "${C_RED}${C_BOLD}[ERROR]${C_RESET} $*" >&2; }

# Directorio del repositorio
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Banner de bienvenida
echo -e "${C_CYAN}${C_BOLD}"
echo "  ✦ Liquid Glass Dotfiles Installer ✦"
echo "  Arch Linux + Hyprland Lua + Matugen"
echo -e "${C_RESET}"

# ------------------------------------------------------------------------------
# 1. Comprobación del Sistema Operativo
# ------------------------------------------------------------------------------
info "Verificando compatibilidad del sistema..."
if [ ! -f /etc/arch-release ]; then
    error "Este script está diseñado exclusivamente para distribuciones basadas en Arch Linux."
    exit 1
fi
success "Sistema Arch Linux detectado."

# ------------------------------------------------------------------------------
# 2. Detección o Instalación de AUR Helper
# ------------------------------------------------------------------------------
info "Comprobando gestor de AUR (paru o yay)..."
AUR_HELPER=""

if command -v paru >/dev/null 2>&1; then
    AUR_HELPER="paru"
elif command -v yay >/dev/null 2>&1; then
    AUR_HELPER="yay"
fi

if [ -n "$AUR_HELPER" ]; then
    success "Gestor de AUR encontrado: $AUR_HELPER"
else
    warn "No se encontró ningún asistente de AUR (paru o yay)."
    read -rp "¿Deseas instalar un gestor de AUR automáticamente? [paru/yay/n]: " aur_choice
    case "$aur_choice" in
        paru|PARU)
            info "Instalando dependencias base y paru desde AUR..."
            sudo pacman -S --needed --noconfirm base-devel git
            TEMP_DIR=$(mktemp -d)
            git clone https://aur.archlinux.org/paru.git "$TEMP_DIR/paru"
            (cd "$TEMP_DIR/paru" && makepkg -si --noconfirm)
            rm -rf "$TEMP_DIR"
            AUR_HELPER="paru"
            success "paru instalado exitosamente."
            ;;
        yay|YAY)
            info "Instalando dependencias base y yay desde AUR..."
            sudo pacman -S --needed --noconfirm base-devel git
            TEMP_DIR=$(mktemp -d)
            git clone https://aur.archlinux.org/yay.git "$TEMP_DIR/yay"
            (cd "$TEMP_DIR/yay" && makepkg -si --noconfirm)
            rm -rf "$TEMP_DIR"
            AUR_HELPER="yay"
            success "yay instalado exitosamente."
            ;;
        *)
            error "Se requiere paru o yay para instalar los componentes de AUR (matugen-bin, quickshell)."
            exit 1
            ;;
    esac
fi

# ------------------------------------------------------------------------------
# 3. Instalación de Paquetes y Dependencias
# ------------------------------------------------------------------------------
OFFICIAL_PKGS=(
    hyprland
    xdg-desktop-portal-hyprland
    rofi-wayland
    swaync
    swayosd
    brightnessctl
    wireplumber
    pipewire
    pipewire-pulse
    ghostty
    fastfetch
    ttf-jetbrains-mono-nerd
    papirus-icon-theme
    jq
    git
)

AUR_PKGS=(
    matugen-bin
    quickshell
)

echo ""
echo -e "${C_BOLD}Paquetes oficiales de Pacman a instalar/verificar:${C_RESET}"
echo "  ${OFFICIAL_PKGS[*]}"
echo -e "${C_BOLD}Paquetes de AUR a instalar/verificar:${C_RESET}"
echo "  ${AUR_PKGS[*]}"
echo ""

read -rp "¿Deseas proceder con la instalación de paquetes? [S/n]: " confirm_pkgs
confirm_pkgs="${confirm_pkgs:-S}"

if [[ "$confirm_pkgs" =~ ^[sSyY]$ ]]; then
    info "Instalando paquetes oficiales con pacman..."
    sudo pacman -S --needed "${OFFICIAL_PKGS[@]}"

    info "Instalando paquetes de AUR con $AUR_HELPER..."
    "$AUR_HELPER" -S --needed "${AUR_PKGS[@]}"
    success "Paquetes instalados correctamente."
else
    warn "Instalación de paquetes omitida por el usuario."
fi

# ------------------------------------------------------------------------------
# 4. Creación de Symlinks y Backup Preventivo
# ------------------------------------------------------------------------------
info "Configurando enlaces simbólicos en ~/.config..."
mkdir -p "$HOME/.config"

CONFIG_FOLDERS=(
    hypr
    quickshell
    rofi
    swaync
    swayosd
    ghostty
    matugen
    fastfetch
)

BACKUP_DIR=""

for folder in "${CONFIG_FOLDERS[@]}"; do
    TARGET="$HOME/.config/$folder"
    SOURCE="$DOTFILES_DIR/.config/$folder"

    if [ ! -d "$SOURCE" ]; then
        warn "La carpeta origen $SOURCE no existe en el repositorio. Omitiendo..."
        continue
    fi

    # Comprobar si ya es el symlink correcto
    if [ -L "$TARGET" ]; then
        CURRENT_LINK=$(readlink "$TARGET")
        if [ "$CURRENT_LINK" = "$SOURCE" ]; then
            success "Symlink al día: $TARGET -> $SOURCE"
            continue
        fi
    fi

    # Si existe un directorio o archivo real que no apunta a este repo, hacer backup
    if [ -e "$TARGET" ] || [ -L "$TARGET" ]; then
        if [ -z "$BACKUP_DIR" ]; then
            BACKUP_DIR="$HOME/.config/backup_dotfiles_$(date +%Y%m%d_%H%M%S)"
            mkdir -p "$BACKUP_DIR"
            info "Creando directorio de respaldo preventivo en: $BACKUP_DIR"
        fi
        info "Moviendo configuración existente de $folder al respaldo..."
        mv "$TARGET" "$BACKUP_DIR/$folder"
    fi

    # Crear el enlace simbólico
    ln -sfn "$SOURCE" "$TARGET"
    success "Enlazado: $TARGET -> $SOURCE"
done

if [ -n "$BACKUP_DIR" ]; then
    success "Respaldo de configuraciones previas guardado en: $BACKUP_DIR"
fi

# ------------------------------------------------------------------------------
# 5. Permisos de Hardware (Grupo video para brillo y OSD)
# ------------------------------------------------------------------------------
info "Comprobando permisos de hardware..."
if id -nG "$USER" | grep -qw "video"; then
    success "El usuario $USER ya pertenece al grupo 'video'."
else
    info "Agregando al usuario $USER al grupo 'video' para control de brillo..."
    sudo usermod -aG video "$USER"
    warn "Se agregó el usuario al grupo 'video'. Esto requerirá cerrar sesión para surtir efecto."
fi

# ------------------------------------------------------------------------------
# 6. Pasos Finales y Mensaje de Éxito
# ------------------------------------------------------------------------------
echo ""
echo -e "${C_GREEN}${C_BOLD}==============================================================================${C_RESET}"
echo -e "${C_GREEN}${C_BOLD}   ✦ ¡Instalación de dotfiles completada exitosamente! ✦${C_RESET}"
echo -e "${C_GREEN}${C_BOLD}==============================================================================${C_RESET}"
echo ""
echo -e "${C_BOLD}Próximos pasos recomendados:${C_RESET}"
echo ""
echo -e "  1. ${C_CYAN}Generar la paleta de colores Material You con tu wallpaper:${C_RESET}"
echo -e "     ${C_BOLD}matugen image /ruta/a/tu/wallpaper.png --source-color-index 0${C_RESET}"
echo ""
echo -e "  2. ${C_CYAN}Reiniciar la sesión o el equipo:${C_RESET}"
echo "     Para que los permisos del grupo 'video' y los demonios de inicio"
echo "     (hypridle, swayosd-server, swaync) inicien correctamente."
echo ""
echo -e "  3. ${C_CYAN}Atajos de teclado clave:${C_RESET}"
echo "     • Super + Espacio : Lanzador Spotlight (Rofi)"
echo "     • F12             : Terminal desplegable (Ghostty Scratchpad)"
echo "     • Super + N       : Centro de Notificaciones (SwayNC)"
echo "     • Teclas de brillo y volumen : OSD interactivo (SwayOSD)"
echo ""
