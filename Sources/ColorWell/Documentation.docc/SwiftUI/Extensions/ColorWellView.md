# ``ColorWell/ColorWellView``

By default, color wells support colors with opacity; to disable opacity support, set the `supportsOpacity` parameter to `false`. In this mode, the color well won't show controls for adjusting the opacity of the selected color.

You create a color well by providing a title string and a `Binding` to a `Color`:

```swift
struct TextFormatter: View {
    @State private var fontColor = Color.black

    var body: some View {
        HStack {
            ColorWellView("Font Color", selection: $fontColor)
        }
    }
}
```

### Styling color wells

You can customize a color well's appearance using one of the standard color well styles, like ``ColorWellStyle/swatches``, and apply the style with the ``colorWellStyle(_:)`` modifier:

```swift
HStack {
    ColorWellView("Foreground", selection: $fgColor)
    ColorWellView("Background", selection: $bgColor)
}
.colorWellStyle(.swatches)
```

If you apply the style to a container view, as in the example above, all the color wells in the container use the style:

![Two color wells, both displayed in the swatches style](swatches-style)

## Topics

### Creating a color well

- ``init(selection:supportsOpacity:)-9qbyv``
- ``init(selection:supportsOpacity:label:)-lv6q``
- ``init(_:selection:supportsOpacity:)-9ug17``
- ``init(_:selection:supportsOpacity:)-229qh``

### Creating a core graphics color well

- ``init(selection:supportsOpacity:)-16r4r``
- ``init(selection:supportsOpacity:label:)-3edc5``
- ``init(_:selection:supportsOpacity:)-9166c``
- ``init(_:selection:supportsOpacity:)-3fmau``

### Modifying color wells

- ``colorWellStyle(_:)``
- ``swatchColors(_:)``

### Getting a color well's content view

- ``body``

### Supporting Types

- ``ColorWellStyle``

### Deprecated

- <doc:ColorWellView.Deprecated>
