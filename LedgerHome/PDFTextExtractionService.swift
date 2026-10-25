import AppKit
import PDFKit

@MainActor
struct PDFTextExtractionService {
    let imageOCRService: ImageOCRService

    func extract(
        from document: PDFDocument
    ) async -> [ExtractedPageText] {
        var pages: [ExtractedPageText] = []

        for index in 0..<document.pageCount {
            let pageNumber = index + 1

            guard let page = document.page(at: index) else {
                pages.append(
                    ExtractedPageText(
                        pageNumber: pageNumber,
                        text: "",
                        issue: "Could not access this PDF page.",
                        extractionMethod: "None"
                    )
                )
                continue
            }

            let existingText = page.string ?? ""

            if !existingText.trimmingCharacters(
                in: .whitespacesAndNewlines
            ).isEmpty {
                pages.append(
                    ExtractedPageText(
                        pageNumber: pageNumber,
                        text: existingText,
                        issue: nil,
                        extractionMethod: "PDF text"
                    )
                )
                continue
            }

            do {
                let imageData = try renderPageForOCR(page)

                let recognizedText = try await imageOCRService
                    .recognizeText(in: imageData)

                pages.append(
                    ExtractedPageText(
                        pageNumber: pageNumber,
                        text: recognizedText,
                        issue: nil,
                        extractionMethod: "OCR"
                    )
                )
            } catch {
                pages.append(
                    ExtractedPageText(
                        pageNumber: pageNumber,
                        text: "",
                        issue: "Page OCR failed: "
                            + error.localizedDescription,
                        extractionMethod: "OCR"
                    )
                )
            }
        }

        return pages
    }

    private func renderPageForOCR(
        _ page: PDFPage
    ) throws -> Data {
        let bounds = page.bounds(for: .cropBox)

        guard
            bounds.width > 0,
            bounds.height > 0,
            bounds.width.isFinite,
            bounds.height.isFinite
        else {
            throw PDFPageOCRError.invalidPageSize
        }

        let longestSide: CGFloat = 2000
        let scale = longestSide / max(
            bounds.width,
            bounds.height
        )

        let targetSize = NSSize(
            width: bounds.width * scale,
            height: bounds.height * scale
        )

        let image = page.thumbnail(
            of: targetSize,
            for: .cropBox
        )

        guard let cgImage = image.cgImage(
            forProposedRect: nil,
            context: nil,
            hints: nil
        ) else {
            throw PDFPageOCRError.cannotRenderPage
        }

        let bitmap = NSBitmapImageRep(cgImage: cgImage)

        guard let data = bitmap.representation(
            using: .png,
            properties: [:]
        ) else {
            throw PDFPageOCRError.cannotRenderPage
        }

        return data
    }
}
