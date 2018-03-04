//
//  ViewController.swift
//  FoodTracker
//
//  Created by 南優也 on 2018/02/03.
//  Copyright © 2018年 南優也. All rights reserved.
//

import UIKit
import MapKit
import os.log

class MealViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // MARK: Properties
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var ratingControl: RatingControl!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var dateTimeTextField: UITextField!
    @IBOutlet weak var noteTextView: UITextView!
    @IBOutlet weak var mapView: MKMapView!
    /*
     This value is either passed by `MealTableViewController` in `prepare(for:sender:)`
     or constructed as part of adding a new meal.
     */
    var meal: Meal?
    var datePicker: UIDatePicker!
    var locationManager: CLLocationManager!
    var pin: MKPointAnnotation?
    var readOnly = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Handle the text field’s user input through delegate callbacks
        nameTextField.delegate = self

        let color = UIColor(red: 186/255, green: 186/255, blue: 186/255, alpha: 1.0).cgColor
        noteTextView.layer.borderColor = color
        noteTextView.layer.borderWidth = 0.5
        noteTextView.layer.cornerRadius = 5.0
        
        mapView.delegate = self
        locationManager = CLLocationManager()
        locationManager.delegate = self
        

        if let meal = self.meal {
            navigationItem.title = meal.name
            nameTextField.text = meal.name
            photoImageView.image = meal.photo
            ratingControl.rating = meal.rating
            dateTimeTextField.text = meal.formattedDate()
            noteTextView.text = meal.note
            if let lat = meal.latitude, let lon = meal.longitude {
                let coord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                displayPin(coord: coord)
            }
        }
        
        updateSaveButtonState()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerObserver()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeObserver()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Navigation
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        // Depending on style of presentation (modal or push presentation), this view controller needs to be dismissed in two different ways
        let isPresentingModally = presentingViewController is UITabBarController
        if isPresentingModally {
            dismiss(animated: true, completion: nil)
        } else if let owingViewController = navigationController {
            owingViewController.popViewController(animated: true)
        } else {
            fatalError("MealViewController is not inside a navigation controller.")
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
        
        updateMeal()
    }
    
    private func updateMeal() {
        let name = nameTextField.text ?? ""
        let photo = photoImageView.image
        let rating = ratingControl.rating
        let note = noteTextView.text.count > 255 ? String(noteTextView.text.prefix(255)) : noteTextView.text
        if let m = self.meal {
            os_log("Updating Meal", log: OSLog.default, type: .debug)
            m.name = name
            m.photo = photo
            m.rating = rating
            m.dateTime = dateTimeTextField.text.flatMap {
                DateTimeFormatter.date(from: $0)
                } ?? nil
            m.note = note
        } else {
            os_log("Creating Meal", log: OSLog.default, type: .debug)
            let dateTime = dateTimeTextField.text.flatMap({ DateTimeFormatter.date(from: $0) })
            self.meal = Meal(name: name, photo: photo, rating: rating, dateTime: dateTime, note: note, model: nil)
        }
        meal?.latitude = pin?.coordinate.latitude
        meal?.longitude = pin?.coordinate.longitude
    }

    // MARK: Actions
    @IBAction func cancelNoteEditing(_ sender: UITapGestureRecognizer) {
        os_log("cancelNoteEditing", log: OSLog.default, type: .debug)
        if (noteTextView.isFirstResponder) {
            noteTextView.resignFirstResponder()
        }
    }
    
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

    @objc func dateTimeValueChanged(datePicker: UIDatePicker) {
        dateTimeTextField.text = DateTimeFormatter.string(from: datePicker.date)
    }
    
    @objc func doneButtonTapped() {
        dateTimeTextField.text = DateTimeFormatter.string(from: datePicker.date)
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
            DateTimeFormatter.date(from: dateTime).map {
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
    
    @objc func keyboardWillShow(notification: Notification) {
        if (!noteTextView.isFirstResponder) {
            return
        }
        if let rect = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue,
            let duration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSValue) as? Double {
            UIView.animate(withDuration: duration, animations: {
                let transform = CGAffineTransform(translationX: 0, y: -rect.size.height)
                self.view.transform = transform
            })
        }
    }
    
    @objc func keyborardWillHide(notification: Notification) {
        if (!noteTextView.isFirstResponder) {
            return
        }
        if let duration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSValue) as? Double {
            UIView.animate(withDuration: duration, animations: {
                self.view.transform = CGAffineTransform.identity
            })
        }
    }
    
    private func registerObserver() {
        let notification = NotificationCenter.default
        notification.addObserver(self, selector: #selector(MealViewController.keyboardWillShow(notification:)), name: .UIKeyboardWillShow, object: nil)
        notification.addObserver(self, selector: #selector(MealViewController.keyborardWillHide(notification:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    private func removeObserver() {
        let notification = NotificationCenter.default
        notification.removeObserver(self)
    }
}

extension MealViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        let util = LocationManagerUtil(locationManager: locationManager)
        util.handleChangeAuthorization(status: status, onAuthorized: nil).map {
            present($0, animated: true, completion: nil)
        }
    }

    func displayPin(coord: CLLocationCoordinate2D) {
        self.pin = MKPointAnnotation()
        self.pin.map {
            $0.coordinate = coord
            mapView.addAnnotation($0)
        }
        mapView.showAnnotations(mapView.annotations, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if self.pin == nil {
            locations.last.map {
                displayPin(coord: $0.coordinate)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let util = LocationManagerUtil(locationManager: locationManager)
        let alert = util.handleFailWithError(error: error)
        present(alert, animated: true, completion: nil)
    }
}

extension MealViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKPointAnnotation {
            let reuseId = "Pin"
            let pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) ??
                MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView.annotation = annotation
            pinView.isDraggable = true
            return pinView
        } else {
            return nil
        }
    }
}
