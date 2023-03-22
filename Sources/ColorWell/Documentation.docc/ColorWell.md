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
    @Binding var fontColor: Color

    var body: some View {
        VStack {
            ColorWellView(color: fontColor) { newColor in
                fontColor = newColor
            }

            // ...
            // ...
            // ...

            CustomTextEditor(fontColor: $fontColor)
        }
    }
}
```

## Cocoa

Create a ``ColorWell/ColorWell`` using one of the available initializers. Observe color changes using the ``ColorWell/ColorWell/onColorChange(perform:)`` method.

```swift
let fontColor = NSColor.black

let textEditor = CustomNSTextEditor(fontColor: fontColor)
let colorWell = ColorWell(color: fontColor)

colorWell.onColorChange { newColor in
    textEditor.fontColor = newColor
}
```

[light-mode]: color-well-with-popover-light.png
[dark-mode]: color-well-with-popover-dark.png
