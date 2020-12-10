//
//  ImagePreviewVC.swift
//  RedditTops
//
//  Created by Sergey Shepilov on 09.12.2020.
//

import UIKit

class ImagePreviewVC: UIViewController {
  @IBOutlet weak var scrollView: ImageScrollView!
  @IBOutlet weak var shareButton: UIButton!
  @IBOutlet weak var closeButton: UIButton!
  @IBOutlet weak var bottomOverlayView: UIView!
  @IBOutlet weak var topOverlayView: UIView!
  
  private var tapGestureRecognizer: UITapGestureRecognizer!
  
  var redditPostsService: ImageLoadService?
  
  var image: UIImage?
  var imageData: ImageData?
  var postId: String?
  var url: String?

  override func viewDidLoad() {
    super.viewDidLoad()
    self.setup()
    self.loadImage()
  }
  
  private func loadImage() {
    guard
      let stringUrl = self.url?.replacingOccurrences(of: "amp;", with: ""), // to resolve 403 error
      let url = URL(string: stringUrl),
      let imageData = self.imageData,
      let postId = self.postId
    else { return }
    
    self.redditPostsService?.load(url: url, postId: postId, imageData: imageData) { [weak self] image in
      DispatchQueue.main.async {
        guard
          let imageData = image?.content,
          let image = UIImage(data: imageData)
        else { return }
        
        self?.image = image
        self?.scrollView.display(image: image)
      }
    }
  }
  
  //MARK: - Setup

  private func setup() {
    self.setupGestureRecognizer()
    self.scrollView.setup()
    self.scrollView.canCancelContentTouches = true
    self.scrollView.imageContentMode = .aspectFit
    self.scrollView.initialOffset = .center
  }
  
  private func setupGestureRecognizer() {
    self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewDidTap(_:)))
    self.tapGestureRecognizer.delegate = self
    self.scrollView.addGestureRecognizer(self.tapGestureRecognizer)
  }
  
  //MARK: - Actions

  @objc private func viewDidTap(_ sender: UITapGestureRecognizer) {
    self.topOverlayView.isHidden.toggle()
    self.bottomOverlayView.isHidden.toggle()
  }
  
  @IBAction func shareButtonDidTap(_ sender: UIButton) {
    guard let image = self.image else { return }
    let ac = UIActivityViewController(activityItems: [image], applicationActivities: nil)
    self.present(ac, animated: true)
  }
  
  @IBAction func closeButtonDidTap(_ sender: UIButton) {
    self.dismiss(animated: true, completion: nil)
  }
}

//MARK: - UIGestureRecognizerDelegate

extension ImagePreviewVC: UIGestureRecognizerDelegate {
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
}
