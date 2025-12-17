// 
// FRACTURADOR >>> (TRANSFORMADOR)
// Objeto "transformador" que analiza y manipula la imagen capturada por
// la webcam para producir una imagen transformada ("Espejo Transformante").
// La "Fractura" consiste en el armado de un mosaico con las partes del  
// de la imagen original, identificadas por el "Fraccionador" a través de
// la funciones de "Face Recognition" de OpenCV.
//
//   https://github.com/atduskgreg/opencv-processing
//
// vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv

import java.awt.Rectangle;


/**
 * Fracturador
 * Componente responsable de interpretar las imágenes de video capturadas 
 * por la cámara para producir los reflejos fracturados ("espejos transformantes").
 * Este transformador invoca a las funciones de "Face Recognition" de OpenCV para
 * generar imágenes fragmentadas a partir de estos estos elementos detectados.
 */
class Fracturador implements Transformador {
  Fraccionador fracc;
  int factorEscala;
  PApplet ventana;
  PImage imagenBase;
  PImage imagenFracturada;
  PGraphics imagenSalida;
  boolean actualizarSalida = true;
  int salidaAncho = 0;
  int salidaAlto = 0;

 
  public Fracturador(Fraccionador fraccionador, int escala) {
    fracc = fraccionador;
    ventana = fraccionador.obtenerContenedor();
    factorEscala = escala;
  }

  public void procesar(PImage imagen) {
    imagenBase = imagen;
  }

  public void mostrar(int x, int y, int ancho, int alto) {
      int ultimaFila = mostrar(x, y, ancho, alto, 1, 0, 0);
      if (ultimaFila < alto) {
        mostrar(x, y, ancho, alto, 1, 0, ultimaFila);
      }
  }
  
  private int mostrar(int x, int y, int ancho, int alto, int iteracion, int indice, int filaIni) {
    PImage img = imagenBase;
    float ajusteX = ancho / img.width;
    float ajusteY = alto / img.height;
    int   columna = 0;
    int   fila = filaIni;
    Rectangle[] fragmentacion = fracc.fragmentos();
    
    push();
    noFill();
    stroke(0);
    stroke(0);
    strokeWeight(10);
    for (int i = indice; i < fragmentacion.length; i++) {
      PImage f = img.get(fragmentacion[i].x, fragmentacion[i].y, fragmentacion[i].width, fragmentacion[i].height);
      int anchoF = int(f.width * ajusteX);
      int altoF  = int(f.height * ajusteY);
      if (anchoF < ancho * 0.4) {
        anchoF *= 2.3;
        altoF  *= 2.3;
      }
      if (fila + altoF > alto) {
        mostrar(x + columna + anchoF, y, ancho, alto, 1, i+1, 0);
        break;
      }
      if (columna + anchoF > ancho) {
        mostrar(x, y + fila, ancho, alto, 1, i+1, fila);
        break;
      }
      Fragmentador frag = new Fragmentador(ventana, anchoF / factorEscala, altoF / factorEscala);
      frag.procesar(f);
      image(frag.salida(anchoF, altoF), x + columna, y + fila, anchoF, altoF);
      rect(x + columna, y + fila, anchoF, altoF);
      if (iteracion > 0) {
        mostrar(x + columna + anchoF, y + fila, ancho, alto, iteracion - 1, i+1, fila);
      }
      fila += altoF;
    }
    pop();
    return fila;
  }  
  
  
  /**
   * imagen
   * Retorna el resultado del procesamiento de la imagen original
   * en la forma de otra imagen (PImage) transformada.
   */ 
  public PImage imagen() {
    return imagenFracturada;
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
   * salida
   * Retorna una imagen (PImage) con la imagen fragmentada (pixelada) pero
   * escalada a los valores de ancho y alto recibidos como argumento.
   */
  public PImage salida(int ancho, int alto) {
    return imagenSalida.get();
  }


}
