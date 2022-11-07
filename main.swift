//
// Bachelor of Software Engineering
// Media Design School
// Auckland
// New Zealand
//
// (c) 2022 Media Design School
//
// File Name     : main.swift
// Description   : Command line app to generate and solve sudokus
// Author        : Oliver Webb-Speight
// Mail          : Oliver.Webb-Speight@mds.ac.nz
//

import Glibc // Used to clear the console
//Glibc.system("clear")

// Structure to hold the values of the Sudoku
struct structTwoDimentionalArray {
  let m_iRows: Int, m_iColumns: Int
  var m_aiGrid: [Int]
  
  init(_iRows: Int, _iColumns: Int) {
    self.m_iRows = _iRows
    self.m_iColumns = _iColumns
    m_aiGrid = Array(repeating: 0, count: m_iRows * m_iColumns)
  }
  
  func IsIndexValid(_iRow: Int, _iColumn: Int) -> Bool {
    return (_iRow >= 0) && (_iRow < m_iRows) && (_iColumn >= 0) && (_iColumn < m_iColumns)
  }

  // essentially used as a copy constructor
  func duplicate() -> Any {
    var aiDuplicated = structTwoDimentionalArray(_iRows: m_iRows, _iColumns: m_iColumns)
    for i in 0...(m_iRows - 1) {
      for j in 0...(m_iColumns - 1) {
        aiDuplicated[i, j] = m_aiGrid[(i * m_iColumns) + j]
      }
    }

    return aiDuplicated
  }

  // allows access similar to a two dimentional array
  subscript(_iRow: Int, _iColumn: Int) -> Int {
    get {
      assert(IsIndexValid(_iRow: _iRow, _iColumn: _iColumn), "Index out of range")
      return m_aiGrid[(_iRow * m_iColumns) + _iColumn]
    }
    set {
      assert(IsIndexValid(_iRow: _iRow, _iColumn: _iColumn), "Index out of range")
      m_aiGrid[(_iRow * m_iColumns) + _iColumn] = newValue
    }
  }

  subscript(_iIndex: Int) -> Int {
    get {
      assert(_iIndex < (m_iRows * m_iColumns), "Index out of range")
      return m_aiGrid[_iIndex]
    }
    set {
      assert(_iIndex < (m_iRows * m_iColumns), "Index out of range")
      m_aiGrid[_iIndex] = newValue
    }
  }
}

// Overloading equvilance operator
func ==(_lhs: structTwoDimentionalArray, _rhs: structTwoDimentionalArray) -> Bool {
  guard _lhs.m_iRows == _rhs.m_iRows && _lhs.m_iColumns == _rhs.m_iColumns else {
    return false
  }
    for i in 0...(_lhs.m_iRows - 1) {
      for j in 0...(_lhs.m_iColumns - 1) {
        if (_lhs[i, j] != _rhs[i, j])
        {
          return false
        }
      }
    }
  return true
}

// Used for conversion of string of integer characters to an array of integers
extension String {
  func ConvertToIntArray() -> [Int] {
    return self.compactMap{$0.wholeNumberValue}
  }
}


//                                                       SUDOKU STRUCTURE
struct structSudoku {
  var m_ai2DGrid = structTwoDimentionalArray(_iRows: 9, _iColumns: 9)

  // Constructor 
  init(_ _iMenuOption: Int) {

    switch (_iMenuOption) {
      case 1:
        RequestInputToGenerateGrid()
      
      case 2:
        GenerateSetGrid()

      case 3:
        fallthrough

      case 4:
        GenerateRandomGrid()

      default:
        break
    }
  }

