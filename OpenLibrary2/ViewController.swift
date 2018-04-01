//
//  ViewController.swift
//  OpenLibrary2
//
//  Created by Juan Esteban Diaz Montejo on 16/12/17.
//  Copyright © 2017 Juan Esteban Diaz Montejo. All rights reserved.
//

import UIKit

class ViewController: UIViewController , UITextFieldDelegate{
    
    @IBOutlet weak var isbnField: UITextField!
    @IBOutlet weak var titleBookLabel: UILabel!
    @IBOutlet weak var authorsBookLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    var isConnError:Bool = false
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchBookData()
    
        return true
    }
    
    
    @IBAction func isbnAction(_ sender: UITextField) {
        if(isConnError){
            presentAlertController(withTitle: "Internet connection error", message: "Verify internet connection")
        }
    }
    
    func callService(isbnBook:NSString) -> Data?{
        let paht = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:"+(isbnBook as String)
        print(paht)
        let url = NSURL(string:paht)
        let datos:NSData? = NSData(contentsOf: url! as URL)
        if datos == nil {
            return nil
        }
        return (datos! as Data?)!
    }
    
    func searchBookData(){
        do{
            let data = callService(isbnBook: isbnField.text! as NSString) as Data?
            if nil != data {
                let json = try JSONSerialization.jsonObject(with:data!, options: JSONSerialization.ReadingOptions(rawValue: 0))
                let rootJson = json as! NSDictionary
                let book = rootJson["ISBN:"+isbnField.text!] as! NSDictionary?
                if nil != book {
                    let title = book!["title"] as! NSString as String
                    print(title)
                    titleBookLabel.text = title
                    let authors = book!["authors"] as! [[String:Any]]
                    setAuthors(authors: authors)
                    let covers = book!["cover"] as! NSDictionary?
                    if nil != covers {
                        let coverURL = covers!["medium"] as!NSString as String
                        downloadImage(coverURL)
                    }
                } else {
                    alert(message: "Book not found")
                }
            } else {
                isConnError = true
            }
        }
        catch _ {
            isConnError = true
        }
    }
    
    func setAuthors(authors:[[String:Any]]){
        authorsBookLabel.text = ""
        for i in 0...authors.count - 1  {
            let author = authors[i]["name"] as! NSString as String
            print(author)
            authorsBookLabel.text = authorsBookLabel.text?.appending("\n\(author)")
        }
    }
    
    func downloadImage(_ uri : String){
        
        let url = URL(string: uri)
        
        let task = URLSession.shared.dataTask(with: url!) {responseData,response,error in
            if error == nil{
                if let data = responseData {
                    
                    DispatchQueue.main.async {
                        self.imageView.image = UIImage(data: data)
                    }
                    
                }else {
                    print("no data")
                }
            }else{
                print(error as Any)
            }
        }
        
        task.resume()
        
    }
    func presentAlertController(withTitle title: String?, message: String?) {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok",
                                                style: .default,
                                                handler: nil))
//        self.present(alertController, animated: true, completion: nil)
        UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
    }

    @IBAction func clearAction(_ sender: UIButton) {
        isbnField.text = ""
        presentAlertController(withTitle: "Internet connection error", message: "Verify internet connection")
    }
    
    func alert(message: String, title: String = "") {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

