//
//  RedditPostCell.swift
//  RedditTops
//
//  Created by Sergey Shepilov on 09.12.2020.
//

import UIKit

class RedditPostCell: UITableViewCell {
  
  @IBOutlet weak var containerView: UIView!
  @IBOutlet weak var postImageView: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var commentsLabel: UILabel!
  @IBOutlet weak var authorLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  
  func setup(with post: Post) {
    self.authorLabel.attributedText = self.author(with: post.author)
    self.titleLabel.text = post.title
    self.commentsLabel.text = "\(post.comments) comments"
    self.dateLabel.text = post.created.timeAgo
    
    guard
      let thumbnailData = post.thumbnail?.content,
      let thumbnail = UIImage(data: thumbnailData)
    else {
      self.postImageView.image = #imageLiteral(resourceName: "Reddit-icon")
      return
    }
    
    self.postImageView.image = thumbnail
  }
  
  private func author(with name: String) -> NSMutableAttributedString {
    let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.black,
                                                     .font: UIFont.systemFont(ofSize: 10)]

    let fullString = "by \(name)"
    let range = (fullString as NSString).range(of: name)
    let attributedString = NSMutableAttributedString(string: fullString, attributes: attributes)

    attributedString.addAttribute(.foregroundColor, value: UIColor.random, range: range)
    return attributedString
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    self.postImageView.image = #imageLiteral(resourceName: "Reddit-icon")
  }
  
  override func layoutSublayers(of layer: CALayer) {
    super.layoutSublayers(of: layer)
    self.containerView.layer.cornerRadius = 7
  }
}