  // Used to ensure row is valid before entering it into the grid
  func IsRowInputValid(_ _iRowIndex: Int, _ _aiRow: [Int]) -> Bool {
    
    // Check self for no duplicates excluding zero
    for i in 0...8 {
      if (_aiRow[i] != 0) {
        for j in 0...8 {
          if (i != j) {
            if (_aiRow[i] == _aiRow[j]) {
              return false
            }
          }
        }
      }
    }
    var bElementValueFoundInTakenSet = false
    // Check each element in row is not within its set of taken numbers
    for iColumn in 0...8 {
      let aiSetOfTakenNumbers = FindSetOfTakenNumbers(_iRowIndex, iColumn)

      aiSetOfTakenNumbers.forEach {
        if ($0 == _aiRow[iColumn]) {
          bElementValueFoundInTakenSet = true // required instead of just returning false as cant in for each
        }
      }

      if(bElementValueFoundInTakenSet) {
        return false
      }
      
    }
    return true
  }

  
  // Requests valid user input to generate/update Sudoku grid
  mutating func RequestInputToGenerateGrid(){
    Glibc.system("clear")
    print("Please input the Sudoku row by row with zeros for empty squares (123406789)")
    print("")
    
    for indexRow in 0...8 {
      var bInputValid = true

      repeat {
        // Reset inputValid
        bInputValid = true

        print("")
        print("Row \(indexRow + 1): ", terminator: " ") // +1 to account for zero index
        let sInput = readLine()

        // need to unwrap
        if let iInputUnwrapped = sInput {
          
          if (iInputUnwrapped.count == 9) {
            
            iInputUnwrapped.forEach {
              if (!($0.isNumber)) {
                // Input invalid
                bInputValid = false
                print("Input invalid: Please ensure all inputs are integers")
              }
            }

            if (bInputValid) // Put into Sudoku Grid
            {
              let aiValidInputtedRow = iInputUnwrapped.ConvertToIntArray()
              
              if (IsRowInputValid(indexRow, aiValidInputtedRow)) {
                for indexColumn in 0...8 {
                  m_ai2DGrid[indexRow, indexColumn] = aiValidInputtedRow[indexColumn]
                }
                print("Inputted row: \(aiValidInputtedRow)")
              }
              else {
                bInputValid = false
                print("Input invalid: Row has duplicates or with previous inputs generates an invalid puzzle")
              }
              
              
            }
            
            
          }
          else // Input Invalid
          {
            bInputValid = false
            print("Input invalid: Please enter 9 integers")
          }
          
        }
        else // Input invalid
        {
          bInputValid = false
          print("Input invalid: No data entered")
        }
        
      } while (!bInputValid) 

      //print(m_ai2DGrid[2,2])
    }
  }

  // Sets the row into the grid
  mutating func SetRow(_ _iRow: Int, _ _aiRow: [Int]) -> Void{
    for iColumn in 0...8 {
      m_ai2DGrid[_iRow - 1, iColumn] = _aiRow[iColumn] // -1 to account for 0 indexed array
    }
  }

  // Example Sudoku used in Brief
  mutating func GenerateSetGrid() -> Void {
    let aiRow1 = [8, 0, 0,  4, 0, 6,  0, 0, 7]
    let aiRow2 = [0, 0, 0,  0, 0, 0,  4, 0, 0]
    let aiRow3 = [0, 1, 0,  0, 0, 0,  6, 5, 0]

    let aiRow4 = [5, 0, 9,  0, 3, 0,  7, 8, 0]
    let aiRow5 = [0, 0, 0,  0, 7, 0,  0, 0, 0]
    let aiRow6 = [0, 4, 8,  0, 2, 0,  1, 0, 3]

    let aiRow7 = [0, 5, 2,  0, 0, 0,  0, 9, 0]
    let aiRow8 = [0, 0, 1,  0, 0, 0,  0, 0, 0]
    let aiRow9 = [3, 0, 0,  9, 0, 2,  0, 0, 5]

    SetRow(1, aiRow1)
    SetRow(2, aiRow2)
    SetRow(3, aiRow3)

    SetRow(4, aiRow4)
    SetRow(5, aiRow5)
    SetRow(6, aiRow6)

    SetRow(7, aiRow7)
    SetRow(8, aiRow8)
    SetRow(9, aiRow9)
      
  }

