# ``ColorWell``

A versatile alternative to `NSColorWell` for Cocoa and `ColorPicker` for SwiftUI.

## Overview

ColorWell is designed to mimic the appearance and behavior of the new color well design in macOS 13 Ventura, for those who want to use the new design on older operating systems.

| Light mode      | Dark mode      |
| --------------- | -------------- |
| ![][light-mode] | ![][dark-mode] |

## SwiftUI

Create a ``ColorWellView`` and add it to your view hierarchy. There are a wide range of initializers, as well as several modifiers to choose from, allowing you to set the color well's color, label, and action.

```swift
import SwiftUI
import ColorWell

struct ContentView: View {
    @Binding var fontColor: Color

    var body: some View {
        VStack {
            ColorWellView("Font Color", color: fontColor, action: updateFontColor)
                .colorWellStyle(.expanded)

            MyCustomTextEditor(fontColor: $fontColor)
        }
    }

    private func updateFontColor(_ color: Color) {
        fontColor = color
    }
}
```

## Cocoa

Create a ``ColorWell/ColorWell`` using one of the available initializers. Observe color changes using the ``ColorWell/ColorWell/onColorChange(perform:)`` method.

```swift
import Cocoa
import ColorWell

class ContentViewController: NSViewController {
    let colorWell: ColorWell
    let textEditor: MyCustomNSTextEditor

    init(fontColor: NSColor) {
        self.colorWell = ColorWell(color: fontColor)
        self.textEditor = MyCustomNSTextEditor(fontColor: fontColor)

        super.init(nibName: "ContentView", bundle: Bundle(for: Self.self))

        // Set the style
        colorWell.style = .expanded

        // Add a change handler
        colorWell.onColorChange { newColor in
            self.textEditor.fontColor = newColor
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(colorWell)
        view.addSubview(textEditor)

        // Layout the views, perform setup work, etc.
    }
}
```

[light-mode]: color-well-with-popover-light.png
[dark-mode]: color-well-with-popover-dark.png
