//
//  InterfaceController.swift
//  calc WatchKit Extension
//
//  Created by Bruno Philipe on 3/2/18.
//  Copyright © 2018 Bruno Philipe. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController
{	
	@IBOutlet weak var calculatorDisplay: WKInterfaceLabel!
	
	
	private var calculator = Calculator()
	
    override func awake(withContext context: Any?)
	{
        super.awake(withContext: context)
        
        // Configure interface objects here.
		setTitle("0.0")
    }
    
    override func willActivate()
	{
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate()
	{
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}

//class CalculatorButton: WKInterfaceButton
//{
//	enum Kind
//	{
//		case digit(Int)
//		case enter
//		case backspace
//		case period
//		case operation(Operation)
//	}
//
//	enum Operation
//	{
//		case add
//		case subtract
//		case multiply
//		case divide
//	}
//}

extension InterfaceController //IBActions
{
	@IBAction func didTap(buttonDigitOne: WKInterfaceButton)
	{
		didTapButton(.digit(1))
	}
	
	@IBAction func didTap(buttonDigitTwo: WKInterfaceButton)
	{
		didTapButton(.digit(2))
	}
	
	@IBAction func didTap(buttonDigitThree: WKInterfaceButton)
	{
		didTapButton(.digit(3))
	}
	
	@IBAction func didTap(buttonDigitFour: WKInterfaceButton)
	{
		didTapButton(.digit(4))
	}
	
	@IBAction func didTap(buttonDigitFive: WKInterfaceButton)
	{
		didTapButton(.digit(5))
	}
	
	@IBAction func didTap(buttonDigitSix: WKInterfaceButton)
	{
		didTapButton(.digit(6))
	}
	
	@IBAction func didTap(buttonDigitSeven: WKInterfaceButton)
	{
		didTapButton(.digit(7))
	}
	
	@IBAction func didTap(buttonDigitEight: WKInterfaceButton)
	{
		didTapButton(.digit(8))
	}
	
	@IBAction func didTap(buttonDigitNine: WKInterfaceButton)
	{
		didTapButton(.digit(9))
	}
	
	@IBAction func didTap(buttonDigitZero: WKInterfaceButton)
	{
		didTapButton(.digit(0))
	}
	
	@IBAction func didTap(buttonDigitDoubleZero: WKInterfaceButton)
	{
		didTapButton(.doubleZero)
	}
	
	@IBAction func didTap(buttonPeriod: WKInterfaceButton)
	{
		didTapButton(.period)
	}
	
	@IBAction func didTap(buttonEnter: WKInterfaceButton)
	{
		didTapButton(.enter)
	}
	
	@IBAction func didTap(buttonBackspace: WKInterfaceButton)
	{
		didTapButton(.backspace)
	}
	
	@IBAction func didTap(buttonMultiplication: WKInterfaceButton)
	{
		didTapButton(.operation(.multiplication))
	}
	
	@IBAction func didTap(buttonDivision: WKInterfaceButton)
	{
		didTapButton(.operation(.division))
	}
	
	@IBAction func didTap(buttonAddition: WKInterfaceButton)
	{
		didTapButton(.operation(.addition))
	}
	
	@IBAction func didTap(buttonSubtraction: WKInterfaceButton)
	{
		didTapButton(.operation(.subtraction))
	}
	
	@IBAction func didTap(buttonExponentiation: WKInterfaceButton)
	{
		didTapButton(.operation(.exponentiation))
	}
	
	@IBAction func didTap(buttonSquareRoot: WKInterfaceButton)
	{
		didTapButton(.operation(.squareRoot))
	}
	
	private func didTapButton(_ button: Calculator.Button)
	{
		calculator.take(inputButton: button)
		setTitle(calculator.currentDisplay)
	}
}
