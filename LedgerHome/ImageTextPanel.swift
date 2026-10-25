import SwiftUI
import Foundation

struct ImageTextPanel: View {
    let text: String
    let hasError: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Image Text — OCR")
                .font(.headline)
                .padding()

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    if hasError {
                        Text(
                            "OCR did not complete. "
                            + "See the error above."
                        )
                        .foregroundStyle(.secondary)
                    } else if text.trimmingCharacters(
                        in: .whitespacesAndNewlines
                    ).isEmpty {
                        Text("No text was recognized in this image.")
                            .foregroundStyle(.secondary)
                    } else {
                        Text(text)
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
                .padding()
            }
        }
        .frame(minWidth: 300, idealWidth: 400)
    }
}
