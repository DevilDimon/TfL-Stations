struct StopPointAdditionalProperty: Codable {
	enum Category: String {
		case facility = "Facility"
	}

	let category: String?
	let key: String?
}
