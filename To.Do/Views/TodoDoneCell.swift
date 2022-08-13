//
//  TodoDoneCell.swift
//  To.Do
//
//  Created by Himanshu Matharu on 2022-08-12.
//

import UIKit

class TodoDoneCell: UITableViewCell {
    
    //MARK: - Variables and Properties
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var todoText: UILabel!
    
    //MARK: - Class Methods
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        setupContainer()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func setupContainer(){
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor(named: "PrimaryYellowColor")?.cgColor
        container.layer.shadowOpacity = 0.2
        container.layer.shadowOffset = CGSize(width: 0, height: 3)
        container.layer.shadowRadius = 1
        container.layer.shadowColor = UIColor(named: "PrimaryYellowColor")?.cgColor
        container.layer.cornerRadius = 20
    }
    
}
