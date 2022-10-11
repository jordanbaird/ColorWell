# ColorWell

An attractive alternative to `NSColorWell`.

<img width="252" alt="color-well-with-popover" src="https://user-images.githubusercontent.com/90936861/195750190-159aaae6-b613-44c0-836e-abecadb3fb71.png">

ColorWell is designed to mimic the appearance and behavior of the new color well design in macOS 13 Ventura, for those who want to use the new design on older operating systems.

## Install

Add the following dependency to your `Package.swift` file:

```swift
.package(url: "https://github.com/jordanbaird/ColorWell", from: "0.0.1")
```

## Usage

Create a color well using one of the `init()` or `init(frame:)` initializers.

```swift
let colorWellDefaultFrame = ColorWell()
let colorWellCustomFrame = ColorWell(frame: NSRect(x: 0, y: 0, width: 400, height: 200))
```

Observe changes to the `color` value.

```swift
let colorWell = ColorWell()
colorWell.observeColor { color in
    print(color)
}
```

## License

ColorWell is licensed under the [MIT license](http://www.opensource.org/licenses/mit-license).
