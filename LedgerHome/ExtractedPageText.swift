struct ExtractedPageText: Identifiable {
    let pageNumber: Int
    let text: String
    let issue: String?
    let extractionMethod: String

    var id: Int { pageNumber }
}
