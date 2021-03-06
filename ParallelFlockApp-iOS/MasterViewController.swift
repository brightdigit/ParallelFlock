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

extension Sequence where Element: Hashable {
  func unique() -> Array<Element> {
    return Array(Set<Element>.init(self))
  }
}

class MasterViewController: UITableViewController {
  var objects: [UInt32]?
  var factors: [UInt32: [UInt32]]?
  var operation: ParallelMapOperation<UInt32, [UInt32]>?
  weak var activityIndicatorView: UIActivityIndicatorView!

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.

    let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    activityIndicatorView.startAnimating()
    self.navigationItem.titleView = activityIndicatorView

    self.tableView.alpha = 0.7
    self.view.backgroundColor = .white

    DispatchQueue.global(qos: .background).async {
      let objects = (0 ... 500_000).map { _ in arc4random_uniform(1_000_000) + 1_000_000 }.unique().sorted()
      self.objects = objects
      DispatchQueue.main.async {
        self.tableView.reloadData()
      }
      print(objects.count)
      self.operation = objects.parallel.map({
        $1(primeFactors(value: $0))
      }, completion: { factorValues in
        self.factors = [UInt32: [UInt32]].init(uniqueKeysWithValues: zip(objects, factorValues))
        self.operation = nil
        DispatchQueue.main.async {
          UIView.animate(withDuration: 1.0, animations: {
            self.navigationItem.titleView = nil
            self.tableView.alpha = 1.0
          })
        }
      })
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  // MARK: - Segues

  override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
    if let factors = self.factors, let detailViewController = segue.destination as? DetailViewController, let indexPath = tableView.indexPathForSelectedRow {
      let multiple = self.objects![indexPath.row]
      detailViewController.detailItem = (multiple, factors[multiple])
    }
  }

  // MARK: - Table View

  override func numberOfSections(in _: UITableView) -> Int {
    return 1
  }

  override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
    return self.objects?.count ?? 0
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

    let object = self.objects![indexPath.row]
    cell.textLabel!.text = object.description
    return cell
  }

  override func tableView(_: UITableView, canEditRowAt _: IndexPath) -> Bool {
    // Return false if you do not want the specified item to be editable.
    return false
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt _: IndexPath) {
    if self.factors != nil {
      self.performSegue(withIdentifier: "cellSegue", sender: tableView)
    }
  }
}
