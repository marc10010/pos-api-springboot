#!/bin/bash

# POS Microservices Stop Script
# Este script detiene todos los microservicios de forma ordenada

echo "🛑 Deteniendo POS Microservices..."
echo "=================================="

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para imprimir con color
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Verificar que estamos en el directorio correcto
if [ ! -f "pom.xml" ]; then
    print_error "No se encontró pom.xml. Asegúrate de estar en el directorio raíz del proyecto."
    exit 1
fi

# Función para detener un servicio
stop_service() {
    local service_name=$1
    local pid_file="logs/$service_name.pid"
    
    if [ -f "$pid_file" ]; then
        local pid=$(cat "$pid_file")
        
        if ps -p $pid > /dev/null 2>&1; then
            print_status "Deteniendo $service_name (PID: $pid)..."
            kill $pid
            
            # Esperar a que el proceso termine
            local count=0
            while ps -p $pid > /dev/null 2>&1 && [ $count -lt 10 ]; do
                sleep 1
                count=$((count + 1))
            done
            
            # Si aún está ejecutándose, forzar terminación
            if ps -p $pid > /dev/null 2>&1; then
                print_warning "Forzando terminación de $service_name..."
                kill -9 $pid
            fi
            
            print_success "$service_name detenido"
        else
            print_warning "$service_name no estaba ejecutándose"
        fi
        
        # Eliminar archivo PID
        rm -f "$pid_file"
    else
        print_warning "No se encontró PID para $service_name"
    fi
}

# Función para detener servicios por puerto
stop_service_by_port() {
    local port=$1
    local service_name=$2
    
    local pid=$(lsof -ti:$port 2>/dev/null)
    
    if [ ! -z "$pid" ]; then
        print_status "Deteniendo servicio en puerto $port ($service_name)..."
        kill $pid
        
        # Esperar a que el proceso termine
        local count=0
        while lsof -ti:$port >/dev/null 2>&1 && [ $count -lt 10 ]; do
            sleep 1
            count=$((count + 1))
        done
        
        # Si aún está ejecutándose, forzar terminación
        if lsof -ti:$port >/dev/null 2>&1; then
            print_warning "Forzando terminación de servicio en puerto $port..."
            kill -9 $(lsof -ti:$port)
        fi
        
        print_success "Servicio en puerto $port detenido"
    else
        print_warning "No hay servicios ejecutándose en puerto $port"
    fi
}

echo ""
print_status "Deteniendo servicios en orden inverso..."

# 5. Order Service (Puerto 8083)
stop_service_by_port 8083 "Order Service"

# 4. Product Service (Puerto 8082)
stop_service_by_port 8082 "Product Service"

# 3. User Service (Puerto 8081)
stop_service_by_port 8081 "User Service"

# 2. Gateway Service (Puerto 8080)
stop_service_by_port 8080 "Gateway Service"

# 1. Discovery Service (Puerto 8761)
stop_service_by_port 8761 "Discovery Service"

echo ""
echo "=================================="
print_success "¡Todos los servicios han sido detenidos!"
echo ""

# Limpiar archivos PID restantes
print_status "Limpiando archivos PID..."
rm -f logs/*.pid

# Mostrar estado de puertos
echo "📊 Estado de puertos:"
echo "===================="
for port in 8761 8080 8081 8082 8083; do
    if lsof -ti:$port >/dev/null 2>&1; then
        echo -e "${RED}Puerto $port:${NC} En uso"
    else
        echo -e "${GREEN}Puerto $port:${NC} Libre"
    fi
done

echo ""
print_status "Para iniciar todos los servicios nuevamente, ejecuta: ./start-services.sh"
