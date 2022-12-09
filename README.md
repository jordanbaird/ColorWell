# ColorWell

A versatile alternative to `NSColorWell` for Cocoa and `ColorPicker` for SwiftUI.

<div align='center'>
    <img src='Sources/ColorWell/Documentation.docc/Resources/color-well-with-popover-dark.png', style='width:37%'>
    <img src='Sources/ColorWell/Documentation.docc/Resources/color-well-with-popover-light.png', style='width:37%'>
</div>

ColorWell is designed to mimic the appearance and behavior of the new color well design in macOS 13 Ventura, for those who want to use the new design on older operating systems.

## Install

Add the following dependency to your `Package.swift` file:

```swift
.package(url: "https://github.com/jordanbaird/ColorWell", from: "0.0.4")
```

## Usage

[Read the full documentation here](https://swiftpackageindex.com/jordanbaird/ColorWell/documentation)

### SwiftUI

Create a `ColorWellView` and add it to your view hierarchy. There are a wide range of initializers to choose from, allowing you to set the color well's color, label, and action.

```swift
struct ContentView: View {
    var body: some View {
        ColorWellView(color: .green) { color in
            print(color)
        }
    }
}
```

### Cocoa

Create a `ColorWell` using one of the available initializers.

```swift
let colorWell1 = ColorWell()
let colorWell2 = ColorWell(color: .green)
let colorWell3 = ColorWell(frame: NSRect(x: 0, y: 0, width: 400, height: 200))
// And more...
```

Observe color changes using the `onColorChange(perform:)` method.

```swift
let colorWell = ColorWell()
colorWell.onColorChange { color in
    print(color)
}
```

## License

ColorWell is licensed under the [MIT license](http://www.opensource.org/licenses/mit-license).
