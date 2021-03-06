//
//  DrawView.swift
//  Pictionary
//
//  Created by Paul Herz on 2017-12-06.
//  Copyright © 2017 Paul Herz. All rights reserved.
//

import UIKit
import TouchDraw

class DrawView: UIView {
	
	var gradientBackgroundLayer: CARadialGradientLayer!
	
	var winsBox: LabelBox!
	var timerBox: LabelBox!
	var lossesBox: LabelBox!
	var numberStack: UIStackView!
	
	var guessBox: LabelBox!
	
	var canvasContainer: UIView!
	var canvas: TouchDrawView!
	
	var clearButton: UIButton!
	var wordBox: LabelBox!
	var quitButton: UIButton!
	var bottomStack: UIStackView!
	
	var mainStack: UIStackView!
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		gradientBackgroundLayer = {
			let l = CARadialGradientLayer()
			l.startColor = Colors.gradientStart.cgColor
			l.endColor = Colors.gradientEnd.cgColor
			l.frame = layer.frame
			return l
		}()
		layer.addSublayer(gradientBackgroundLayer)
		
		winsBox = {
			let b = LabelBox()
			b.translatesAutoresizingMaskIntoConstraints = false
			b.backgroundColor = Colors.confirmBackground
			b.label.textColor = .white
			b.label.text = "0"
			return b
		}()
		
		timerBox = {
			let b = LabelBox()
			b.translatesAutoresizingMaskIntoConstraints = false
			b.backgroundColor = Colors.text
			b.label.textColor = Colors.inverseText
			b.label.text = "99"
			return b
		}()
		
		lossesBox = {
			let b = LabelBox()
			b.translatesAutoresizingMaskIntoConstraints = false
			b.backgroundColor = Colors.denyBackground
			b.label.textColor = .white
			b.label.text = "0"
			return b
		}()
		
		numberStack = {
			let s = UIStackView(arrangedSubviews: [ winsBox, timerBox, lossesBox ])
			s.translatesAutoresizingMaskIntoConstraints = false
			s.axis = .horizontal
			s.distribution = .equalSpacing
			return s
		}()
//		addSubview(numberStack)
		
		guessBox = {
			let b = LabelBox()
			b.translatesAutoresizingMaskIntoConstraints = false
			b.layer.cornerRadius = 35
			b.backgroundColor = Colors.guessBackground
			b.label.textColor = .white
			b.label.text = "Is it CAT?"
			b.label.textAlignment = .left
			b.label.adjustsFontSizeToFitWidth = true
			return b
		}()
		
		canvasContainer = {
			let v = UIView()
			v.translatesAutoresizingMaskIntoConstraints = false
			v.backgroundColor = .white
			v.layer.cornerRadius = 20
			v.layer.borderColor = Colors.text.cgColor
			v.layer.borderWidth = 7
			v.clipsToBounds = true
			return v
		}()
//		addSubview(canvasContainer)
		
		canvas = {
			let c = TouchDrawView()
			c.translatesAutoresizingMaskIntoConstraints = false
			c.backgroundColor = .clear
			return c
		}()
		canvasContainer.addSubview(canvas)
		
		clearButton = {
			let b = PushButton()
			b.translatesAutoresizingMaskIntoConstraints = false
//			b.setTitle("Clear", for: .normal)
			b.setImage(UIImage(imageLiteralResourceName: "Clear"), for: .normal)
			b.imageView?.translatesAutoresizingMaskIntoConstraints = false
			b.setContentCompressionResistancePriority(.required, for: .horizontal)
			return b
		}()
		addSubview(clearButton)
		
		wordBox = {
			let b = LabelBox()
			b.translatesAutoresizingMaskIntoConstraints = false
			b.backgroundColor = Colors.inverseText
			b.label.textColor = Colors.text
			b.label.adjustsFontSizeToFitWidth = true
			b.label.text = "CAR"
			b.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
			return b
		}()
		addSubview(wordBox)
		
