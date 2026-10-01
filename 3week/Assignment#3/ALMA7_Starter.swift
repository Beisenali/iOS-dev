// =============================================================
//  Station ALMA-7: Rescue Protocol
//  iOS Mobile Development · Module 3 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_Starter.swift
//
//  Rules:
//   • Do NOT modify the STARTER CODE section.
//   • `!` (force unwrap) is forbidden: −0.5 points each.
//   • No map / filter / reduce / compactMap.
//   • Use the exact function names from the assignment PDF.
// =============================================================


// MARK: - =================== STARTER CODE ===================
// MARK: - Do not modify anything in this section

typealias Reading = (sensor: String, value: Int)

/// Splits a string at the first occurrence of the separator.
/// splitOnce("O2:87", by: ":") -> ("O2", "87")
/// splitOnce("hello", by: ":") -> nil
func splitOnce(_ line: String, by separator: Character) -> (String, String)? {
    guard let index = line.firstIndex(of: separator) else { return nil }
    let left = String(line[..<index])
    let right = String(line[line.index(after: index)...])
    return (left, right)
}

let rawLog = [
    "O2:87", "TEMP:-12", "O2:9x", "PRESS:101", "TEMP:abc", "O2:",
    "RAD:3", "O2:64", ":55", "TEMP:31", "PRESS:98", "O2:71",
    "RAD:-1", "TEMP:4", "PRESS:1o2", "O2:90"
]

class Tank {
    var level: Int
    init(level: Int) { self.level = level }
}

class Module {
    let name: String
    var oxygenTank: Tank?
    init(name: String, oxygenTank: Tank?) {
        self.name = name
        self.oxygenTank = oxygenTank
    }
}

class CrewMember {
    let name: String
    let role: String
    let priority: Int      // 1 = evacuated first
    var module: Module?    // nil = in open space
    init(name: String, role: String, priority: Int, module: Module?) {
        self.name = name
        self.role = role
        self.priority = priority
        self.module = module
    }
}

let lab  = Module(name: "Lab",  oxygenTank: Tank(level: 40))
let hab  = Module(name: "Hab",  oxygenTank: Tank(level: 12))
let dock = Module(name: "Dock", oxygenTank: nil)

let crew = [
    CrewMember(name: "Timur",   role: "Engineer",  priority: 3, module: lab),
    CrewMember(name: "Dana",    role: "Scientist", priority: 4, module: dock),
    CrewMember(name: "Aigerim", role: "Commander", priority: 1, module: hab),
    CrewMember(name: "Nurlan",  role: "Pilot",     priority: 2, module: nil)
]

var roster: [String: CrewMember] = [:]
for member in crew { roster[member.name] = member }

print("ALMA-7 systems online: \(rawLog.count) log lines, \(crew.count) crew members.")

// MARK: - ================= END OF STARTER CODE =================


// MARK: - =================== YOUR SOLUTION ===================
// Uncomment each signature when you start working on it.


// MARK: Level 1 · Decoding Telemetry

// 1.1
func parseReading(_ raw: String) -> Reading? {
    guard let parts = splitOnce(raw, by: ":"),
          !parts.0.isEmpty,
          let value = Int(parts.1),
          value >= 0 || parts.0 == "TEMP" else {
        return nil
    }
    return (sensor: parts.0, value: value)
}

// 1.2
func parseLog(_ lines: [String]) -> (valid: [Reading], invalidCount: Int) {
    var validReadings: [Reading] = []
    var invalid = 0
    
    for line in lines {
        if let validReading = parseReading(line) {
            validReadings.append(validReading)
        } else {
            invalid += 1
        }
    }
    return (validReadings, invalid)
}

let parsedLog = parseLog(rawLog)
let A = parsedLog.invalidCount


// MARK: Level 2 · Analysis

// 2.1
func select(_ readings: [Reading], where isIncluded: (Reading) -> Bool) -> [Reading] {
    var result: [Reading] = []
    for reading in readings {
        if isIncluded(reading) {
            result.append(reading)
        }
    }
    return result
}

func values(of readings: [Reading]) -> [Int] {
    var result: [Int] = []
    for reading in readings {
        result.append(reading.value)
    }
    return result
}

