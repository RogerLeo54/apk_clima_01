# Clima 360 - Aplicación de Pronóstico del Clima

## Descripción del Proyecto
Clima 360 es una aplicación móvil desarrollada en Flutter que permite a los usuarios ver el clima actual y el pronóstico para los próximos tres días. Utiliza la API de OpenWeatherMap para obtener datos meteorológicos en tiempo real y presenta información relevante como temperatura máxima, mínima, descripción del clima e íconos representativos.

## Características
- Visualización del clima actual basado en la ubicación del usuario.
- Pronóstico del clima para los próximos tres días.
- Interfaz de usuario intuitiva y atractiva.
- Integración con servicios de localización para determinar automáticamente la ubicación del usuario.

## Instrucciones para Instalar y Ejecutar la Aplicación

1. **Clonar el repositorio**:
   ```bash
   git clone https://github.com/tu_usuario/clima_360.git
   cd clima_360

Configurar permisos: La aplicación solicita permisos para acceder a la ubicación. 
Asegúrate de permitirlos en tu dispositivo.

Instalación de fuentes desconocidas: Dado que la aplicación no está publicada en la Play Store,
es posible que necesites habilitar la instalación de aplicaciones de fuentes desconocidas en tu dispositivo. 
Esto se puede hacer en la configuración de seguridad.

API Key
La aplicación utiliza la API de OpenWeatherMap, que ya está configurada en el código. 
No es necesario reemplazar la API key, 
ya que está vinculada a una cuenta creada para este proyecto.

Dependencias
El archivo pubspec.yaml incluye las siguientes dependencias:
dependencies:
flutter:
sdk: flutter
cupertino_icons: ^1.0.8
weather: ^3.1.1
intl: ^0.19.0
geolocator: ^13.0.1

Plataforma
Esta aplicación está diseñada exclusivamente para dispositivos Android.
