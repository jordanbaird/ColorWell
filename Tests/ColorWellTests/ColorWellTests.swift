//
// ColorWellTests.swift
// ColorWell
//

import XCTest
@testable import ColorWell

final class ColorWellTests: XCTestCase {
    func testCGPointTranslate() {
        let tx: CGFloat = 10
        let ty: CGFloat = 20
        let point1 = CGPoint.zero
        let point2 = point1.translating(x: tx, y: ty)
        XCTAssertEqual(CGPoint(x: tx, y: ty), point2)
    }

    func testCGRectCenter() {
        let rect1 = CGRect(x: 0, y: 0, width: 500, height: 500)
        let rect2 = CGRect(x: 1000, y: 1000, width: 250, height: 250)
        let rect3 = rect2.centered(in: rect1)
        XCTAssertEqual(rect3.origin.x, rect1.midX - (rect3.width / 2))
        XCTAssertEqual(rect3.origin.y, rect1.midY - (rect3.height / 2))
    }

    func testCGSizeApplyingInsets() {
        let insets = NSEdgeInsets(top: 5, left: 10, bottom: 15, right: 20)
        let size1 = CGSize(width: 500, height: 500)
        let size2 = size1.applying(insets: insets)
        XCTAssertEqual(size2.width, size1.width - insets.horizontal)
        XCTAssertEqual(size2.height, size1.height - insets.vertical)
    }

    func testComparableClamped() {
        var value = 10
        value = value.clamped(to: 0...5)
        XCTAssertEqual(value, 5)
        value = value.clamped(to: 20...100)
        XCTAssertEqual(value, 20)
        value = value.clamped(to: 10...30)
        XCTAssertEqual(value, 20)
    }

    func testNSColorFromHexString() throws {
        XCTAssertNil(
            NSColor(hexString: "green")
        )
        XCTAssertNotNil(
            NSColor(hexString: "FFFFFF")
        )
        try XCTAssertEqual(
            XCTUnwrap(NSColor(hexString: "FFFFFF")),
            NSColor(srgbRed: 1, green: 1, blue: 1, alpha: 1)
        )
        try XCTAssertEqual(
            XCTUnwrap(NSColor(hexString: "000000")),
            NSColor(srgbRed: 0, green: 0, blue: 0, alpha: 1)
        )
        try XCTAssertEqual(
            XCTUnwrap(NSColor(hexString: "FF0000")),
            NSColor(srgbRed: 1, green: 0, blue: 0, alpha: 1)
        )
        try XCTAssertEqual(
            XCTUnwrap(NSColor(hexString: "00FF00")),
            NSColor(srgbRed: 0, green: 1, blue: 0, alpha: 1)
        )
        try XCTAssertEqual(
            XCTUnwrap(NSColor(hexString: "0000FF")),
            NSColor(srgbRed: 0, green: 0, blue: 1, alpha: 1)
        )
        try XCTAssertTrue(
            XCTUnwrap(NSColor(hexString: "0000007F")).resembles(
                NSColor(srgbRed: 0, green: 0, blue: 0, alpha: 0.5),
                using: .sRGB,
                tolerance: 0.01
            )
        )
        try XCTAssertFalse(
            XCTUnwrap(NSColor(hexString: "0000007F")).resembles(
                NSColor(srgbRed: 0, green: 0, blue: 0, alpha: 0.4),
                using: .sRGB,
                tolerance: 0.01
            )
        )
    }

    func testNSColorBlendedAndClamped() {
        func randomComponent() -> CGFloat {
            .random(in: 0...1)
        }

        func randomColor() -> NSColor {
            NSColor(
                red: randomComponent(),
                green: randomComponent(),
                blue: randomComponent(),
                alpha: randomComponent()
            )
        }

        for _ in 0..<10_000 {
            let color1 = randomColor()
            let color2 = randomColor()
            let fraction = randomComponent()

            let blended1 = color1.blended(withFraction: fraction, of: color2)
            let blended2 = color1.blendedAndClamped(withFraction: fraction, of: color2)

            XCTAssertEqual(blended1, blended2)
        }
    }

    func testNSEdgeInsets() {
        let insets = NSEdgeInsets(top: 20, left: 40, bottom: 60, right: 80)
        XCTAssertEqual(insets.horizontal, insets.left + insets.right)
        XCTAssertEqual(insets.vertical, insets.top + insets.bottom)
    }
}