// 2.2
func stats(of values: [Int]) -> (min: Int, max: Int, average: Double)? {
    guard !values.isEmpty else { return nil }
    
    var minVal = values[0]
    var maxVal = values[0]
    var sum = 0
    
    for v in values {
        if v < minVal { minVal = v }
        if v > maxVal { maxVal = v }
        sum += v
    }
    
    return (minVal, maxVal, Double(sum) / Double(values.count))
}

func stats(_ values: Int...) -> (min: Int, max: Int, average: Double)? {
    stats(of: values)
}

let o2Readings = select(parsedLog.valid) { $0.sensor == "O2" }
let o2Values = values(of: o2Readings)
let B = Int(stats(of: o2Values)?.average ?? 0)

// 2.3 · The Closure Ladder (5 sorts, then compare results in code)
let sort1 = parsedLog.valid.sorted(by: { (s1: Reading, s2: Reading) -> Bool in return s1.value > s2.value })
let sort2 = parsedLog.valid.sorted(by: { s1, s2 in return s1.value > s2.value })
let sort3 = parsedLog.valid.sorted(by: { s1, s2 in s1.value > s2.value })
let sort4 = parsedLog.valid.sorted(by: { $0.value > $1.value })
let sort5 = parsedLog.valid.sorted { $0.value > $1.value }


// MARK: Level 3 · Temperature Stabilization

// 3.1
func heatUp(_ t: Int) -> Int { return t + 5 }
func coolDown(_ t: Int) -> Int { return t - 3 }
func hold(_ t: Int) -> Int { return t }

func chooseProtocol(for temp: Int) -> (Int) -> Int {
    if temp < 18 { return heatUp }
    if temp > 24 { return coolDown }
    return hold
}

// 3.2
func runUntilStable(from start: Int, maxSteps: Int = 10) -> (finalTemp: Int, steps: Int, isStable: Bool) {
    var currentTemp = start
    var steps = 0
    
    while (currentTemp < 18 || currentTemp > 24) && steps < maxSteps {
        let protocolFunc = chooseProtocol(for: currentTemp)
        currentTemp = protocolFunc(currentTemp)
        steps += 1
    }
    
    return (currentTemp, steps, currentTemp >= 18 && currentTemp <= 24)
}

let tempReadings = select(parsedLog.valid) { $0.sensor == "TEMP" }
let tempValues = values(of: tempReadings)
let minTemp = stats(of: tempValues)?.min ?? 0

let C = runUntilStable(from: minTemp).steps


// MARK: Level 4 · The Crew

// 4.1
func oxygenLevel(of member: CrewMember) -> Int? {
    return member.module?.oxygenTank?.level
}

// 4.2
func status(of member: CrewMember) -> String {
    guard let module = member.module else {
        return "\(member.name): no data (open space)"
    }
    
    guard let level = oxygenLevel(of: member) else {
        return "\(member.name): no data (\(module.name))"
    }
    
    return level < 20 ? "\(member.name): \(level)% CRITICAL" : "\(member.name): \(level)% OK"
}

// 4.3
@discardableResult
func transferOxygen(from source: inout Int, to target: inout Int, amount: Int) -> Int {
    if amount <= 0 { return 0 }
    
    let take = min(source, amount)
    let space = 100 - target
    let actualTransfer = min(take, space)
    
    source -= actualTransfer
    target += actualTransfer
    
    return actualTransfer
}

var labO2 = lab.oxygenTank?.level ?? 0
var habO2 = hab.oxygenTank?.level ?? 0
transferOxygen(from: &labO2, to: &habO2, amount: 30)
lab.oxygenTank?.level = labO2
hab.oxygenTank?.level = habO2

let D = habO2

// 4.4
func evacuationOrder(_ names: String..., roster: [String: CrewMember]) -> [String] {
    var foundMembers: [CrewMember] = []
    
    for name in names {
        guard let member = roster[name] else {
            print("Unknown crew member: \(name)")
            continue
        }
        foundMembers.append(member)
    }
    
    foundMembers.sort { $0.priority < $1.priority }
    
    var result: [String] = []
    for member in foundMembers { result.append(member.name) }
    
    return result
}


