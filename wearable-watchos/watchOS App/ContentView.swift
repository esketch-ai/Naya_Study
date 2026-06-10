import SwiftUI

struct ContentView: View {
    @StateObject private var bleManager = BleManager.shared
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.black, Color.gray.opacity(0.8)]),
                          startPoint: .top, endPoint: .bottom)
            
            VStack(spacing: 20) {
                Text("Naya Watch")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                
                if bleManager.isConnected {
                    Text("Connected ✓")
                        .font(.headline)
                        .foregroundColor(.green)
                    
                    Text("Heart Rate: \(bleManager.heartRate ?? "N/A") bpm")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                } else {
                    Button(action: { /* Connect action */ }) {
                        Text("Connect Device")
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                            .foregroundColor(.white)
                    }
                }
            }
            .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
