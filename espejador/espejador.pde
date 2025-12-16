// 
// ESPEJADOR
// 
// Módulo principal del proyecto que se ocupa de capturar la imagen de
// la webcam, analizarla y procesarla para generar las correspondientes 
// imágenes espejadas (mediante la fragmentación de la imagen original).
//
// vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv



// CONFIGURACIÓN DE LAS DIMENSIONES DE LA ENTRADA DEL VIDEO (WEBCAM)
// vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
// Dimensiones de cada fotograma capturado por la cámara principal
final int CAMARA_ANCHO = 640;
final int CAMARA_ALTO  = 480;


// DEFINICIÓN DE LA PROPORCIÓN (ASPECT RATIO) DE LA REGIÓN DE INTERÉS (RECORTE)
// vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
// La proporción de la imagen reflejada debe coincidir con la del soporte acrílico donde se proyectará (11x25)
final int PROPORCION_ANCHO = 11;
final int PROPORCION_ALTO  = 25;


// RENDERER POR DEFECTO PARA LA GENERACIÓN DEL VIDEO
// vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
// Por defecto, Processing utiliza el "renderer build-in" de Java (JAVA2D).
// Para poder utilizar "Spout" o cualquier función que requiera hacer uso del
// procesador gráfico (OpenGL o gráficos 3D) se requiere usar P2D o P3D
final String VIDEO_RENDERER = JAVA2D;


// DEFINICIÓN DE LAS DIMENSIONES (EN PÍXELES) DE LAS VISTAS, REGIONES Y ESPACIADOS 
// vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
// Tamaño de la ventana de previsualización del módulo
final int SEPARADOR = 6;

// La región de interés es el área de la imagen capturada que se procesa (la región central)
final int REGION_DE_INTERES_ANCHO = PROPORCION_ANCHO * CAMARA_ALTO / PROPORCION_ALTO;
final int REGION_DE_INTERES_ALTO  = CAMARA_ALTO;

// Dimensiones de las vistas (imágenes espejadas a generar a partir de la región de interés)
final int VISTA_ALTO  = CAMARA_ALTO * 2 + SEPARADOR;
final int VISTA_ANCHO = VISTA_ALTO * PROPORCION_ANCHO / PROPORCION_ALTO;

// Tamaño de la ventana de previsualización del módulo (salida del video)
final int VIDEO_ANCHO = CAMARA_ANCHO + REGION_DE_INTERES_ANCHO + (VISTA_ANCHO * 2) + (SEPARADOR * 3);
final int VIDEO_ALTO  = VISTA_ALTO;



// CONFIGURACIÓN DE PARÁMETROS PARA EL ENVÍO DE MENSAJES "OSC"
// vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
// Configuración de las direcciones IPs de los equipos y de los puertos 
// para transmitir los mensajes vía el protocolo OSC
final String IP_DEL_ESPEJADOR    = "192.168.0.5";
final String IP_DEL_SONORIZADOR  = "192.168.0.5";
final String IP_DEL_REFLECTOR    = "192.168.0.5";
final int PUERTO_DEL_ESPEJADOR   = 12000;
final int PUERTO_DEL_SONORIZADOR = 9000;
final int PUERTO_DEL_REFLECTOR   = 12011;



// DEFINICIÓN DE LAS DIRECCIONES PARA LOS MENSAJES "OSC"
// vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
// Definición de los nombres de los eventos OSC (las direcciones) 
final String MENSAJE_OSC_FLUJO_OPTICO_MATRIZ = "/opticalflow/matriz";
final String MENSAJE_OSC_FLUJO_OPTICO        = "/opticalflow";
final String MENSAJE_OSC_FOTOGRAMA           = "/espejo/fotograma";
final String MENSAJE_OSC_CIERRE              = "/espejo/cierre";



// CONFIGURACIÓN PARA EL ENVÍO DE LOS PÍXELES DE LA PANTALLA DE LEDS
// vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
// Este módulo puede, o bien enviar los píxeles de la imagen fragmentada
// directamente a la pantalla de leds (a través del puerto serial), o 
// bien puede enviárselos (por OSC) al módulo intermediario "Reflector" 
// para que éste se ocupe de encender/apagar los leds de la pantalla.
//  - FALSE: se envían los pixeles a la pantalla de leds (x serial)
//  - TRUE : se envían los píxeles al módulo "Reflector" (x OSC)
boolean REFLECTAR_PIXELES = true;



