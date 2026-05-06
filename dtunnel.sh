#!/bin/bash

# ============================================
# DTunnelMod Panel - Instalador y Gestor
# Versión: 2.4 - FIXEAD ALL
# Powerby Code: X
# ============================================

# Colores
NC='\033[0m'
NEGRO='\033[0;30m'
ROJO='\033[0;31m'
VERDE='\033[0;32m'
AMARILLO='\033[0;33m'
AZUL='\033[0;34m'
MORADO='\033[0;35m'
CYAN='\033[0;36m'
BLANCO='\033[0;37m'
GRIS='\033[0;90m'
ROJO_CLARO='\033[0;91m'
VERDE_CLARO='\033[0;92m'
AMARILLO_CLARO='\033[0;93m'
AZUL_CLARO='\033[0;94m'
ROSA='\033[0;95m'
CELESTE='\033[0;96m'

# Configuraciones
INSTALL_DIR="/var/www/html/dtunnel"
DROPBOX_URL="https://www.dropbox.com/scl/fi/tgfddiyr7a9pgl9atrmso/paineldtunnelmodBeta1.0.2.zip?rlkey=clqpgdykvguqioc61e3l0elbd&st=eph2g160&dl=1"
DOMINIO=""
ES_IP=false
HTTP_PORT=8080
HTTPS_PORT=443
DB_FILE="$INSTALL_DIR/db/usuarios.json"
EMAIL_ADMIN=""
BACKUP_DIR="/backup/dtunnel"

# Detectar la ruta del script
SCRIPT_PATH="/root/dtunnel.sh"
LINK_PATH="/bin/menu2"

if [ ! -f "$SCRIPT_PATH" ]; then
    exit 1
fi

if [ ! -L "$LINK_PATH" ]; then
    sudo ln -s "$SCRIPT_PATH" "$LINK_PATH"
    sudo chmod +x "$LINK_PATH"
fi

if [ ! -x "$SCRIPT_PATH" ]; then
    sudo chmod +x "$SCRIPT_PATH"
fi

# Crear directorio de backups si no existe
mkdir -p "$BACKUP_DIR"

# ============================================
# FUNCIONES DE BARRA DE PROGRESO
# ============================================

fun_bar() {
    comando[0]="$1"
    comando[1]="$2"
    (
        [[ -e $HOME/fim ]] && rm $HOME/fim
        ${comando[0]} > /dev/null 2>&1
        ${comando[1]} > /dev/null 2>&1
        touch $HOME/fim
    ) > /dev/null 2>&1 &
    tput civis
    echo -ne "${BLANCO}["
    while true; do
        for((i=0; i<18; i++)); do
            echo -ne "${ROJO}#"
            sleep 0.1s
        done
        [[ -e $HOME/fim ]] && rm $HOME/fim && break
        echo -e "${BLANCO}]"
        sleep 1s
        tput cuu1
        tput dl1
        echo -ne "${BLANCO}["
    done
    echo -e "${BLANCO}] ${VERDE}Ok !${NC}"
    tput cnorm
}

aguarde() {
    comando[0]="$1"
    comando[1]="$2"
    (
        [[ -e $HOME/fim ]] && rm $HOME/fim
        ${comando[0]} > /dev/null 2>&1
        ${comando[1]} > /dev/null 2>&1
        touch $HOME/fim
    ) > /dev/null 2>&1 &
    tput civis
    echo -ne "${BLANCO}Aguarde ${BLANCO}- ${BLANCO}["
    while true; do
        for((i=0; i<18; i++)); do
            echo -ne "${ROJO}#"
            sleep 0.1s
        done
        [[ -e $HOME/fim ]] && rm $HOME/fim && break
        echo -e "${BLANCO}]"
        sleep 1s
        tput cuu1
        tput dl1
        echo -ne "${BLANCO}Aguarde ${BLANCO}- ${BLANCO}["
    done
    echo -e "${BLANCO}] ${VERDE}OK !${NC}"
    clear
    tput cnorm
}

# ============================================
# FUNCIONES DE MENSAJES CON MARCOS CELESTES
# ============================================

mensaje() {
    echo -e "${CELESTE}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${NC}"
    echo -e "${CELESTE}┃${NC} ${BLANCO}$1${NC}"
    echo -e "${CELESTE}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${NC}"
}

exito() {
    echo -e "${CELESTE}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${NC}"
    echo -e "${CELESTE}┃${NC} ${VERDE}✓ $1${NC}"
    echo -e "${CELESTE}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${NC}"
}

error() {
    echo -e "${CELESTE}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${NC}"
    echo -e "${CELESTE}┃${NC} ${ROJO}✗ $1${NC}"
    echo -e "${CELESTE}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${NC}"
}

aviso() {
    echo -e "${CELESTE}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${NC}"
    echo -e "${CELESTE}┃${NC} ${AMARILLO}! $1${NC}"
    echo -e "${CELESTE}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${NC}"
}

cabecera() {
    echo -e "${CELESTE}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${NC}"
    echo -e "${CELESTE}┃${NC} ${BLANCO}$1${NC}"
    echo -e "${CELESTE}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${NC}"
}

# ============================================
# FUNCIONES DEL SISTEMA
# ============================================

verificar_root() {
    if [[ $EUID -ne 0 ]]; then
        error "¡Este script debe ejecutarse como root!"
        exit 1
    fi
}

obtener_ip() {
    IP=$(curl -s -4 ifconfig.me)
    if [ -z "$IP" ]; then
        IP=$(curl -s -4 icanhazip.com)
    fi
    if [ -z "$IP" ]; then
        IP=$(hostname -I | awk '{print $1}')
    fi
    echo "$IP"
}

es_ip() {
    local ip=$1
    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        return 0
    else
        return 1
    fi
}