  // Used to help generate random grid based off an initial array
  func OffsetArrayElements(_ _iOffset: Int, _ _iArray: inout [Int], _ _iFirstRow: [Int]) {

    let iCurrentRow: Int = _iOffset / 3
    var iSubSquareOffset: Int
    
    switch (iCurrentRow) {
      case (1...3):
        iSubSquareOffset = 0

      case (4...6):
        iSubSquareOffset = 1

      case (7...9):
        iSubSquareOffset = 2
      
      default:
        iSubSquareOffset = 0
    }
    
    
    for i in 0...(_iArray.count - 1) {
      _iArray[i] = _iFirstRow[(i + _iOffset + iSubSquareOffset) % _iArray.count] // will wrap values
    }
  }
  
  
  // Generates a random Sudoku that is garenteed to be solvable
  mutating func GenerateRandomGrid() -> Void {

    // Request difficulty from user
    print("")
    print("")
    print("")
    print("Difficulty")
    print("")
    print("1) Easy")
    print("2) Intermediate")
    print("3) Hard")
    print("4) Extreme - Only Grandparents can solve")
    print("")

    
    var bInputValid: Bool
    //var EDifficultySelection: EDIFFICULTYOPTIONS
    var iElementsToBeErased = 0

    repeat {
      bInputValid = true
      
      print("Select difficulty(1-4):", terminator: " ")

      if let sInputUnwrapped = readLine() {

        let iDifficultySelection = Int(sInputUnwrapped)
        
       //let EDifficultySelection = Int(sInputUnwrapped) as! EDIFFICULTYOPTIONS ?? 0
        switch (iDifficultySelection) {
          case 1:
            iElementsToBeErased = 36
        
          case 2:
            iElementsToBeErased = 54
          
          case 3:
            iElementsToBeErased = 63
          
          case 4:
            iElementsToBeErased = 72
  
          default:
            bInputValid = false
            print("")
            print("Input Invalid; Please input a valid integer")
        
        }
      }
      else {
        print("")
        print("Please make an input")

        bInputValid = false
      }
      
      
    } while (!bInputValid)


    //                              Generate Random Complete Grid
    // First generate a random row
    var aiFirstRow = [1, 2, 3, 4, 5, 6, 7, 8, 9]

    // For each element, swap it with another random element
    for i in 0...8 {
      let iRandomIndex = Int.random(in: 0...8)
      
      let iTemp = aiFirstRow[i]
      
      aiFirstRow[i] = aiFirstRow[iRandomIndex]
      aiFirstRow[iRandomIndex] = iTemp
    }

    // Create each row  by offsetting the valid row in a fashion that keeps the puzzle valid
    for iRow in 1...9 {
      var aiRow = [0, 0, 0, 0, 0, 0, 0, 0, 0]
      OffsetArrayElements(iRow * 3, &aiRow, aiFirstRow)
      
      SetRow(iRow, aiRow)
    }
    //PrintGrid()
    
    //print(iElementsToBeErased)

       // Make an array of coords and delete values at random elements and remove them from the array
    var aiiListOfCoords: [(Int, Int)] = []
    for iRow in 0...8 {
      for iColumn in 0...8 {
        aiiListOfCoords.append((iRow, iColumn))
      }
    } 
      
    //Eliminate a number of the elements based on difficulty
    for _ in 0..<iElementsToBeErased {
      
      let iCoordsTuple = aiiListOfCoords.randomElement()!
      m_ai2DGrid[iCoordsTuple.0, iCoordsTuple.1] = 0
      aiiListOfCoords.removeAll(where: {$0 == iCoordsTuple})
      
    }
    // Used for debugging
    /*
    var iCount = 0
    Array(0...80).forEach({if (m_ai2DGrid[$0] == 0) {iCount += 1}})
    print(iCount)
    */
    
  }