// PARÁMETROS PARA EL CÁLCULO DEL FLUJO OPTICO
// vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
// Valores para calcular el "flujo óptico" en la imagen de video capturada.
final float FLUJO_OPTICO_TECHO    = 30;
final int   FLUJO_OPTICO_COLUMNAS = 10;
final int   FLUJO_OPTICO_FILAS    = 10;



// VARIABLES GLOBALES PARA EL PROCESAMIENTO
// vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
// Definición de las variables para el procesamiento  de las imágenes y 
// de los transmisores para el envío de los mensajes (OSC y/o serial).
Camara camara;
Difusora difusora;
Imagista imagista;
Transformador espejo1;
Transformador espejo2;
Transformador espejo3;
Transmisor transmisorDePixeles;
TransmisorOSC transmisorDeEventos;
PImage imagenOriginal;
PImage imagenRecortada;




/**
 * settings
 * Función estándar de Processing usada para definir las dimensiones
 * de la ventana de previsualización (salida del video).
 */
void settings() {
  //size(1280, 720);
  size(VIDEO_ANCHO, VIDEO_ALTO, VIDEO_RENDERER);
}


/**
 * setup
 * Función estándar de Processing para ejecutar las tareas
 * iniciales y de configuración.
 */
void setup() {
  surface.setLocation(0, 0);
  frameRate(30);
  textureMode(NORMAL);
  colorMode(RGB, 255); 
  background(0);
      
  // 1. INICIALIZACIÓN DE OBJETOS
  // Se crean las instancias de los objetos para capturar, analizar y también
  // para crear las versiones fragmentadas de la imagen de la çamara.
  // vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv  
  camara   = new Camara(this);
  imagista = new Imagista(this, CAMARA_ANCHO, CAMARA_ALTO, FLUJO_OPTICO_COLUMNAS, FLUJO_OPTICO_FILAS);
  espejo1  = new Fragmentador(this, PROPORCION_ANCHO, PROPORCION_ALTO);
  espejo2  = new Fraccionador(this, VISTA_ANCHO / 10, VISTA_ALTO / 10);
  espejo3  = new Fragmentador(this, VISTA_ANCHO / 6, VISTA_ALTO / 6);


  // 2. INICIALIZACIÓN DE TRANSMISORES (OSC Y SERIAL)
  // Se crean las instancias de los transmistores encargados de enviar los 
  // mensajes a través del protocolo OSC y a través del puerto serial.
  // vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv  
  transmisorDeEventos = new TransmisorOSC(this, PUERTO_DEL_ESPEJADOR, IP_DEL_SONORIZADOR, PUERTO_DEL_SONORIZADOR);
  transmisorDePixeles = REFLECTAR_PIXELES ? new TransmisorOSC(this, PUERTO_DEL_ESPEJADOR, IP_DEL_REFLECTOR, PUERTO_DEL_REFLECTOR) : new TransmisorSerial(this);
  
  
  // 3. INICIALIZACIÓN DE LA TRANSMISIÓN
  // Creación de la "Difusora" para la transmisión del video generado por este 
  // módulo a través de Spout para que pueda ser, luego, mapeado y proyectado.
  // vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
  //difusora = new Difusora(this);
}


/**
 * Función estándar de Processing que se ejecuta en cada una de las
 * iteraciones del ciclo principal
 */
