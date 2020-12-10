//
//  RedditPostsVC.swift
//  RedditTops
//
//  Created by Sergey Shepilov on 07.12.2020.
//

import UIKit
import CoreData

class RedditPostsVC: UITableViewController {
  private lazy var redditPostsService: RedditPostsService = RedditPostsService()
  private lazy var transition = TransitionAnimator()
  private var canLoadMore: Bool = true

  private var fetchResultsController: NSFetchedResultsController<RedditPost> {
    self.redditPostsService.fetchResultsController.delegate = self
    return self.redditPostsService.fetchResultsController
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.setup()
  }
  
  private func setup() {
    self.refreshControl?.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
    self.refreshControl?.beginRefreshing()

    do {
      try self.fetchResultsController.performFetch()
    } catch {
      self.redditPostsService.loadNextPosts()
      print(error)
    }
    
    self.redditPostsService.loadNextPosts()
  }
  
  @objc func refresh(sender: UIRefreshControl) {
    self.redditPostsService.reloadPosts()
  }
}

//MARK: - UITableViewDelegate

extension RedditPostsVC {
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let post = self.fetchResultsController.object(at: indexPath)

    guard let image = post.image else { return }
    
    let vc = UIStoryboard.main.instantiate(ImagePreviewVC.self) {
      let imageData = ImageData(url: image.url ?? "",
                                width: Int(image.width ),
                                height: Int(image.height ))

      $0?.transitioningDelegate = self
      $0?.url = image.url
      $0?.postId = post.id
      $0?.imageData = imageData
      $0?.redditPostsService = self.redditPostsService
      $0?.modalPresentationStyle = .fullScreen
    }
    
    self.present(vc!, animated: true, completion: nil)
  }
}

//MARK: - UITableViewDataSource

extension RedditPostsVC {
  override func numberOfSections(in tableView: UITableView) -> Int {
    return self.fetchResultsController.sections?.count ?? 0
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let sections = self.fetchResultsController.sections else { return 0 }
    return sections[section].numberOfObjects
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(ofType: RedditPostCell.self, for: indexPath)
    let post = self.fetchResultsController.object(at: indexPath)
    self.configure(cell: cell, with: post)
    
    return cell
  }
  
  func configure(cell: RedditPostCell, with post: RedditPost) {
    var post = Post(with: post)
    
    if let _ = post.thumbnail?.storageUrl {
      let thumbnail = self.redditPostsService.getThumbnail(from: post.id)
      post.thumbnail?.content = thumbnail?.content
    }
    
    cell.setup(with: post)
  }
  
  override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    guard
      self.canLoadMore,
      let sections = self.fetchResultsController.sections
    else { return }
    
    let total = sections[0].numberOfObjects
    
    guard indexPath.row >= total - 10 else { return }
    self.redditPostsService.loadNextPosts()
    self.canLoadMore = false
  }
}

//MARK: - NSFetchedResultsControllerDelegate

extension RedditPostsVC: NSFetchedResultsControllerDelegate {
  func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    self.tableView.beginUpdates()
  }
  
  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
    
    switch type {
    case .insert:
      self.tableView.insertRows(at: [newIndexPath!], with: .automatic)
    case .delete:
      self.tableView.deleteRows(at: [indexPath!], with: .automatic)
    case .update:
      self.tableView.reloadRows(at: [indexPath!], with: .automatic)
    case .move:
      self.tableView.deleteRows(at: [indexPath!], with: .automatic)
      self.tableView.insertRows(at: [newIndexPath!], with: .automatic)
    @unknown default:
      break
    }
    
    self.canLoadMore = true
    self.refreshControl?.endRefreshing()
  }
  
  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
    
    switch type {
    case .insert:
      self.tableView.insertSections([sectionIndex], with: .automatic)
    case .delete:
      self.tableView.deleteSections([sectionIndex], with: .automatic)
    case .move:
      self.tableView.deleteSections([sectionIndex], with: .automatic)
      self.tableView.insertSections([sectionIndex], with: .automatic)
    case .update:
      self.tableView.reloadSections([sectionIndex], with: .automatic)
    @unknown default:
      break
    }
    
    self.refreshControl?.endRefreshing()
  }
  
  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    self.tableView.endUpdates()
  }
}

//MARK: - UIViewControllerTransitioningDelegate

extension RedditPostsVC: UIViewControllerTransitioningDelegate {
  func animationController(
    forPresented presented: UIViewController,
    presenting: UIViewController, source: UIViewController)
      -> UIViewControllerAnimatedTransitioning? {
    guard
      let selectedIndexPathCell = self.tableView.indexPathForSelectedRow,
      let selectedCell = self.tableView.cellForRow(at: selectedIndexPathCell) as? RedditPostCell,
      let selectedCellSuperview = selectedCell.superview
    else { return nil }

    let frame = selectedCellSuperview.convert(selectedCell.frame, to: nil)
    
    self.transition.originFrame = CGRect(
      x: frame.origin.x,
      y: frame.origin.y + frame.height / 2,
      width: frame.size.width,
      height: 1
    )

    self.transition.presenting = true

    return transition
  }

  func animationController(forDismissed dismissed: UIViewController)
      -> UIViewControllerAnimatedTransitioning? {
    self.transition.presenting = false
    return transition
  }
}
