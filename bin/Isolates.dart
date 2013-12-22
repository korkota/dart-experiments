import 'dart:isolate';
import 'dart:async';

void main() {
  ReceivePort fromChild = new ReceivePort();
  Stream<String> streamFromChild = fromChild.asBroadcastStream();
  SendPort toChild;
  
  streamFromChild
    .skip(1)
    .listen((message) {
      print('Parent received message from child: $message');
      new Timer(new Duration(seconds: 2), () => toChild.send('GO TO YOUR ROOM!!!'));
    });
  
  Isolate.spawn(isolate, fromChild.sendPort)
    .then((_) => streamFromChild.first)
    .then((sendPort) {
      toChild = sendPort; 
      toChild.send('GO TO YOUR ROOM!!!');
    })
    .catchError((error) => print('error: $error'));
}

void isolate(SendPort toParent) {
  ReceivePort fromParent = new ReceivePort();
  
  fromParent
    .listen((message) { 
      print('Child received message from parent: $message');
      new Timer(new Duration(seconds: 2), () => toParent.send('NNNOOOOO! :O'));
    });
  
  toParent.send(fromParent.sendPort);
}