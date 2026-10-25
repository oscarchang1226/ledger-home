import SwiftUI
import Foundation

struct PDFTextPanel: View {
    let pages: [ExtractedPageText]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Extracted PDF Text")
                .font(.headline)
                .padding()

            Divider()

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 20) {
                    ForEach(pages) { page in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(page.extractionMethod)
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            if let issue = page.issue {
                                Text(issue)
                                    .foregroundStyle(.red)
                            } else if page.text.trimmingCharacters(
                                in: .whitespacesAndNewlines
                            ).isEmpty {
                                Text(
                                    "No text was extracted from this page. "
                                    + "It may be blank, or its text may not be recognizable."
                                )
                                .foregroundStyle(.secondary)
                            } else {
                                Text(page.text)
                                    .font(
                                        .system(
                                            .body,
                                            design: .monospaced
                                        )
                                    )
                                    .textSelection(.enabled)
                            }
                        }
                        .frame(
                            maxWidth: .infinity,
                            alignment: .leading
                        )
                    }
                }
                .padding()
            }
        }
        .frame(minWidth: 300, idealWidth: 400)
    }
}
