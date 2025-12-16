// 
// TRANSFORMADOR
// Interfaz que define las funciones básicas de los objetos
// transformadores de imágenes.
//
// vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv

interface Transformador {
  public void procesar(PImage imagen);
  public PImage imagen();
  public PImage imagenOriginal();
  public PImage salida(int ancho, int alto);
  public void mostrar(int x, int y, int ancho, int alto);
}
