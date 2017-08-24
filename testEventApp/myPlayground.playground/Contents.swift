//: Playground - noun: a place where people can play

import UIKit

class FeedAndGroupsViewController: ...{
    
    @IBOutlet weak var feedAndGroupsCollectionView: UICollectionView!
    
    var eventClassRef: eventsCustomCollectionCell = eventsCustomCollectionCell()
    
    //used for segue to eventinfo
    var latestEventCell: eventUICell2!
    var latestEventCollectionCell: eventsCustomCollectionCell!
    var latestIndexPath: IndexPath!
    
    func didClick(collectionCell:eventsCustomCollectionCell,eventCell: eventUICell2, indexPathInTableView: IndexPath){
        if var collectionIndex = feedAndGroupsCollectionView.indexPath(for: collectionCell){
            if var cellIndex = collectionCell.events.indexPath(for: eventCell){
                latestEventCell = eventCell
                latestEventCollectionCell = collectionCell
                latestIndexPath = indexPathInTableView
                performSegue(withIdentifier: "segueFeedToEvent", sender: self)
            }
        }
    }

    @IBAction func unwindToFeedWithDeletedEvent(segue: UIStoryboardSegue) {
        let child = self.childViewControllers[0] as! eventInformationVC
        let index = self.latestEventCollectionCell.eventCells.index(of: self.latestEventCell)
        self.latestEventCollectionCell.eventCells.remove(at: index! as! Int)
        self.latestEventCollectionCell.events.deleteRows(at: [self.latestIndexPath], with: UITableViewRowAnimation.automatic)
    
        child.willMove(toParentViewController: nil)
        child.view.removeFromSuperview()
        child.removeFromParentViewController()
    }
}

protocol eventsCustomCollectionCellDelegate : class{
    func didClick(collectionCell:eventsCustomCollectionCell,eventCell: eventUICell2, indexPathInTableView: IndexPath)
}

class eventsCustomCollectionCell: ... {
    
    let events = UITableView()
    var eventCells = [eventUICell2]()
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didClick(collectionCell: self, eventCell: events.cellForRow(at: indexPath) as! eventUICell2, indexPathInTableView: indexPath)
    }
}