//
//  ContentView.swift
//  HRangeBar
//
//  Created by Mateusz Siatrak on 24/04/2023.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            HRangeBar(rangeMin: 0, rangeMax: 300, minValue: 120, maxValue: 275).frame(height: 50)
            HRangeBar(rangeMin: 0, rangeMax: 300, minValue: 75, maxValue: 98).frame(height: 50)
            HRangeBar(rangeMin: 0, rangeMax: 300, minValue: 5, maxValue: 200).frame(height: 50)
        }.padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
