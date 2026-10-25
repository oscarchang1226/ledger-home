import SwiftUI
import AppKit
import PDFKit
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var isImporting = false
    @State private var documentName = "No document selected"
    @State private var preview: DocumentPreview?
    @State private var errorMessage: String?
    @State private var extractedPages: [ExtractedPageText] = []
    @State private var imageOCRText = ""
    @State private var isProcessing = false
    @State private var imageOCRService = ImageOCRService()

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button("Open Document…") {
                    isImporting = true
                }.disabled(isProcessing)

                Text(documentName)
                    .lineLimit(1)
                    .truncationMode(.middle)
                
                if isProcessing {
                    ProgressView()
                        .controlSize(.small)
                    
                    Text("Processing...")
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
            .padding()

            Divider()

            if let errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
                    .textSelection(.enabled)
                    .padding()
            }

            Group {
                switch preview {
                case .pdf(let document):
                    HSplitView {
                        PDFPreview(document: document)
                            .frame(minWidth: 350)
                        PDFTextPanel(pages: extractedPages)
                    }

                case .image(let image):
                    HSplitView {
                        Image(nsImage: image)
                            .resizable()
                            .scaledToFit()
                            .padding()
                            .frame(minWidth: 350)
                        
                        ImageTextPanel(text: imageOCRText, hasError: errorMessage != nil)
                    }


                case nil:
                    Text("Open a PDF, PNG, or JPEG to preview it.")
                        .foregroundStyle(.secondary)
                        .frame(
                            maxWidth: .infinity,
                            maxHeight: .infinity
                        )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(minWidth: 900, minHeight: 500)
        .fileImporter(
            isPresented: $isImporting,
            allowedContentTypes: [.pdf, .png, .jpeg]
        ) { result in
            switch result {
            case .success(let url):
                Task { @MainActor in
                    await openDocument(at: url)
                }

            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
    }

    @MainActor
    private func openDocument(at url: URL) async {
        guard !isProcessing else {
            return
        }

        isProcessing = true
        errorMessage = nil

        let hasAccess = url.startAccessingSecurityScopedResource()

        defer {
            if hasAccess {
                url.stopAccessingSecurityScopedResource()
            }

            isProcessing = false
        }

        do {
            let data = try Data(contentsOf: url)

            let contentType = try url.resourceValues(
                forKeys: [.contentTypeKey]
            ).contentType

            let loadedPreview: DocumentPreview
            let loadedPages: [ExtractedPageText]
            let loadedImageText: String

            if contentType?.conforms(to: .pdf) == true {
                guard let document = PDFDocument(data: data) else {
                    throw PreviewError.unreadableDocument
                }

                guard !document.isLocked else {
                    throw PreviewError.lockedPDF
                }

                guard document.pageCount > 0 else {
                    throw PreviewError.emptyPDF
                }

                loadedPreview = .pdf(document)
                
                let extractor = PDFTextExtractionService(imageOCRService: imageOCRService)
                loadedPages = await extractor.extract(from: document)
                loadedImageText = ""
            } else {
                guard let image = NSImage(data: data) else {
                    throw PreviewError.unreadableDocument
                }

                loadedPreview = .image(image)
                loadedPages = []

                do {
                    loadedImageText = try await imageOCRService
                        .recognizeText(in: data)
                } catch {
                    loadedImageText = ""
                    errorMessage = "The image opened, but OCR failed: "
                        + error.localizedDescription
                }
            }

            preview = loadedPreview
            extractedPages = loadedPages
            imageOCRText = loadedImageText
            documentName = url.lastPathComponent
        } catch {
            errorMessage = "Could not open \(url.lastPathComponent): "
                + error.localizedDescription
        }
    }
}

