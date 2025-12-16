// 
// TRANSMISOR OSC
// Objeto a cargo de la inicialización de los servicios de envío y
// recepción de mensajes mediante el protocolo de red OSC (Open Sound
// Control). Utiliza la librería "oscP5" de Andreas Schelegel:
//
//   https://sojamo.de/libraries/oscp5/
//
// vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
import oscP5.*;
import netP5.*;

OscP5 oscP5;
int puertoEntrante = 0;
boolean oscInicializado = false;

class TransmisorOSC implements Transmisor {  
  NetAddress direccionRemota;
  NetAddress direccionAdicional;
  OscMessage mensajeOSC;
  byte[] datos = {0x00, 0x00, 0x00, 0x00, 0x00};
  byte paquete[] = new byte[825];
  boolean replicador = false;

  
  public TransmisorOSC(PApplet contenedor) {
    this(contenedor, 12000, "127.0.0.1", 12001);
  }

  public TransmisorOSC(PApplet contenedor, int puertoLocal, String ipDestino, int puertoDestino) {
    if (!oscInicializado) {
      oscP5 = new OscP5(contenedor, puertoLocal);
      puertoEntrante = puertoLocal;
      oscInicializado = true;
    }
    else {
      if (puertoEntrante != puertoLocal) {
        println("Error creando transmisor OSC para el puerto " + puertoLocal + 
                ". El servidor ya se encuentra escuchando en el puerto " + puertoEntrante);
      }
    }
    direccionRemota = new NetAddress(ipDestino, puertoDestino);
  }
  
  public TransmisorOSC replicar(String ipDestino, int puertoDestino) {
    direccionAdicional = new NetAddress(ipDestino, puertoDestino);
    replicador = true;
    return this;
  }
  
  
  public void enviar(byte[] paquete, String direccion) {
    if (oscInicializado) {
      mensajeOSC = new OscMessage(direccion);
      mensajeOSC.add(paquete);
      oscP5.send(mensajeOSC, direccionRemota);
      if (replicador) {
        oscP5.send(mensajeOSC, direccionAdicional);
      }
    }
  }  
  
  public void enviar(float[][] matriz, String direccion) {
    OscMessage mensaje;
    if (oscInicializado) {
      mensaje = new OscMessage(direccion);
      for (int i = 0; i < matriz.length; i++) {
        for (int j = 0; j < matriz[i].length; j++) {
          mensaje.add(matriz[i][j]);
        }
      }
      oscP5.send(mensaje, direccionRemota);
      if (replicador) {
        oscP5.send(mensaje, direccionAdicional);
      }
    }
  }

        
  /**
   * enviar
   * Envia los valores de cada uno de los píxeles de la imagen (fragmentada)
   * recibida como argumento. El mensaje OSC se construye como un tipo de dato 
   * BLOB, colocando en orden y en secuencia los 3 bytes de los canales RGB de
   * cada uno de los píxeles de la imagen. Es decir, el paquete de datos del 
   * mensaje OSC tiene un tamaño de 825 bytes (3 bytes/pixel x 275 pixels). 
   * Por ejemplo, los primeros 6 bytes serían:
   *   PAQUETE[0] = canal "Rojo" del pixel  "0"
   *   PAQUETE[1] = canal "Verde" del pixel "0"
   *   PAQUETE[2] = canal "Azul" del pixel  "0"
   *   PAQUETE[3] = canal "Rojo" del pixel  "1"
   *   PAQUETE[4] = canal "Verde" del pixel "1"
   *   PAQUETE[5] = canal "Azul" del pixel  "1"
   *   ...
   */
  void enviar(PImage imagen, String direccion) {
    int indice = 0;
    int contador = 0;
    for (int i = 0; i < imagen.width; i++) {
      for (int j = imagen.height - 1; j >= 0; j--) {
        indice = i + (j * imagen.width);
        color colorPixel = imagen.pixels[indice];
        paquete[contador++] = byte(red(colorPixel));
        paquete[contador++] = byte(green(colorPixel));
        paquete[contador++] = byte(blue(colorPixel));
      }
    }
    enviar(paquete, direccion);
  }
  
  
  public void enviarFinDeCuadro() {
    datos[0] = byte(CODIGO_FIN_DE_CUADRO);
    datos[1] = byte(CODIGO_FIN_DE_CUADRO);
    datos[2] = byte(0);
    datos[3] = byte(0);
    datos[4] = byte(0);
    enviar(datos, MENSAJE_OSC_CIERRE);
  }
  
}
