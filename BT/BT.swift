import SwiftUI

struct BT: View {
    
    @ObservedObject var bleManager = BLEManager()
    
    var body: some View {
        
        VStack (spacing: 10) {

            if(!bleManager.connected) {
                Text("Wearables")
                    .font(.largeTitle)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            
            if(!bleManager.connected) {
                List(bleManager.peripherals) { peripheral in
                    
                    HStack {
                        Button(action: {
                            bleManager.connect(periph: peripheral.periph)
                        }) {
                            Text(peripheral.name)
                        }
                        Spacer()
    //                    Text(String(peripheral.rssi))
                    }
                }.frame(height: 300)
            }
            
            Spacer()
            
            if(bleManager.connected) {
                let data = bleManager.data
                
//                Text(data)
//                    .foregroundColor(.white)
                
                let x = Float(data.split(separator: "~")[0])!
                let y = Float(data.split(separator: "~")[1])!
                let z = Float(data.split(separator: "~")[2])!
                let nx = -1 * x
                let y2 = y * y
                let z2 = z * z
                let syz = sqrt(y2 + z2)

                let roll = abs(atan2(y, z) * 57.3)
                let pit = abs(atan2(nx, syz) * 57.3)
                
                Text("Connected to wearable")
                    .foregroundColor(.white)
                    .font(.largeTitle)
                Spacer()
                
                VStack {
                    
                    Text("X: \(x, specifier: "%.1f")")
                        .foregroundColor(.white)
                        .font(.largeTitle)
                    Spacer()

                    Text("Y: \(y, specifier: "%.1f")")
                         .foregroundColor(.white)
                         .font(.largeTitle)
                    Spacer()

                    Text("Z: \(z, specifier: "%.1f")")
                         .foregroundColor(.white)
                         .font(.largeTitle)
                    Spacer()

                    Text("Roll: \(roll, specifier: "%.1f")")
                         .foregroundColor(.white)
                         .font(.largeTitle)
                    Spacer()

                    Text("Pitch: \(pit, specifier: "%.1f")")
                          .foregroundColor(.white)
                          .font(.largeTitle)
                }
            }

            Spacer()
            
            if(bleManager.isSwitchedOn && !bleManager.connected) {
                Button(action: {
                    self.bleManager.startScanning()
                })
                {
                    Text("Scan")
                        .foregroundColor(bleManager.isScanning == true ? .green : .blue)
                        .font(.largeTitle)
                }
                Spacer()

            }
        }
    }
}
