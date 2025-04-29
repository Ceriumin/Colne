//
//  ContentView.swift
//  Colne
//
//  Created by Gracjan Baryla on 29/04/2025.
//

import SwiftUI
import FamilyControls
import ManagedSettings

struct ContentView: View {
    
    @State private var BlockApps = false
    @StateObject private var manager = ShieldManager()
    @State private var showActivityPicker = false
    
    var body: some View {
        VStack(spacing: 20) {
            Button {
                showActivityPicker = true
            } label: {
                Label("Configure Apps", systemImage: "gearshape")
            }
            .buttonStyle(.borderedProminent)
            
            Button {
                BlockApps.toggle()
                if BlockApps {
                    manager.shield()
                } else {
                    manager.unshield()
                }
            } label: {
                Label {
                    Text(BlockApps ? "Disable Shields" : "Enable Shields")
                } icon: {
                    Image(systemName: BlockApps ? "lock.open.fill" : "lock.fill")
                }
                .font(.headline)
            }
            .buttonStyle(.borderedProminent)
            .tint(BlockApps ? .red : .green)
        }
        .padding()
        .familyActivityPicker(isPresented: $showActivityPicker, selection: $manager.selection)
    }
}

#Preview {
    ContentView()
}
