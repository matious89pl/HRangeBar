//
//  HRangeBar.swift
//  carbonwatchuk
//
//  Created by Mateusz Siatrak on 20/02/2023.
//

import SwiftUI

struct HRangeBar: View {
    var minLimit: CGFloat
    var maxLimit: CGFloat
    var minValue: CGFloat
    var maxValue: CGFloat
    
    private var normalisedMinValue: CGFloat
    private var normalisedMaxValue: CGFloat
    private var normalisedRange: CGFloat
    
    private let pillThicknessRatio: CGFloat = 2 / 3
    private var cornerRadius: CGFloat = 30
    
    private let MAX_CI: CGFloat = 400
    private let MIN_CI: CGFloat = 40
    
    private var colours: [Color] = [.green, .yellow, .red]
    
    init(rangeMin: CGFloat, rangeMax: CGFloat, minValue: CGFloat, maxValue: CGFloat) {
        if rangeMax < rangeMin {
            fatalError("Error: rangeMax cannot be lower than rangeMin")
        }
        
        if maxValue < minValue {
            fatalError("Error: maxValue cannot be lower than minValue")
        }
        
        minLimit = rangeMin
        maxLimit = rangeMax
        self.minValue = max(minValue, rangeMin)
        self.maxValue = min(maxValue, rangeMax)
        
        normalisedMaxValue = (self.maxValue - minLimit) / (maxLimit - minLimit)
        normalisedMinValue = (self.minValue - minLimit) / (maxLimit - minLimit)
        normalisedRange = normalisedMaxValue - normalisedMinValue
    }
    
    var body: some View {
        HStack {
            Text(minValue, format: .number)
                .font(.footnote)
                .frame(width: 30, alignment: .trailing)
            GeometryReader { geometry in
                VStack {
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .opacity(0.3)
                            .foregroundColor(.black.opacity(0.2))
                        
                            .cornerRadius(cornerRadius)
                        
                        LinearGradient(gradient: Gradient(colors: [colours.intermediateColor(at: minLimit / MAX_CI), colours.intermediateColor(at: maxLimit / MAX_CI)]), startPoint: .leading, endPoint: .trailing)
                            .mask(alignment: .leading) {
                                Rectangle()
                                
                                    .frame(width: normalisedRange * geometry.size.width - (geometry.size.height - geometry.size.height * self.pillThicknessRatio),
                                           height: geometry.size.height * self.pillThicknessRatio)
                                //                            .foregroundColor(Color.green)
                                
                                    .cornerRadius(cornerRadius - (geometry.size.height - geometry.size.height * self.pillThicknessRatio) / 2)
                                    .offset(x: self.normalisedMinValue * geometry.size.width + (geometry.size.height - geometry.size.height * self.pillThicknessRatio) / 2)
                            }
                    }
                }
            }
            Text(maxValue, format: .number)
                .font(.footnote)
                .frame(width: 30, alignment: .leading)
        }
    }
}

extension HRangeBar {
    func getPillMargin(height: CGFloat, ratio: CGFloat) -> CGFloat {
        return (height - (height * ratio)) * 0.5
    }
    
    func stretchRange(minValue: CGFloat, maxValue: CGFloat, fullRange: CGFloat, width: CGFloat, height: CGFloat) -> CGFloat {
        return (maxValue - minValue) / fullRange * width - 2 * getPillMargin(height: height, ratio: pillThicknessRatio)
    }
    
    func startOffset(minValue: CGFloat, fullRange: CGFloat, width: CGFloat, height: CGFloat) -> CGFloat {
        let offset = (minValue / fullRange) * width + getPillMargin(height: height, ratio: pillThicknessRatio)
        return offset
    }
    
    func getGradientFill(minValue: Double, maxValue _: Double, fullRange: Double) -> LinearGradient {
        let percentage = (minValue - minLimit) / fullRange
        
        let startColor: Color
        if percentage <= 0.33 {
            startColor = Color.green
        } else if percentage <= 0.66 {
            startColor = Color.yellow
        } else {
            startColor = Color.red
        }
        
        return LinearGradient(gradient: Gradient(colors: [startColor, Color.red]), startPoint: .leading, endPoint: .trailing)
    }
}


#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

extension Color {
    var components: (red: CGFloat, green: CGFloat, blue: CGFloat, opacity: CGFloat) {
#if canImport(UIKit)
        typealias NativeColor = UIColor
#elseif canImport(AppKit)
        typealias NativeColor = NSColor
#endif
        
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var o: CGFloat = 0
        
        guard NativeColor(self).getRed(&r, green: &g, blue: &b, alpha: &o) else {
            // You can handle the failure here as you want
            return (0, 0, 0, 0)
        }
        
        return (r, g, b, o)
    }
}

extension Array where Element == Color {
    func intermediateColor(at percent: Double) -> Color {
        switch percent {
        case 0: return first ?? .clear
        case 1: return last ?? .clear
        default:
            let approxIndex = Swift.min(percent, 1) / (1 / CGFloat(count - 1)) // 0.5 / (1 / 2)
            let firstIndex = Int(approxIndex.rounded(.down))
            let secondIndex = Int(approxIndex.rounded(.up))
            
            let start = self[firstIndex]
            let end = self[secondIndex]
            
            let startRed = start.components.red
            let startGreen = start.components.green
            let startBlue = start.components.blue
            let startOpacity = start.components.opacity
            
            let endRed = end.components.red
            let endGreen = end.components.green
            let endBlue = end.components.blue
            let endOpacity = end.components.opacity
            
            let intermediateRed = startRed + (endRed - startRed) * Swift.min(percent, 1)
            let intermediateGreen = startGreen + (endGreen - startGreen) * Swift.min(percent, 1)
            let intermediateBlue = startBlue + (endBlue - startBlue) * Swift.min(percent, 1)
            let intermediateOpacity = startOpacity + (endOpacity - startOpacity) * Swift.min(percent, 1)
            
            return Color(red: intermediateRed, green: intermediateGreen, blue: intermediateBlue, opacity: intermediateOpacity)
        }
    }
}


struct HRangeBar_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            HRangeBar(rangeMin: 0, rangeMax: 300, minValue: 120, maxValue: 275).frame(height: 50)
            HRangeBar(rangeMin: 0, rangeMax: 300, minValue: 75, maxValue: 98).frame(height: 50)
            HRangeBar(rangeMin: 0, rangeMax: 300, minValue: 5, maxValue: 200).frame(height: 50)
        }.padding()
    }
}
