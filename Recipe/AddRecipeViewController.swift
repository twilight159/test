//
//  AddRecipeViewController.swift
//  Recipe
//
//  Created by Aidan Lee on 02/11/2020.
//

import UIKit
import RealmSwift
import FirebaseStorage

class AddRecipeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate {
    let realm = try! Realm()
    public var addHandler: (()->Void)?
    private let storage = Storage.storage().reference()
    public var myrecipetype: RecipeType?
    
    var selectedType : String?
    var link : String = ""
    
    private var RType = [RecipeType]()
    @IBOutlet var imageView: UIImageView!
    @IBOutlet weak var txtrname: UITextField!
    @IBOutlet weak var txtrecipetype: UITextField!
    @IBOutlet weak var txtringredient: UITextView!
    @IBOutlet weak var txtrsteps: UITextView!
    
    @IBAction func BtnCreate(_ sender: UIButton){
        
        
        guard let recipename = txtrname.text else { return }
        guard let recipetype = txtrecipetype.text else { return }
        guard let recipeingredients = txtringredient.text else { return }
        guard let recipesteps = txtrsteps.text else { return }
        
        let myRecipe = Recipe()
        let rid = realm.objects(Recipe.self)
        let rrid = rid.last?.id
        
        
        if(rrid == nil){
            myRecipe.Rname = recipename
            myRecipe.RecType = recipetype
            myRecipe.Ingredients = recipeingredients
            myRecipe.Steps = recipesteps
            myRecipe.url = link
        }else{
            myRecipe.id = rrid!+1
            myRecipe.Rname = recipename
            myRecipe.RecType = recipetype
            myRecipe.Ingredients = recipeingredients
            myRecipe.Steps = recipesteps
            myRecipe.url = link
        }
        
            
        
        
        
        try! realm.write{
            realm.add(myRecipe)
            addHandler?()
        }
        navigationController?.popToRootViewController(animated: true)
        
        
    }
    
    //@IBOutlet weak var AddRecipePicker: UIPickerView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.createAndSetupPickerView()
        self.dismissAndClosePickerView()
        imageView.contentMode = .scaleAspectFill
        RType = realm.objects(RecipeType.self).map({ $0 })
        
        //AddRecipePicker.dataSource = self
        //AddRecipePicker.delegate = self
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Upload Image", style: .done, target: self, action: #selector(TapAddImage))
        
        
        
        let myRecipe = Recipe()
        let rid = realm.objects(Recipe.self).last?.id
        
        
        if(rid == nil){
            guard let urlString = UserDefaults.standard.value(forKey: "0") as? String,
                  let url = URL(string: urlString) else {
                return
            }
            
            let task = URLSession.shared.dataTask(with: url, completionHandler: {data, _, error in
                guard let data = data, error == nil else {
                    return
                }
                DispatchQueue.main.async {
                    let image = UIImage(data: data)
                    self.imageView.image = image
                }
            })
            
            task.resume()
        }else{
            let key = rid!+1
            guard let urlString = UserDefaults.standard.value(forKey: "\(key)") as? String,
                  let url = URL(string: urlString) else {
                return
            }
            
            let task = URLSession.shared.dataTask(with: url, completionHandler: {data, _, error in
                guard let data = data, error == nil else {
                    return
                }
                DispatchQueue.main.async {
                    let image = UIImage(data: data)
                    self.imageView.image = image
                }
            })
            
            task.resume()
        }
        
        txtrname.becomeFirstResponder()
        txtrecipetype.becomeFirstResponder()
        txtringredient.becomeFirstResponder()
        txtrsteps.becomeFirstResponder()
        
        txtrname.delegate = self
        txtrecipetype.delegate = self
        txtringredient.delegate = self
        txtrsteps.delegate = self
        
        
        
        // Do any additional setup after loading the view.
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        txtrname.resignFirstResponder()
        txtrecipetype.resignFirstResponder()
        
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            txtringredient.resignFirstResponder()
            txtrsteps.resignFirstResponder()
            return false
        }
        return true
        
    }
    
    func createAndSetupPickerView(){
        let pickerview = UIPickerView()
        pickerview.delegate = self
        pickerview.dataSource = self
        self.txtrecipetype.inputView = pickerview
    }
    
    @objc private func TapAddImage(){
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        guard let imageData = image.pngData() else {
            return
        }
        
        let myRecipe = Recipe()
        let rid = realm.objects(Recipe.self).last?.id
        let foldername = myrecipetype?.recipetype
        
        
        if(rid == nil){
            storage.child("\(String(describing: foldername))/0.png").putData(imageData, metadata: nil, completion: {_, error in
                guard error == nil else {
                    print("Failed to upload")
                    return
                }
                
                self.storage.child("\(String(describing: foldername))/0.png").downloadURL(completion: { url, error in
                    guard let url = url, error == nil else {
                        return
                    }
                    
                    let urlString = url.absoluteString
                    self.link = urlString
                    DispatchQueue.main.async {
                        self.imageView.image = image
                    }
                    UserDefaults.standard.set(urlString, forKey: "0")
                    
                    
                })
                
                
                
            })
        }else{
            let randomid = rid!+1
            storage.child("\(String(describing: foldername))/\(randomid).png").putData(imageData, metadata: nil, completion: {_, error in
                guard error == nil else {
                    print("Failed to upload")
                    return
                }
                
                self.storage.child("\(String(describing: foldername))/\(randomid).png").downloadURL(completion: { url, error in
                    guard let url = url, error == nil else {
                        return
                    }
                    
                    let urlString = url.absoluteString
                    
                    DispatchQueue.main.async {
                        self.imageView.image = image
                    }
                    
                    self.link = urlString
                    UserDefaults.standard.set(urlString, forKey: "\(randomid)")
                    
                    
                })
                
                
                
            })
        }
        
        
        //upload image data
        //get download url
        //save download url
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func dismissAndClosePickerView(){
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let button = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.dismissAction))
        toolBar.setItems([button], animated: true)
        toolBar.isUserInteractionEnabled = true
        self.txtrecipetype.inputAccessoryView = toolBar
    }
    
    @objc func dismissAction(){
        self.view.endEditing(true)
    }
    
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


extension AddRecipeViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        self.RType.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.RType[row].recipetype
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedType = self.RType[row].recipetype
        txtrecipetype.text = self.selectedType
    }
}
