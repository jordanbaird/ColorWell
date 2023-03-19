# ``ColorWell/ColorWellView``

You create a color well view by providing an initial color value and an action to perform when the color changes. The action can be a method, a closure-typed property, or a literal closure. You can provide a label for the color well in the form of a string, a `LocalizedStringKey`, or a custom view.

```swift
ColorWellView("Font Color", color: fontColor) { newColor in
    fontColor = newColor
}
```

By default, color wells support colors with opacity; to disable opacity support, set the `supportsOpacity` parameter to `false`.

### Styling color wells

You can customize a color well's appearance using one of the standard color well styles, like ``ColorWellStyle/swatches``, and apply the style with the ``colorWellStyle(_:)`` modifier:

```swift
HStack {
    ColorWellView("Foreground", color: .blue)
    ColorWellView("Background", color: .blue)
}
.colorWellStyle(.swatches)
```

If you apply the style to a container view, as in the example above, all the color wells in the container use the style:

![Two color wells, both displayed in the swatches style](swatches-style)

## Topics

### Creating a color well with an initial color

- ``init(color:supportsOpacity:)``
- ``init(cgColor:supportsOpacity:)``

### Creating a color well with a color and action

- ``init(color:supportsOpacity:action:)``
- ``init(cgColor:supportsOpacity:action:)``

### Creating a color well with a color and label

- ``init(color:supportsOpacity:label:)``
- ``init(cgColor:supportsOpacity:label:)``
- ``init(_:color:supportsOpacity:)-4e9vl``
- ``init(_:cgColor:supportsOpacity:)-1zr5r``
- ``init(_:color:supportsOpacity:)-2js4x``
- ``init(_:cgColor:supportsOpacity:)-91mdm``

### Creating a color well with a label and action

- ``init(supportsOpacity:label:action:)``
- ``init(_:supportsOpacity:action:)-4ijj0``
- ``init(_:supportsOpacity:action:)-1dho9``

### Creating a color well with a color, label, and action

- ``init(color:supportsOpacity:label:action:)``
- ``init(cgColor:supportsOpacity:label:action:)``
- ``init(_:color:supportsOpacity:action:)-7turx``
- ``init(_:cgColor:supportsOpacity:action:)-78agl``
- ``init(_:color:supportsOpacity:action:)-6lguj``
- ``init(_:cgColor:supportsOpacity:action:)-3f573``

### Modifying color wells

- ``colorWellStyle(_:)``
- ``swatchColors(_:)``
- ``onColorChange(perform:)``

### Getting a color well's content view

- ``body``

### Supporting Types

- ``ColorWellStyle``

### Deprecated

- <doc:ColorWellView.Deprecated>
