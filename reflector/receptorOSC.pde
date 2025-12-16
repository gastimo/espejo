// 
// RECEPTOR OSC
// Funciones de inicialización de los servicios de comunicación
// mediante el protocolo de red OSC (Open Sound Protocol).
// Se utiliza la librería "oscP5" de Andreas Schelegel:
//
//   https://sojamo.de/libraries/oscp5/
//
// vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
import oscP5.*;
import netP5.*;

class ReceptorOSC {
  OscP5 oscP5;
  boolean inicializado = false;
  
  public ReceptorOSC(PApplet contenedor, int puertoLocal) {
    oscP5 = new OscP5(contenedor, puertoLocal);
    inicializado = true;
  }
}