  // Prints the grid to the console
  func PrintGrid() -> Void {
    for indexRow in 0...8 {
      for indexColumn in 0...8 {
        
        print(m_ai2DGrid[indexRow, indexColumn], terminator: " ")
        
        if (indexColumn == 2 || indexColumn == 5) {
          print("|", terminator: " ")
        }
        
      }
      print("")

      if (indexRow == 2 || indexRow == 5) {
        print("--------------------")
      }
    }
  }

  // Checks if number is in the array
  func IsNumberPresentInSet(_ _iNumber: Int, _ _iSet: Set<Int>) -> Bool {
    var bNumberFound = false
    _iSet.forEach {
      if (_iNumber == $0) {
        bNumberFound = true
      }
    }
    return bNumberFound
  }

  // Given coords; finds the subsquare base location (top left)
  func FindSubSquareLoc3x3(_ _iRow: Int, _ _iColumn: Int) -> (Int, Int) {
    return ((_iRow / 3), (_iColumn / 3)) // Truncation will drop the decimal and round down
  }

  // populate set of taken numbers from current row, column and subsquare
  func FindSetOfTakenNumbers(_ _iRow: Int, _ _iColumn: Int) -> Set<Int>{

    var aiSetOfTakenNumbers = Set<Int>()
    
    for index in 0...8 {
      // load row
      aiSetOfTakenNumbers.insert(m_ai2DGrid[_iRow, index])
      // load column
      aiSetOfTakenNumbers.insert(m_ai2DGrid[index, _iColumn])
    }
  
    // load subsquare
    let (iSubSquareRowSet, iSubSquareColumnSet) = FindSubSquareLoc3x3(_iRow, _iColumn)
    for i in 0...2 {
      for j in 0...2 {
      aiSetOfTakenNumbers.insert(m_ai2DGrid[(iSubSquareRowSet * 3) + i, (iSubSquareColumnSet * 3) + j])
      }
    }

    aiSetOfTakenNumbers.remove(0)

    return aiSetOfTakenNumbers
  }

  // Called to solve the Sudoku held in the grid
  mutating func Solve() -> Bool {

    print("")
    print("")
    print("Solving!")
    
    var bSolved = true
    var bFailedToFindNewNumber = false
    
    // main iterative loop over grid
    repeat {
      // Reset as it is flagged if the sudoku is NOT solved
      bSolved = true
      
      // Used to see if no numbers have been changed this loop
      let ai2DGridSnapshot = m_ai2DGrid.duplicate() as! structTwoDimentionalArray
      
      InitialSolveStrategyLoop(_bSolved: &bSolved)

      // If no numbers have been changed then this method will provide no further numbers
      bFailedToFindNewNumber = (ai2DGridSnapshot == m_ai2DGrid)
      
    } while(!bSolved && !bFailedToFindNewNumber)

    
    if (bFailedToFindNewNumber && !bSolved) // Begin next solve strategy
    {
      return BruteForceDFSSolvingAlgorithm() // Returns true if successfull and false if unsuccessful
    }
    else {
      return true // Solved by initial strategy
    }
    
  }

  // Finds numbers that can immediately be filled in if they are the only valid number in the difference of the set of possible numbers and the collated set of row, column, subsquare numbers
  mutating func InitialSolveStrategyLoop(_bSolved: inout Bool) -> Void {
    for iRow in 0...8 {
        for iColumn in 0...8{
          if (m_ai2DGrid[iRow, iColumn] == 0){
            
            let aiSetOfPossibleNumbers: Set = [1, 2, 3, 4, 5, 6, 7, 8, 9]
            let aiSetOfTakenNumbers = FindSetOfTakenNumbers(iRow, iColumn)

            // SetA - SetB = (set of elements in A but not in B)
            let aiSetOfRemainingNumbers = aiSetOfPossibleNumbers.subtracting(aiSetOfTakenNumbers)
            //print(aiSetOfRemainingNumbers)

            
            // if there is only 1 possible number left - assign it to the present element
            if (aiSetOfRemainingNumbers.count == 1) {
              m_ai2DGrid[iRow, iColumn] = aiSetOfRemainingNumbers.max() ?? 0 // As it is a singleton set it will return the one value it contains
     
            }
            else
            {
              _bSolved = false // Tag as unsolved so grid will be iterated over in future
            }
            
          }
        }
      }
  }

