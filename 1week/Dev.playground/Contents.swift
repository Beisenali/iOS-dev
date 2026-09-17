import Cocoa

let array = [1, 2, 3, 4]
let number: Double = 1
let name: String = "Adam"
let colors: [String] = ["Orange", "Red", "Blue", "Orange"]
let setColors: Set<String> = ["Orange", "Red", "Blue", "Blue"]
let dict: [String: Int] = ["Mom": 7777, "Dad": 1111]
//
//for color in colors {
//    print(color)
//}

let customColor = colors[0]

let mom = dict["Mom"]

for (name, phone) in dict {
    print("Name: \(name) - \(phone)")
}

//for c in setColors {
//    print(c)
//}
