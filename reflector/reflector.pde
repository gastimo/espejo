// 
// REFLECTOR
//
// Módulo que funciona como intermediario entre el dispositivo de la "Pantalla
// de Leds" y el módulo principal del "Espejador", responsable de capturar, 
// analizar y procesar (fragmentar) la imagen.
// Este módulo "Reflector" simplemente recibe por el protocolo OSC los píxeles
// que forman parte de la imagen fragmentada del espejo. En la medida que van
// llegando, los píxeles son interpretados, ordenados y guardados en una 
// estructura auxiliar llamada "Pantalla" para, luego, ser transmitidos por
// el puerto serial de comunicación hacia el espejo (la "Pantalla de Leds"),
// donde finalmente son encendidos o apagados según corresponda.
//
// vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv



// CONFIGURACIÓN DE LA CÁMARA
// vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
// Altura en píxeles de la webcam principal que captura las imágenes
final int CAMARA_ALTO = 480;



// CONFIGURACIÓN DE PARÁMETROS PARA EL ENVÍO DE MENSAJES OSC
// vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
// Este módulo simplemente se ocupa de recibir mensajes, por lo tanto alcanza
// con definir únicamente el puerto local donde está escuchando el "Reflector".
final int PUERTO_LOCAL = 12011;



// DEFINICIÓN DE LAS DIRECCIONES PARA LOS MENSAJES "OSC"
// vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
// Definición de los nombres de los eventos OSC (las direcciones) 
final String MENSAJE_OSC_FLUJO_OPTICO_MATRIZ = "/opticalflow/matriz";
final String MENSAJE_OSC_FLUJO_OPTICO        = "/opticalflow";
final String MENSAJE_OSC_FOTOGRAMA           = "/espejo/fotograma";
final String MENSAJE_OSC_CIERRE              = "/espejo/cierre";



// Definición de transmisores/receptores para:
//  1. Recibir los datos (píxeles) dela imagen fragmentada
//  2. Enviar los píxeles ordenados hacia la "Pantalla de Leds"
ReceptorOSC receptorDePixeles;
TransmisorSerial transmisorDelEspejo;



// Variables globales para el procesamiento
Pantalla pantalla;
byte paquete[];



/**
 * settings
 * Función estándar de Processing, usada en este caso para poder
 * definir las dimensiones de la ventana principal mediante variables.
 */
void settings() {
  size(VISTA_ANCHO, CAMARA_ALTO);
}


/**
 * setup
 * Función estándar de Processing para ejecutar las tareas
 * iniciales y de configuración.
 */
void setup() {
  frameRate(30);
  colorMode(RGB, 255); 
  background(0);
  
  // Inicialización de los transmisores/receptores
  receptorDePixeles = new ReceptorOSC(this, PUERTO_LOCAL);  
  transmisorDelEspejo = new TransmisorSerial(this); 
  
  // Inicialización de la pantalla auxiliar
  pantalla = new Pantalla();
}



/**
 * Función estándar de Processing que se ejecuta en cada una de 
 * las iteraciones del ciclo principal y dibuja el contenido de 
 * la ventana principal.
 */
void draw() {
    if (frameCount % 2 == 0) {
      pantalla.mostrar(0, 0);
    }
    // La información de los píxeles es enviada a la "Pantalla de Leds"
    // a una tasa de 10 fps porque el puerto serial no es capaz de
    // procesar todos los bytes de cada fotograma más rápidamente
    if (frameCount % 3 == 0) {
      transmisorDelEspejo.enviar(pantalla.imagen(), MENSAJE_OSC_FOTOGRAMA);
    }
}



/**
 * oscEvent
 * Función principal de la librería oscP5 que es invocada de
 * forma automática cada vez que un evento OSC es recibido.
 * Se recibe un mensaje OSC con todos los píxeles de la imagen.
 */
void oscEvent(OscMessage mensajeEntrante) {
  int pixelX, pixelY;

  // MENSAJE CON LOS DATOS DEL FOTOGRAMA
  // El mensaje contiene una estructura de datos de tipo BLOB de
  // 825 bytes de longitud. Se utilizan 3 bytes por pixel (uno por
  // cada canal RGB) y se disponen como una secuencia ordenada.
  if (mensajeEntrante.checkAddrPattern(MENSAJE_OSC_FOTOGRAMA)) {
    if (mensajeEntrante.checkTypetag("b")) {
      pixelX = 0;
      pixelY = 0;
      paquete = mensajeEntrante.get(0).blobValue();
      for (int i = 0; i + 2 < paquete.length; i += 3) {
        pantalla.definir(pixelX, pixelY, int(paquete[i]), int(paquete[i+1]), int(paquete[i+2]));
        if (pixelY == 24) {
          pixelY = 0;
          pixelX++;
        }
        else
          pixelY++;
      }
      pantalla.asegurar();
    }
  }
}
