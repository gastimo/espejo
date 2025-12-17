// 
// VIDEO
// 
//
// vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv

class Salida {
  
  // RENDER POR DEFECTO PARA LA GENERACIÓN DEL VIDEO
  // vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
  // Por defecto, Processing utiliza el "render built-in" de Java (JAVA2D).
  // Para poder utilizar "Spout" o cualquier función que requiera hacer uso del
  // procesador gráfico (OpenGL o gráficos 3D) se requiere usar P2D o P3D
  String VIDEO_RENDER = JAVA2D;
  
  
  // REGIÓN DE INTERÉS
  // vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
  // La región de interés es el área central de la imagen capturada por la cámara
  // con la cual se trabaja verdaderamente. El video de la webcam tiene orientación
  // horizontal. La región de interés es el recorte central para volverlo vertical.
  int REGION_DE_INTERES_ANCHO = PROPORCION_ANCHO * CAMARA_ALTO / PROPORCION_ALTO;
  int REGION_DE_INTERES_ALTO  = CAMARA_ALTO;
  
  
  // VISTA
  // vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
  // La vista dentro de la ventana de Processing representa el contenido a mostrar
  // o proyectar en cada pantalla. Hay 3 vistas, una por cada espejo del tríptico:
  // - La vista del "Fragmentador": Espejo central del tríptico (pantalla de leds)
  // - La vista del "Fraccionador": Espejo lateral izquierdo del tríptico
  // - La vista del "Fracturador" : Espejo lateral derecho del tríptico
  int VISTA_ALTO;
  int VISTA_ANCHO;
  
  
  // VIDEO
  // vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
  // Define las dimensiones total de la ventana de Processing (el video a generar)
  int VIDEO_ANCHO;
  int VIDEO_ALTO;


  // SEPARADOR
  // vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
  // Es el espaciado entre cada una de las vistas
  int SEPARADOR;



  public Salida(boolean monitoreo) {
    if (monitoreo) {
      SEPARADOR = 6;
      VISTA_ALTO  = CAMARA_ALTO * 2;
      VISTA_ANCHO = VISTA_ALTO * PROPORCION_ANCHO / PROPORCION_ALTO;
      VIDEO_ANCHO = CAMARA_ANCHO + REGION_DE_INTERES_ANCHO + (VISTA_ANCHO * 2) + (SEPARADOR * 3);
      VIDEO_ALTO  = VISTA_ALTO + SEPARADOR;
    }
    else {
      SEPARADOR = 12;
      VISTA_ALTO  = 960;
      VISTA_ANCHO = VISTA_ALTO * PROPORCION_ANCHO / PROPORCION_ALTO;
      VIDEO_ANCHO = 1820; //(VISTA_ANCHO * 3) + (SEPARADOR * 2);
      VIDEO_ALTO  = 1140; //VISTA_ALTO;
    }
  }
}
