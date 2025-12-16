// 
// FRACTURADOR >>> (TRANSFORMADOR)
// Objeto transformador que analiza y manipula la imagen capturada por la
// webcam para producir una imagen transformada ("Espejo Transformante").
// La fractura consiste en el armado de un mosaico con las partes del  
// de la imagen original.
//
//   https://github.com/atduskgreg/opencv-processing
//
// vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv

import gab.opencv.*;
import java.awt.Rectangle;


/**
 * Fracturador
 * Componente responsable de interpretar las imágenes de video capturadas 
 * por la cámara para producir los reflejos fracturados ("espejos transformantes").
 * Este transformador invoca a las funciones de "Face Recognition" de OpenCV para
 * generar imágenes fragmentadas a partir de estos estos elementos detectados.
 */
class Fracturador {
  OpenCV opencv;
  Fragmentador fragmentador;
  Rectangle[] fragmentacion;

  public Fracturador(PApplet contenedor, int ancho, int alto, Fragmentador frag) {
    opencv = new OpenCV(contenedor, ancho, alto);
    fragmentador = frag;
  }

  public void procesar(PImage imagen) {
    opencv.loadImage(imagen);
    cargarFragmentos(OpenCV.CASCADE_FRONTALFACE);
    cargarFragmentos(OpenCV.CASCADE_EYE, true);    
    cargarFragmentos(OpenCV.CASCADE_NOSE, true);
    cargarFragmentos(OpenCV.CASCADE_MOUTH, true);
  }

  
  private void cargarFragmentos(String selector) {
    cargarFragmentos(selector, false);
  }


  private void cargarFragmentos(String selector, boolean agregar) {
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


  public void mostrar(int x, int y) {
    mostrar(null, x, y, 0, 0, 0, 0);
  }

  
  public void mostrar(PImage imagen, int x, int y, int anchoOriginal, int altoOriginal, int anchoFinal, int altoFinal) {
    float ajusteX = 1.0;
    float ajusteY = 1.0;
    boolean espejar = false;
    
    push();
    noFill();
    stroke(0);
    if (imagen != null) {
      espejar = true;
      ajusteX = anchoFinal / anchoOriginal;
      ajusteY = altoFinal / altoOriginal;
      fragmentador.mostrar(x, y, anchoFinal, altoFinal);
    }
    stroke(0, 255, 0);
    strokeWeight(3);   
    for (int i = 0; i < fragmentacion.length; i++) {
      float fragX = fragmentacion[i].x * ajusteX;
      float fragY = fragmentacion[i].y * ajusteY;
      float fragAncho = fragmentacion[i].width * ajusteX;
      float fragAlto  = fragmentacion[i].height * ajusteY;
      rect(x + (espejar ? anchoFinal - fragX - fragAncho : fragX), y + fragY, fragAncho, fragAlto);
    }
    pop();
  } 
}
