// 
// PANTALLA
// Se trata de un objeto auxiliar que almacena los píxeles
// recibidos (por OSC) de la imagen fragmentada para ser
// enviados, luego, a la "Pantalla de Leds".
//
// vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv


// Dimensiones de la matriz de leds de la pantalla
final int FRAGMENTADOR_ANCHO = 11;
final int FRAGMENTADOR_ALTO  = 25;


// Dimensiones de la vista a mostrar en la previsualización
final int VISTA_ANCHO = FRAGMENTADOR_ANCHO * CAMARA_ALTO / FRAGMENTADOR_ALTO;
final int VISTA_ALTO  = CAMARA_ALTO;


// Dimensiones de cada celda (pixel) de la vista
final int FRAGMENTO_ANCHO = VISTA_ANCHO / FRAGMENTADOR_ANCHO;
final int FRAGMENTO_ALTO  = VISTA_ALTO  / FRAGMENTADOR_ALTO;



class Pantalla {
  PImage imagen;
  
  public Pantalla() {  
    imagen = createImage(FRAGMENTADOR_ANCHO, FRAGMENTADOR_ALTO, RGB);
    imagen.loadPixels();
  }
  
  public PImage imagen() {
    return imagen;
  }
  
  
  /**
   * definir
   * Calcula la posición del pixel en la pantalla (espeja la imagen) y
   * establece los valores RGB que definen el color que debe tomar el led.
   */
  public void definir(int x, int y, int rojo, int verde, int azul) {
    int indice = x + ((FRAGMENTADOR_ALTO - y - 1) * FRAGMENTADOR_ANCHO);
    imagen.pixels[indice] = color(rojo, verde, azul);
  }
  
  
  /**
   * asegurar
   * Fija los píxeles en sus posiciones correspondientes en la pantalla
   */
  public void asegurar() {
    imagen.updatePixels();
  }

  
  /**
   * mostrar
   * Dibuja la imagen fragmentada en la ventana principal de la previsualización
   * a partir de las coordenadas x e y recibidas como argumento.
   */
  void mostrar(int posX, int posY) {
    int indice = 0;
    for (int j = 0; j < FRAGMENTADOR_ALTO; j++) {
      for (int i = 0; i < FRAGMENTADOR_ANCHO; i++) {
        fill(imagen.pixels[indice]);
        strokeWeight(1);
        stroke(0);
        rect(posX + (i * FRAGMENTO_ANCHO), posY + (j * FRAGMENTO_ALTO), FRAGMENTO_ANCHO, FRAGMENTO_ALTO);
        indice++;
      }
    }
  }
  
}
