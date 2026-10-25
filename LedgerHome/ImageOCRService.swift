import Foundation
import ImageIO
import Vision

actor ImageOCRService {
    func recognizeText(in data: Data) throws -> String {
        guard
            let source = CGImageSourceCreateWithData(
                data as CFData,
                nil
            ),
            let image = CGImageSourceCreateImageAtIndex(
                source,
                0,
                nil
            )
        else {
            throw ImageOCRError.cannotCreateImage
        }

        let properties = CGImageSourceCopyPropertiesAtIndex(
            source,
            0,
            nil
        ) as? [CFString: Any]

        let orientationValue = (
            properties?[kCGImagePropertyOrientation] as? NSNumber
        )?.uint32Value ?? 1

        let orientation = CGImagePropertyOrientation(
            rawValue: orientationValue
        ) ?? .up

        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = false

        let handler = VNImageRequestHandler(
            cgImage: image,
            orientation: orientation,
            options: [:]
        )

        try handler.perform([request])

        let lines = (request.results ?? []).compactMap {
            $0.topCandidates(1).first?.string
        }

        return lines.joined(separator: "\n")
    }
}
