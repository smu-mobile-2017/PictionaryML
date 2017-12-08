//
//  NextWordViewController.swift
//  Pictionary
//
//  Created by Paul Herz on 2017-12-06.
//  Copyright © 2017 Paul Herz. All rights reserved.
//

import UIKit

class NextWordViewController: UIViewController {
	
	var nextWordView: NextWordView {
		return view as! NextWordView
	}
	
	var currentWord: String? = nil {
		didSet {
			nextWordView.drawItemLabel.text = currentWord?.uppercased() ?? "?"
		}
	}
	
	override func loadView() {
		view = NextWordView(frame: UIScreen.main.bounds)
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		GameManager.shared.delegate = self
		
		currentWord = GameManager.shared.currentWord
		
		nextWordView.quitButton.addTarget(GameManager.shared, action: #selector(GameManager.quit), for: .touchUpInside)
		
		GyroManager.shared.onFlipDown(didAcceptWord)
		GyroManager.shared.onFlipUp(didDenyWord)
		GyroManager.shared.listen()
    }
	
	override func viewDidDisappear(_ animated: Bool) {
		GyroManager.shared.stop()
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	func didAcceptWord() {
		self.nextWordView.flashCard(self.nextWordView.acceptCard)
	}
	
	func didDenyWord() {
		self.nextWordView.flashCard(self.nextWordView.denyCard)
		GameManager.shared.generateNextWord()
	}
}

extension NextWordViewController: GameManagerDelegate {
	func modelDidGuess(_ guess: String?) {}
	func countdownDidUpdate(secondsRemaining: Int?) {}
	
	func currentWordDidUpdate(_ currentWord: String?) {
		print("currentWordDidUpdate: \(currentWord ?? "nil")")
		self.currentWord = currentWord
	}
}
