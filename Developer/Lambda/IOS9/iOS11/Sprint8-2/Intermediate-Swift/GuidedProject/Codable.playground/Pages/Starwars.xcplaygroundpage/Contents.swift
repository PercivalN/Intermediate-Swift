import UIKit

/*
{
    "name": "Luke Skywalker",
    "height": "172",
    "mass": "77",
    "hair_color": "blond",
    "skin_color": "fair",
    "eye_color": "blue",
    "birth_year": "19BBY",
    "gender": "male",
    "homeworld": "https://swapi.co/api/planets/1/",
    "films": [
        "https://swapi.co/api/films/2/",
        "https://swapi.co/api/films/6/",
        "https://swapi.co/api/films/3/",
        "https://swapi.co/api/films/1/",
        "https://swapi.co/api/films/7/"
    ],
    "species": [
        "https://swapi.co/api/species/1/"
    ],
    "vehicles": [
        "https://swapi.co/api/vehicles/14/",
        "https://swapi.co/api/vehicles/30/"
    ],
    "starships": [
        "https://swapi.co/api/starships/12/",
        "https://swapi.co/api/starships/22/"
    ],
    "created": "2014-12-09T13:50:51.644000Z",
    "edited": "2014-12-20T21:17:56.891000Z",
    "url": "https://swapi.co/api/people/1/"
}
*/

struct Person: Codable {

	enum PersonKeys: String, CodingKey {
		case name
		case height
		case hairColor = "hair_color"
		case films
		case vehicles
		case starships
	}

	let name: String
	let height: Int
	let hairColor: String

	let films: [URL]
	let vehicles: [URL]
	let starships: [URL]

	init(from decoder: Decoder) throws {

		// Keyed containers are dictionaries
		// Unkeyed are arrays
		// Single value are single values

		let container = try decoder.container(keyedBy: PersonKeys.self)
		name = try container.decode(String.self, forKey: .name)
		hairColor = try container.decode(String.self, forKey: .hairColor)
		let heightString = try container.decode(String.self, forKey: .height)
		height = Int(heightString) ?? 0
		// TODO: Improve in future

		var filmsContainer = try container.nestedUnkeyedContainer(forKey: .films)
		var filmsURLs = [URL]() // filmsURL: [URL] = []
		while filmsContainer.isAtEnd == false {
			let filmString = try filmsContainer.decode(String.self)
			if let filmURL = URL(string: filmString) {
				filmsURLs.append(filmURL)
			}
		}
		films = filmsURLs

		let vehicleStrings = try container.decode([String].self, forKey: .vehicles)
		vehicles = vehicleStrings.compactMap{
			URL(string: $0)
		}

		starships = try container.decode([URL].self, forKey: .starships)
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: PersonKeys.self)

		try container.encode(name, forKey: .name)
		try container.encode(hairColor, forKey: .hairColor)
		try container.encode("\(height)", forKey: .height)

		var filmsContainer = container.nestedUnkeyedContainer(forKey: .films)
		for filmURL in films {
			try filmsContainer.encode(filmURL.absoluteString)
		}

		let vehicleString = vehicles.map {
			$0.absoluteString
		}
		try container.encode(vehicleString, forKey: .vehicles)

		try container.encode(starships, forKey: .starships)
	}
}

let url = URL(string: "https://swapi.co/api/people/1/")!
let data = try! Data(contentsOf: url)

let decoder = JSONDecoder()
let luke = try! decoder.decode(Person.self, from: data)

let encoder = JSONEncoder()
encoder.outputFormatting = [.prettyPrinted]
let lukeData = try! encoder.encode(luke)

let lukeString = String(data: data, encoding: .utf8)!
print(lukeString)

let plistEncoder = PropertyListEncoder()
plistEncoder.outputFormat = .xml
let plistData = try! plistEncoder.encode(luke)
let plistString = String(data: plistData, encoding: .utf8)!
print(plistString)

