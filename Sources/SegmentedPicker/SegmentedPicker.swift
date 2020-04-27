import SwiftUI
import Shapes

// MARK: - Style Setup
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , *)
public struct KSegmentedPickerConfiguration {
    public let isDisabled: Bool
    public let isSelected: Bool
    public let label: AnyView
}
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , *)
public protocol KSegmentedPickerStyle {
    associatedtype Body: View
    associatedtype Selection: View
    associatedtype DividerView: View
    
    func makeDivider(isVertical: Bool) -> Self.DividerView
    func makeSelectionFill(configuration: KSegmentedPickerConfiguration) -> Self.Selection
    func makeBody(configuration: KSegmentedPickerConfiguration) -> Self.Body
}
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , *)
extension KSegmentedPickerStyle {
    func makeDividerTypeErased(isVertical: Bool) -> AnyView {
        AnyView(self.makeDivider(isVertical: isVertical))
    }
    func makeSelectionFillTypeErased(configuration: KSegmentedPickerConfiguration) -> AnyView {
        AnyView(self.makeSelectionFill(configuration: configuration))
    }
    func makeBodyTypeErased(configuration: KSegmentedPickerConfiguration) -> AnyView {
        AnyView(self.makeBody(configuration: configuration))
    }
}
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , *)
public struct AnyKSegmentedPickerStyle: KSegmentedPickerStyle {
    private let _makeDivider: (Bool) -> AnyView
    public func makeDivider(isVertical: Bool) -> some View {
        return self._makeDivider(isVertical)
    }
    private let _makeBody: (KSegmentedPickerConfiguration) -> AnyView
    public func makeBody(configuration: KSegmentedPickerConfiguration) -> some View {
        return self._makeBody(configuration)
    }
    private let _makeSelectionFill: (KSegmentedPickerConfiguration) -> AnyView
    public func makeSelectionFill(configuration: KSegmentedPickerConfiguration) -> some View {
        return self._makeSelectionFill(configuration)
    }
    
    init<ST: KSegmentedPickerStyle>(_ style: ST) {
        self._makeDivider = style.makeDividerTypeErased
        self._makeBody = style.makeBodyTypeErased
        self._makeSelectionFill = style.makeSelectionFillTypeErased
    }
}
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , *)
public struct DefaultKSegmentedPickerStyle: KSegmentedPickerStyle {
    public init() {}
    public func makeDivider(isVertical: Bool) -> some View {
        Group {
            if isVertical {
                HorizontalLine().stroke(Color.green, lineWidth: 0.5)
            } else {
                VerticalLine().stroke(Color.green, lineWidth: 0.5)
            }
        }
    }
    public func makeBody(configuration: KSegmentedPickerConfiguration) -> some View {
        configuration.label
            .foregroundColor(configuration.isSelected ? .white : .green)
            .padding()
    }
    
    
    public func makeSelectionFill(configuration: KSegmentedPickerConfiguration) -> some View {
        RoundedRectangle(cornerRadius: 5)
            .fill(Color.green)
    }
}
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , *)
public struct KSegmentedPickerStyleKey: EnvironmentKey {
    public static let defaultValue: AnyKSegmentedPickerStyle  = AnyKSegmentedPickerStyle(DefaultKSegmentedPickerStyle())
}
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , *)
extension EnvironmentValues {
    public var kSegmentedPickerStyle: AnyKSegmentedPickerStyle {
        get {
            return self[KSegmentedPickerStyleKey.self]
        }
        set {
            self[KSegmentedPickerStyleKey.self] = newValue
        }
    }
}
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , *)
extension View {
    public func kSegmentedPickerStyle<S>(_ style: S) -> some View where S: KSegmentedPickerStyle {
        self.environment(\.kSegmentedPickerStyle, AnyKSegmentedPickerStyle(style))
    }
}


@available(iOS 13.0, macOS 10.15, watchOS 6.0 , *)
public struct SegmentedPicker<Data: RandomAccessCollection, Content: View>: View where Data.Element: Hashable  {
    @Environment(\.kSegmentedPickerStyle) var style: AnyKSegmentedPickerStyle
    typealias Key = PickerKey<Data.Element, Anchor<CGRect>>
    struct PickerKey<Key: Hashable, Value>: PreferenceKey {
        static var defaultValue: [Key:Value] { [:] }
        static func reduce(value: inout [Key:Value], nextValue: () -> [Key:Value]) {
            value.merge(nextValue(), uniquingKeysWith: {$1})
        }
    }
    @Binding var selected: Data.Element
    @State private var offset: CGPoint = .zero
    @State private var currentlyInside: CGRect = .zero
    var isVertical: Bool = false
    var isDisabled: Bool = false
    private let data: Data
    private let itemView: (Data.Element) -> Content
    
