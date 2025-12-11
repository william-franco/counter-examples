import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

typedef _ViewModel = ChangeNotifier;

abstract interface class CounterViewModel extends _ViewModel {
  CounterModel get model;

  void increment();
  void decrement();
}

class CounterViewModelImpl extends _ViewModel implements CounterViewModel {
  CounterModel _model = CounterModel();

  @override
  CounterModel get model => _model;

  @override
  void increment() {
    _model = _model.copyWith(counter: _model.counter + 1);
    _debug();
  }

  @override
  void decrement() {
    _model = _model.copyWith(counter: _model.counter - 1);
    _debug();
  }

  void _debug() {
    notifyListeners();
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
    counterViewModel = CounterViewModelImpl();
    debugPrint('COUNTER HASHCODE: ${counterViewModel.hashCode}');
  }

  @override
  void dispose() {
    counterViewModel.dispose();
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
            StateBuilderWidget<CounterViewModel>(
              viewModel: counterViewModel,
              builder: (context, state) {
                return Text(
                  '${state.model.counter}',
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
typedef StateBuilder<S> = Widget Function(BuildContext context, S state);

class StateBuilderWidget<T extends ChangeNotifier> extends StatelessWidget {
  final T viewModel;
  final StateBuilder<T> builder;

  const StateBuilderWidget({
    super.key,
    required this.builder,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<T>.value(
      value: viewModel,
      child: Consumer<T>(
        builder: (context, notifier, child) {
          return builder(context, notifier);
        },
      ),
    );
  }
}
