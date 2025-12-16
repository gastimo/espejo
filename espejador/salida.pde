// 
// SALIDA
// Contenedor para el dibujo de una región del video de salida.
//
// vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv

final int DURACION_ACTIVACION = 2600;

class Salida {
  int identificador;
  int ancho, alto;
  int inicioActivacion = 0;
  int finActivacion = 0;
  PGraphics salidaShader;
  PShader shader;
  Fragmentador frag;
  
  public Salida() {
    this(0, width, height);
  }
  
  public Salida(Fragmentador fragmentador, int salidaAncho, int salidaAlto) {
    this(0, salidaAncho, salidaAlto);
    frag = fragmentador;
  }
  
  public Salida(int salidaAncho, int salidaAlto) {
    this(0, salidaAncho, salidaAlto);
  }    
      
  public Salida(int id, int salidaAncho, int salidaAlto) {
    identificador = id;
    ancho = salidaAncho;
    alto = salidaAlto;
    shader = loadShader("shader.txt");
    salidaShader= createGraphics(salidaAncho, salidaAlto, VIDEO_RENDER);
  }
  
  
  public void mostrar(int x, int y) {
    if (frag != null) {
      mostrar(frag.salida(ancho, alto), x, y);
    }
  }
  
  
  private void mostrar(PImage imagen, int x, int y) {
    shader.set("resolution", (float) ancho, (float) alto);
    shader.set("texture0", imagen);
    
    // Dibujo el contenido de la pantalla con el shader
    salidaShader.beginDraw();
    salidaShader.background(0);
    salidaShader.shader(shader);
    salidaShader.endDraw();
  
    // Finalmente, vuelvo la salida del shader en la ventana
    image(salidaShader, x, y, ancho, alto);
  }
  
  public void procesar() {
    if (inicioActivacion > 0 && millis() > finActivacion) {
      desactivar();
    }
  }
  
  public boolean estaActiva() {
      return millis() <= finActivacion && inicioActivacion > 0;
  }
  
  public void activar() {
    inicioActivacion = millis();
    finActivacion = inicioActivacion + DURACION_ACTIVACION;
  }
  
  public void desactivar() {
    inicioActivacion  = 0;
    finActivacion = 0;
  }
  
}
