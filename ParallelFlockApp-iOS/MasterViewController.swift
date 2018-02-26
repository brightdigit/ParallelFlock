import ParallelFlock
import UIKit
func primeFactors(value: UInt32) -> [UInt32] {
  if value == 1 {
    return [1]
  }

  var result: [UInt32] = []

  var number = value
  var divisor = 2

  func testDivisor(_ divisor: UInt32) {
    while number > divisor && number % divisor == 0 {
      result.append(divisor)
      number /= divisor
    }
  }

  testDivisor(2)

  for other in stride(from: 3, to: sqrt(Double(value)), by: 2) {
    testDivisor(UInt32(other))
  }

  if number > 1 {
    result.append(number)
  }

  return result
}

class MasterViewController: UITableViewController {
  var detailViewController: DetailViewController?
  var objects = (0 ... 100).map { _ in arc4random_uniform(100) + 100 }
  var factors: [UInt32: [UInt32]]?
  var operation : ParallelMapOperation<UInt32, [UInt32]>?

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    navigationItem.leftBarButtonItem = editButtonItem

    let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.insertNewObject(_:)))
    navigationItem.rightBarButtonItem = addButton
    if let split = splitViewController {
      let controllers = split.viewControllers
      detailViewController = (controllers[controllers.count - 1] as! UINavigationController).topViewController as? DetailViewController
    }

    self.operation = self.objects.parallel.map(primeFactors) { factorValues in
      self.factors = [UInt32: [UInt32]].init(uniqueKeysWithValues: zip(self.objects, factorValues))
      self.operation = nil
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
    super.viewWillAppear(animated)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  @objc
  func insertNewObject(_: Any) {
    self.objects.insert(arc4random_uniform(100) + 100, at: 0)
    let indexPath = IndexPath(row: 0, section: 0)
    tableView.insertRows(at: [indexPath], with: .automatic)
  }

  // MARK: - Segues

  override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
    if segue.identifier == "showDetail" {
      if let indexPath = tableView.indexPathForSelectedRow {
        let object = objects[indexPath.row]
        let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
        controller.detailItem = (object, self.factors?[object])
        controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
        controller.navigationItem.leftItemsSupplementBackButton = true
      }
    }
  }

  // MARK: - Table View

  override func numberOfSections(in _: UITableView) -> Int {
    return 1
  }

  override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
    return self.objects.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

    let object = objects[indexPath.row]
    cell.textLabel!.text = object.description
    return cell
  }

  override func tableView(_: UITableView, canEditRowAt _: IndexPath) -> Bool {
    // Return false if you do not want the specified item to be editable.
    return true
  }

  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      self.objects.remove(at: indexPath.row)
      tableView.deleteRows(at: [indexPath], with: .fade)
    } else if editingStyle == .insert {
      // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
  }
}
