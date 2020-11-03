//
//  DetailViewController.swift
//  Recipe
//
//  Created by Aidan Lee on 02/11/2020.
//

import UIKit
import RealmSwift

class DetailViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    let realm = try! Realm()
    public var item: Recipe?
    public var editHandler: (()->Void)?
    public var deletionHandler: (()->Void)?
    private var myRecipe = [Recipe]()
    
    
    
    @IBOutlet weak var txtrecipename: UITextField!
    @IBOutlet weak var txtrecipetype: UITextField!
    @IBOutlet weak var txtrecipeingredients: UITextView!
    @IBOutlet weak var txtrecipesteps: UITextView!
    @IBOutlet weak var imageView : UIImageView!
    
    @IBAction func BtnUpdate(_ sender: UIButton){
        let rid = item?.id
        let recipes = realm.objects(Recipe.self).filter("id == %@", rid).first
        if recipes != nil {
            try! realm.write{
                recipes?.Rname = txtrecipename.text!
                recipes?.Ingredients = txtrecipeingredients.text
                recipes?.Steps = txtrecipesteps.text
                editHandler?()
            }
        }
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.contentMode = .scaleAspectFill
        txtrecipename.text = item?.Rname
        txtrecipetype.text = item?.RecType
        txtrecipeingredients.text = item?.Ingredients
        txtrecipesteps.text = item?.Steps
        
        
        if item?.url != "" {
            let pictureurl = URL(string: item!.url)!
            let session = URLSession(configuration: .default)
            let downloadPicTask = session.dataTask(with: pictureurl) {(data, response, error) in
                if let e = error {
                    print("Error downloading picture \(self.item?.id)")
                } else {
                    if let res = response as? HTTPURLResponse {
                        print("Download picture with response code \(res.statusCode)")
                        
                        if let imageData = data{
                            DispatchQueue.main.async {
                                let image = UIImage(data: imageData)
                                self.imageView.image = image
                            }
                            
                        } else {
                            print("Couldn't Get Image, Image is Nil.")
                        }
                    } else {
                        print("Couldn't get response code.")
                    }
                }
            }
            downloadPicTask.resume()
        } else {
            print("No Image")
        }
        

        
        txtrecipename.becomeFirstResponder()
        txtrecipeingredients.becomeFirstResponder()
        txtrecipesteps.becomeFirstResponder()
        
        txtrecipename.delegate = self
        txtrecipeingredients.delegate = self
        txtrecipesteps.delegate = self
        
        
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(ToDoDelete))
        // Do any additional setup after loading the view.
    }
    
    


func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    txtrecipename.resignFirstResponder()

    
    return true
}

func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    if text == "\n" {
        txtrecipeingredients.resignFirstResponder()
        txtrecipesteps.resignFirstResponder()
        return false
    }
    return true
    
}
    
    
    
    
    @objc private func ToDoDelete(){
        guard let myItem = self.item else {
            return
        }
        realm.beginWrite()
        
        realm.delete(myItem)
        try! realm.commitWrite()
        deletionHandler?()
        navigationController?.popToRootViewController(animated: true)
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
