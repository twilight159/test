//
//  InputRecipeViewController.swift
//  Recipe
//
//  Created by Aidan Lee on 02/11/2020.
//

import UIKit
import RealmSwift

class InputRecipeViewController: UIViewController, UITextFieldDelegate {
    let realm = try! Realm()
    public var completionHandler: (()-> Void)?
    
    
    @IBOutlet weak var txtRecipeType: UITextField!
    @IBAction func Submit(_ sender: UIButton){
        
        guard let RType = txtRecipeType.text else { return }
        
        let myRecipeType = RecipeType()
        let rid = realm.objects(RecipeType.self)
        let rrid = rid.last?.id
        
        
        if(rrid == nil){
            myRecipeType.recipetype = RType
        }else{
            myRecipeType.id = rrid!+1
            myRecipeType.recipetype = RType
        }
        
            
        
        
        
        try! realm.write{
            realm.add(myRecipeType)
        }
        navigationController?.popToRootViewController(animated: true)
        completionHandler?()
        
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        txtRecipeType.becomeFirstResponder()
        txtRecipeType.delegate = self
        
        
        // Do any additional setup after loading the view.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        txtRecipeType.resignFirstResponder()
        return true
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
