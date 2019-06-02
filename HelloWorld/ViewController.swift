//
//  ViewController.swift
//  HelloWorld
//
//  Created by Maggie Salak on 25/11/2018.
//  Copyright © 2018 Maggie Salak. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBAction func onClick(_ sender: UIButton) {
            startOver(sender: sender)
    }
    
    class MyButton: UIButton {
        var row: Int
        var col: Int
        
        required init(row: Int, col: Int) {
            self.row = row
            self.col = col
            super.init(frame: .zero)
//            super.init(type: UIButton.ButtonType.system)
        }
    
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    //MARK: - Constants, Outlets and Properties
    let image = UIImage(named:"sliceOfAppPie400x400Black1")
    @IBOutlet weak var mainStackView: UIStackView!
    let myLabel = UILabel()
    let d_count = 8
    let size_row = 9
    let size_col = 9
    let totalMines = 10
    
    var buttons = [[MyButton]]()
    var mines = Array(repeating: Array(repeating: false, count: 9), count: 9)
    var visited = Array(repeating: Array(repeating: false, count: 9), count: 9)
    var d_row = [0, 1, 1, 1, 0, -1, -1, -1]
    var d_col = [1, 1, 0, -1, -1, -1, 0, 1]
    var vis = 0
    var gameOver = false

    func drawButtons(view:UIView) {
        for i in 0...size_row-1 {
            var row = [MyButton]()
            for j in 0...size_col-1 {
                let myButton = makeButton(
                    text: "?",
                    d_x: CGFloat((i-1)*36),
                    d_y: CGFloat((j-1)*36),
                    mine: mines[Int(i)][Int(j)],
                    row: i,
                    col: j)
                view.addSubview(myButton)
                row.append(myButton)
            }
            buttons.append(row)
        }
    }
    
    func prepareMines() {
        var selected = 0
        while selected < totalMines {
            let randomInt = Int.random(in: 0..<80)
            let row = randomInt / 9
            let col = randomInt % 9
            if !mines[row][col] {
                mines[row][col] = true
                selected += 1
            }
        }
    }
    
    func makeButton(text:String, d_x:CGFloat, d_y:CGFloat, mine:Bool, row: Int, col: Int) -> MyButton {
        let myButton = MyButton(row: row, col: col)
//        myButton = UIButton(type: UIButton.ButtonType.system)
        //Set a frame for the button. Ignored in AutoLayout/ Stack Views
        myButton.frame = CGRect(x: 80+d_x, y: 200+d_y, width: 35, height: 35)
        //Set background color
        myButton.backgroundColor = UIColor.gray
        //State dependent properties title and title color
        myButton.setTitle(text, for: .normal)
        myButton.setTitleColor(UIColor.black, for: .normal)
        
        //Assign a target (i.e. action) to the button
        if mine {
            myButton.addTarget(self,
                               action: #selector(mineButton),
                               for: .touchUpInside
            )
        } else {
            myButton.addTarget(self,
                               action: #selector(regularButton),
                               for: .touchUpInside
            )
        }
        
        
        return myButton
    }
    
    func countMines(row: Int, col: Int) -> Int {
        var res = 0
        for i in 0...d_count-1 {
            let row1 = row + d_row[i]
            let col1 = col + d_col[i]
            if 0 <= row1 && row1 < size_row && 0 <= col1 && col1 < size_col {
                if mines[row1][col1] {
                    res += 1
                }
            }
        }
        return res
    }
    
    @IBAction func regularButton(sender:MyButton){
        if gameOver {
            return
        }
        visited[sender.row][sender.col] = true
        vis += 1
        sender.setTitleColor(UIColor.black, for: .normal)
        let mineCount = countMines(row: sender.row, col: sender.col)
        sender.setTitle(String(mineCount), for: .normal)
        
        if mineCount == 0 {
            for i in 0...d_count-1 {
                let row1 = sender.row + d_row[i]
                let col1 = sender.col + d_col[i]
                if 0 <= row1 && row1 < size_row && 0 <= col1 && col1 < size_col {
                    if !visited[row1][col1] && !mines[row1][col1] {
                        regularButton(sender: buttons[row1][col1])
                    }
                }
            }
        }
        
        if vis == size_row * size_col - totalMines {
            configureLabelWithText(text: "You won!")
            for i in 0...size_row-1 {
                for j in 0...size_col-1 {
                    if !visited[i][j] && mines[i][j] {
                        mineButton(sender: buttons[i][j])
                    }
                }
            }
        }
    }
    
    //MARK: - Actions and Selectors
    @IBAction func mineButton(sender:MyButton){
        if gameOver {
            return
        }
        visited[sender.row][sender.col] = true
        sender.setTitle("X", for: .normal)
        sender.setTitleColor(UIColor.red, for: .normal)
        configureLabelWithText(text: "Game over!")
        gameOver = true
    }
    
    func configureLabelWithText(text:String){
        //Set the attributes of the label
        myLabel.frame = CGRect(x: 0, y: 90, width: self.view.frame.width, height: 50)
        myLabel.center.x = self.view.center.x
        myLabel.textColor = UIColor.gray
        myLabel.font = UIFont(name: "Chalkduster", size: 20)
        myLabel.text = text
        myLabel.textAlignment = .center
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a
        //background color for the view
        view.backgroundColor = UIColor(white: 0.8, alpha: 1.0)

        //Iteration 2: Make a Button and a label
        configureLabelWithText(text: "Minesweeper by Maggie")
        view.addSubview(myLabel)
        prepareMines()
        drawButtons(view: view)
        //view.addSubview(makeButton(text: "?"))
    }
    
    @IBAction func showMessage(sender: UIButton) {
        let alertController = UIAlertController(title: "Welcome to My First App", message: "Start over", preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func startOver(sender:UIButton){
        configureLabelWithText(text: "Minesweeper by Maggie")
        buttons = [[MyButton]]()
        mines = Array(repeating: Array(repeating: false, count: 9), count: 9)
        visited = Array(repeating: Array(repeating: false, count: 9), count: 9)
        vis = 0
        gameOver = false
        prepareMines()
        drawButtons(view: view)
    }
}

