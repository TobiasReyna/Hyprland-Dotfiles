# Ruta de Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"

# Tema elegido: 'ys' (Limpio, sin problemas de contraste, colores adaptables)
# Otras opciones buenas si este no te convence: 'robbyrussell' o 'gnzh'
ZSH_THEME="agnoster"

# Plugins útiles (puedes agregar más después)
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

# Inicializar Oh My Zsh
source $ZSH/oh-my-zsh.sh

# Cybersigilism: Cargar paleta de colores de Wallust
if [ -f ~/.cache/wallust/sequences ]; then
    cat ~/.cache/wallust/sequences
fi

# Tu mascota ASCII
catnap
