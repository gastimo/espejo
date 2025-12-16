// 
// TRANSMISOR
// Interfaz que define los métodos básicos apra los objetos transmisores 
// de datos (salientes y entrantes) ya sea a través del protocolo OSC  
// (Open Sound Control) o del puerto serial de comunicación.
//
// vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv

// Constantes para la transmisión
final int CODIGO_FIN_DE_CUADRO = 25;


interface Transmisor {
  
  public void enviar(PImage imagen,  String direccion);
  public void enviar(byte[] paquete, String direccion);

}
