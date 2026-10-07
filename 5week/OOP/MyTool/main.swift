import Foundation

// Encapsulation
struct Person {
    let name: String

    private var age: Int = 19

    func getAge() -> Int {
        //
        return age
    }
    mutating func setAge(_ age: Int) {
        //
        if age == 0 {
            return
        }
        self.age = age
    }
}

let person = Person(name: "John")

// person.age = 0
// person.setAge(20)

// Inheritance & Abstraction

protocol CanFly {
    func fly()
}

class Bird {
    var numberOfEggs: Int {
        return 2
    }
}

class Hawk: Bird, CanFly {
    func fly() {
        print("Hawk")
    }
}

class Penguin: Bird {
}

class Airplane: CanFly {
    func fly() {
        print("Airplane Fly")
    }
}

//let hawk = Hawk()
//print(hawk.numberOfEggs)
//hawk.fly()
//
//let penguin = Penguin()
//print(penguin.numberOfEggs)
//
//let airplane = Airplane()
//airplane.fly()

// Polymorphism

class Animal {
    func makeSound() {
        print("")
    }

    final func eat() {

    }
}

class Dog: Animal {
    override func makeSound() {
        print("")
    }
}

func add(lhs: Int, rhs: Int) -> Int {
    return lhs + rhs
}

func add(lhs: Double, rhs: Double) -> Double {
    return lhs + rhs
}

//add(lhs: 1, rhs: 2)
//add(lhs: 1.2, rhs: 3.2)


// Abstraction

protocol Movable {
    func move()
}

protocol Flyable {
    func fly()
}

protocol Swimmable {
    func swimm()
}

struct Duck: Movable, Flyable, Swimmable {
    func move() {
        print("Move")
    }
    
    func fly() {
        print("Fly")
    }
    
    func swimm() {
        print("Swim")
    }
}

// SOLID
// O - Open / Closed

enum CoffeeType {
    case americano
    case latte
}

protocol Coffee {
    func brew() -> String
}

class Americano: Coffee {
    func brew() -> String {
        "Americano"
    }
}

class Latte: Coffee {
    func brew() -> String {
        "Latte"
    }
}

class CoffeMachine {

    let coffee: Coffee

    init(coffee: Coffee) {
        self.coffee = coffee
    }

    func brewCupOfCoffee() -> String {
        return coffee.brew()
    }
}

let object = Latte()
let coffeMachine = CoffeMachine(coffee: object)
print(coffeMachine.brewCupOfCoffee())


// Extension
extension Int {
    func isBiggerThanThree() -> Bool {
        return self > 3
    }
}

let someInt = 5
//someInt.isBiggerThanThree()

protocol Greet {
    func greeting()
}

extension Greet {
    func greeting() {
        print("Default Greeting!") // A
    }
}

struct GreetStruct: Greet {
    func greeting() {
        print("Struct Greeting") // B
    }
}

private extension GreetStruct {
}

// Inheritance
// Composition vs Aggregation

struct Human {

}

struct Pet {
    let person: Human

    init(person: Human) { // Composition
        self.person = person
    }
}

let human = Human()
let pet = Pet(person: human)

struct Flower {

}

struct Garden {
    var flowers: [Flower] = []
    var selectedFlower: Flower?

    init(selectedFlower: Flower?) {
        self.selectedFlower = selectedFlower
    }
}

var garden = Garden(selectedFlower: nil)
let flower = Flower()

garden.flowers.append(flower)
