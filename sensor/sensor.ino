#include <ArduinoBLE.h>

#include "LSM6DS3.h"

//Create a instance of class LSM6DS3

LSM6DS3 myIMU(I2C_MODE, 0x6A);    //I2C device address 0x6A


BLEService ledService ("19B10000-E8F2-537E-4F6C-D104768A1214"); // Bluetooth® Low Energy LED Service
BLEStringCharacteristic switchCharacteristic ("19B10001-E8F2-537E-4F6C-D104768A1214", BLERead | BLEWrite | BLENotify, 20);

String full_string;


void setup() {

    //Call .begin() to configure the IMUs

    if (myIMU.begin() != 0) {

        Serial.println("Device error");

    } else {

        Serial.println("Device OK!");

    }

    if (!BLE.begin()) {

      Serial.println("starting Bluetooth® Low Energy module failed!");

      while (1);

  }

     BLE.setLocalName("LED");

     BLE.setAdvertisedService(ledService);
     ledService.addCharacteristic(switchCharacteristic);
     BLE.addService(ledService);
     BLE.advertise();
}

 

void loop() {

 
  BLEDevice central = BLE.central();

  if (central) {

    Serial.print("Connected to central: ");

 
  while (central.connected()) {

    full_string = String(myIMU.readFloatAccelX()) + "~" + String(myIMU.readFloatAccelY()) + "~" + String(myIMU.readFloatAccelZ());

    switchCharacteristic.setValue(full_string);

    
  }

  }
 
    Serial.print(F("Disconnected from central: "));
    Serial.println(central.address());

    delay(200);

}
