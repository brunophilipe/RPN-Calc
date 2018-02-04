//
//  Calculator.swift
//  calc WatchKit Extension
//
//  Created by Bruno Philipe on 4/2/18.
//  Copyright © 2018 Bruno Philipe. All rights reserved.
//

import Foundation

class Calculator
{
	private(set) public var currentDisplay: String = "0"
	
	private var inputBuffer = [Input]()
	private var operationStack = [Float]()
	
	public func take(inputButton: Button)
	{
		switch inputButton
		{
		case .digit(let digit):
			inputBuffer.append(.digit(digit))
			updateDisplayFromInputBuffer()
		
		case .doubleZero:
			inputBuffer.append(.digit(0))
			inputBuffer.append(.digit(0))
			updateDisplayFromInputBuffer()
			
		case .period:
			// Only accept a period if the input buffer has no periods yet
			if !inputBuffer.contains(.period)
			{
				inputBuffer.append(.period)
				updateDisplayFromInputBuffer()
			}
			
		case .backspace:
			if inputBuffer.count > 0
			{
				inputBuffer.removeLast()
				updateDisplayFromInputBuffer()
			}
			else
			{
				operationStack.removeAll()
				currentDisplay = "0.0"
			}
			
		case .enter:
			if inputBuffer.count > 0, let inputAsFloat = inputBuffer.floatValue
			{
				inputBuffer.removeAll()
				operationStack.push(inputAsFloat)
			}
			else if let stackTop = operationStack.top
			{
				// If the input buffer is empty, we instead duplicate the top element in the stack.
				operationStack.push(stackTop)
			}
			
		case .operation(let operation):
			if inputBuffer.count > 0, let inputAsFloat = inputBuffer.floatValue
			{
				inputBuffer.removeAll()
				operationStack.push(inputAsFloat)
				runOperation(operation)
			}
			else
			{
				runOperation(operation)
			}
		}
	}
	
	private func runOperation(_ operation: Operation)
	{
		guard operationStack.depth >= operation.requiredDepth else
		{
			return
		}
		
		switch (operation, operationStack.depth)
		{
		case (.addition, 1):
			operationStack.push(operationStack.pop()!)
		
		case (.addition, _):
			let valueA = operationStack.pop()!
			let valueB = operationStack.pop()!
			operationStack.push(valueA + valueB)
			
		case (.subtraction, 1):
			operationStack.push(operationStack.pop()! * -1)
			
		case (.subtraction, _):
			let valueA = operationStack.pop()!
			let valueB = operationStack.pop()!
			operationStack.push(valueB - valueA)
			
		case (.multiplication, _):
			let valueA = operationStack.pop()!
			let valueB = operationStack.pop()!
			operationStack.push(valueA * valueB)
			
		case (.division, _):
			let valueA = operationStack.pop()!
			let valueB = operationStack.pop()!
			operationStack.push(valueB / valueA)
			
		case (.exponentiation, _):
			let valueA = operationStack.pop()!
			let valueB = operationStack.pop()!
			operationStack.push(powf(valueB, valueA))
			
		case (.squareRoot, _):
			operationStack.push(sqrtf(operationStack.pop()!))
		}
		
		updateDisplayFromStack()
	}
	
	fileprivate enum Input: Equatable
	{
		case digit(Int)
		case period
		
		static func ==(lhs: Calculator.Input, rhs: Calculator.Input) -> Bool
		{
			switch (lhs, rhs)
			{
			case (.digit(let leftDigit), .digit(let rightDigit)): return leftDigit == rightDigit
			case (.period, .period): return true
			default: return false
			}
		}
		
		var stringValue: String
		{
			switch self
			{
			case .digit(let digit): return "\(digit)"
			case .period: return "."
			}
		}
	}
	
	private func updateDisplayFromInputBuffer()
	{
		if let inputAsFloat = inputBuffer.floatValue
		{
			currentDisplay = "\(inputAsFloat)"
		}
		else
		{
			currentDisplay = "Error"
		}
	}
	
	private func updateDisplayFromStack()
	{
		if let topOfStack = operationStack.top
		{
			currentDisplay = "\(topOfStack)"
		}
		else
		{
			currentDisplay = "Error"
		}
	}
	
	enum Button
	{
		case digit(Int)
		case doubleZero
		case enter
		case backspace
		case period
		case operation(Operation)
	}
	
	enum Operation
	{
		case addition
		case subtraction
		case multiplication
		case division
		case squareRoot
		case exponentiation
		
		var requiredDepth: Int
		{
			switch self
			{
			case .addition: 		return 1
			case .subtraction: 		return 1
			case .multiplication:	return 2
			case .division:			return 2
			case .squareRoot:		return 1
			case .exponentiation:	return 2
			}
		}
	}
}

private extension Array where Element == Calculator.Input
{
	var floatValue: Float?
	{
		// Prepending a zero is a quick way to make numbers starting with a period work (eg: ".37" => 0.37).
		return Float("0" + map({ $0.stringValue }).joined())
	}
}

/// Provided by objects that behave like stacks.
private protocol Stack
{
	associatedtype StackElement
	
	/// Inserts an element at the start of the array (top of the stack).
	mutating func push(_ element: StackElement)
	
	/// Removes the element at the start of the array (top of the stack) and returns it, if any.
	mutating func pop() -> StackElement?
	
	/// Allows the top element of the stack to be read without it being popped.
	var top: StackElement? { get }
	
	/// Returns the stack depth (how many items are there in the stack).
	var depth: Int { get }
}


extension Array: Stack
{
	typealias StackElement = Element
	
	mutating func push(_ element: Element)
	{
		insert(element, at: 0)
	}
	
	mutating func pop() -> Element?
	{
		return remove(at: 0)
	}
	
	var top: Element?
	{
		return depth > 0 ? self[0] : nil
	}
	
	var depth: Int
	{
		return count
	}
}