void draw() {
  background(0);
  if (camara.inicializada() && camara.imagenDisponible()) {
    
    // 1. PROCESAMIENTO DE LA IMAGEN DE VIDEO CAPTURADA
    // En primer lugar, se captura el fotograma actual del video de la cámara,
    // se calcula el "flujo óptico" para determinar la interacción del visitante
    // y, finalmente, se fragmenta la imagen a transmitir a la pantalla de leds.
    // vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
    camara.capturar();
    imagenOriginal  = camara.video().get(0, 0, CAMARA_ANCHO, CAMARA_ALTO);
    imagenRecortada = imagenOriginal.get(CAMARA_ANCHO/2 - REGION_DE_INTERES_ANCHO/2, 0, REGION_DE_INTERES_ANCHO, REGION_DE_INTERES_ALTO);
    imagista.procesar(imagenOriginal, FLUJO_OPTICO_TECHO);
    espejo1.procesar(imagenRecortada);
    espejo2.procesar(imagenRecortada);
    espejo3.procesar(imagenRecortada);


    // 2. ENVÍO DE MENSAJES Y COMUNICACIÓN SERIAL
    // Una vez capturada la imagen, interpretada y fragmentada, se envía la información
    // tanto al "Sonorizador" como a la "Pantalla de Leds". Esto último puede realizarse 
    // directa o indirectamente (con o sin la intervención del módulo "Reflector").
    // vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
    
    // ENVIAR MENSAJE (PÍXELES) A LA PANTALLA LED   
    if (!REFLECTAR_PIXELES && frameCount % 3 == 0) {
      // Envío directo por el puerto SERIAL (a no más de 10fps)
      transmisorDePixeles.enviar(espejo1.imagen(), MENSAJE_OSC_FOTOGRAMA);
    }
    else if (REFLECTAR_PIXELES) {
      // Envío indirecto a través del módulo intermediario del "Reflector" (OSC)
      transmisorDePixeles.enviar(espejo1.imagen(), MENSAJE_OSC_FOTOGRAMA);
    }
    
    // ENVÍO DE MENSAJES DEL FLUJO ÓPTICO AL "SONORIZADOR" (para disparar los audios)
    transmisorDeEventos.enviar(imagista.flujoOptico(), MENSAJE_OSC_FLUJO_OPTICO);
    
    
    
    // 3. RENDER DEL VIDEO DE SALIDA DEL MÓDULO
    // Se lleva a cabo el render del video de salida en la ventana principal de Processing.
    // Este video es, en realidad, un mosaico compuesto de varias vistas. A la derecha se
    // muestran las vistas finales (los "Espejos") que serán transmitidas (via "Spout"), 
    // mapeadas y proyectadas sobre las pantallas. A la izquierda, se muestran las "Vistas 
    // de Monitoreo", es decir, previsualizaciones intermedias del proceso de captura de la 
    // webcam, de su análisis y procesamiento a través de OpenCV (ej. cálculo del "Flujo 
    // Óptico") y de la fragmentación a realizar para mostrar en la "Pantalla de Leds".
    // vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
    int posColumna = 0;
    int posFilaSuperior = 0;
    int posFilaInferior = CAMARA_ALTO + SEPARADOR;
    
    // PRIMERA COLUMNA: imagen original de la webcam y "Flujo Óptico"
    image(imagenOriginal, posColumna, posFilaSuperior);
    imagista.mostrar(posColumna, posFilaInferior, FLUJO_OPTICO_TECHO);
    posColumna += imagenOriginal.width + SEPARADOR;
    
    // SEGUNDA COLUMNA: imagen recortada (región de interés) y el "Espejo 1" (la "Pantalla de Leds")
    image(imagenRecortada, posColumna, posFilaSuperior, REGION_DE_INTERES_ANCHO, REGION_DE_INTERES_ALTO);
    //((Fraccionador) espejo2).mostrarFraccionado(posColumna, posFilaSuperior);
    espejo1.mostrar(posColumna, posFilaInferior, REGION_DE_INTERES_ANCHO, REGION_DE_INTERES_ALTO);
    posColumna += REGION_DE_INTERES_ANCHO + SEPARADOR;
    
    // TERCERA COLUMNA: imagen transformada para mapear y proyectar sobre el "Espejo 2"
    espejo2.mostrar(posColumna, posFilaSuperior, VISTA_ANCHO, VISTA_ALTO);
    posColumna += VISTA_ANCHO + SEPARADOR;
    
    // CUARTA COLUMNA: imagen transformada para mapear y proyectar sobre el "Espejo 3"
    espejo3.mostrar(posColumna, posFilaSuperior, VISTA_ANCHO, VISTA_ALTO);
    
    
    
    // 4. TRANSMISIÓN DEL VIDEO GENERADO
    // Finalmente, todo el contenido del de la ventana principal de Processing (el 
    // mosaico con el video de salida) es difundido con la librería de "Spout" para
    // poder ser mapeado y proyectado sobre las pantallas.
    // vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
    //difusora.transmitir();
  }
 
}
