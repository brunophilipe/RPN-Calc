//
//  Calculator.swift
//  calc WatchKit Extension
//
//  Created by Bruno Philipe on 4/2/18.
//  Copyright © 2018 Bruno Philipe. All rights reserved.
//

import Foundation

/// Implementation of an RPN (Reverse Polish Notation) calculator.
class Calculator
{
	private(set) public var currentDisplay: String = "0"

	/// Stores digit and period inputs until enter or an operation input is taken.
	private var inputBuffer = [Input]()

	/// Main memory stack of the calculator.
	private var operationStack = [Float]()

	/// Calulator input function. Will write to the input buffer if an input digit/period is provided, or run an operation.
	public func take(inputButton: Button)
	{
		switch inputButton
		{
		case .digit(let digit):
			inputBuffer.append(.digit(digit))
			updateDisplayFromInputBuffer()
		
		case .doubleZero:
			// Special case of the digit input. We simply append zero twice.
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
				// If the input buffer is not empty, remove the last-inserted element.
				inputBuffer.removeLast()
				updateDisplayFromInputBuffer()
			}
			else
			{
				// If the input buffer is empty, then also empty the operation stack, thus essentially "resetting" the calculator.
				operationStack.removeAll()
				currentDisplay = "0.0"
			}
			
		case .enter:
			if inputBuffer.count > 0, let inputAsFloat = inputBuffer.floatValue
			{
				// If parsing of the input buffer succeeds, we push that value into the operation stack and empty the input buffer.
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
				// If parsing of the input buffer succeeds, we push that value into the operations stack, empty the input buffer, and run
				// the provided operation.
				inputBuffer.removeAll()
				operationStack.push(inputAsFloat)
				runOperation(operation)
			}
			else
			{
				// If the input buffer is empty, we simply operate on whatever is already on the stack.
				runOperation(operation)
			}
		}
	}
	
	private func runOperation(_ operation: Operation)
	{
		// Check whether the operation stack has enough elements for the provided operation.
		guard operationStack.depth >= operation.requiredDepth else
		{
			// If not we simply do nothing for now.
			return
		}

		// Run the operation by popping from the stack, operating, then pushing the result back in.
		switch (operation, operationStack.depth)
		{
		// Commutative operations:
		case (.addition, _):
			operationStack.push(operationStack.pop()! + operationStack.pop()!)

		case (.multiplication, _):
			operationStack.push(operationStack.pop()! * operationStack.pop()!)

		case (.squareRoot, _):
			operationStack.push(sqrtf(operationStack.pop()!))

		case (.subtraction, 1):
			// Subtracting with a stack depth of one has the effect of subtracting the top value
			// from zero, which is equivalent to multiplying it by -1.
			operationStack.push(operationStack.pop()! * -1)

		// Non-commutative operations (those that require a buffer to reorder the operands):
		case (.subtraction, _):
			let buffer = operationStack.pop()!
			operationStack.push(operationStack.pop()! - buffer)
			
		case (.division, _):
			let buffer = operationStack.pop()!
			operationStack.push(operationStack.pop()! / buffer)
			
		case (.exponentiation, _):
			let buffer = operationStack.pop()!
			operationStack.push(powf(operationStack.pop()!, buffer))
		}

		// Write to the display string from the stack top.
		updateDisplayFromStack()
	}

	/// Represents one valid element in the input buffer.
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
	}

	/// Sets the display value from the input buffer.
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

	/// Sets the display value from the top stack element.
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

	/// Represents each of the "buttons" this calculator is capable of undertstanding.
	enum Button
	{
		case digit(Int)
		case doubleZero
		case enter
		case backspace
		case period
		case operation(Operation)
	}

	/// Represents each mathematical operation this calculator can perform.
	enum Operation
	{
		case addition
		case subtraction
		case multiplication
		case division
		case squareRoot
		case exponentiation

		/// How many elements there need to be in the stack so that a specific operation can be executed.
		var requiredDepth: Int
		{
			switch self
			{
			case .addition: 		return 2
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
	/// Parses each input element in the array, operating its value into an accumulator, and returning the accumulator value after the
	/// last element is parsed.
	var floatValue: Float?
	{
		var accumulator: Float = 0.0
		var decimalsExponent: Float = 0.0

		for element in self
		{
			switch (element, decimalsExponent)
			{
			// Integer digits, increasing exponent simply by multiplying by 10
			case (.digit(let digit), 0):
				accumulator *= 10.0
				accumulator += Float(digit)

			// First period input, start decrementing decimals exponent
			case (.period, 0):
				decimalsExponent = -1.0

			// Decimal digits, decreasing exponent by decrementing `decimalsExponent`.
			case (.digit(let digit), let exponent):
				accumulator += Float(digit) * powf(10.0, exponent)
				decimalsExponent -= 1.0

			case (.period, _):
				// This is an error. A number can only have one decimal point. Currently we simply do nothing.
				break
			}
		}

		// Prepending a zero is a quick way to make numbers starting with a period work (eg: ".37" => 0.37).
		return accumulator
	}
}

/// Provided by objects that behave like stacks.
private protocol Stack
{
	associatedtype StackElement
	
	/// Inserts an element at the top of the stack.
	mutating func push(_ element: StackElement)
	
	/// Removes the element from the top of the stack and returns it, if any.
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
