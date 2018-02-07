//
//  RatingControl.swift
//  FoodTracker
//
//  Created by 南優也 on 2018/02/06.
//  Copyright © 2018年 南優也. All rights reserved.
//

import UIKit

@IBDesignable class RatingControl: UIStackView {
    // MARK: Properties
    // @IBInspectable make property controllable from storyboard's attribute
    //  including: Booleans, numbers, strings, as well as CGRect, CGSize, CGPoint, and UIColor.
    @IBInspectable var starSize: CGSize = CGSize(width: 44.0, height: 44.0) {
        didSet {
            setupButtons()
        }
    }
    @IBInspectable var starCount: Int = 5 {
        didSet {
            setupButtons()
        }
    }
    private var ratingButtons = [UIButton]()
    var rating = 0 {
        didSet {
            updateButtonSelectionStates()
        }
    }
    
    // MARK: Initialization
    // Initializer for programatically initializing the view
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButtons()
    }
    // Initializer for loading view from storyboard
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupButtons()
    }
    
    // MARK: Button Action
    @objc func ratingButtonTapped(button: UIButton) {
        guard let index = ratingButtons.index(of: button) else {
            fatalError("The button, \(button), is not in the ratingButtons array: \(ratingButtons)")
        }
        let selectedRating = index + 1
        if (selectedRating == rating) {
            rating = 0
        } else {
            rating = selectedRating
        }
    }
    
    // MARK: Private Methods
    private func updateButtonSelectionStates() {
        for (index, button) in ratingButtons.enumerated() {
            button.isSelected = (index < rating)
            
            let hintString: String?
            if (rating == index + 1) {
                hintString = "Tap to reset the rating to zero."
            } else {
                hintString = nil
            }
            
            button.accessibilityHint = hintString
            
            let valueString: String
            switch(rating) {
            case 0:
                valueString = "No rating set."
            case 1:
                valueString = "1 star set."
            default:
                valueString = "\(index + 1) stars set."
            }
            button.accessibilityValue = valueString
        }
    }
    private func setupButtons() {
        // Clear any exsiting buttons
        for button in ratingButtons {
            // This tells stack view that it should no longer calculate the button’s size and position—but the button is still a subview of the stack view.
            removeArrangedSubview(button)
            button.removeFromSuperview()
        }
        ratingButtons.removeAll()
        
        let bundle = Bundle(for: type(of: self))
        let filledStar = UIImage(named: "filledStar", in: bundle, compatibleWith: self.traitCollection)
        let emptyStar = UIImage(named: "emptyStar", in: bundle, compatibleWith: self.traitCollection)
        let highlightedStar = UIImage(named: "highlightedStar", in: bundle, compatibleWith: self.traitCollection)
        
        for index in 0..<starCount {
            let button = UIButton()
            button.setImage(emptyStar, for: .normal)
            button.setImage(filledStar, for: .selected)
            button.setImage(highlightedStar, for: .highlighted)
            button.setImage(highlightedStar, for: [.highlighted, .selected])

            // Disable constraints that define the view’s size and position based on the view’s frame and autoresizingmask properties
            button.translatesAutoresizingMaskIntoConstraints = false
            
            // Define and activate fixed constraint, width x height = (44 point) x (44 point)
            button.heightAnchor.constraint(equalToConstant: starSize.height).isActive = true
            button.widthAnchor.constraint(equalToConstant: starSize.width).isActive = true
            
            button.accessibilityLabel = "Set \(index + 1) star rating."
            
            button.addTarget(self, action: #selector(RatingControl.ratingButtonTapped(button:)), for: .touchUpInside)
            
            // Add the button to stack
            addArrangedSubview(button)
            
            ratingButtons.append(button)
        }
        updateButtonSelectionStates()
    }
}
