//
//  GameManager.swift
//  Pictionary
//
//  Created by Paul Herz on 2017-12-07.
//  Copyright © 2017 Paul Herz. All rights reserved.
//

import Foundation
import TouchDraw

protocol GameManagerDelegate {
	func modelDidGuess(_ guess: String?)
	func countdownDidUpdate(secondsRemaining: Int?)
	func currentWordDidUpdate(_ currentWord: String?)
	func gameStateDidChange(_ gameState: GameState)
}

enum GameState {
	case none, choosingWord, drawing, postDrawing(win: Bool), waitForPass
}

class GameManager {
	
	var navigationController: UINavigationController? = nil
	
	var currentCanvas: TouchDrawView? = nil {
		didSet {
			if currentCanvas != nil {
				startPollingCanvas()
			} else {
				stopPollingCanvas()
			}
		}
	}
	
	static let guessThreshold = 0.5
	static let shared = GameManager()
	var currentWord: String? = nil {
		didSet {
			delegate?.currentWordDidUpdate(currentWord)
		}
	}
	var isRandomForest = false {
		didSet {
			if isRandomForest {
				print("Switching to RF classifier")
				classifier = RandomForestClassifier()
			} else {
				print("Switching to CNN classifier")
				classifier = CNNClassifier()
			}
		}
	}
	var classifier: DrawingClassifier = CNNClassifier()
	var delegate: GameManagerDelegate? = nil
	var canvasPollingTimer: Timer? = nil
	var secondsRemaining: Int? = nil
	var countdownTimer: Timer? = nil
	
	var wins: Int = 0
	var losses: Int = 0
	
	private(set) var singlePlayer = true
	private var gameState: GameState = .none {
		didSet {
			print("gameState: \(String(describing: gameState))")
			delegate?.gameStateDidChange(gameState)
		}
	}
	
	private init() {}
	
	func prepareSinglePlayerGame() {
		singlePlayer = true
		generateNextWord()
		goToNextPage()
	}
	
	func prepareMultiPlayerGame() {
		singlePlayer = false
		generateNextWord()
		goToNextPage()
	}
	
	func generateNextWord() {
		currentWord = Words.shared.random()
	}
	
	func startCountdown() {
		
		let gameLength = 20
		
		self.secondsRemaining = gameLength
		self.delegate?.countdownDidUpdate(secondsRemaining: self.secondsRemaining)
		countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
			self.secondsRemaining = self.secondsRemaining! - 1
			self.delegate?.countdownDidUpdate(secondsRemaining: self.secondsRemaining)
			if self.secondsRemaining == 0 {
				self.secondsRemaining = nil
				self.stopCountdown()
				print("Time's up")
				if case .drawing = self.gameState {
					self.gameState = .postDrawing(win: false)
					if self.singlePlayer { self.losses += 1 }
				} else {
					print("Warning: timer ran out in state other than drawing: \(String(describing: self.gameState))")
				}
			}
		}
	}
	
	func stopCountdown() {
		countdownTimer?.invalidate()
		countdownTimer = nil
	}
	
	@objc func goToNextPage() {
		var next: UIViewController? = nil
		if singlePlayer {
			next = nextPageSinglePlayer()
		} else {
			next = nextPageMultiPlayer()
		}
		guard let nextController = next else {
			print("Could not get next page...")
			return
		}
		navigationController?.pushViewController(nextController, animated: true)
	}
	
	private func nextPageSinglePlayer() -> UIViewController? {
		switch gameState {
		case .none:
			gameState = .choosingWord
			return NextWordViewController()
		case .choosingWord:
			gameState = .drawing
			return DrawViewController()
		case .drawing:
			return nil
		case .postDrawing:
			gameState = .choosingWord
			generateNextWord()
			return NextWordViewController()
		case .waitForPass:
			print("WARNING: waitForPass state invalid in single player mode.")
			return nil
		}
	}
	
	private func nextPageMultiPlayer() -> UIViewController? {
		switch gameState {
		case .none:
			gameState = .waitForPass
			return PassViewController()
		case .choosingWord:
			gameState = .drawing
			return DrawViewController()
		case .drawing:
			return nil
		case .postDrawing:
			gameState = .waitForPass
			return PassViewController()
		case .waitForPass:
			gameState = .choosingWord
			generateNextWord()
			return NextWordViewController()
		}
	}
	
	func didReceiveGuessGesture() {
		print("Guess Gesture")
		self.stopCountdown()
		self.stopPollingCanvas()
		self.gameState = .postDrawing(win: true)
		self.wins += 1
	}
	
	@objc func quit() {
		let alertController = UIAlertController(title: "Confirm quit", message: "Are you sure you want to quit?", preferredStyle: .alert)
		
		let cancelAction = UIAlertAction(title: "Cancel", style: .default) { action in
			// nothing
		}
		alertController.addAction(cancelAction)
		
		let quitAction = UIAlertAction(title: "Quit", style: .cancel) { action in
			self.forceQuit()
		}
		alertController.addAction(quitAction)
		
		navigationController?.present(alertController, animated: true) {}
	}
	
	func forceQuit() {
		gameState = .none
		wins = 0
		losses = 0
		stopCountdown()
		navigationController?.popToRootViewController(animated: true)
	}
	
	private func startPollingCanvas() {
		
		canvasPollingTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { timer in
			guard case .drawing = self.gameState else { return }
			guard let canvas = self.currentCanvas else { return }
			guard !canvas.exportStack().isEmpty else { return }
			
			self.classifier.classify(drawing: canvas.exportDrawing()) { bestWord, results in
				guard
					let bestWord = bestWord,
					let results = results,
					let bestConfidence = results[bestWord]
				else {
					print("No results.")
					self.delegate?.modelDidGuess(nil)
					return
				}
				
				if bestConfidence > GameManager.guessThreshold {
					self.modelDidGuess(bestWord)
				} else {
					self.modelDidGuess(nil)
				}
			}
		}
	}
	
	private func stopPollingCanvas() {
		canvasPollingTimer?.invalidate()
		canvasPollingTimer = nil
	}
	
	private func modelDidGuess(_ word: String?) {
		self.delegate?.modelDidGuess(word)
		guard word != nil else { return }
		if word == currentWord {
			if case .drawing = gameState {} else { print("Warning: postDrawing entered from non-drawing state") }
			stopCountdown()
			stopPollingCanvas()
			if singlePlayer {
				gameState = .postDrawing(win: true)
				self.wins += 1
			} else {
				gameState = .postDrawing(win: false)
				self.losses += 1 // versus machine
			}
		}
	}
}
