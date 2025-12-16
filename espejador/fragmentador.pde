// 
// FRAGMENTADOR >>> (TRANSFORMADOR)
// Objeto responsable de realizar la fragmentación de la imagen
// capturada en vivo, para desplegarla en el "Espejo de Leds".
//
// vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv


// Constantes con valores predefinidos para la fragmentación
final int FRAG00_TINTE      = 0;
final int FRAG00_SATURACION = 0;
final int FRAG00_BRILLO     = 0;

final int FRAG01_TINTE      = 21;
final int FRAG01_SATURACION = 75;
final int FRAG01_BRILLO     = -2;
        
final int FRAG02_TINTE      = 104;
final int FRAG02_SATURACION = 55;
final int FRAG02_BRILLO     = -8;

final int FRAG03_TINTE      = 221;
final int FRAG03_SATURACION = 65;
final int FRAG03_BRILLO     = -24;

final int FRAG04_TINTE      = 3;
final int FRAG04_SATURACION = -61;
final int FRAG04_BRILLO     = -18;

final int FRAG05_TINTE      = 78;
final int FRAG05_SATURACION = 93;
final int FRAG05_BRILLO     = -15;

final int FRAG06_TINTE      = 13;
final int FRAG06_SATURACION = 52;
final int FRAG06_BRILLO     = -11;


/**
 * Fragmentador
 * Clase para fragmentar (reducir a cuadros o píxeles) una imagen. 
 */
class Fragmentador implements Transformador {
  PApplet ventana;
  int cuadrosAncho, cuadrosAlto;
  int anchoFragmento, altoFragmento;
  int ajusteTinte, ajusteSaturacion, ajusteBrillo;
  PImage imagenBase;
  PImage imagenFragmentada;
  PGraphics imagenSalida;
  boolean actualizarSalida = true;
  int salidaAncho = 0;
  int salidaAlto = 0;
  

  /**
   * constructor
   * El constructor de la clase recibe el tamaño final en píxeles
   * (ancho y alto) que tendrá la imagen fragmentada. La imagen a
   * fragmentar se indica en la invocación del método "procesar".
   */
  public Fragmentador(PApplet contenedor, int ancho, int alto) {
    ventana          = contenedor;
    cuadrosAncho     = ancho;
    cuadrosAlto      = alto;
    anchoFragmento   = 1;
    altoFragmento    = 1;
    ajusteTinte      = FRAG00_TINTE;
    ajusteSaturacion = FRAG00_SATURACION;
    ajusteBrillo     = FRAG00_BRILLO;
  }

  public Fragmentador() {
    this(null, 0, 0);
  }
  
  
  /**
   * procesar
   * Crear una imagen como una versión pixelada de la imagen recibida como argumento. 
   * El tamaño de los píxeles dependen del ancho y el alto indicados en el constructor.
   * La imagen es, además, reflejada horizontalmente para que funcione como "espejo".
   * Adicionalmente, el color de los pixeles son manipulados según la configuración 
   * del "Fragmentador" (se modifica el tinte, la saturación y el brillo).
   */
  public void procesar(PImage imagen) {
    int indice = 0;
    int ancho_fragmento = imagen.width  / cuadrosAncho;
    int alto_fragmento  = imagen.height / cuadrosAlto;
    imagenBase = imagen;
    imagenFragmentada = createImage(cuadrosAncho, cuadrosAlto, RGB);
    imagenFragmentada.loadPixels();
    
    push();
    colorMode(HSB, 360, 100, 100);
    for (int j = 0; j < cuadrosAlto; j++) {
      for (int i = cuadrosAncho - 1; i >= 0; i--) {
        color colorPixel = imagen.get((i * ancho_fragmento) + (ancho_fragmento/2), (j * alto_fragmento) + (alto_fragmento/2));
        boolean esFondo = saturation(colorPixel) < 13 || brightness(colorPixel) < 12;
        float colorTinte      = ajusteTinte == 0      ? hue(colorPixel) : esFondo ? (hue(colorPixel) + 172 + ajusteTinte/2) % 360 : (hue(colorPixel) + ajusteTinte) % 360;
        float colorSaturacion = ajusteSaturacion == 0 ? constrain(saturation(colorPixel) * 2, 0, 100) : 
                                                        esFondo ? constrain(ajusteSaturacion - 10, 0, 100) : constrain(ajusteSaturacion, 0, 100);
        float colorBrillo     = ajusteBrillo == 0     ? constrain(brightness(colorPixel) * 0.82, 0, 100) : 
                                                        esFondo ? constrain(brightness(colorPixel/10) + (ajusteBrillo*1.5), 0, 100) : constrain(brightness(colorPixel) + (ajusteBrillo*2), 0, 100);
        colorPixel = color(int(colorTinte), int(colorSaturacion), int(colorBrillo));   
        imagenFragmentada.pixels[indice++] = colorPixel;
      }
    }
    imagenFragmentada.updatePixels();
    actualizarSalida = true;
    pop();
  }
  
  
  /**
   * imagen
   * Retorna el resultado del procesamiento de la imagen original
   * en la forma de otra imagen (PImage) transformada.
   */ 
  public PImage imagen() {
    return imagenFragmentada;
  }


