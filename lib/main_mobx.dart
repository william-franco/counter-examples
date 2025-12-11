import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';

part 'main_mobx.g.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Counter Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: ThemeMode.system,
      home: const CounterView(),
    );
  }
}

class CounterModel {
  final int counter;

  CounterModel({this.counter = 0});

  CounterModel copyWith({int? counter}) =>
      CounterModel(counter: counter ?? this.counter);
}

class CounterViewModel = CounterViewModelBase with _$CounterViewModel;

abstract class CounterViewModelBase with Store {
  @observable
  CounterModel model = CounterModel();

  @action
  void increment() {
    model = model.copyWith(counter: model.counter + 1);
    _debug();
  }

  @action
  void decrement() {
    model = model.copyWith(counter: model.counter - 1);
    _debug();
  }

  void _debug() {
    debugPrint('Counter: ${model.counter}');
  }
}

class CounterView extends StatefulWidget {
  const CounterView({super.key});

  @override
  State<CounterView> createState() => _CounterViewState();
}

class _CounterViewState extends State<CounterView> {
  late final CounterViewModel counterViewModel;

  @override
  void initState() {
    super.initState();
    counterViewModel = CounterViewModel();
    debugPrint('COUNTER HASHCODE: ${counterViewModel.hashCode}');
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Counter')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            StateBuilderWidget(
              builder: (context) {
                return Text(
                  '${counterViewModel.model.counter}',
                  style: Theme.of(context).textTheme.headlineMedium,
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
            key: const Key('increment'),
            child: const Icon(Icons.add_outlined),
            onPressed: () {
              counterViewModel.increment();
            },
          ),
          const SizedBox(height: 8.0),
          FloatingActionButton(
            key: const Key('decrement'),
            child: const Icon(Icons.remove_outlined),
            onPressed: () {
              counterViewModel.decrement();
            },
          ),
        ],
      ),
    );
  }
}

@protected
typedef StateBuilder = Widget Function(BuildContext context);

class StateBuilderWidget extends StatelessWidget {
  final StateBuilder builder;

  const StateBuilderWidget({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) => builder(context));
  }
}
