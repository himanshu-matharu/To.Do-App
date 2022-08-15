//
//  TodoCellTableViewCell.swift
//  To.Do
//
//  Created by Himanshu Matharu on 2022-08-12.
//

import UIKit

class TodoCell: UITableViewCell {
    
    //MARK: - Variables and Properties
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var todoText: UILabel!
    @IBOutlet weak var dueByText: UILabel!
    @IBOutlet weak var priorityIndicator: UIView!
    @IBOutlet weak var toggleView: UIImageView!
    
    //MARK: - Class methods
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        setupContainerShadow()
        setupPriorityIndicator()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func setupPriorityIndicator(){
        priorityIndicator.layer.cornerRadius = priorityIndicator.frame.height / 2
    }
    
    private func setupContainerShadow(){
//        container.layer.borderWidth = 1
//        container.layer.borderColor = UIColor(named: "PrimaryGrayColor")?.cgColor
        container.layer.shadowOpacity = 0.4
        container.layer.shadowOffset = CGSize(width: 0, height: 2)
        container.layer.shadowRadius = 4
        container.layer.shadowColor = UIColor(named: "PrimaryGrayColor")?.cgColor
        container.layer.cornerRadius = 5
    }
    
}
