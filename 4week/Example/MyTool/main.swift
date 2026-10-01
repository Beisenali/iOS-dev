import Foundation

/// Enums
//enum Seasons: CaseIterable {
//    case winter
//    case summer
//    case autumn
//    case spring
//}
//
//let currentSeason: Seasons = .autumn
//
//switch currentSeason {
//case .autumn:
//    print("A")
//case .spring:
//    print("S")
//case .summer:
//    print("Su")
//case .winter:
//    print("W")
//}
//
//let allSeasons = Seasons.allCases
//
//for item in allSeasons {
//    print(item)
//}
//
//enum Barcode {
//    case upc(Int, Int, Int, Int)
//    case qr(String)
//}
//
//let upcCode: Barcode = .upc(1, 12, 13, 11)
//let qrCode: Barcode = .qr("someQRHash")
//
//switch qrCode {
//case .qr(let hash):
//    print(hash)
//case let .upc(a, b, c, d):
//    print("\(a) - \(b) - \(c) - \(d)")
//}
//
//enum Gender: String {
//    case male
//    case female
//}
//
//let currentGender: Gender = .female
//
//let createdGender = Gender(rawValue: "male")
//print(createdGender)

/// Structs and Classes
///

//struct Person {
//    let name: String
//
//    init() {
//        self.name = "Sam"
//    }
//
//    init(name: String) {
//        self.name = name
//    }
//
//    func greeting() {
//        print("Hello, my name is \(name)")
//    }
//}
//
//let personObject = Person()
//let secondPerson = Person(name: "Samantha")
//secondPerson.greeting()
//print(personObject.name)
//
//struct Celcius {
//    var tempInCelc: Double
//
//    init(fromFarenheit farenheit: Double) {
//        tempInCelc = (farenheit - 32.0) / 1.8
//    }
//
//    init(fromKelvin kelvin: Double) {
//        tempInCelc = kelvin - 273.15
//    }
//}
//
//let celcFromFar = Celcius(fromFarenheit: 100)
//let celcFromKel = Celcius(fromKelvin: 300)
//
//print(celcFromFar.tempInCelc)
//print(celcFromKel.tempInCelc)
//

class Hero { // Reference-Type
    var name: String

    init(name: String) {
        self.name = name
    }
}

var hero = Hero(name: "Spider-Man")
var copyHero = hero
copyHero.name = "Iron-Man"

print(hero.name) // Iron-Man
print(copyHero.name) // Iron-Man


struct Cub {
    var side: Double = 2 {
        willSet {
            print("Side will be change from \(side) to \(newValue)")
        }
        didSet {
            print("Side was changed to \(side) from \(oldValue)")
        }
    }

    // Computed Property
    var square: Double {
        get {
            return side * side
        }
        set {
            side = sqrt(newValue)
        }
    }
}

var rect = Cub(side: 4)
print(rect.square)
rect.square = 25
print(rect.side)

struct Counter {
    var count = 0

    init(count: Int = 0) {
        self.count = count
    }

    mutating func increment(by number: Int) {
        count += number
    }
}

var counter = Counter(count: 5)
counter.increment(by: 2)
print(counter.count)