// MARK: Level 5 · The Saboteur's Logbook
/*
 Проблемы в коде саботажника:
 1. `member.module!` - Если у CrewMember нет модуля (open space, например, Нурлан), приложение "упадет" с Fatal Error.
 2. `oxygenTank!` - Если у модуля нет бака (например, у Даны в Dock), произойдет крэш.
 3. `oxygenLevel(of: member)!` - Упадет, если кислород = nil.
 4. Логическая ошибка в `firstCritical`: цикл не останавливается при нахождении первого критического! Он переписывает переменную `result`, возвращая ПОСЛЕДНЕГО человека с критическим кислородом.
 5. `return result!` - Если ни у кого нет критического кислорода, переменная останется nil и вызовет Fatal Error при принудительном извлечении.
 */

func reportOxygen(for member: CrewMember) -> String {
    guard let level = oxygenLevel(of: member) else {
        return "\(member.name): no data"
    }
    return "\(member.name): \(level)%"
}

func firstCritical(in crew: [CrewMember]) -> String? {
    for member in crew {
        if let level = oxygenLevel(of: member), level < 20 {
            return member.name
        }
    }
    return nil
}

// Тест логики Level 5
let testCrew = [
    CrewMember(name: "Test1", role: "A", priority: 1, module: Module(name: "M1", oxygenTank: Tank(level: 10))),
    CrewMember(name: "Test2", role: "B", priority: 2, module: Module(name: "M2", oxygenTank: Tank(level: 5)))
]
print("First critical in test: \(firstCritical(in: testCrew) ?? "none")") // Должно вывести Test1, а не Test2


// MARK: Finale · Launch Code

let launchCode = "\(A)-\(B)-\(C)-\(D)"
print("\nLAUNCH CODE: \(launchCode)")


// MARK: Bonus

func makeAlarm(threshold: Int) -> (Int) -> Bool {
    var counter = 0
    return { currentLevel in
        if currentLevel < threshold {
            counter += 1
            print("Alarm #\(counter)")
            return true
        }
        return false
    }
}


// MARK: - ================= DEFENSE QUESTIONS =================
/*
 1. guard let vs if let beyond syntax:
 `guard let` делает "ранний выход" (early exit), если условие не выполнилось (обязателен return, continue или break). Это спасает код от глубокой вложенности блоков `{ }` ("Пирамиды смерти"), которая появляется при использовании серии `if let`. `if let` делает код хуже, когда нам нужно проверить несколько обязательных условий подряд, чтобы продолжить работу функции.

 2. Why can't you pass [Int] to stats(_ values: Int...)?
 Синтаксис `Int...` позволяет передавать элементы через запятую (например, `stats(1, 2, 3)`), а Swift сам упаковывает их в массив `[Int]` внутри функции. Но передать туда уже готовый массив напрямую нельзя, так как типы на этапе компиляции не совпадают (функция ожидает одиночные значения, а не контейнер-массив).

 3. Why doesn't transferOxygen(from: &x, to: &x, amount: 5) compile?
 Это предотвращает "конфликт доступа к памяти" (Memory Access Conflict). В Swift запрещено одновременно модифицировать одну и ту же переменную через два разных inout параметра (эксклюзивность памяти), иначе поведение программы было бы непредсказуемым.

 4. Why doesn't oxygenLevel(of: dana) ?? "no data" compile?
 `oxygenLevel` возвращает опционал `Int?`, а `"no data"` имеет тип `String`. Оператор `??` (Nil-Coalescing) требует, чтобы значение по умолчанию совпадало по типу с извлекаемым значением. Мы не можем использовать строку там, где ожидается целое число.

 5. Full type of chooseProtocol and how to read it:
 Тип функции: `(Int) -> (Int) -> Int`
 Как читается: "Функция `chooseProtocol` принимает одно значение типа `Int` и ВОЗВРАЩАЕТ другую функцию, которая в свою очередь принимает `Int` и возвращает `Int`".

 Bonus. Where does the alarm counter live after makeAlarm returns?
 Переменная `counter` "захватывается" (captured) замыканием. В Swift замыкания — это ссылочные типы (reference types). Когда `makeAlarm` завершает работу, замыкание сохраняет ссылку на область памяти (heap), где лежит переменная `counter`, и продолжает работать с ней при каждом последующем вызове.
*/
