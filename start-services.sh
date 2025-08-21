#!/bin/bash

# POS Microservices Startup Script
# Este script inicia todos los microservicios en el orden correcto

echo "🚀 Iniciando POS Microservices..."
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

# Función para iniciar un servicio
start_service() {
    local service_name=$1
    local service_dir=$2
    local port=$3
    
    print_status "Compilando e iniciando $service_name en puerto $port..."
    
    if [ ! -d "$service_dir" ]; then
        print_error "Directorio $service_dir no encontrado!"
        return 1
    fi
    
    cd "$service_dir"
    
    # Verificar si el servicio ya está ejecutándose
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
        print_warning "$service_name ya está ejecutándose en puerto $port"
        cd ..
        return 0
    fi
    
    # Compilar el servicio
    print_status "Compilando $service_name..."
    mvn clean install > "../logs/${service_name}_build.log" 2>&1
    if [ $? -ne 0 ]; then
        print_error "Error al compilar $service_name. Revisa los logs en logs/${service_name}_build.log"
        cd ..
        return 1
    fi
    print_success "$service_name compilado correctamente"
    
    # Iniciar el servicio en background
    print_status "Iniciando $service_name..."
    nohup mvn spring-boot:run > "../logs/$service_name.log" 2>&1 &
    local pid=$!
    
    # Guardar el PID para poder detenerlo después
    echo $pid > "../logs/$service_name.pid"
    
    print_success "$service_name iniciado con PID: $pid"
    
    # Esperar un poco para que el servicio se inicie
    sleep 5
    
    cd ..
}

# Crear directorio de logs si no existe
mkdir -p logs

# Limpiar logs anteriores
print_status "Limpiando logs anteriores..."
rm -f logs/*.log logs/*.pid

echo ""
print_status "Iniciando servicios en orden..."

# 1. Discovery Service (Puerto 8761)
start_service "Discovery Service" "discovery-service" 8761
if [ $? -ne 0 ]; then
    print_error "Error al iniciar Discovery Service"
    exit 1
fi

# Esperar a que Eureka esté listo
print_status "Esperando a que Discovery Service esté listo..."
sleep 10

# 2. Gateway Service (Puerto 8080)
start_service "Gateway Service" "gateway-service" 8080
if [ $? -ne 0 ]; then
    print_error "Error al iniciar Gateway Service"
    exit 1
fi

# 3. User Service (Puerto 8081)
start_service "User Service" "user-service" 8081
if [ $? -ne 0 ]; then
    print_error "Error al iniciar User Service"
    exit 1
fi

# 4. Product Service (Puerto 8082)
start_service "Product Service" "product-service" 8082
if [ $? -ne 0 ]; then
    print_error "Error al iniciar Product Service"
    exit 1
fi

# 5. Order Service (Puerto 8084)
start_service "Order Service" "order-service" 8084
if [ $? -ne 0 ]; then
    print_error "Error al iniciar Order Service"
    exit 1
fi

echo ""
echo "=================================="
print_success "¡Todos los servicios han sido iniciados!"
echo ""

# Mostrar información de acceso
echo "📋 Información de acceso:"
echo "=========================="
echo -e "${GREEN}Eureka Dashboard:${NC} http://localhost:8761"
echo -e "${GREEN}Gateway:${NC} http://localhost:8080"
echo -e "${GREEN}User Service:${NC} http://localhost:8080/api/users"
echo -e "${GREEN}Product Service:${NC} http://localhost:8080/api/products"
echo -e "${GREEN}Order Service:${NC} http://localhost:8080/api/orders"
echo ""

# Mostrar logs disponibles
echo "📝 Logs disponibles:"
echo "==================="
for log_file in logs/*.log; do
    if [ -f "$log_file" ]; then
        service_name=$(basename "$log_file" .log)
        echo -e "${BLUE}$service_name:${NC} $log_file"
    fi
done

echo ""
print_warning "Para detener todos los servicios, ejecuta: ./stop-services.sh"
print_warning "Para ver logs en tiempo real: tail -f logs/[servicio].log"

echo ""
print_status "Los servicios están iniciándose. Puede tomar unos segundos para que estén completamente listos."
