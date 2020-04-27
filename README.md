<p align="center">
<img src="Segmented-Picker.svg" alt="Segmented Picker Logo" border="2"/>

<p align="center">
    <img src="https://img.shields.io/badge/platforms-iOS_13_|macOS_10.15_| watchOS_6.0-blue.svg" alt="SwiftUI" />
    <img src="https://img.shields.io/badge/Swift-5.1-orange.svg" alt="Swift 5.1" />
    <img src="https://img.shields.io/badge/SwiftPM-compatible-green.svg" alt="Swift 5.1" />
    <img src="https://img.shields.io/github/followers/kieranb662?label=Follow" alt="kieranb662 followers" />
</p>

<p align="center">
    <img src="Segmented-Picker.gif" alt="Segmented Picker Example Gif" width="300"/>
</p>

Use the SegmentedPicker library to create custom vertical or horizontal `SegmentedPicker`s. Follow along with the examples below to get started quickly. 

```swift 
import SwiftUI
import SegmentedPicker
import Shapes


struct LineCapPicker: View {
    @State var lineCap: LineCap = .butt
    
    
    enum LineCap: String, CaseIterable, Identifiable {
        case butt = "butt"
        case round = "round"
        case square = "square"
        
        var id: String { self.rawValue }
        
        var cgLineCap: CGLineCap {
            switch self {
            case .butt:
                return .butt
            case .round:
                return .round
            case .square:
                return .square
            }
        }
    }
    
    var body: some View {
        SegmentedPicker($lineCap, LineCap.allCases, isVertical: true) { (cap: LineCap)   in
            HorizontalLine()
                .stroke(Color(white: 0.85), style: StrokeStyle(lineWidth: 20, lineCap: cap.cgLineCap))
                .frame(width: 40)
            
        }.overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.green))
            .frame(height: 120)
    }
}


struct RGBColorSpacePicker: View {
    let colorSpaces: [String] = ["sRGB", "sRGB Linear", "Display P3"]
    @State var selected: String = "sRGB"
    
    var body: some View {
        SegmentedPicker($selected, colorSpaces) { (text: String)   in
            Text(text)
        }.overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.green))
    }
}

struct TextAlignmentPicker: View {
    @State var alignment: TextAlignmentEnum = .left
    
    enum TextAlignmentEnum: String, CaseIterable, Identifiable {
        case left = "text.alignleft"
        case center = "text.aligncenter"
        case right = "text.alignright"
        var id: String {rawValue}
        
        var alignment: TextAlignment {
            switch self {
            case .left:
                return .leading
            case .center:
                return .center
            case .right:
                return .trailing
            
            }
        }
    }
    
    
    var body: some View {
        SegmentedPicker($alignment, TextAlignmentEnum.allCases) { (alignment)   in
            Image(systemName: alignment.rawValue)
        }.overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.green))
    }
}


struct SegmentedPickerExample: View {
    
    var body: some View {
        ZStack {
            Color(white: 0.1)
                .edgesIgnoringSafeArea(.all)
            VStack {
                Text("RGB Color Space").padding()
                RGBColorSpacePicker()
                Divider()
                Text("Text Alignment").padding()
                TextAlignmentPicker()
                Divider()
                Text("Line Cap").padding()
                LineCapPicker()
            }
        }.navigationBarTitle("Segmented Picker")
        
    }
}

struct ContentView: View {
    var body: some View {
        SegmentedPickerExample()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().colorScheme(.dark)
    }
}
```
