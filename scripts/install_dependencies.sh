#!/bin/bash

# Script de instalación de dependencias para Autocondat
# Versión: 1.2
# Autor: Autocondat DevOps Team

set -e

echo "🚀 Iniciando instalación de dependencias para Autocondat..."
echo "⏱  Este proceso puede tardar varios minutos"

# 1. Verificar sistema operativo
if [[ "$OSTYPE" != "linux-gnu"* && "$OSTYPE" != "darwin"* ]]; then
    echo "❌ Error: Este script solo es compatible con Linux y macOS"
    exit 1
fi

# 2. Verificar si es WSL (Windows Subsystem for Linux)
if grep -qi microsoft /proc/version; then
    IS_WSL=true
    echo "ℹ️  Detectado entorno WSL"
else
    IS_WSL=false
fi

# 3. Instalar dependencias básicas
echo "🔧 Instalando dependencias básicas..."
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    sudo apt update
    sudo apt install -y git curl make jq python3-pip
elif [[ "$OSTYPE" == "darwin"* ]]; then
    # Verificar si Homebrew está instalado
    if ! command -v brew &> /dev/null; then
        echo "🍺 Instalando Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    brew update
    brew install git curl make jq python@3.11
fi

# 4. Instalar Docker y Docker Compose
if ! command -v docker &> /dev/null; then
    echo "🐳 Instalando Docker..."
    
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Instalación para Linux
        curl -fsSL https://get.docker.com -o get-docker.sh
        sudo sh get-docker.sh
        sudo usermod -aG docker $USER
        rm get-docker.sh
        
        # Para WSL
        if [ "$IS_WSL" = true ]; then
            echo "ℹ️  Configurando Docker para WSL..."
            sudo mkdir -p /etc/docker
            sudo tee /etc/docker/daemon.json <<EOF
{
  "hosts": ["unix:///var/run/docker.sock", "tcp://0.0.0.0:2375"]
}
EOF
            sudo service docker start
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        # Instalación para macOS
        brew install --cask docker
        open /Applications/Docker.app
        echo "⏳ Esperando que Docker se inicie..."
        sleep 30
    fi
else
    echo "✅ Docker ya está instalado"
fi

# Instalar Docker Compose si no está presente
if ! command -v docker-compose &> /dev/null; then
    echo "📦 Instalando Docker Compose..."
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo curl -L "https://github.com/docker/compose/releases/download/v2.23.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew install docker-compose
    fi
else
    echo "✅ Docker Compose ya está instalado"
fi

# 5. Instalar mkcert para certificados locales
if ! command -v mkcert &> /dev/null; then
    echo "🔐 Instalando mkcert para certificados SSL locales..."
    
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo apt install -y libnss3-tools
        curl -JLO "https://dl.filippo.io/mkcert/latest?for=linux/amd64"
        chmod +x mkcert-v*-linux-amd64
        sudo mv mkcert-v*-linux-amd64 /usr/local/bin/mkcert
        
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew install mkcert
    fi
    
    # Configurar certificados locales
    mkcert -install
    echo "✅ Certificado raíz instalado en el sistema"
else
    echo "✅ mkcert ya está instalado"
fi

# 6. Instalar herramientas adicionales
echo "🧰 Instalando herramientas adicionales..."

# Redis CLI
if ! command -v redis-cli &> /dev/null; then
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo apt install -y redis-tools
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew install redis
    fi
fi

# RabbitMQ CLI
if ! command -v rabbitmqadmin &> /dev/null; then
    echo "🐇 Instalando rabbitmqadmin..."
    curl -L https://raw.githubusercontent.com/rabbitmq/rabbitmq-server/v3.12.0/deps/rabbitmq_management/bin/rabbitmqadmin -o rabbitmqadmin
    chmod +x rabbitmqadmin
    sudo mv rabbitmqadmin /usr/local/bin/
fi

# 7. Instalar herramientas de calidad de código
echo "📊 Instalando herramientas de calidad de código..."

# SonarScanner CLI
if ! command -v sonar-scanner &> /dev/null; then
    echo "🔍 Instalando SonarScanner..."
    
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        SONAR_SCANNER_VERSION="5.0.1.3006"
        SONAR_SCANNER_ZIP="sonar-scanner-cli-${SONAR_SCANNER_VERSION}-linux.zip"
        wget "https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/${SONAR_SCANNER_ZIP}"
        unzip $SONAR_SCANNER_ZIP
        sudo mv sonar-scanner-${SONAR_SCANNER_VERSION}-linux /opt/sonar-scanner
        sudo ln -s /opt/sonar-scanner/bin/sonar-scanner /usr/local/bin/sonar-scanner
        rm $SONAR_SCANNER_ZIP
        
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew install sonar-scanner
    fi
fi

# 8. Verificar instalaciones
echo ""
echo "✅ Instalación completada!"
echo ""
echo "Verificando herramientas instaladas:"
echo "-----------------------------------"
echo "Docker:         $(docker --version 2>/dev/null || echo 'No instalado')"
echo "Docker Compose: $(docker-compose --version 2>/dev/null || echo 'No instalado')"
echo "mkcert:         $(mkcert --version 2>/dev/null || echo 'No instalado')"
echo "Redis CLI:      $(redis-cli --version 2>/dev/null || echo 'No instalado')"
echo "SonarScanner:   $(sonar-scanner --version 2>/dev/null || echo 'No instalado')"
echo ""

# 9. Configuración para WSL
if [ "$IS_WSL" = true ]; then
    echo "⚠️  ATENCIÓN PARA USUARIOS WSL:"
    echo "1. Debes instalar Docker Desktop en Windows: https://www.docker.com/products/docker-desktop/"
    echo "2. En Docker Desktop Settings > General:"
    echo "   - Habilitar 'Use the WSL 2 based engine'"
    echo "   - Habilitar integración con tu distro WSL"
    echo "3. En Docker Desktop Settings > Resources > WSL Integration:"
    echo "   - Activar integración con tu distro WSL"
    echo "4. Reinicia Docker Desktop después de configurar"
    echo ""
fi

echo "📌 Pasos siguientes:"
echo "1. Clona el repositorio de infraestructura:"
echo "   git clone https://github.com/tu-usuario/autocondat-infra.git"
echo "2. Agrega tu código Symfony como submódulo:"
echo "   cd autocondondat-infra"
echo "   git submodule add https://github.com/enriquepascalin/autocondat7.git"
echo "3. Inicia los servicios:"
echo "   make start"
echo ""
echo "¡Listo para desarrollar! 🎉"