# ``ColorWell/ColorWellView``

## Topics

### Creating a color well with an initial color

- ``init(color:supportsOpacity:)``
- ``init(cgColor:supportsOpacity:)``

### Creating a color well with a color and action

- ``init(color:supportsOpacity:action:)``
- ``init(cgColor:supportsOpacity:action:)``

### Creating a color well with a color and label

- ``init(supportsOpacity:color:label:)``
- ``init(supportsOpacity:cgColor:label:)``
- ``init(_:color:supportsOpacity:)-4e9vl``
- ``init(_:cgColor:supportsOpacity:)-1zr5r``
- ``init(_:color:supportsOpacity:)-2js4x``
- ``init(_:cgColor:supportsOpacity:)-91mdm``

### Creating a color well with a label and action

- ``init(supportsOpacity:label:action:)``
- ``init(_:supportsOpacity:action:)-4ijj0``
- ``init(_:supportsOpacity:action:)-1dho9``

### Creating a color well with a color, label, and action

- ``init(supportsOpacity:color:label:action:)``
- ``init(supportsOpacity:cgColor:label:action:)``
- ``init(_:color:supportsOpacity:action:)-7turx``
- ``init(_:cgColor:supportsOpacity:action:)-78agl``
- ``init(_:color:supportsOpacity:action:)-6lguj``
- ``init(_:cgColor:supportsOpacity:action:)-3f573``

### Modifying color wells

- ``colorWellStyle(_:)``
- ``swatchColors(_:)``
- ``onColorChange(perform:)``

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

- ``ColorWellStyle``

### A color well's content view

- ``body``

### Deprecated

- <doc:ColorWellView.Deprecated>
