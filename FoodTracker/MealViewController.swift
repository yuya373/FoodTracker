//
//  ViewController.swift
//  FoodTracker
//
//  Created by 南優也 on 2018/02/03.
//  Copyright © 2018年 南優也. All rights reserved.
//

import UIKit
import os.log

class MealViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // MARK: Properties
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var ratingControl: RatingControl!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var dateTimeTextField: UITextField!
    
    /*
     This value is either passed by `MealTableViewController` in `prepare(for:sender:)`
     or constructed as part of adding a new meal.
     */
    var meal: Meal?
    var datePicker: UIDatePicker!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Handle the text field’s user input through delegate callbacks
        nameTextField.delegate = self

        if let meal = self.meal {
            nameTextField.text = meal.name
            photoImageView.image = meal.photo
            ratingControl.rating = meal.rating
            dateTimeTextField.text = meal.dateTime.map {
                formatDateTime(dateTime: $0)
            }
        }
        
        updateSaveButtonState()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Navigation
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        // Depending on style of presentation (modal or push presentation), this view controller needs to be dismissed in two different ways
        let isPresentingInAddMealMode = presentingViewController is UINavigationController
        if isPresentingInAddMealMode {
            dismiss(animated: true, completion: nil)
        } else if let owingNavigationController = navigationController {
            owingNavigationController.popViewController(animated: true)
        } else {
            fatalError("The MealViewController is not inside a navigation controller")
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
        
        let name = nameTextField.text ?? ""
        let photo = photoImageView.image
        let rating = ratingControl.rating
        
        if let m = self.meal {
            os_log("Updating Meal", log: OSLog.default, type: .debug)
            m.name = name
            m.photo = photo
            m.rating = rating
            m.dateTime = dateTimeTextField.text.flatMap {
                dateFormatter().date(from: $0)
            } ?? nil
        } else {
            os_log("Creating Meal", log: OSLog.default, type: .debug)
            let dateTime = dateTimeTextField.text.flatMap({ dateFormatter().date(from: $0) })
            meal = Meal(name: name, photo: photo, rating: rating, dateTime: dateTime, model: nil)
        }

    }

    // MARK: Actions
    @IBAction func selectImageFromPhotoLibrary(_ sender: UITapGestureRecognizer) {
        // ensure text field resign first responder (hide the keyboard).
        nameTextField.resignFirstResponder();
        
        let alert = UIAlertController(title: "Select Image Source", message: nil, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {_ in })
        alert.addAction(cancelAction)
        
        if (UIImagePickerController.isSourceTypeAvailable(.camera)) {
            let cameraAction = UIAlertAction(title: "Camera", style: .default) { _ in
                let imagePickerController = UIImagePickerController()
                imagePickerController.sourceType = .camera
                imagePickerController.showsCameraControls = true
                imagePickerController.allowsEditing = true
                imagePickerController.delegate = self
                self.present(imagePickerController, animated: true, completion: nil)
            }
            alert.addAction(cameraAction)
        }
        
        if (UIImagePickerController.isSourceTypeAvailable(.photoLibrary)) {
            let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { _ in
                let imagePickerController = UIImagePickerController()
                imagePickerController.sourceType = .photoLibrary
                imagePickerController.allowsEditing = true
                imagePickerController.delegate = self
                self.present(imagePickerController, animated: true, completion: nil)
            }
            alert.addAction(photoLibraryAction)
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func dateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter
    }
    
    private func formatDateTime(dateTime: Date) -> String {
        return dateFormatter().string(from: dateTime)
    }
    
    @objc func dateTimeValueChanged(datePicker: UIDatePicker) {
        dateTimeTextField.text = formatDateTime(dateTime: datePicker.date)
    }
    
    @objc func doneButtonTapped() {
        dateTimeTextField.text = formatDateTime(dateTime: datePicker.date)
        dateTimeTextField.resignFirstResponder()
    }
    
    @objc func closeButtonTapped() {
        dateTimeTextField.resignFirstResponder()
    }
    
    @IBAction func dateTimeTextFieldEditingDidBegin(_ sender: UITextField) {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(MealViewController.doneButtonTapped))
        let closeButton = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(MealViewController.closeButtonTapped))
        toolbar.items = [
            closeButton,
            doneButton
        ]
        dateTimeTextField.inputAccessoryView = toolbar
        
        datePicker = UIDatePicker()
        datePicker.locale = Locale(identifier: "ja_JP")
        datePicker.datePickerMode = .dateAndTime
        // datePicker.addTarget(self, action: #selector(MealViewController.dateTimeValueChanged(datePicker:)), for: .valueChanged)
        if let dateTime = dateTimeTextField.text {
            dateFormatter().date(from: dateTime).map {
                datePicker.date = $0
            }
        }
        sender.inputView = datePicker
    }

    // MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // The info dictionary may contain multiple representations of the image. You want to use the original
        // UIImagePickerControllerEditedImage needs UIImagePickerController#allowsEditing = true
        guard let selectedImage = info[UIImagePickerControllerEditedImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided following \(info)")
        }
        photoImageView.image = selectedImage
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        saveButton.isEnabled = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateSaveButtonState()
        navigationItem.title = nameTextField.text
    }
    
    // MARK: Private Methods
    func updateSaveButtonState() {
        let text = nameTextField.text ?? ""
        saveButton.isEnabled = !text.isEmpty
    }
}

