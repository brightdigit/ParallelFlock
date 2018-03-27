import UIKit

private let styleReuseIdentifier = "style"
private let metricReuseIdentifier = "metric"

public struct Record {
  public let values = [Double].init(repeating: Double(arc4random()) / Double(arc4random()), count: 3)
}

class CollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
  let records = [Record].init(repeating: Record(), count: 100)

  override func viewDidLoad() {
    super.viewDidLoad()

    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false

    // Register cell classes
    self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: styleReuseIdentifier)
    self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: metricReuseIdentifier)

    // Do any additional setup after loading the view.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  /*
   // MARK: - Navigation

   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using [segue destinationViewController].
   // Pass the selected object to the new view controller.
   }
   */

  // MARK: UICollectionViewDataSource

  override func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
    // #warning Incomplete implementation, return the number of items
    return self.records.count * 5
  }

  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    // Configure the cell
    let recordIndex = indexPath.row / 5
    let valueIndex = indexPath.row % 5

    let record = self.records[recordIndex]

    if valueIndex < 2 {
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: styleReuseIdentifier, for: indexPath)
      cell.backgroundColor = .green
      return cell
    } else {
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: metricReuseIdentifier, for: indexPath)
      let label = cell.viewWithTag(1) as! UILabel
      label.text = record.values[valueIndex - 2].description

      return cell
    }
  }

  // MARK: UICollectionViewDelegate

  /*
   // Uncomment this method to specify if the specified item should be highlighted during tracking
   override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
   return true
   }
   */

  /*
   // Uncomment this method to specify if the specified item should be selected
   override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
   return true
   }
   */

  /*
   // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
   override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
   return false
   }

   override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
   return false
   }

   override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {

   }
   */
}
