//
//  ViewController.swift
//  Simple Hangman Game
//
//  Created by Metehan Veliashvili on 14.05.2024.
//

import UIKit

class ViewController: UIViewController {
    var answerLabel: UILabel!
    var currentAnswer: UITextField!
    var scoreLabel: UILabel!
    var letterButtons =  [UIButton]()
    var submit: UIButton!
    var clear: UIButton!
    var answer: String = ""
    
    var triedCount = 0
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        performSelector(inBackground: #selector(startGame), with: nil)

    }
    
    @objc func loadArea () {
        view = UIView()
        view.backgroundColor = .white
        
        scoreLabel = UILabel()
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.textAlignment = .right
        scoreLabel.text = "Score: \(score)"
        view.addSubview(scoreLabel)
        
        answerLabel = UILabel()
        answerLabel.translatesAutoresizingMaskIntoConstraints = false
        answerLabel.textAlignment = .center
        answerLabel.font = UIFont.systemFont(ofSize: 33)
        answerLabel.text = String(repeating: "?", count: answer.count)
        view.addSubview(answerLabel)
        
        currentAnswer = UITextField()
        currentAnswer.translatesAutoresizingMaskIntoConstraints = false
        currentAnswer.placeholder = "Enter a Letter"
        currentAnswer.textAlignment = .center
        currentAnswer.font = UIFont.systemFont(ofSize: 33)
        view.addSubview(currentAnswer)
        
        let submit = UIButton(type: .system)
        submit.translatesAutoresizingMaskIntoConstraints = false
        submit.setTitle("SUBMIT", for: .normal)
        submit.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
        view.addSubview(submit)
        
        let clear = UIButton(type: .system)
        clear.translatesAutoresizingMaskIntoConstraints = false
        clear.setTitle("CLEAR", for: .normal)
        clear.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)
        view.addSubview(clear)
        
        //5 satır 6 sütun yapalım
        //width: 450, height: 200
        
        let buttonsView = UIView()
        buttonsView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonsView)
        
        let width = 65
        let height = 50
        
        let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let alphabetArr = Array(alphabet)
        
        for row in 0..<5 {
            for col in 0..<6 {
                let letterIndex = row * 6 + col
                if letterIndex < alphabetArr.count {
                    let letterButton = UIButton(type: .system)
                    letterButton.titleLabel?.font = UIFont.systemFont(ofSize: 22)
                    letterButton.setTitle(String(alphabetArr[letterIndex]), for: .normal)
                    letterButton.addTarget(self, action: #selector(letterTapped), for: .touchUpInside)
                    let frame = CGRect(x: col * width, y: row * height, width: width, height: height)
                    letterButton.frame = frame
                    
                    buttonsView.addSubview(letterButton)
                    letterButtons.append(letterButton)
                }
            }
        }

        

        
        NSLayoutConstraint.activate([
            scoreLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            scoreLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: 0),
            
            answerLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 100),
            answerLabel.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor, constant: 0),
            
            currentAnswer.topAnchor.constraint(equalTo: answerLabel.bottomAnchor, constant: 100),
            currentAnswer.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor, constant: 0),
            
            submit.topAnchor.constraint(equalTo: currentAnswer.bottomAnchor, constant: 100),
            submit.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor, constant: -100),
            
            clear.topAnchor.constraint(equalTo: currentAnswer.bottomAnchor, constant: 100),
            clear.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor, constant: 100),
            
            buttonsView.widthAnchor.constraint(equalToConstant: 450),
            buttonsView.heightAnchor.constraint(equalToConstant: 200),
            buttonsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonsView.topAnchor.constraint(equalTo: submit.bottomAnchor, constant: 20),
            buttonsView.bottomAnchor.constraint(lessThanOrEqualTo: view.layoutMarginsGuide.bottomAnchor, constant: -20),
            buttonsView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: 10),
            

        ])
    }
    
    @objc func startGame() {
        let urlString: String = "https://random-word-api.herokuapp.com/word"
        
        // URLSession ile asenkron bir şekilde veri al
        URLSession.shared.dataTask(with: URL(string: urlString)!) { [weak self] (data, response, error) in
            guard let self = self else { return }
            
            // Hata kontrolü
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            // Veri kontrolü
            guard let data = data else {
                print("No data received")
                return
            }
            
            // Veriyi işle
            do {
                if let wordList = try JSONSerialization.jsonObject(with: data, options: []) as? [String] {
                    if let word = wordList.first {
                        self.answer = word
                        DispatchQueue.main.async {
                            self.loadArea()
                        }
                        print("Cevap: \(word)")
                    }
                }
            } catch {
                print("Error parsing JSON: \(error)")
            }
        }.resume()
    }

    
    @objc func letterTapped(_ btn: UIButton) {
        currentAnswer.text = currentAnswer.text! + btn.titleLabel!.text!
    }

    @objc func submitTapped(_ btn: UIButton) {
        guard let current = currentAnswer.text?.uppercased() else {
            showAlert(title: "Opps..!", message: "Please enter a single letter.")
            return
        }
        
        if current.count != 1 {
            showAlert(title: "Opps..!", message: "Please enter a single letter.")
            return
        }
        
        var newAnswer = ""
        var correctGuess = false
        
        for (index, char) in answer.uppercased().enumerated() {
            let currentCharIndex = answer.index(answer.startIndex, offsetBy: index)
            if char == current.first {
                newAnswer += String(current.first!)
                correctGuess = true
            } else {
                newAnswer += String(answerLabel.text![currentCharIndex])
            }
        }
        
        // Eğer doğru tahmin yapılmışsa cevabı güncelle
        if correctGuess {
            answerLabel.text = newAnswer
        } else {
            showAlert(title: "Opps..!", message: "The answer does not contain this letter.")
        }
        if answer.uppercased() == answerLabel.text {
            finishedGame(title: "Cong!", message: "You Won!")
            score += 1
        } else if triedCount == answer.count {
            finishedGame(title: "Game Over!", message: "You Lost! Do you wanna play again?")
            score -= 1
        } else {
            print("Answer.count: \(answer.count), triedCount: \(triedCount), Answer: \(answer), answerlabelçtext: \(answerLabel.text ?? "")")
        }

        triedCount += 1
        currentAnswer.text = ""
    }


    @objc func clearTapped(_ btn: UIButton) {
        currentAnswer.text = ""
    }
    
    func showAlert (title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default, handler: nil)
        ac.addAction(okButton)
        present(ac, animated: true)
    }
    
    func finishedGame (title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelButton = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        let retryButton = UIAlertAction(title: "Retry",style: .default) { action in
            self.answerLabel.text = ""
            self.triedCount = 0
            self.startGame()
        }

        ac.addAction(cancelButton)
        ac.addAction(retryButton)
        present(ac, animated: true)
    }


}