  // DFSesque method - find a valid number then the next gaps valid number until a gap cant find a valid number; then return up one level and find another valid number and continue on as before or if a valid number cant be found again return up a further level and repeat
  mutating func BruteForceDFSSolvingAlgorithm() -> Bool {

    for iRow in 0...8 {
      for iColumn in 0...8 {

        // Find first occurance of a zero
        if (m_ai2DGrid[iRow, iColumn] == 0) {
          
          // Find row, column and subsquare collated taken numbers for this element
          let aiSetOfTakenNumbers = FindSetOfTakenNumbers(iRow, iColumn)

          // Find valid number
          for iPossibleNumber in 1...9 {
            if (!(IsNumberPresentInSet(iPossibleNumber, aiSetOfTakenNumbers))) {
              
              // Valid number is found
              m_ai2DGrid[iRow, iColumn] = iPossibleNumber

              // Recursively call
              if (BruteForceDFSSolvingAlgorithm()) {
                // Once last valid number is found it will return true and all recursive calls on the stack will cascade as true till the base call returns true
                return true
              }
              else {
                // reset this number as a future number can not find a solution with this number as it is
                m_ai2DGrid[iRow, iColumn] = 0
              }
            }
            else
            {
              // Number is not valid progress to the next possible number
            }
            
          }
          // No valid number found with previous numbers as they are - return up a level to try another
          return false
        }
      }
    }

    return true // There are no more zeros remaining in the sudoku
  }

  
  
}




// START OF MAIN PROGRAM

let closurePushEnterToContinue = { () -> Void in print("Push enter to continue: ", terminator: " "); readLine()}

var bGameRunning = true

while(bGameRunning) {
  Glibc.system("clear")
  print("Welcome to the Super Sudoku Solver Supreme!")
  print("")
  print("1) Input a Sudoku to be solved")
  print("2) Solve the set example Sudoku")
  print("3) Generate a random Sudoku")
  print("4) Generate and solve a random Sudoku")
  print("5) Exit the Program")
  print("")
  
  var bInputValid: Bool
  
    repeat {
      bInputValid = true
      
      print("Select Option(1-5):", terminator: " ")
  
      if let sInputUnwrapped = readLine() {
  
        let iMenuSelection = Int(sInputUnwrapped)

        switch (iMenuSelection) {
          case 1,2,4:
            var Sudoku = structSudoku(iMenuSelection!)
            Glibc.system("clear")
            Sudoku.PrintGrid()
            print("")
            print("")
            print("")
            if(Sudoku.Solve()) {
              print("Solved!")
            }
            else {
             print("Sudoku can not be solved!")
            }
            Sudoku.PrintGrid()
            print("")
            print("")
            print("")
            closurePushEnterToContinue()
          
          case 3:
            var Sudoku = structSudoku(iMenuSelection!)
          
            Glibc.system("clear")
            Sudoku.PrintGrid()
            print("")
            print("")
            print("")
            print("Push enter to solve: ", terminator: " ")
            readLine()
            print("")
            if(Sudoku.Solve()) {
              print("Solved!")
            }
            else {
             print("Sudoku can not be solved!")
            }
            Sudoku.PrintGrid()
            print("")
            print("")
            print("")
            closurePushEnterToContinue()
          
  
          case 5:
            bGameRunning = false
  
          default:
            bInputValid = false
            print("")
            print("Input Invalid; Please input a valid integer")
        
        }
      }
      else {
        print("")
        print("Please make an input")
  
        bInputValid = false
      }
      
      
    } while (!bInputValid)
}

Glibc.system("clear")
print("Thank you! Have a nice Day!")



