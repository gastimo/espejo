// 
// TRANSMISOR SERIAL
// Funciones de inicialización del puerto serial de comunicación
// y de envío de datos a través de este mismo puerto.
// Se utiliza la libreria "Serial" de Processing:
//
//   https://processing.org/reference/libraries/serial/index.html
//
// vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
import processing.serial.*;

// Constantes para la serialización
int TASA_TRANSFERENCIA = 115200;


class TransmisorSerial implements Transmisor {
  Serial puertoSerial;
  String conexion = null;
  boolean inicializado = false;
  byte[] datos = {0x00, 0x00, 0x00, 0x00, 0x00};
  
  public TransmisorSerial(PApplet contenedor) {
    String[] puertos = Serial.list();
    for (int i = 0; i < puertos.length; i++) {
      println("PUERTOS SERIALES DETECTADOS=" + puertos[i]);
      if (puertos.length > 0 && puertos[i].startsWith("/dev/ttyUSB")) {
        conexion = Serial.list()[i];
        break;
      }
    }
    
    if (conexion == null && puertos.length > 0) {
      conexion = Serial.list()[0];
    }

    if (conexion != null) {
      // CREACIÓN DEL PUERTO 
      // Se crea un puerto serial que debe ser el mismo que el puerto
      // donde está conectado el Arduino. La velocidad de transferencia
      // también debe coincidir en ambos casos.
      puertoSerial = new Serial(contenedor, conexion, TASA_TRANSFERENCIA);
      
      
      // TASA DE TRANSFERENCIA
      // La matriz de "pixel leds" tiene en total 275 leds y por cada uno
      // de ellos se indican sus valores de rojo, verde y azul, que ocupan
      // un byte por canal. Además, por cada pixel se envía también su 
      // posición <X,Y> en la matriz (un byte adicional por coordenada).
      // En resumen, se envía un paquete de 5 bytes por pixel.
      //
      //              275 * 5 * 8 = 11.600 bits/frame
      //
      // Es decir, enviar un único fotograma consume 11.600 bits de la tasa
      // de transferencia. Por lo tanto, a una velocidad de 115.200 bits por 
      // segundo, la tasa de fps debería ser inferior a los 10fps.
      // 
      //    10 frames/seg. x 11.600 bits/frame = 116.000 bits/seg.
      //
      inicializado = true;
      println("PUERTO SERIAL CONECTADO");
    }
    
    if (!inicializado) {
      println("No se detectó ningún puerto.");
    } 
  }
  
  private void enviar(byte[] datos) {
    if (inicializado) {
      puertoSerial.write(datos);
    }
  }
  
  public void enviar(byte[] paquete, String dirección) {
    enviar(paquete);
  }

  
  /**
   * enviar
   * Envia los valores de cada uno de los píxeles de la imagen (fragmentada)
   * recibida como argumento. Por cada pixel de la imagen se envía un paquete
   * de 5 bytes, según la siguiente especificación:
   *   - BYTE #0: Coordenada X (entre 0 y 10)
   *   - BYTE #1: Coordenada Y traspuesta (entre 0 y 24)
   *   - BYTE #2: Valor numérico para el canal rojo del color del pixel
   *   - BYTE #3: Valor numérico para el canal verde del color del pixel
   *   - BYTE #4: Valor numérico para el canal azul del color del pixel
   */
  public void enviar(PImage imagen, String direccion) {
    int indice = 0;
    for (int i = 0; i < imagen.width; i++) {
      for (int j = imagen.height - 1; j >= 0; j--) {
        indice = i + (j * imagen.width);
        color colorPixel = imagen.pixels[indice];
        int pixelX = i;
        int pixelY = imagen.height - j - 1;
        datos[0] = byte(pixelX);
        datos[1] = byte(pixelY);
        datos[2] = byte(red(colorPixel));
        datos[3] = byte(green(colorPixel));
        datos[4] = byte(blue(colorPixel));
        enviar(datos);
      }
    }
    enviarFinDeCuadro();
  }  
  
  
  /**
   * enviarFinDeCuadro
   * Envía un paquete de 5 bytes para indicar que ya fueron
   * transmitidos todos los pixels de la imagen.
   */
  public void enviarFinDeCuadro() {
    datos[0] = byte(CODIGO_FIN_DE_CUADRO);
    datos[1] = byte(CODIGO_FIN_DE_CUADRO);
    datos[2] = byte(0);
    datos[3] = byte(0);
    datos[4] = byte(0);
    enviar(datos);
  }
}
