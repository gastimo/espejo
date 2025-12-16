#include <Adafruit_NeoPixel.h>

#define FRAGMENTADOR_ANCHO 11
#define FRAGMENTADOR_ALTO 25
#define MAX_BRILLO 255
#define MAX_POSICION 25
#define NULL_POSICION 99
#define VELOCIDAD 115200
#define PIN_LED 6

int posX = 0;
int posY = 0;
int cantPixeles = FRAGMENTADOR_ANCHO * FRAGMENTADOR_ALTO;
float maxBrilloR = 17;
float maxBrilloG = 18;
float maxBrilloB = 20;
int valorR = int(maxBrilloR);
int valorG = int(maxBrilloG);
int valorB = int(maxBrilloB);
byte datos[5];
Adafruit_NeoPixel strip(cantPixeles, PIN_LED, NEO_GRB + NEO_KHZ800);


void setup() {
  Serial.begin(VELOCIDAD);  // Debe coincidir con la velocidad definida en Processing
  strip.begin(); 
  strip.fill(strip.Color(0,0,0)); 
  strip.show();
}

void loop() {
  int indice = 0;
  while (Serial.available() > 0) {
    int bytesLeidos = Serial.readBytes(datos, 5);
    if (bytesLeidos == 5) {
      posX = int(datos[0]);
      posY = int(datos[1]);
      if (posX < MAX_POSICION && posY < MAX_POSICION) {
        valorR = int(datos[2]) * maxBrilloR / MAX_BRILLO;
        valorG = int(datos[3]) * maxBrilloG / MAX_BRILLO;
        valorB = int(datos[4]) * maxBrilloB / MAX_BRILLO;
        indice = (posX * FRAGMENTADOR_ALTO) + posY;
        strip.setPixelColor(indice, strip.Color(valorR, valorG, valorB));
      }
      else if (posX == NULL_POSICION && posY == NULL_POSICION) {
        strip.fill(strip.Color(0,0,0)); 
        strip.show();
        break;
      }
      else {
        strip.show();
        break;
      }
    }
  }
}