// Unutilised attempt to solve with recursive enums
/*
//                                      ENUMS
enum ESUDOKU_NUM_ROW{
  case iPossibleNumbers([Int])
  indirect case ERow(ESUDOKU_NUM_ROW, ESUDOKU_NUM_ROW, ESUDOKU_NUM_ROW, ESUDOKU_NUM_ROW, ESUDOKU_NUM_ROW, ESUDOKU_NUM_ROW, ESUDOKU_NUM_ROW, ESUDOKU_NUM_ROW, ESUDOKU_NUM_ROW)
}

enum ESUDOKU_NUM_COLUMN{
  case iPossibleNumbers([Int])
  indirect case ECOLUMN(ESUDOKU_NUM_COLUMN, ESUDOKU_NUM_COLUMN, ESUDOKU_NUM_COLUMN, ESUDOKU_NUM_COLUMN, ESUDOKU_NUM_COLUMN, ESUDOKU_NUM_COLUMN, ESUDOKU_NUM_COLUMN, ESUDOKU_NUM_COLUMN, ESUDOKU_NUM_COLUMN)
}

enum ESUDOKU_NUM_SUBSQUARE{
  case iPossibleNumbers([Int])
  indirect case ESUBSQUARE(ESUDOKU_NUM_SUBSQUARE, ESUDOKU_NUM_SUBSQUARE, ESUDOKU_NUM_SUBSQUARE, ESUDOKU_NUM_SUBSQUARE, ESUDOKU_NUM_SUBSQUARE, ESUDOKU_NUM_SUBSQUARE, ESUDOKU_NUM_SUBSQUARE, ESUDOKU_NUM_SUBSQUARE, ESUDOKU_NUM_SUBSQUARE)
}

enum ESUDOKU_NUM {
  case iNumber(Int)
  indirect case ERow([ESUDOKU_NUM])
  indirect case EColumn([ESUDOKU_NUM])
  indirect case ESUBSQUARE([ESUDOKU_NUM])
}

func IsNumberPresentInArray(_ iNumber: Int, _ iArray: [Int]) -> Bool {
  var bNumberFound = false
  iArray.forEach {
    if (iNumber == $0) {
      bNumberFound = true
    }
  }
  return bNumberFound
}

let array = [1, 2, 3, 4, 6, 7, 8]

print("\(IsNumberPresentInArray(2, array))")
print("\(IsNumberPresentInArray(5, array))")

func EvaluatePossibleNums(_ ESudoku: ESUDOKU_NUM, _ aiPossibleNumbers: [Int]) -> Int {

  switch ESudoku {
    case let .iNumber(iValue):
      return iValue
    case let .ERow(aRow):
      return EvaluatePossibleNums(ESudoku, aiPossibleNumbers)
  }
}


//                                       INDIRECT ENUM EXAMPLE
indirect enum ArithmeticExpression {
  case number(Int)
  case addition(ArithmeticExpression, ArithmeticExpression)
  case multiplication(ArithmeticExpression, ArithmeticExpression)
}

//Solve (5 + 4) * 2
let five = ArithmeticExpression.number(5)
let four = ArithmeticExpression.number(4)
let sum = ArithmeticExpression.addition(five, four)
let product = ArithmeticExpression.multiplication(sum, ArithmeticExpression.number(2))

func evaluate(_ expression: ArithmeticExpression) -> Int {
  switch expression {
    case let .number(value):
      return value
    case let .addition(left, right):
      return evaluate(left) + evaluate(right)
    case let .multiplication(left, right):
      return evaluate(left) * evaluate(right)
  }
}

print(evaluate(product))
*/




// Create Rows, Columns and SubSquares then pass a index and an array to be filled with possible numbers for that index



//func EvaluatePossibleNums(_ Sudoku: ESUDOKUNUM) -> [Int] {
//  switch Sudoku {
//    case let .iNumber(value):
//      return value
   // case let .ERow(R1, R2, R3, R4, R5, R6, R7, R8, R9):
     // return
//  }
//}
