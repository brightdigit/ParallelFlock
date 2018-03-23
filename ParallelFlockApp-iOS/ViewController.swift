import ParallelFlock
import UIKit

extension Array: DefaultInitializable {
}

extension UInt32: DefaultInitializable {
}

extension String: DefaultInitializable {
}

func primeFactors(value: UInt32) -> UInt32 {
  if value == 1 {
    return 1
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

  return result.max() ?? 1
}

func primeFactorsAsync(_ value: UInt32, _ completion: (UInt32) -> Void) {
  completion(primeFactors(value: value))
}

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
  enum RecordType: Int, CustomStringConvertible {
    case nonParallel = 0
    case parallelBarrier = 1
    case parallelPointer = 2

    var description: String {
      return RecordType.descriptions[self.rawValue]
    }

    static let descriptions = ["Serial", "Barrier", "Pointer"]
    static let all: [RecordType] = [.nonParallel, .parallelBarrier, .parallelPointer]
  }

  var records: [RecordType: [(Date, Date)]] = [
    .nonParallel: [],
    .parallelBarrier: [],
    .parallelPointer: []
  ]

  var currentProcess: (Date, RecordType)?
  var operation: AnyObject?
  var alertController: UIAlertController?

  let source = [Void].init(repeating: Void(), count: 100_000).map { UInt32.max }

  @IBOutlet var tableViews: [UITableView]!
  @IBOutlet var performanceTestButton: UIButton!
  @IBOutlet var activityContainer: UIView!

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.

    self.tableViews.forEach {
      $0.delegate = self
      $0.dataSource = self
    }
  }

  @IBAction func performanceButtonAction(_ sender: UIButton) {
    let alertController = UIAlertController(title: sender.titleLabel?.text, message: nil, preferredStyle: .actionSheet)

    let alertActions = RecordType.all.map { (recordType) -> UIAlertAction in
      return UIAlertAction(title: recordType.description, style: .default, handler: self.onAlertAction)
    }

    for action in alertActions {
      alertController.addAction(action)
    }

    alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

    self.alertController = alertController
    self.present(alertController, animated: true, completion: nil)
  }

  func onOperationCompletion(_: [UInt32]) {
    self.operation = nil

    DispatchQueue.main.async(execute: self.endActivity)
  }

  func onAlertAction(_ action: UIAlertAction) {
    guard let title = action.title else {
      return
    }

    guard let index = RecordType.descriptions.index(of: title) else {
      return
    }

    self.performanceTestButton.isHidden = true
    self.activityContainer.isHidden = false
    let recordType = RecordType.all[index]
    self.currentProcess = (Date(), recordType)

    switch recordType {
    case .nonParallel:
      ParallelOptions.defaultQueue.async {
        _ = self.source.map(primeFactors)
        DispatchQueue.main.async {
          self.endActivity()
        }
      }
      break
    case .parallelPointer:
      let operation = ParallelMapOperation<UInt32, UInt32>(source: source, default: 0, transform: primeFactorsAsync, completion: self.onOperationCompletion)
      operation.begin()
      self.operation = operation
      break
    case .parallelBarrier:
      let operation = ParallelMapBarrierArrayOperation<UInt32, UInt32>(source: source, transform: primeFactorsAsync, completion: self.onOperationCompletion)
      operation.begin()
      self.operation = operation
      break
    }
  }

  func endActivity() {
    let endDate = Date()

    guard let (startDate, recordType) = self.currentProcess else {
      return
    }

    self.records[recordType]!.append((startDate, endDate))
    self.performanceTestButton.isHidden = false
    self.activityContainer.isHidden = true
    self.tableViews.forEach { $0.reloadData() }
    self.alertController = nil
    self.currentProcess = nil
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection _: Int) -> Int {
    let tableIndex = self.tableViews.index(of: tableView)

    guard let index = tableIndex, let recordType = RecordType(rawValue: index) else {
      return 0
    }

    return self.records[recordType]?.count ?? 0
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")

    let tableIndex = self.tableViews.index(of: tableView)

    guard let index = tableIndex, let recordType = RecordType(rawValue: index) else {
      return cell
    }

    guard let value = self.records[recordType]?[indexPath.row] else {
      return cell
    }

    cell.textLabel?.text = abs(value.0.timeIntervalSince(value.1)).description

    return cell
  }

  func tableView(_ tableView: UITableView, titleForHeaderInSection _: Int) -> String? {
    let tableIndex = self.tableViews.index(of: tableView)

    guard let index = tableIndex, let recordType = RecordType(rawValue: index) else {
      return nil
    }

    return recordType.description
  }
}