validar_email() {
    local email=$1
    if [[ $email =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        return 0
    else
        return 1
    fi
}

# ============================================
# FUNCIONES SSL INTELIGENTES
# ============================================

verificar_certificado_existente() {
    if [ -d "/etc/letsencrypt/live/$DOMINIO" ] && [ -f "/etc/letsencrypt/live/$DOMINIO/fullchain.pem" ]; then
        # Obtener fecha de expiración
        local expira=$(openssl x509 -enddate -noout -in "/etc/letsencrypt/live/$DOMINIO/fullchain.pem" 2>/dev/null | cut -d= -f2)
        if [ -n "$expira" ]; then
            echo "$expira"
            return 0
        fi
        return 0
    else
        return 1
    fi
}

obtener_dias_restantes() {
    local cert_file="/etc/letsencrypt/live/$DOMINIO/fullchain.pem"
    if [ -f "$cert_file" ]; then
        local expira=$(openssl x509 -enddate -noout -in "$cert_file" 2>/dev/null | cut -d= -f2)
        if [ -n "$expira" ]; then
            local expira_epoch=$(date -d "$expira" +%s 2>/dev/null)
            local ahora_epoch=$(date +%s)
            local dias=$(( ($expira_epoch - $ahora_epoch) / 86400 ))
            echo "$dias"
        else
            echo "0"
        fi
    else
        echo "0"
    fi
}

verificar_puerto_http() {
    # Verificar si el puerto HTTP está escuchando
    if ss -tlnp 2>/dev/null | grep -q ":$HTTP_PORT "; then
        return 0
    fi
    return 1
}

verificar_puerto_80() {
    # Let's Encrypt necesita el puerto 80 real para validación standalone
    # No podemos cambiar esto porque es un requisito de Let's Encrypt
    if ss -tlnp 2>/dev/null | grep -q ":80 "; then
        return 0
    fi
    return 1
}

gestionar_ssl() {
    local es_instalacion="${1:-false}"
    
    if [ "$ES_IP" = true ]; then
        aviso "SSL no disponible para IP. Necesitas un dominio real."
        sleep 2
        return 1
    fi
    
    cabecera "GESTIÓN SSL INTELIGENTE"
    
    # Verificar email
    if [ -z "$EMAIL_ADMIN" ]; then
        while true; do
            echo -ne "${CELESTE}┗━┫${NC} ${VERDE}Ingrese su correo electrónico para SSL: ${BLANCO}"; read EMAIL_ADMIN
            if [ -z "$EMAIL_ADMIN" ]; then
                error "El correo no puede estar vacío"
            elif validar_email "$EMAIL_ADMIN"; then
                exito "Email válido: $EMAIL_ADMIN"
                break
            else
                error "Email inválido. Ejemplo: usuario@dominio.com"
            fi
        done
    else
        echo -e "${CELESTE}┃${NC} ${BLANCO}Email actual: ${VERDE}$EMAIL_ADMIN${NC}"
        echo -ne "${CELESTE}┗━┫${NC} ${VERDE}¿Usar este email? (s/n): ${BLANCO}"; read usar_existente
        if [ "$usar_existente" != "s" ] && [ "$usar_existente" != "S" ]; then
            while true; do
                echo -ne "${CELESTE}┗━┫${NC} ${VERDE}Ingrese nuevo correo: ${BLANCO}"; read EMAIL_ADMIN
                if [ -z "$EMAIL_ADMIN" ]; then
                    error "El correo no puede estar vacío"
                elif validar_email "$EMAIL_ADMIN"; then
                    exito "Email actualizado: $EMAIL_ADMIN"
                    break
                else
                    error "Email inválido. Ejemplo: usuario@dominio.com"
                fi
            done
        fi
    fi
    
    # Verificar si ya existe certificado
    if verificar_certificado_existente > /dev/null; then
        local dias_restantes=$(obtener_dias_restantes)
        echo -e "${CELESTE}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${NC}"
        echo -e "${CELESTE}┃${NC} ${VERDE}✓ Certificado SSL existente detectado${NC}"
        echo -e "${CELESTE}┃${NC} ${BLANCO}Dominio: ${CYAN}$DOMINIO${NC}"
        echo -e "${CELESTE}┃${NC} ${BLANCO}Días restantes: ${AMARILLO}$dias_restantes días${NC}"
        
        if [ $dias_restantes -lt 30 ]; then
            echo -e "${CELESTE}┃${NC} ${ROJO}⚠ El certificado expirará pronto (menos de 30 días)${NC}"
        fi
        echo -e "${CELESTE}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${NC}"
        echo ""
        
        echo -ne "${CELESTE}┗━┫${NC} ${VERDE}¿Desea RENOVAR el certificado? (s/n): ${BLANCO}"; read respuesta
        
        if [ "$respuesta" = "s" ] || [ "$respuesta" = "S" ]; then
            renovar_ssl
            return $?
        else
            aviso "Renovación cancelada - El certificado actual seguirá vigente"
            return 0
        fi
    else
        # No existe certificado
        echo -e "${CELESTE}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${NC}"
        echo -e "${CELESTE}┃${NC} ${AMARILLO}⚠ No se encontró certificado SSL para $DOMINIO${NC}"
        echo -e "${CELESTE}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${NC}"
        echo ""
        
        # Verificar puerto 80 (requerido por Let's Encrypt)
        if ! verificar_puerto_80; then
            aviso "El puerto 80 no parece estar accesible desde internet"
            aviso "Let's Encrypt REQUIERE el puerto 80 para la validación (no se puede cambiar)"
            aviso "Tu panel usa el puerto $HTTP_PORT, pero para SSL necesitas el puerto 80 abierto"
            echo ""
            echo -ne "${CELESTE}┗━┫${NC} ${VERDE}¿Intentar de todas formas? (s/n): ${BLANCO}"; read continuar
            if [ "$continuar" != "s" ] && [ "$continuar" != "S" ]; then
                aviso "SSL cancelado - Abra el puerto 80 primero"
                return 1
            fi
        fi
        
        echo -ne "${CELESTE}┗━┫${NC} ${VERDE}¿Generar nuevo certificado SSL? (s/n): ${BLANCO}"; read respuesta
        
        if [ "$respuesta" = "s" ] || [ "$respuesta" = "S" ]; then
            generar_ssl_nuevo
            return $?
        else
            aviso "Generación de SSL cancelada"
            return 0
        fi
    fi
}

generar_ssl_nuevo() {
    mensaje "Generando nuevo certificado SSL para $DOMINIO..."
    
    # IMPORTANTE: Certbot standalone usa el puerto 80, no podemos cambiarlo
    # Es un requisito de Let's Encrypt para la validación del dominio
    aviso "Let's Encrypt usará el puerto 80 para validar tu dominio (requisito obligatorio)"
    aviso "Tu panel seguirá funcionando en el puerto $HTTP_PORT"
    
    # Detener Apache (libera el puerto 80)
    if command -v apt-get &> /dev/null; then
        systemctl stop apache2
    else
        systemctl stop httpd
    fi
    
    # Intentar generar certificado
    certbot certonly --standalone -d $DOMINIO --email $EMAIL_ADMIN \
        --non-interactive --agree-tos --no-eff-email --keep-until-expiring
    
    local resultado=$?
    
    # Iniciar Apache nuevamente
    if command -v apt-get &> /dev/null; then
        systemctl start apache2
    else
        systemctl start httpd
    fi
    
    if [ $resultado -eq 0 ]; then
        exito "SSL generado correctamente para $DOMINIO"
        
        # Configurar renovación automática
        (crontab -l 2>/dev/null | grep -v "certbot renew"; echo "0 0 * * * certbot renew --quiet --post-hook 'systemctl reload apache2'") | crontab -
        exito "Renovación automática configurada (cada día a las 00:00)"
        
        # Mostrar información del certificado
        local dias=$(obtener_dias_restantes)
        echo -e "${CELESTE}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${NC}"
        echo -e "${CELESTE}┃${NC} ${VERDE}Certificado válido por $dias días${NC}"
        echo -e "${CELESTE}┃${NC} ${BLANCO}Se renovará automáticamente cuando falten 30 días${NC}"
        echo -e "${CELESTE}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${NC}"
        
        # Reconfigurar Apache con SSL
        configurar_apache
        
        return 0
    else
        error "Error al generar SSL"
        echo -e "${CELESTE}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${NC}"
        echo -e "${CELESTE}┃${NC} ${ROJO}Posibles causas:${NC}"
        echo -e "${CELESTE}┃${NC} ${ROJO}• Puerto 80 no está abierto en el firewall${NC}"
        echo -e "${CELESTE}┃${NC} ${ROJO}• Dominio no apunta correctamente al servidor${NC}"
        echo -e "${CELESTE}┃${NC} ${ROJO}• Demasiadas solicitudes (límite de Let's Encrypt)${NC}"
        echo -e "${CELESTE}┃${NC} ${ROJO}• El puerto 80 está siendo usado por otro servicio${NC}"
        echo -e "${CELESTE}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${NC}"
        return 1
    fi
}

renovar_ssl() {
    mensaje "Renovando certificado SSL para $DOMINIO..."
    
    # Detener Apache (libera el puerto 80)
    if command -v apt-get &> /dev/null; then
        systemctl stop apache2
    else
        systemctl stop httpd
    fi
    
    # Renovar certificado
    certbot renew --cert-name $DOMINIO --force-renewal
    
    local resultado=$?
    
    # Iniciar Apache nuevamente
    if command -v apt-get &> /dev/null; then
        systemctl start apache2
    else
        systemctl start httpd
    fi
    
    if [ $resultado -eq 0 ]; then
        exito "Certificado renovado correctamente para $DOMINIO"
        
        local dias=$(obtener_dias_restantes)
        echo -e "${CELESTE}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${NC}"
        echo -e "${CELESTE}┃${NC} ${VERDE}Nuevo certificado válido por $dias días${NC}"
        echo -e "${CELESTE}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${NC}"
        return 0
    else
        error "Error al renovar el certificado"
        return 1
    fi
}

# ============================================
# FUNCIONES DE BACKUP Y RESTAURACIÓN
# ============================================

listar_backups() {
    cabecera "BACKUPS DISPONIBLES"
    
    if [ ! -d "$BACKUP_DIR" ] || [ -z "$(ls -A $BACKUP_DIR 2>/dev/null)" ]; then
        aviso "No hay backups disponibles en $BACKUP_DIR"
        return 1
    fi
    
    echo -e "${CELESTE}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${NC}"
    echo -e "${CELESTE}┃${NC} ${BLANCO}LISTA DE BACKUPS${NC}"
    echo -e "${CELESTE}┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫${NC}"
    
    local i=1
    for backup in $(ls -t $BACKUP_DIR | grep -E '\.(tar\.gz|zip)$'); do
        local size=$(du -h "$BACKUP_DIR/$backup" | cut -f1)
        local date=$(stat -c %y "$BACKUP_DIR/$backup" 2>/dev/null | cut -d'.' -f1 || stat -f "%Sm" "$BACKUP_DIR/$backup" 2>/dev/null)
        printf "${CELESTE}┃${NC} ${VERDE}%2d${NC} │ ${CYAN}%-50s${NC} │ ${AMARILLO}%8s${NC} │ ${BLANCO}%s${NC} ${CELESTE}┃${NC}\n" "$i" "$backup" "$size" "$date"
        ((i++))
    done
    
    echo -e "${CELESTE}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${NC}"
    return 0
}

eliminar_usuario() {
    local username="$1"
    
    if [ -z "$username" ]; then
        error "Nombre de usuario no especificado"
        return 1
    fi
    
    if [ ! -f "$DB_FILE" ]; then
        error "Base de datos de usuarios no encontrada: $DB_FILE"
        return 1
    fi
    
    # Verificar si el usuario existe y contar admins
    local usuario_existe=false
    local es_admin=false
    local total_admins=0
    local user_data=""
    
    # Leer el archivo JSON y procesar
    while IFS= read -r line; do
        if [[ $line =~ \"username\"[[:space:]]*:[[:space:]]*\"([^\"]+)\" ]]; then
            local found_user="${BASH_REMATCH[1]}"
            if [ "$found_user" = "$username" ]; then
                usuario_existe=true
            fi
        fi
        if [[ $line =~ \"role\"[[:space:]]*:[[:space:]]*\"([^\"]+)\" ]] && [ "$usuario_existe" = true ]; then
            if [ "${BASH_REMATCH[1]}" = "admin" ]; then
                es_admin=true
            fi
            usuario_existe=false
        fi
        if [[ $line =~ \"role\"[[:space:]]*:[[:space:]]*\"admin\" ]]; then
            ((total_admins++))
        fi
    done < <(cat "$DB_FILE")
    
    # Si el usuario no existe
    if [ "$es_admin" = false ] && [ "$total_admins" -eq 0 ]; then
        # Recontar porque la lectura anterior puede haber fallado
        total_admins=$(grep -c '"role": "admin"' "$DB_FILE" 2>/dev/null || echo "0")
    fi
    
    # Verificar si el usuario existe realmente
    if ! grep -q "\"username\": \"$username\"" "$DB_FILE" 2>/dev/null; then
        error "El usuario '$username' no existe en la base de datos"
        return 1
    fi
    
    # Verificar que no sea el último administrador
    if [ "$es_admin" = true ] && [ "$total_admins" -le 1 ]; then
        error "No se puede eliminar el último administrador del sistema"
        aviso "Debe haber al menos un administrador activo"
        return 1
    fi
    
    # Confirmar eliminación
    echo ""
    echo -e "${CELESTE}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${NC}"
    echo -e "${CELESTE}┃${NC} ${ROJO}⚠ ¡ADVERTENCIA!${NC}"
    echo -e "${CELESTE}┃${NC} ${ROJO}Se eliminarán TODOS los datos del usuario:${NC}"
    echo -e "${CELESTE}┃${NC} ${BLANCO}• Username${NC}"
    echo -e "${CELESTE}┃${NC} ${BLANCO}• UUID / ID${NC}"
    echo -e "${CELESTE}┃${NC} ${BLANCO}• Email${NC}"
    echo -e "${CELESTE}┃${NC} ${BLANCO}• Contraseña (hash)${NC}"
    echo -e "${CELESTE}┃${NC} ${BLANCO}• Rol${NC}"
    echo -e "${CELESTE}┃${NC} ${BLANCO}• Fecha de expiración${NC}"
    echo -e "${CELESTE}┃${NC} ${BLANCO}• Configuraciones personales${NC}"
    echo -e "${CELESTE}┃${NC} ${ROJO}Esta acción NO se puede deshacer${NC}"
    echo -e "${CELESTE}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${NC}"
    echo ""
    echo -ne "${CELESTE}┗━┫${NC} ${VERDE}¿Está seguro de eliminar al usuario '$username'? (s/n): ${BLANCO}"; read confirmar
    
    if [ "$confirmar" != "s" ] && [ "$confirmar" != "S" ]; then
        aviso "Eliminación cancelada"
        return 0
    fi
    
    # Crear backup del usuario antes de eliminar (por si acaso)
    local backup_user="$BACKUP_DIR/usuario_${username}_$(date +%Y%m%d_%H%M%S).json"
    grep -A 10 -B 10 "\"username\": \"$username\"" "$DB_FILE" > "$backup_user" 2>/dev/null
    
    # Eliminar el usuario usando PHP (más seguro para JSON)
    php -r "
        \$db_file = '$DB_FILE';
        \$username = '$username';
        
        if (!file_exists(\$db_file)) {
            echo '0';
            exit(1);
        }
        
        \$data = json_decode(file_get_contents(\$db_file), true);
        if (!is_array(\$data)) {
            echo '0';
            exit(1);
        }
        
        \$encontrado = false;
        \$nuevo_array = [];
        
        foreach (\$data as \$usuario) {
            if (\$usuario['username'] != \$username) {
                \$nuevo_array[] = \$usuario;
            } else {
                \$encontrado = true;
            }
        }
        
        if (\$encontrado) {
            file_put_contents(\$db_file, json_encode(\$nuevo_array, JSON_PRETTY_PRINT));
            echo '1';
        } else {
            echo '0';
        }
    " 2>/dev/null
    
    local resultado=$?
    
    if [ $resultado -eq 0 ] || [ $resultado -eq 1 ]; then
        exito "Usuario '$username' eliminado completamente del sistema"
        
        # Mostrar información del backup
        if [ -f "$backup_user" ]; then
            echo -e "${CELESTE}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${NC}"
            echo -e "${CELESTE}┃${NC} ${AMARILLO}Backup del usuario guardado en:${NC}"
            echo -e "${CELESTE}┃${NC} ${CYAN}$backup_user${NC}"
            echo -e "${CELESTE}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${NC}"
        fi
    else
        error "Error al eliminar el usuario '$username'"
        return 1
    fi
    
    sleep 2
}

backup_manual() {
    cabecera "BACKUP MANUAL"
    
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_file="$BACKUP_DIR/dtunnel_backup_$timestamp.tar.gz"
    
    mensaje "Creando backup en: $backup_file"
    
    # Crear backup manteniendo la estructura de directorios
    cd /
    tar -czf "$backup_file" var/www/html/dtunnel 2>/dev/null
    
    if [ $? -eq 0 ] && [ -f "$backup_file" ]; then
        local size=$(du -h "$backup_file" | cut -f1)
        exito "Backup creado correctamente"
        echo -e "${CELESTE}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${NC}"
        echo -e "${CELESTE}┃${NC} ${BLANCO}Archivo: ${CYAN}$backup_file${NC}"
        echo -e "${CELESTE}┃${NC} ${BLANCO}Tamaño:  ${VERDE}$size${NC}"
        echo -e "${CELESTE}┃${NC} ${BLANCO}Para restaurar use: ${VERDE}menu2 → Opción 10${NC}"
        echo -e "${CELESTE}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${NC}"
    else
        error "Error al crear el backup"
    fi
    
    echo -e "\n${AMARILLO}Presione ENTER...${NC}"
    read
}

restaurar_backup() {
    cabecera "RESTAURAR BACKUP"
    
    if ! listar_backups; then
        sleep 3
        return
    fi
    
    echo ""
    echo -ne "${CELESTE}┗━┫${NC} ${VERDE}Seleccione el número del backup a restaurar (0 para cancelar): ${BLANCO}"; read opcion
    
    if [ "$opcion" = "0" ] || [ -z "$opcion" ]; then
        aviso "Restauración cancelada"
        return
    fi
    
    local backup_file=$(ls -t $BACKUP_DIR | grep -E '\.(tar\.gz|zip)$' | sed -n "${opcion}p")
    
    if [ -z "$backup_file" ]; then
        error "Opción inválida"
        sleep 2
        return
    fi
    
    backup_path="$BACKUP_DIR/$backup_file"
    
    echo ""
    echo -e "${CELESTE}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${NC}"
    echo -e "${CELESTE}┃${NC} ${ROJO}⚠ ¡ADVERTENCIA!${NC}"
    echo -e "${CELESTE}┃${NC} ${ROJO}Restaurar este backup SOBRESCRIBIRÁ la instalación actual${NC}"
    echo -e "${CELESTE}┃${NC} ${BLANCO}Backup seleccionado: ${CYAN}$backup_file${NC}"
    echo -e "${CELESTE}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${NC}"
    echo ""
    echo -ne "${CELESTE}┗━┫${NC} ${VERDE}¿Está seguro de restaurar? (s/n): ${BLANCO}"; read confirmar
    
    if [ "$confirmar" != "s" ] && [ "$confirmar" != "S" ]; then
        aviso "Restauración cancelada"
        return
    fi
    
    # Crear backup de seguridad antes de restaurar
    local safety_backup="$BACKUP_DIR/pre_restore_$(date +%Y%m%d_%H%M%S).tar.gz"
    mensaje "Creando backup de seguridad pre-restauración..."
    tar -czf "$safety_backup" -C /var/www/html dtunnel 2>/dev/null
    
    # Detener servicios
    if command -v apt-get &> /dev/null; then
        systemctl stop apache2 2>/dev/null
    else
        systemctl stop httpd 2>/dev/null
    fi
    
    mensaje "Restaurando backup..."
    
    # Eliminar instalación actual
    rm -rf $INSTALL_DIR
    
    # Crear directorio padre si no existe
    mkdir -p /var/www/html
    
    # Restaurar según el tipo de archivo
    if [[ "$backup_file" == *.tar.gz ]]; then
        # Extraer en el directorio correcto
        tar -xzf "$backup_path" -C / 2>/dev/null
    elif [[ "$backup_file" == *.zip ]]; then
        # Para zip, extraer y luego mover
        local temp_dir="/tmp/restore_$$"
        mkdir -p "$temp_dir"
        unzip -o "$backup_path" -d "$temp_dir" 2>/dev/null
        
        # Buscar la carpeta dtunnel dentro de la extracción
        if [ -d "$temp_dir/dtunnel" ]; then
            mv "$temp_dir/dtunnel" "$INSTALL_DIR" 2>/dev/null
        elif [ -d "$temp_dir/var/www/html/dtunnel" ]; then
            mkdir -p /var/www/html
            mv "$temp_dir/var/www/html/dtunnel" "$INSTALL_DIR" 2>/dev/null
        else
            # Buscar cualquier carpeta que contenga index.php
            local found_dir=$(find "$temp_dir" -name "index.php" -type f 2>/dev/null | head -1 | xargs dirname 2>/dev/null)
            if [ -n "$found_dir" ] && [ -d "$found_dir" ]; then
                mv "$found_dir" "$INSTALL_DIR" 2>/dev/null
            fi
        fi
        rm -rf "$temp_dir"
    fi
    
    # Verificar que la restauración fue exitosa
    if [ -d "$INSTALL_DIR" ] && [ -f "$INSTALL_DIR/index.php" ]; then
        exito "Backup restaurado correctamente"
        
        # Reparar permisos
        if command -v apt-get &> /dev/null; then
            chown -R www-data:www-data $INSTALL_DIR
        else
            chown -R apache:apache $INSTALL_DIR
        fi
        chmod -R 755 $INSTALL_DIR
        chmod -R 777 $INSTALL_DIR/db 2>/dev/null
        chmod -R 777 $INSTALL_DIR/database 2>/dev/null
        chmod -R 777 $INSTALL_DIR/storage 2>/dev/null
        chmod -R 777 $INSTALL_DIR/tmp 2>/dev/null
        
        # Reiniciar servicios
        if command -v apt-get &> /dev/null; then
            systemctl start apache2
        else
            systemctl start httpd
        fi
        
        exito "Permisos reparados y servicio reiniciado"
    else
        error "Error al restaurar el backup"
        aviso "Intentando restaurar backup de seguridad..."
        
        if [ -f "$safety_backup" ]; then
            # Limpiar antes de restaurar seguridad
            rm -rf $INSTALL_DIR
            tar -xzf "$safety_backup" -C / 2>/dev/null
            
            if [ -d "$INSTALL_DIR" ] && [ -f "$INSTALL_DIR/index.php" ]; then
                exito "Backup de seguridad restaurado correctamente"
                
                # Reparar permisos
                if command -v apt-get &> /dev/null; then
                    chown -R www-data:www-data $INSTALL_DIR
                else
                    chown -R apache:apache $INSTALL_DIR
                fi
                chmod -R 755 $INSTALL_DIR
                chmod -R 777 $INSTALL_DIR/db 2>/dev/null
            else
                error "El backup de seguridad también falló"
            fi
        else
            error "No hay backup de seguridad disponible"
        fi
        
        if command -v apt-get &> /dev/null; then
            systemctl start apache2
        else
            systemctl start httpd
        fi
    fi
    
    echo -e "\n${AMARILLO}Presione ENTER para continuar...${NC}"
    read
}

# ============================================
# FUNCIONES DE GESTIÓN DE USUARIOS
# ============================================

listar_usuarios() {
    if [ ! -f "$DB_FILE" ]; then
        error "Base de datos de usuarios no encontrada: $DB_FILE"
        return 1
    fi
    
    echo -e "${CELESTE}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${NC}"
    echo -e "${CELESTE}┃${NC} ${BLANCO}LISTA DE USUARIOS${NC}"
    echo -e "${CELESTE}┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫${NC}"
    printf "${CELESTE}┃${NC} ${BLANCO}%-4s${NC} │ ${BLANCO}%-20s${NC} │ ${BLANCO}%-25s${NC} │ ${BLANCO}%-10s${NC} │ ${BLANCO}%-19s${NC} ${CELESTE}┃${NC}\n" "#" "USUARIO" "EMAIL" "ROL" "EXPIRACIÓN"
    echo -e "${CELESTE}┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫${NC}"
    
    local i=0
    while IFS= read -r line; do
        if [[ $line =~ \"username\"[[:space:]]*:[[:space:]]*\"([^\"]+)\" ]]; then
            username="${BASH_REMATCH[1]}"
        fi
        if [[ $line =~ \"email\"[[:space:]]*:[[:space:]]*\"([^\"]+)\" ]]; then
            email="${BASH_REMATCH[1]}"
        fi
        if [[ $line =~ \"role\"[[:space:]]*:[[:space:]]*\"([^\"]+)\" ]]; then
            role="${BASH_REMATCH[1]}"
        fi
        if [[ $line =~ \"expires_at\"[[:space:]]*:[[:space:]]*\"([^\"]+)\" ]]; then
            expires_at="${BASH_REMATCH[1]}"
            
            local color_rol=""
            if [ "$role" = "admin" ]; then
                color_rol="${VERDE}$role${NC}"
            else
                color_rol="${AMARILLO}$role${NC}"
            fi
            
            printf "${CELESTE}┃${NC} ${BLANCO}%-4s${NC} │ ${VERDE}%-20s${NC} │ ${CYAN}%-25s${NC} │ ${color_rol}%-10s${NC} │ ${AMARILLO}%-19s${NC} ${CELESTE}┃${NC}\n" "$i" "$username" "$email" "$role" "$expires_at"
            ((i++))
        fi
    done < <(cat "$DB_FILE" | grep -E '(username|email|role|expires_at)')
    
    echo -e "${CELESTE}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${NC}"
    echo ""
}

agregar_dias_usuario() {
    local username="$1"
    local dias="$2"
    
    if [ -z "$username" ] || [ -z "$dias" ]; then
        error "Usuario o días no especificados"
        return 1
    fi
    
    if ! [[ "$dias" =~ ^[0-9]+$ ]]; then
        error "Días debe ser un número válido"
        return 1
    fi
    
    php -r "
        \$db_file = '$DB_FILE';
        \$username = '$username';
        \$dias = $dias;
        
        if (!file_exists(\$db_file)) exit(1);
        \$usuarios = json_decode(file_get_contents(\$db_file), true);
        \$encontrado = false;
        
        foreach (\$usuarios as \$idx => \$u) {
            if (\$u['username'] == \$username) {
                \$fecha_actual = new DateTime();
                \$fecha_expira = new DateTime(\$u['expires_at']);
                
                if (\$fecha_expira < \$fecha_actual) {
                    \$fecha_expira = \$fecha_actual;
                }
                
                \$fecha_expira->modify(\"+{\$dias} days\");
                \$usuarios[\$idx]['expires_at'] = \$fecha_expira->format('Y-m-d H:i:s');
                \$encontrado = true;
                break;
            }
        }
        
        if (\$encontrado) {
            file_put_contents(\$db_file, json_encode(\$usuarios, JSON_PRETTY_PRINT));
            echo \"1\";
        } else {
            echo \"0\";
        }
    " 2>/dev/null
    
    if [ $? -eq 0 ] || [ $? -eq 1 ]; then
        exito "Se agregaron $dias días al usuario: $username"
    else
        error "Error al actualizar el usuario"
    fi
    sleep 2
}

cambiar_rol_usuario() {
    local username="$1"
    local rol="$2"
    
    if [ -z "$username" ] || [ -z "$rol" ]; then
        error "Usuario o rol no especificados"
        return 1
    fi
    
    if [[ "$rol" != "user" && "$rol" != "admin" ]]; then
        error "Rol inválido. Use 'user' o 'admin'"
        return 1
    fi
    
    php -r "
        \$db_file = '$DB_FILE';
        \$username = '$username';
        \$rol = '$rol';
        
        if (!file_exists(\$db_file)) exit(1);
        \$usuarios = json_decode(file_get_contents(\$db_file), true);
        \$encontrado = false;
        
        foreach (\$usuarios as \$idx => \$u) {
            if (\$u['username'] == \$username) {
                \$usuarios[\$idx]['role'] = \$rol;
                \$encontrado = true;
                break;
            }
        }
        
        if (\$encontrado) {
            file_put_contents(\$db_file, json_encode(\$usuarios, JSON_PRETTY_PRINT));
            echo \"1\";
        } else {
            echo \"0\";
        }
    " 2>/dev/null
    
    if [ $? -eq 0 ] || [ $? -eq 1 ]; then
        if [ "$rol" = "admin" ]; then
            exito "Usuario $username ahora es ADMINISTRADOR"
        else
            exito "Usuario $username ahora es USUARIO NORMAL"
        fi
    else
        error "Error al cambiar el rol"
    fi
    sleep 2
}

hacer_admin_vitalicio() {
    local username="$1"
    
    if [ -z "$username" ]; then
        error "Usuario no especificado"
        return 1
    fi
    
    php -r "
        \$db_file = '$DB_FILE';
        \$username = '$username';
        
        if (!file_exists(\$db_file)) exit(1);
        \$usuarios = json_decode(file_get_contents(\$db_file), true);
        \$encontrado = false;
        
        foreach (\$usuarios as \$idx => \$u) {
            if (\$u['username'] == \$username) {
                \$usuarios[\$idx]['expires_at'] = '2099-12-31 00:00:00';
                \$usuarios[\$idx]['role'] = 'admin';
                \$encontrado = true;
                break;
            }
        }
        
        if (\$encontrado) {
            file_put_contents(\$db_file, json_encode(\$usuarios, JSON_PRETTY_PRINT));
            echo \"1\";
        } else {
            echo \"0\";
        }
    " 2>/dev/null
    
    if [ $? -eq 0 ] || [ $? -eq 1 ]; then
        exito "Usuario $username ahora es ADMIN VITALICIO (expira: 2099-12-31)"
    else
        error "Error al hacer admin vitalicio"
    fi
    sleep 2
}

gestionar_usuarios() {
    cabecera "GESTIÓN DE USUARIOS"
    
    if [ ! -f "$DB_FILE" ]; then
        error "Base de datos de usuarios no encontrada"
        aviso "Ruta esperada: $DB_FILE"
        sleep 3
        return
    fi
    
    while true; do
        clear
        mostrar_banner
        listar_usuarios
        
        echo -e "${CELESTE}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${NC}"
        echo -e "${CELESTE}┃${NC} ${BLANCO}OPCIONES DE USUARIO${NC}"
        echo -e "${CELESTE}┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫${NC}"
        echo -e "${CELESTE}┃${NC} ${VERDE}[1]${NC} ${BLANCO}Dar días de expiración${NC}"
        echo -e "${CELESTE}┃${NC} ${VERDE}[2]${NC} ${BLANCO}Cambiar rol de usuario${NC}"
        echo -e "${CELESTE}┃${NC} ${VERDE}[3]${NC} ${BLANCO}Hacer admin vitalicio${NC}"
        echo -e "${CELESTE}┃${NC} ${VERDE}[4]${NC} ${BLANCO}Volver al menú principal${NC}"
        echo -e "${CELESTE}┃${NC} ${VERDE}[5]${NC} ${BLANCO}Eliminar Usuario${NC}"
        echo -e "${CELESTE}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${NC}"
        echo ""
        echo -ne "${CELESTE}┗━┫${NC} ${VERDE}Seleccione una opción: ${BLANCO}"; read op_user
        
        case $op_user in
            1)
                echo -ne "${CELESTE}┗━┫${NC} ${VERDE}Nombre de usuario: ${BLANCO}"; read username
                if [ -z "$username" ]; then
                    error "Nombre de usuario vacío"
                    sleep 2
                    continue
                fi
                echo -ne "${CELESTE}┗━┫${NC} ${VERDE}Días a agregar: ${BLANCO}"; read dias
                agregar_dias_usuario "$username" "$dias"
                ;;
            2)
                echo -ne "${CELESTE}┗━┫${NC} ${VERDE}Nombre de usuario: ${BLANCO}"; read username
                if [ -z "$username" ]; then
                    error "Nombre de usuario vacío"
                    sleep 2
                    continue
                fi
                echo -ne "${CELESTE}┗━┫${NC} ${VERDE}Nuevo rol (user/admin): ${BLANCO}"; read rol
                cambiar_rol_usuario "$username" "$rol"
                ;;
            3)
                echo -ne "${CELESTE}┗━┫${NC} ${VERDE}Nombre de usuario: ${BLANCO}"; read username
                if [ -z "$username" ]; then
                    error "Nombre de usuario vacío"
                    sleep 2
                    continue
                fi
                hacer_admin_vitalicio "$username"
                ;;
            4)
                return
                ;;
                
            5) 
                echo -ne "${CELESTE}┗━┫${NC} ${VERDE}Nombre de usuario a eliminar: ${BLANCO}"; read username
                if [ -z "$username" ]; then
                    error "Nombre de usuario vacío"
                    sleep 2
                    continue
                fi
                eliminar_usuario "$username"
                ;;
            
            *)
                error "Opción inválida"
                sleep 2
                ;;
            
        esac
    done
}

# ============================================
# FUNCIONES DEL SISTEMA (continuación)
# ============================================

recopilar_info() {
    cabecera "CONFIGURACIÓN INICIAL"
    
    IP_SERVIDOR=$(obtener_ip)
    
    echo -e "${CELESTE}┗━┫${NC} ${AMARILLO}IP detectada: ${VERDE}$IP_SERVIDOR${NC}"
    echo -ne "${CELESTE}┗━┫${NC} ${VERDE}Ingrese su dominio (ENTER para IP): ${BLANCO}"; read input_dominio
    
    if [ ! -z "$input_dominio" ]; then
        DOMINIO="$input_dominio"
        if es_ip "$DOMINIO"; then
            ES_IP=true
            aviso "Usando IP: $DOMINIO - SSL no disponible"
        else
            ES_IP=false
            exito "Usando dominio: $DOMINIO - SSL disponible"
            
            # Solicitar email manualmente
            while true; do
                echo -ne "${CELESTE}┗━┫${NC} ${VERDE}Ingrese su correo electrónico para SSL: ${BLANCO}"; read EMAIL_ADMIN
                if [ -z "$EMAIL_ADMIN" ]; then
                    error "El correo no puede estar vacío"
                elif validar_email "$EMAIL_ADMIN"; then
                    exito "Email válido: $EMAIL_ADMIN"
                    break
                else
                    error "Email inválido. Ejemplo: usuario@dominio.com"
                fi
            done
        fi
    else
        DOMINIO="$IP_SERVIDOR"
        ES_IP=true
        aviso "Usando IP: $DOMINIO - SSL no disponible"
    fi
    
    exito "Configuración: $DOMINIO"
    exito "Directorio: $INSTALL_DIR"
    exito "Puerto HTTP: $HTTP_PORT | Puerto HTTPS: $HTTPS_PORT"
}

detectar_os() {
    cabecera "VERIFICANDO SISTEMA"
    
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        exito "Sistema: $NAME $VERSION_ID"
    fi
}

actualizar_sistema() {
    cabecera "ACTUALIZANDO SISTEMA"
    
    if command -v apt-get &> /dev/null; then
        fun_bar 'apt-get update -y' 'apt-get upgrade -y'
    elif command -v yum &> /dev/null; then
        fun_bar 'yum update -y' 'sleep 1'
    fi
    exito "Sistema actualizado"
}

instalar_dependencias() {
    cabecera "INSTALANDO DEPENDENCIAS"
    
    if command -v apt-get &> /dev/null; then
        fun_bar 'apt-get install -y apache2 php php-sqlite3 php-curl php-json php-mbstring php-xml php-zip unzip wget curl sqlite3 openssl' 'sleep 1'
        
        if [ "$ES_IP" = false ]; then
            fun_bar 'apt-get install -y certbot python3-certbot-apache' 'sleep 1'
        fi
        
        a2enmod rewrite headers ssl proxy proxy_http 2>/dev/null
    elif command -v yum &> /dev/null; then
        fun_bar 'yum install -y httpd php php-sqlite3 php-curl php-json php-mbstring php-xml php-zip unzip wget curl sqlite openssl' 'sleep 1'
        
        if [ "$ES_IP" = false ]; then
            fun_bar 'yum install -y certbot python3-certbot-apache mod_ssl' 'sleep 1'
        fi
        
        systemctl enable httpd
    fi
    
    exito "Dependencias instaladas"
}

configurar_puertos() {
    cabecera "CONFIGURANDO PUERTOS ($HTTP_PORT/$HTTPS_PORT)"
    
    if command -v apt-get &> /dev/null; then
        cat > /etc/apache2/ports.conf << EOF
Listen $HTTP_PORT
EOF
        if [ "$ES_IP" = false ]; then
            echo "Listen $HTTPS_PORT" >> /etc/apache2/ports.conf
        fi
    else
        cat > /etc/httpd/conf/ports.conf << EOF
Listen $HTTP_PORT
EOF
        if [ "$ES_IP" = false ]; then
            echo "Listen $HTTPS_PORT" >> /etc/httpd/conf/ports.conf
        fi
    fi
    
    exito "Puertos configurados: HTTP=$HTTP_PORT, HTTPS=$HTTPS_PORT"
}

descargar_extraer() {
    cabecera "DESCARGANDO PANEL"
    
    mkdir -p $INSTALL_DIR
    cd /tmp
    wget -O dtunnel.zip "$DROPBOX_URL"
    
    if [ $? -ne 0 ]; then
        error "Error al descargar"
        exit 1
    fi
    
    rm -rf /tmp/dtunnel_extract
    mkdir -p /tmp/dtunnel_extract
    unzip -o dtunnel.zip -d /tmp/dtunnel_extract
    
    EXTRACTED=$(ls /tmp/dtunnel_extract)
    ENTRY_COUNT=$(ls /tmp/dtunnel_extract | wc -l)
    if [ "$ENTRY_COUNT" -eq 1 ] && [ -d "/tmp/dtunnel_extract/$EXTRACTED" ]; then
        cp -r /tmp/dtunnel_extract/$EXTRACTED/. $INSTALL_DIR/
    else
        cp -r /tmp/dtunnel_extract/. $INSTALL_DIR/
    fi
    
    rm -rf /tmp/dtunnel_extract
    rm -f dtunnel.zip
    
    exito "Archivos extraídos"
}

configurar_permisos() {
    cabecera "CONFIGURANDO PERMISOS"
    
    if command -v apt-get &> /dev/null; then
        chown -R www-data:www-data $INSTALL_DIR
    else
        chown -R apache:apache $INSTALL_DIR
    fi
    
    chmod -R 755 $INSTALL_DIR
    mkdir -p $INSTALL_DIR/db
    chmod -R 777 $INSTALL_DIR/db
    
    exito "Permisos configurados"
}

configurar_apache() {
    cabecera "CONFIGURANDO APACHE (Puertos: HTTP:$HTTP_PORT | HTTPS:$HTTPS_PORT)"
    
    if command -v apt-get &> /dev/null; then
        CONF_FILE="/etc/apache2/sites-available/dtunnel.conf"
        a2dissite 000-default.conf 2>/dev/null
    else
        CONF_FILE="/etc/httpd/conf.d/dtunnel.conf"
    fi
    
    if [ "$ES_IP" = false ] && [ -f "/etc/letsencrypt/live/$DOMINIO/fullchain.pem" ]; then
        cat > $CONF_FILE << EOF
<VirtualHost *:$HTTP_PORT>
    ServerName $DOMINIO
    Redirect permanent / https://$DOMINIO:$HTTPS_PORT/
</VirtualHost>

<VirtualHost *:$HTTPS_PORT>
    ServerName $DOMINIO
    DocumentRoot $INSTALL_DIR
    
    <Directory $INSTALL_DIR>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    
    SSLEngine on
    SSLCertificateFile /etc/letsencrypt/live/$DOMINIO/fullchain.pem
    SSLCertificateKeyFile /etc/letsencrypt/live/$DOMINIO/privkey.pem
    
    ErrorLog \${APACHE_LOG_DIR}/dtunnel_https_error.log
    CustomLog \${APACHE_LOG_DIR}/dtunnel_https_access.log combined
</VirtualHost>
EOF
        exito "Apache configurado con SSL: HTTP:$HTTP_PORT → HTTPS:$HTTPS_PORT"
    elif [ "$ES_IP" = false ]; then
        cat > $CONF_FILE << EOF
<VirtualHost *:$HTTP_PORT>
    ServerName $DOMINIO
    DocumentRoot $INSTALL_DIR
    
    <Directory $INSTALL_DIR>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    
    ErrorLog \${APACHE_LOG_DIR}/dtunnel_error.log
    CustomLog \${APACHE_LOG_DIR}/dtunnel_access.log combined
</VirtualHost>
EOF
        exito "Apache configurado: HTTP:$HTTP_PORT (SSL pendiente)"
    else
        cat > $CONF_FILE << EOF
<VirtualHost *:$HTTP_PORT>
    ServerName $DOMINIO
    DocumentRoot $INSTALL_DIR
    
    <Directory $INSTALL_DIR>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    
    ErrorLog \${APACHE_LOG_DIR}/dtunnel_error.log
    CustomLog \${APACHE_LOG_DIR}/dtunnel_access.log combined
</VirtualHost>
EOF
        exito "Apache configurado: HTTP:$HTTP_PORT (sin SSL)"
    fi
    
    if command -v apt-get &> /dev/null; then
        a2ensite dtunnel.conf
        systemctl reload apache2
    else
        systemctl reload httpd
    fi
}

configurar_firewall() {
    cabecera "CONFIGURANDO FIREWALL"
    
    if command -v ufw &> /dev/null; then
        ufw allow $HTTP_PORT/tcp
        if [ "$ES_IP" = false ]; then
            ufw allow $HTTPS_PORT/tcp
            ufw allow 80/tcp  # Puerto requerido por Let's Encrypt
            ufw allow 443/tcp
        fi
        ufw reload
        exito "Firewall configurado"
        exito "Puertos abiertos: $HTTP_PORT, 80, 443"
    fi
}

corregir_register() {
    if [ -f "$INSTALL_DIR/pages/register.php" ]; then
        ln -sf $INSTALL_DIR/pages/register.php $INSTALL_DIR/pages/registro.php 2>/dev/null
        ln -sf $INSTALL_DIR/pages/register.php $INSTALL_DIR/registro.php 2>/dev/null
    fi
}

# ============================================
# FUNCIONES DEL MENÚ PRINCIPAL
# ============================================

mostrar_banner() {
    clear
    echo -e "${CELESTE}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${NC}"
    echo -e "${CELESTE}┃${NC} ${BLANCO}DTunnelMod PANEL v2.4 - Puerto HTTP: $HTTP_PORT${NC}"
    echo -e "${CELESTE}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${NC}"
}

mostrar_estado() {
    echo -e "${CELESTE}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${NC}"
    echo -e "${CELESTE}┃${NC} ${BLANCO}ESTADO DEL SISTEMA${NC}"
    echo -e "${CELESTE}┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫${NC}"
    
    if command -v apt-get &> /dev/null; then
        if systemctl is-active --quiet apache2; then
            echo -e "${CELESTE}┃${NC} ${VERDE}●${NC} ${BLANCO}Servicio APACHE:        ${VERDE}ACTIVO${NC}"
        else
            echo -e "${CELESTE}┃${NC} ${ROJO}●${NC} ${BLANCO}Servicio APACHE:        ${ROJO}DETENIDO${NC}"
        fi
    else
        if systemctl is-active --quiet httpd; then
            echo -e "${CELESTE}┃${NC} ${VERDE}●${NC} ${BLANCO}Servicio APACHE:        ${VERDE}ACTIVO${NC}"
        else
            echo -e "${CELESTE}┃${NC} ${ROJO}●${NC} ${BLANCO}Servicio APACHE:        ${ROJO}DETENIDO${NC}"
        fi
    fi
    
    if [ -d "$INSTALL_DIR" ]; then
        echo -e "${CELESTE}┃${NC} ${VERDE}●${NC} ${BLANCO}Panel DTunnel:          ${VERDE}INSTALADO${NC}"
    else
        echo -e "${CELESTE}┃${NC} ${ROJO}●${NC} ${BLANCO}Panel DTunnel:          ${ROJO}NO INSTALADO${NC}"
    fi
    
    if ss -tlnp 2>/dev/null | grep -q ":$HTTP_PORT "; then
        echo -e "${CELESTE}┃${NC} ${VERDE}●${NC} ${BLANCO}Puerto $HTTP_PORT (HTTP):   ${VERDE}ESCUCHANDO${NC}"
    else
        echo -e "${CELESTE}┃${NC} ${ROJO}●${NC} ${BLANCO}Puerto $HTTP_PORT (HTTP):   ${ROJO}CERRADO${NC}"
    fi
    
    if [ "$ES_IP" = false ]; then
        if ss -tlnp 2>/dev/null | grep -q ":$HTTPS_PORT "; then
            echo -e "${CELESTE}┃${NC} ${VERDE}●${NC} ${BLANCO}Puerto $HTTPS_PORT (HTTPS):  ${VERDE}ESCUCHANDO${NC}"
        else
            echo -e "${CELESTE}┃${NC} ${ROJO}●${NC} ${BLANCO}Puerto $HTTPS_PORT (HTTPS):  ${ROJO}CERRADO${NC}"
        fi
    fi
    
    # Estado SSL
    if [ "$ES_IP" = false ]; then
        if verificar_certificado_existente > /dev/null; then
            local dias=$(obtener_dias_restantes)
            if [ $dias -lt 30 ]; then
                echo -e "${CELESTE}┃${NC} ${ROJO}●${NC} ${BLANCO}Certificado SSL:        ${ROJO}Expira en $dias días${NC}"
            else
                echo -e "${CELESTE}┃${NC} ${VERDE}●${NC} ${BLANCO}Certificado SSL:        ${VERDE}Válido ($dias días)${NC}"
            fi
        else
            echo -e "${CELESTE}┃${NC} ${ROJO}●${NC} ${BLANCO}Certificado SSL:        ${ROJO}NO INSTALADO${NC}"
        fi
    fi
    
    local backup_count=$(ls -1 $BACKUP_DIR 2>/dev/null | grep -c -E '\.(tar\.gz|zip)$')
    echo -e "${CELESTE}┃${NC} ${CYAN}●${NC} ${BLANCO}Backups disponibles:    ${CYAN}$backup_count backups${NC}"
    
    echo -e "${CELESTE}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${NC}"
}

start_dtunnel() {
    cabecera "INICIANDO DTUNNEL"
    if command -v apt-get &> /dev/null; then
        systemctl start apache2
    else
        systemctl start httpd
    fi
    exito "Panel iniciado en puerto $HTTP_PORT"
    sleep 2
}

stop_dtunnel() {
    cabecera "DETENIENDO DTUNNEL"
    if command -v apt-get &> /dev/null; then
        systemctl stop apache2
    else
        systemctl stop httpd
    fi
    exito "Panel detenido"
    sleep 2
}

restart_dtunnel() {
    cabecera "REINICIANDO DTUNNEL"
    if command -v apt-get &> /dev/null; then
        systemctl restart apache2
    else
        systemctl restart httpd
    fi
    exito "Panel reiniciado"
    sleep 2
}

reparar_permisos() {
    cabecera "REPARANDO PERMISOS"
    
    if command -v apt-get &> /dev/null; then
        chown -R www-data:www-data $INSTALL_DIR
    else
        chown -R apache:apache $INSTALL_DIR
    fi
    chmod -R 755 $INSTALL_DIR
    chmod -R 777 $INSTALL_DIR/db
    
    exito "Permisos reparados"
    sleep 2
}

ver_logs() {
    cabecera "VISUALIZADOR DE LOGS"
    aviso "Presione Ctrl+C para salir del log en tiempo real"
    echo ""
    
    echo -e "${CELESTE}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${NC}"
    echo -e "${CELESTE}┃${NC} ${BLANCO}SELECCIONE EL LOG${NC}"
    echo -e "${CELESTE}┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫${NC}"
    echo -e "${CELESTE}┃${NC} ${VERDE}[1]${NC} ${BLANCO}Log de Error HTTP${NC}"
    echo -e "${CELESTE}┃${NC} ${VERDE}[2]${NC} ${BLANCO}Log de Acceso HTTP${NC}"
    echo -e "${CELESTE}┃${NC} ${VERDE}[3]${NC} ${BLANCO}Log de Error HTTPS (solo dominio)${NC}"
    echo -e "${CELESTE}┃${NC} ${VERDE}[4]${NC} ${BLANCO}Log de Acceso HTTPS (solo dominio)${NC}"
    echo -e "${CELESTE}┃${NC} ${VERDE}[5]${NC} ${BLANCO}Log principal de Apache${NC}"
    echo -e "${CELESTE}┃${NC} ${VERDE}[6]${NC} ${BLANCO}Volver${NC}"
    echo -e "${CELESTE}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${NC}"
    echo -ne "${CELESTE}┗━┫${NC} ${VERDE}Opción: ${BLANCO}"; read op_log
    
    case $op_log in
        1)
            if command -v apt-get &> /dev/null; then
                tail -f /var/log/apache2/dtunnel_error.log 2>/dev/null || tail -f /var/log/apache2/error.log
            else
                tail -f /var/log/httpd/dtunnel_error.log 2>/dev/null || tail -f /var/log/httpd/error_log
            fi
            ;;
        2)
            if command -v apt-get &> /dev/null; then
                tail -f /var/log/apache2/dtunnel_access.log 2>/dev/null || tail -f /var/log/apache2/access.log
            else
                tail -f /var/log/httpd/dtunnel_access.log 2>/dev/null || tail -f /var/log/httpd/access_log
            fi
            ;;
        3)
            if [ "$ES_IP" = false ]; then
                if command -v apt-get &> /dev/null; then
                    tail -f /var/log/apache2/dtunnel_https_error.log 2>/dev/null
                else
                    tail -f /var/log/httpd/dtunnel_https_error.log 2>/dev/null
                fi
            else
                aviso "HTTPS no disponible para IP"
                sleep 2
            fi
            ;;
        4)
            if [ "$ES_IP" = false ]; then
                if command -v apt-get &> /dev/null; then
                    tail -f /var/log/apache2/dtunnel_https_access.log 2>/dev/null
                else
                    tail -f /var/log/httpd/dtunnel_https_access.log 2>/dev/null
                fi
            else
                aviso "HTTPS no disponible para IP"
                sleep 2
            fi
            ;;
        5)
            if command -v apt-get &> /dev/null; then
                tail -f /var/log/apache2/error.log
            else
                tail -f /var/log/httpd/error_log
            fi
            ;;
        6)
            return
            ;;
        *)
            error "Opción inválida"
            sleep 2
            ;;
    esac
}

update_code() {
    cabecera "ACTUALIZANDO CÓDIGO"
    echo -ne "${CELESTE}┗━┫${NC} ${VERDE}¿Continuar? (s/n): ${BLANCO}"; read confirmar
    
    if [ "$confirmar" = "s" ] || [ "$confirmar" = "S" ]; then
        local pre_update_backup="$BACKUP_DIR/pre_update_$(date +%Y%m%d_%H%M%S).tar.gz"
        mensaje "Creando backup pre-actualización..."
        tar -czf "$pre_update_backup" -C /var/www/html dtunnel 2>/dev/null
        exito "Backup creado: $pre_update_backup"
        
        cd /tmp
        wget -O dtunnel_new.zip "$DROPBOX_URL"
        
        if [ $? -eq 0 ]; then
            unzip -o dtunnel_new.zip -d /tmp/dtunnel_new/
            
            if [ -f "$INSTALL_DIR/database/database.sqlite" ]; then
                cp $INSTALL_DIR/database/database.sqlite /tmp/dtunnel_new/database/ 2>/dev/null
            fi
            
            rm -rf $INSTALL_DIR/*
            cp -r /tmp/dtunnel_new/* $INSTALL_DIR/
            
            if command -v apt-get &> /dev/null; then
                chown -R www-data:www-data $INSTALL_DIR
            else
                chown -R apache:apache $INSTALL_DIR
            fi
            chmod -R 755 $INSTALL_DIR
            chmod -R 777 $INSTALL_DIR/db
            
            rm -rf /tmp/dtunnel_new/
            rm -f dtunnel_new.zip
            
            exito "Código actualizado"
            restart_dtunnel
        else
            error "Error al descargar"
        fi
    fi
    sleep 2
}

info_sistema() {
    cabecera "INFORMACIÓN DEL SISTEMA"
    
    echo -e "${CELESTE}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${NC}"
    echo -e "${CELESTE}┃${NC} ${BLANCO}Sistema:${NC} $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
    echo -e "${CELESTE}┃${NC} ${BLANCO}Kernel:${NC} $(uname -r)"
    echo -e "${CELESTE}┃${NC} ${BLANCO}CPU:${NC} $(nproc) núcleos"
    echo -e "${CELESTE}┃${NC} ${BLANCO}RAM:${NC} $(free -h | awk '/^Mem:/ {print $2}') total"
    echo -e "${CELESTE}┃${NC} ${BLANCO}IP:${NC} $(obtener_ip)"
    echo -e "${CELESTE}┃${NC} ${BLANCO}Panel HTTP:${NC} http://$(obtener_ip):$HTTP_PORT/"
    if [ "$ES_IP" = false ]; then
        echo -e "${CELESTE}┃${NC} ${BLANCO}Panel HTTPS:${NC} https://$(obtener_ip):$HTTPS_PORT/"
    fi
    echo -e "${CELESTE}┃${NC} ${BLANCO}Directorio backups:${NC} $BACKUP_DIR"
    
    if [ "$ES_IP" = false ] && verificar_certificado_existente > /dev/null; then
        local dias=$(obtener_dias_restantes)
        echo -e "${CELESTE}┃${NC} ${BLANCO}SSL expira en:${NC} $dias días"
    fi
    
    echo -e "${CELESTE}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${NC}"
    
    echo -e "\n${AMARILLO}Presione ENTER...${NC}"
    read
}

desinstalar() {
    cabecera "DESINSTALAR DTUNNEL PANEL"
    
    echo -e "${CELESTE}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${NC}"
    echo -e "${CELESTE}┃${NC} ${ROJO}⚠ ¡ADVERTENCIA!${NC}"
    echo -e "${CELESTE}┃${NC} ${ROJO}Esto eliminará TODO el panel${NC}"
    echo -e "${CELESTE}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${NC}"
    echo -ne "${CELESTE}┗━┫${NC} ${VERDE}¿Está seguro? (s/n): ${BLANCO}"; read confirmar
    
    if [ "$confirmar" != "s" ] && [ "$confirmar" != "S" ]; then
        aviso "Cancelado"
        return
    fi
    
    echo -ne "${CELESTE}┗━┫${NC} ${VERDE}¿Crear backup antes de desinstalar? (s/n): ${BLANCO}"; read backup
    
    if [ "$backup" = "s" ] || [ "$backup" = "S" ]; then
        backup_manual
    fi
    
    mensaje "Eliminando..."
    
    if command -v apt-get &> /dev/null; then
        systemctl stop apache2
        rm -f /etc/apache2/sites-available/dtunnel.conf
        rm -f /etc/apache2/sites-enabled/dtunnel.conf
        cat > /etc/apache2/ports.conf << EOF
Listen 80
Listen 443
EOF
    else
        systemctl stop httpd
        rm -f /etc/httpd/conf.d/dtunnel.conf
        rm -f /etc/httpd/conf/ports.conf
    fi
    
    rm -rf $INSTALL_DIR
    
    if [ -d "/etc/letsencrypt/live/$DOMINIO" ]; then
        certbot delete --cert-name $DOMINIO --non-interactive 2>/dev/null
    fi
    
    rm -f /bin/menu2
    rm -f /usr/local/bin/menu2
    
    if command -v apt-get &> /dev/null; then
        a2ensite 000-default.conf 2>/dev/null
        systemctl start apache2
    else
        systemctl start httpd
    fi
    
    exito "Desinstalado completamente"
    sleep 2
}

# ============================================
# MENÚ PRINCIPAL
# ============================================

menu_principal() {
    while true; do
        mostrar_banner
        mostrar_estado
        
        echo -e "${CELESTE}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${NC}"
        echo -e "${CELESTE}┃${NC} ${AMARILLO}MENÚ PRINCIPAL${NC}"
        echo -e "${CELESTE}┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫${NC}"
        echo -e "${CELESTE}┃${NC} ${VERDE}[1]${NC} ${CYAN}Iniciar DTunnel${NC}"
        echo -e "${CELESTE}┃${NC} ${VERDE}[2]${NC} ${ROJO}Detener DTunnel${NC}"
        echo -e "${CELESTE}┃${NC} ${VERDE}[3]${NC} ${AMARILLO}Reiniciar DTunnel${NC}"
        echo -e "${CELESTE}┃${NC} ${VERDE}[4]${NC} ${BLANCO}Ver Logs${NC}"
        echo -e "${CELESTE}┃${NC} ${VERDE}[5]${NC} ${MORADO}Actualizar Código${NC}"
        echo -e "${CELESTE}┃${NC} ${VERDE}[6]${NC} ${AZUL}Gestionar SSL (Inteligente)${NC}"
        echo -e "${CELESTE}┃${NC} ${VERDE}[7]${NC} ${VERDE_CLARO}Gestionar Usuarios${NC}"
        echo -e "${CELESTE}┃${NC} ${VERDE}[8]${NC} ${ROSA}Reparar Permisos${NC}"
        echo -e "${CELESTE}┃${NC} ${VERDE}[9]${NC} ${CAFE}Backup Manual${NC}"
        echo -e "${CELESTE}┃${NC} ${VERDE}[10]${NC} ${VERDE}Restaurar Backup${NC}"
        echo -e "${CELESTE}┃${NC} ${VERDE}[11]${NC} ${GRIS}Información del Sistema${NC}"
        echo -e "${CELESTE}┃${NC} ${VERDE}[12]${NC} ${ROJO}Desinstalar${NC}"
        echo -e "${CELESTE}┃${NC} ${VERDE}[0]${NC} ${BLANCO}Salir${NC}"
        echo -e "${CELESTE}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${NC}"
        echo ""
        echo -ne "${CYAN}┗━┫${NC} ${VERDE}Seleccione una opción: ${BLANCO}"; read opcion
        
        case $opcion in
            1) start_dtunnel ;;
            2) stop_dtunnel ;;
            3) restart_dtunnel ;;
            4) ver_logs ;;
            5) update_code ;;
            6) gestionar_ssl ;;
            7) gestionar_usuarios ;;
            8) reparar_permisos ;;
            9) backup_manual ;;
            10) restaurar_backup ;;
            11) info_sistema ;;
            12) desinstalar ;;
            0) 
                echo -e "\n${CYAN}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${NC}"
                echo -e "${CELESTE}┃${NC} ${VERDE}✨ ¡Hasta luego! ✨${NC}"
                echo -e "${CELESTE}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${NC}"
                exit 0
                ;;
            *)
                error "Opción inválida"
                sleep 2
                ;;
        esac
    done
}

# ============================================
# INSTALACIÓN
# ============================================

instalar() {
    cabecera "INSTALADOR DTUNNEL PANEL"
    
    verificar_root
    recopilar_info
    detectar_os
    actualizar_sistema
    instalar_dependencias
    configurar_puertos
    descargar_extraer
    configurar_permisos
    configurar_apache
    configurar_firewall
    corregir_register
    
    # SSL Inteligente durante la instalación
    if [ "$ES_IP" = false ]; then
        gestionar_ssl "instalacion"
    fi
    
    cabecera "INSTALACIÓN COMPLETADA"
    
    echo -e "${CELESTE}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${NC}"
    echo -e "${CELESTE}┃${NC} ${VERDE}Panel instalado correctamente${NC}"
    echo -e "${CELESTE}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${NC}\n"
    echo -e "${CELESTE}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${NC}"
    echo -e "${CELESTE}┃${NC} ${AMARILLO}Acceso:${NC}"
    echo -e "${CELESTE}┃${NC} ${CYAN}http://$DOMINIO:$HTTP_PORT/register${NC}"
    echo -e "${CELESTE}┃${NC} ${CYAN}http://$DOMINIO:$HTTP_PORT/login${NC}"
    
    if [ "$ES_IP" = false ] && [ -f "/etc/letsencrypt/live/$DOMINIO/fullchain.pem" ]; then
        echo -e "${CELESTE}┃${NC} ${CYAN}https://$DOMINIO:$HTTPS_PORT/register${NC}"
        echo -e "${CELESTE}┃${NC} ${CYAN}https://$DOMINIO:$HTTPS_PORT/login${NC}"
    fi
    
    echo -e "${CELESTE}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${NC}"
    echo -e "\n${CELESTE}┗━┫${NC} ${AMARILLO}Comando:${NC} ${VERDE}menu2${NC} ${BLANCO}- Gestionar el panel${NC}"
    echo -e "${CELESTE}┗━┫${NC} ${AMARILLO}Backups:${NC} ${VERDE}$BACKUP_DIR${NC}"
    echo ""
}

# ============================================
# PUNTO DE ENTRADA
# ============================================

if [ "$1" = "install" ]; then
    instalar
    exit 0
fi

if [ "$1" = "uninstall" ] || [ "$1" = "desinstalar" ]; then
    verificar_root
    desinstalar
    exit 0
fi

# Si no está instalado
if [ ! -d "$INSTALL_DIR" ] || [ ! -f "$INSTALL_DIR/index.php" ]; then
    echo -e "${CELESTE}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${NC}"
    echo -e "${CELESTE}┃${NC} ${AMARILLO}DTunnel no está instalado${NC}"
    echo -e "${CELESTE}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${NC}"
    echo -ne "${CELESTE}┗━┫${NC} ${VERDE}¿Instalar ahora? (s/n): ${BLANCO}"; read respuesta
    if [ "$respuesta" = "s" ] || [ "$respuesta" = "S" ]; then
        instalar
    fi
    exit 0
fi

# Verificar root
if [[ $EUID -ne 0 ]]; then
    error "Ejecute: sudo menu2"
    exit 1
fi

# Re-detect domain/IP state for menu mode
if [ -z "$DOMINIO" ]; then
    DOMINIO=$(obtener_ip)
    ES_IP=true
    if command -v apt-get &> /dev/null; then
        _CONF="/etc/apache2/sites-available/dtunnel.conf"
    else
        _CONF="/etc/httpd/conf.d/dtunnel.conf"
    fi
    if [ -f "$_CONF" ]; then
        _SN=$(grep -m1 "ServerName" "$_CONF" | awk '{print $2}')
        if [ -n "$_SN" ]; then
            DOMINIO="$_SN"
            if ! es_ip "$DOMINIO"; then
                ES_IP=false
            fi
        fi
    fi
fi

# Ejecutar menú
menu_principal