		quitButton = {
			let b = PushButton()
			b.translatesAutoresizingMaskIntoConstraints = false
//			b.setTitle("Quit", for: .normal)
			b.setImage(UIImage(imageLiteralResourceName: "Quit"), for: .normal)
			b.imageView?.translatesAutoresizingMaskIntoConstraints = false
			b.setContentCompressionResistancePriority(.required, for: .horizontal)
			return b
		}()
		addSubview(quitButton)
		
		mainStack = {
			let s = UIStackView(arrangedSubviews: [
				numberStack,
				guessBox,
				canvasContainer,
				UIView()
			])
			s.translatesAutoresizingMaskIntoConstraints = false
			s.axis = .vertical
			s.distribution = .equalSpacing
			s.alignment = .center
			return s
		}()
		addSubview(mainStack)
		
		setNeedsUpdateConstraints()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func updateConstraints() {
		super.updateConstraints()
		
		let margins = layoutMarginsGuide
		numberStack.topAnchor.constraint(equalTo: margins.topAnchor, constant: 10).isActive = true
		numberStack.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
		numberStack.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
		
		winsBox.widthAnchor.constraint(equalTo: timerBox.widthAnchor).isActive = true
		timerBox.widthAnchor.constraint(equalTo: lossesBox.widthAnchor).isActive = true
		winsBox.heightAnchor.constraint(equalTo: timerBox.heightAnchor).isActive = true
		timerBox.heightAnchor.constraint(equalTo: lossesBox.heightAnchor).isActive = true
		lossesBox.heightAnchor.constraint(equalToConstant: 65).isActive = true
		lossesBox.widthAnchor.constraint(equalToConstant: 85).isActive = true
		
		guessBox.heightAnchor.constraint(equalToConstant: 70).isActive = true
		guessBox.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
		guessBox.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
		
		canvasContainer.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
		canvasContainer.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
		canvasContainer.heightAnchor.constraint(equalTo: canvasContainer.widthAnchor).isActive = true
		
		canvas.topAnchor.constraint(equalTo: canvasContainer.topAnchor).isActive = true
		canvas.trailingAnchor.constraint(equalTo: canvasContainer.trailingAnchor).isActive = true
		canvas.leadingAnchor.constraint(equalTo: canvasContainer.leadingAnchor).isActive = true
		canvas.bottomAnchor.constraint(equalTo: canvasContainer.bottomAnchor).isActive = true
		
		mainStack.bottomAnchor.constraint(equalTo: wordBox.topAnchor, constant: -30).isActive = true
		
		clearButton.widthAnchor.constraint(equalTo: quitButton.widthAnchor).isActive = true
		clearButton.heightAnchor.constraint(equalTo: quitButton.heightAnchor).isActive = true
		quitButton.widthAnchor.constraint(equalTo: quitButton.heightAnchor).isActive = true
		clearButton.topAnchor.constraint(equalTo: quitButton.topAnchor).isActive = true
		quitButton.topAnchor.constraint(equalTo: wordBox.topAnchor).isActive = true
		
		clearButton.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
		quitButton.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
		
		// Must remove default vertical centering of button image before recentering
		for b in [clearButton, quitButton] {
			guard let b = b, let iv = b.imageView else { continue }
			let oldConstraints = b.constraints.filter {
				$0.firstAnchor == iv.centerYAnchor || $0.secondAnchor == iv.centerYAnchor
			}
			b.removeConstraints(oldConstraints)
			iv.centerYAnchor.constraint(equalTo: wordBox.centerYAnchor).isActive = true
		}
		
		clearButton.trailingAnchor.constraint(lessThanOrEqualTo: wordBox.leadingAnchor, constant: 0).isActive = true
		quitButton.leadingAnchor.constraint(greaterThanOrEqualTo: wordBox.trailingAnchor, constant: 0).isActive = true
		
		clearButton.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
		quitButton.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
		
		wordBox.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
		wordBox.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: -15).isActive = true
		wordBox.heightAnchor.constraint(equalToConstant: 65).isActive = true
	}
}
