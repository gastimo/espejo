// 
// FRACCIONADOR >>> (TRANSFORMADOR)
// Objeto "transformador" que analiza y manipula la imagen capturada por
// la webcam para producir una imagen transformada ("Espejo Transformante").
// El "fraccionamiento" consiste en identificar las partes de la imagen, 
// delimitarlas y aislarlas a través del uso de los métodos de "Face 
// Recognition" de la librería OpenCV para Processing.
//
//   https://github.com/atduskgreg/opencv-processing
//
// vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv

import gab.opencv.*;
import java.awt.Rectangle;


/**
 * Fraccionador
 * Este transformador invoca a las funciones de "Face Recognition" de OpenCV para
 * generar imágenes transformadas a partir de estos estos elementos detectados.
 */
class Fraccionador extends Fragmentador implements Transformador {
  OpenCV opencv;
  Rectangle[] fragmentacion;
  
  
  public Fraccionador(PApplet contenedor, int ancho, int alto) {
    // Los argumentos de "ancho" y "alto" indican la cantidad de
    // píxeles para el "Fragmentador" y no el tamaño de la imagen.
    super(contenedor, ancho, alto);
  }


  public void procesar(PImage imagen) {
    // El objeto de OpenCV se crea recién acá, porque es recién en
    // este punto cuando se dispone de las dimensiones de la imagen
    if (opencv == null) {
      opencv = new OpenCV(obtenerContenedor(), imagen.width, imagen.height);
    }
    super.procesar(imagen);
    opencv.loadImage(imagen);
    cargarFraccionados(OpenCV.CASCADE_FRONTALFACE);
    cargarFraccionados(OpenCV.CASCADE_EYE, true);    
    cargarFraccionados(OpenCV.CASCADE_NOSE, true);
    cargarFraccionados(OpenCV.CASCADE_MOUTH, true);
  }
  
  
  private void cargarFraccionados(String selector) {
    cargarFraccionados(selector, false);
  }


  private void cargarFraccionados(String selector, boolean agregar) {
    opencv.loadCascade(selector);  
    if (!agregar) {
      fragmentacion = opencv.detect();
    }
    else {
      Rectangle[] f = opencv.detect();
      Rectangle[] todos = new Rectangle[fragmentacion.length + f.length];
      for (int i = 0; i < fragmentacion.length; i++) {
        todos[i] = fragmentacion[i];
      }      
      for (int i = 0; i < f.length; i++) {
        todos[i + fragmentacion.length] = f[i];
      }
      fragmentacion = todos;
    }
  }

  
  public Rectangle[] fragmentos() {
    return fragmentacion;
  }

  
  public void mostrarFraccionado(int x, int y) {
    mostrar(false, x, y, 0, 0, 0, 0);
  }

  
  public void mostrar(int x, int y, int ancho, int alto) {
    PImage img = imagenOriginal();
    mostrar(true, x, y, img.width, img.height, ancho, alto);
  }
  
  
  private void mostrar(boolean espejarYEscalar, int x, int y, int anchoOriginal, int altoOriginal, int anchoFinal, int altoFinal) {
    float ajusteX = 1.0;
    float ajusteY = 1.0;
    if (espejarYEscalar) {
      ajusteX = anchoFinal / anchoOriginal;
      ajusteY = altoFinal / altoOriginal;
      super.mostrar(x, y, anchoFinal, altoFinal);
    }
    push();
    noFill();
    stroke(0);
    stroke(0, 255, 0);
    strokeWeight(3);
    for (int i = 0; i < fragmentacion.length; i++) {
      float fragX = fragmentacion[i].x * ajusteX;
      float fragY = fragmentacion[i].y * ajusteY;
      float fragAncho = fragmentacion[i].width * ajusteX;
      float fragAlto  = fragmentacion[i].height * ajusteY;
      rect(x + (espejarYEscalar ? anchoFinal - fragX - fragAncho : fragX), y + fragY, fragAncho, fragAlto);
    }
    pop();
  } 
}
