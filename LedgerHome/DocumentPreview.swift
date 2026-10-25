import AppKit
import PDFKit

enum DocumentPreview {
    case pdf(PDFDocument)
    case image(NSImage)
}
