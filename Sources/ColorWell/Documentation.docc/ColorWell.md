# ``ColorWell``

A versatile alternative to `NSColorWell` for Cocoa and `ColorPicker` for SwiftUI.

## Overview

ColorWell is designed to mimic the appearance and behavior of the new color well design in macOS 13 Ventura, for those who want to use the new design on older operating systems.

| Light mode      | Dark mode      |
| --------------- | -------------- |
| ![][light-mode] | ![][dark-mode] |

## SwiftUI

Create a ``ColorWellView`` and add it to your view hierarchy. There are a wide range of initializers to choose from, allowing you to set the color well's color, label, and action.

```swift
struct ContentView: View {
    var body: some View {
        ColorWellView(color: .green) { color in
            print(color)
        }
    }
}
```

## Cocoa

Create a ``ColorWell/ColorWell`` using one of the available initializers.

```swift
let colorWell1 = ColorWell()
let colorWell2 = ColorWell(color: .green)
let colorWell3 = ColorWell(frame: NSRect(x: 0, y: 0, width: 400, height: 200))
// And more...
```

Observe color changes using the ``ColorWell/ColorWell/onColorChange(perform:)`` method.

```swift
let colorWell = ColorWell()
colorWell.onColorChange { color in
    print(color)
}
```

[light-mode]: color-well-with-popover-light.png
[dark-mode]: color-well-with-popover-dark.png
