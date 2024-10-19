//
//  TASAccountView.swift
//  TASShopping
//
//  Created by Sarah Akhtar on 10/18/24.
//

import SwiftUI

struct TASAccountView: View {
    @State private var name: String = ""
    @State private var frequency: Int = 0

    var body: some View {
        Form {
            Section(header: Text("User Info")) {
                TextField("Name", text: $name)
                Stepper(value: $frequency, in: 0...100) {
                    Text("Frequency of visits: \(frequency)")
                }
            }
        }
        .navigationTitle("Account Settings")
    }
}

#Preview {
    TASAccountView()
}
