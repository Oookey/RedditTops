//
//  Extensions.swift
//  RedditTops
//
//  Created by Sergey Shepilov on 09.12.2020.
//

import UIKit

extension UITableView {
  ///
  /// Dequeue reusable cell
  ///
  /// Reusable identifier must be the same as cell type name
  ///
  func dequeueReusableCell<T: UITableViewCell>(ofType type: T.Type, for indexPath: IndexPath) -> T {
    let identifier = String(describing: type)
    
    guard let cell = self.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? T
      else { fatalError("cell of type \(type) with identifier \(type) not found") }
    
    return cell
  }
}

extension Date {
  var timeAgo: String {
    let formatter = RelativeDateTimeFormatter()
    formatter.unitsStyle = .full
    return formatter.localizedString(for: self, relativeTo: Date())
  }
}

extension UIColor {
  class var random: UIColor {
    return UIColor(red: .random(in: 0...1), green: .random(in: 0...1), blue: .random(in: 0...1), alpha: 1.0)
  }
}

extension UIStoryboard {
  static var main: UIStoryboard {
    return UIStoryboard(name: "Main", bundle: nil)
  }
  
  func instantiate<T: UIViewController>(_ type: T.Type, builder: (T?) -> ()) -> T? {
    let vc = instantiateViewController(withIdentifier: String(describing: T.self)) as? T
    builder(vc)
    return vc
  }
}
