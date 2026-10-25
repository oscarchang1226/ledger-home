import Foundation

enum PreviewError: LocalizedError {
    case unreadableDocument
    case lockedPDF
    case emptyPDF

    var errorDescription: String? {
        switch self {
        case .unreadableDocument:
            return "The file could not be decoded as a PDF or image."
        case .lockedPDF:
            return "Password-protected PDFs are not supported yet."
        case .emptyPDF:
            return "The PDF contains no pages."
        }
    }
}

enum ImageOCRError: LocalizedError {
    case cannotCreateImage

    var errorDescription: String? {
        "The image could not be prepared for text recognition."
    }
}

enum PDFPageOCRError: LocalizedError {
    case invalidPageSize
    case cannotRenderPage

    var errorDescription: String? {
        switch self {
        case .invalidPageSize:
            return "The PDF page has an invalid size."
        case .cannotRenderPage:
            return "The PDF page could not be rendered for OCR."
        }
    }
}
