import UIKit
import PlaygroundSupport
import Combine

extension UIControl {
    class InteractionSubscription<S: Subscriber>: Subscription where S.Input == Void {
        
        private let subscriber: S?
        private let control: UIControl
        private let event: UIControl.Event
        
        init(subscriber: S?, control: UIControl, event: UIControl.Event) {
            self.subscriber = subscriber
            self.control = control
            self.event = event
            
            self.control.addTarget(self, action: #selector(handleEvent), for: event)
        }
        
        @objc
        func handleEvent(_ sender: UIControl) {
            _ = self.subscriber?.receive(())
        }
        
        func request(_ demand: Subscribers.Demand) { }
        
        func cancel() {
            
        }
    }
    
    struct InteractionPublisher: Publisher {
        
        typealias Output = Void
        typealias Failure = Never
        
        private let control: UIControl
        private let event: UIControl.Event
        
        init(control: UIControl, event: UIControl.Event) {
            self.control = control
            self.event = event
        }
        
        func receive<S>(subscriber: S) where S : Subscriber, Never == S.Failure, Void == S.Input {
            let subscription = InteractionSubscription(subscriber: subscriber, control: control, event: event)
            subscriber.receive(subscription: subscription)
        }
    }
    
    func publisher(for event: UIControl.Event) -> UIControl.InteractionPublisher {
        
        return InteractionPublisher(control: self, event: event)
    }
}

class MyViewController: UIViewController {
    var cancellables = Set<AnyCancellable>()
    
    lazy var button: UIButton = {
        let button = UIButton()
        button.setTitle("Tap! \(counter)", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var counter = 3
    
    private func observeButtonTaps() {
        button
            .publisher(for: .touchUpInside)
            .sink { [unowned self] _ in
                self.counter -= 1
                self.button.setTitle("Tap! \(self.counter)", for: .normal)
                print("Tapped")
                print(counter)
            }
            .store(in: &cancellables)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.observeButtonTaps()
    }
    
    override func loadView() {
        let view = UIView()
        view.backgroundColor = .white
        
        view.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.centerXAnchor
                .constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor
                .constraint(equalTo: view.centerYAnchor)
        ])
        
        self.view = view
    }
    
}

PlaygroundPage.current.liveView = MyViewController()