  /**
   * imagenOriginal
   * Retorna la imagen original que se le pasó al método procesar
   * pero sin haberle realizado ninguna transformación.
   */
  public PImage imagenOriginal() {
    return imagenBase;
  }



  /**
   * mostrar
   * Dibuja la imagen fragmentada en la ventana principal a partir de las
   * coordenadas <x,y> recibidas como argumento. Básicamente, escala la
   * imagen fragmentada para dibujarla del ancho y alto indicados, 
   * dibujando cada pixel como un rectángulo de color sólido.
   */
  void mostrar(int posX, int posY, int ancho, int alto) {
    actualizarSalida(ancho, alto);
    image(salida(ancho, alto), posX, posY, ancho, alto);
  }
  
  
  /**
   * salida
   * Retorna una imagen (PImage) con la imagen fragmentada (pixelada) pero
   * escalada a los valores de ancho y alto recibidos como argumento.
   */
  public PImage salida(int ancho, int alto) {
    actualizarSalida(ancho, alto);
    return imagenSalida.get();
  }
  
  
  /**
   * actualizarSalida
   * Método privado que actualiza los píxeles de la imagen fragmentada de salida
   * (escalada) en caso que no se haya realizado después de la última vez que se 
   * ejecutó la función "procesar" o que las dimensiones hayan variado. 
   */
  private void actualizarSalida(int ancho, int alto) {
    inicializarSalida(ancho, alto);
    if (actualizarSalida) {
      push();
      int indice = 0;
      imagenSalida.beginDraw();
      imagenSalida.background(0);
      for (int j = 0; j < cuadrosAlto; j++) {
        for (int i = 0; i < cuadrosAncho; i++) {
          imagenSalida.fill(imagenFragmentada.pixels[indice]);
          imagenSalida.strokeWeight(1);
          imagenSalida.stroke(0);
          imagenSalida.rect(i * anchoFragmento, j * altoFragmento, anchoFragmento, altoFragmento);
          indice++;
        }
      }
      imagenSalida.endDraw();
      actualizarSalida = false;
      pop();
    }
  }
  
  
  /**
   * inicializarSalida
   * Verifica si la imagen fragmentada de salida debe ser incializada,
   * ya sea por tratarse de la primera vez o porque el ancho o la altura
   * indicados son diferentes o los pedidos anteriormente.
   */
  private void inicializarSalida(int ancho, int alto) {
    if (salidaAncho == 0 || salidaAlto == 0 ||
        salidaAncho != ancho || salidaAlto != alto) {
      salidaAncho = ancho;
      salidaAlto = alto;
      anchoFragmento = ancho / cuadrosAncho;
      altoFragmento  = alto  / cuadrosAlto;
      imagenSalida = createGraphics(ancho, alto, VIDEO_RENDER);
      actualizarSalida = true;
    }
  }
  
  
  /**
   * configurar
   * Modifica los parámetros de la configuración del "Fragmentador" relacionados
   * con los ajustes del color de cada pixel de la imagen (se guardan coeficientes
   * que alteran el tinte, la saturación y el brillo de cada pixel) organizados
   * en diferentes configuraciones pre-establecidas.
   */
  void configurar(char modo) {
    if (modo == '0') {
      ajusteTinte      = FRAG00_TINTE;
      ajusteSaturacion = FRAG00_SATURACION;
      ajusteBrillo     = FRAG00_BRILLO;
    }    
    else if (modo == '1') {
      ajusteTinte      = FRAG01_TINTE;
      ajusteSaturacion = FRAG01_SATURACION;
      ajusteBrillo     = FRAG01_BRILLO;
    }
    else if (modo == '2') {
      ajusteTinte      = FRAG02_TINTE;
      ajusteSaturacion = FRAG02_SATURACION;
      ajusteBrillo     = FRAG02_BRILLO;
    }
    else if (modo == '3') {
      ajusteTinte      = FRAG03_TINTE;
      ajusteSaturacion = FRAG03_SATURACION;
      ajusteBrillo     = FRAG03_BRILLO;
    }
    else if (modo == '4') {
      ajusteTinte      = FRAG04_TINTE;
      ajusteSaturacion = FRAG04_SATURACION;
      ajusteBrillo     = FRAG04_BRILLO;
    }
    else if (modo == '5') {
      ajusteTinte      = FRAG05_TINTE;
      ajusteSaturacion = FRAG05_SATURACION;
      ajusteBrillo     = FRAG05_BRILLO;
    }
    else if (modo == '6') {
      ajusteTinte      = FRAG06_TINTE;
      ajusteSaturacion = FRAG06_SATURACION;
      ajusteBrillo     = FRAG06_BRILLO;
    }
  }
}