    public init(_ selected: Binding<Data.Element>, _ data: Data, @ViewBuilder itemView: @escaping (Data.Element) -> Content) {
        self.data = data
        self.itemView = itemView
        self._selected = selected
    }
    public init(_ selected: Binding<Data.Element>, _ data: Data, isVertical: Bool, @ViewBuilder itemView: @escaping (Data.Element) -> Content) {
        self.data = data
        self.itemView = itemView
        self._selected = selected
        self.isVertical = isVertical
    }
    
    var geometry: some View {
        Group {
            if isVertical {
                VStack(spacing: 0) {
                    ForEach(self.data, id: \.self) { (element: Data.Element) in
                        self.style.makeBody(configuration: .init(isDisabled: self.isDisabled, isSelected: self.selected == element, label: AnyView(self.itemView(element))))
                            .anchorPreference(key: Key.self, value: .bounds, transform: {[element : $0]})
                            .tag(element)
                            .opacity(0)
                    }
                }
            } else {
                HStack(spacing: 0) {
                    ForEach(self.data, id: \.self) { (element: Data.Element) in
                        self.style.makeBody(configuration: .init(isDisabled: self.isDisabled,  isSelected: self.selected == element, label: AnyView(self.itemView(element))))
                            .anchorPreference(key: Key.self, value: .bounds, transform: {[element : $0]})
                            .tag(element)
                            .opacity(0)
                    }
                }
            }
        }
    }
    
    func makeOptions(_ proxy: GeometryProxy, bounds: [Data.Element: Anchor<CGRect>]) -> some View  {
        Group {
            if isVertical {
                VStack(spacing: 0) {
                    ForEach(self.data, id: \.self) { (element: Data.Element) in
                        self.style.makeBody(configuration: .init(isDisabled: self.isDisabled, isSelected: self.selected == element, label: AnyView(self.itemView(element))))
                            .anchorPreference(key: Key.self, value: .bounds, transform: {[element : $0]})
                            .tag(element)
                    }
                }
            } else {
                HStack(spacing: 0) {
                    ForEach(self.data, id: \.self) { (element: Data.Element) in
                        self.style.makeBody(configuration: .init(isDisabled: self.isDisabled,  isSelected: self.selected == element, label: AnyView(self.itemView(element))))
                            .tag(element)
                        
                    }
                }
            }
        }
    }
    
    
    
    func makeDividers(_ proxy: GeometryProxy, bounds: [Data.Element: Anchor<CGRect>]) -> some View {
        let spacing: [CGFloat] = bounds.map { self.isVertical ? proxy[$0.value].maxY : proxy[$0.value].maxX }.sorted(by: {$1 > $0}).dropLast()
        
        return ZStack {
            ForEach(spacing, id: \.self) { (position)  in
                Group {
                    if self.isVertical {
                        self.style.makeDivider(isVertical: self.isVertical)
                            .position(x: proxy.size.width/2, y: position )
                        
                    } else {
                        self.style.makeDivider(isVertical: self.isVertical)
                            .position(x: position, y: proxy.size.height/2)
                    }
                }
                
            }
        }
        
    }
    
    func makePicker(_ proxy: GeometryProxy, bounds: [Data.Element: Anchor<CGRect>]) -> some View {
        ZStack {
            self.makeDividers(proxy , bounds: bounds)
            Rectangle()
                .fill(Color.clear)
                .contentShape(Rectangle())
                .gesture(DragGesture(minimumDistance: 0)
                    .onChanged({ (drag) in
                        self.offset = self.isVertical ? CGPoint(x: proxy.size.width/2, y: drag.location.y) :  CGPoint(x: drag.location.x, y: proxy.size.height/2)
                        bounds.forEach { (key: Data.Element, value: Anchor<CGRect>) in
                            let rect = proxy[value]
                            if rect.contains(drag.location) {
                                self.currentlyInside = rect
                                self.selected = key
                            }
                        }
                    })
                    .onEnded({ (drag) in
                        self.offset = .zero
                        bounds.forEach { (key: Data.Element, value: Anchor<CGRect>) in
                            let rect = proxy[value]
                            if rect.contains(drag.location) {
                                self.currentlyInside = rect
                                self.selected = key
                            }
                        }
                    }))
        }.onAppear {
            self.currentlyInside = proxy[bounds[self.selected]!]
        }
    }
    
    public var body: some View {
        geometry
            .overlayPreferenceValue(Key.self) { (bounds: [Data.Element: Anchor<CGRect>])  in
                ZStack {
                    GeometryReader { proxy in
                        self.style.makeSelectionFill(configuration: .init(isDisabled: self.isDisabled, isSelected: false, label: AnyView(EmptyView())))
                            .frame(width: self.currentlyInside.width, height: self.currentlyInside.height)
                            .position(x: self.offset == .zero ? self.currentlyInside.midX : self.offset.x,
                                      y: self.offset == .zero ? self.currentlyInside.midY : self.offset.y)
                            .animation(.spring())
                        self.makeOptions(proxy, bounds: bounds)
                        self.makePicker(proxy, bounds: bounds)
                    }
                }
        }
    }
}
