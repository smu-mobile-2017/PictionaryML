//
//  TitleViewController.swift
//  Pictionary
//
//  Created by Paul Herz on 2017-12-05.
//  Copyright © 2017 Paul Herz. All rights reserved.
//

import UIKit

class TitleViewController: UIViewController {
	
	var titleView: TitleView {
		return view as! TitleView
	}
	
	override func loadView() {
		view = TitleView(frame: UIScreen.main.bounds)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		GyroManager.shared.stop()
		
		titleView.singlePlayerButton.addTarget(
			self,
			action: #selector(didTouchSinglePlayerButton(sender:)),
			for: .touchUpInside
		)
		
		titleView.multiPlayerButton.addTarget(
			self,
			action: #selector(didTouchMultiPlayerButton(sender:)),
			for: .touchUpInside
		)
		
		titleView.settingsButton.addTarget(
			self,
			action: #selector(didTouchSettingsButton(sender:)),
			for: .touchUpInside
		)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	@objc func didTouchSettingsButton(sender: UIButton) {
		print("Settings button")
		present(SettingsViewController(), animated: true, completion: nil)
	}

	@objc func didTouchSinglePlayerButton(sender: UIButton) {
		print("Single player mode selected.")
		GameManager.shared.prepareSinglePlayerGame()
	}
	
	@objc func didTouchMultiPlayerButton(sender: UIButton) {
		print("Multi player mode selected.")
		GameManager.shared.prepareMultiPlayerGame()
	}
}

