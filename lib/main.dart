import 'package:flutter/material.dart';

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
  final int count;

  const CounterModel({this.count = 0});

  CounterModel copyWith({int? counter}) {
    return CounterModel(count: counter ?? count);
  }

  @override
  String toString() => 'CounterModel(counter: $count)';
}

typedef _ViewModel = StateManagement<CounterModel>;

abstract interface class CounterViewModel extends _ViewModel {
  void increment();
  void decrement();
}

class CounterViewModelImpl extends _ViewModel implements CounterViewModel {
  @override
  CounterModel build() => CounterModel();

  @override
  void increment() {
    final model = state.copyWith(counter: state.count + 1);
    _emit(model);
  }

  @override
  void decrement() {
    final model = state.copyWith(counter: state.count - 1);
    _emit(model);
  }

  void _emit(CounterModel newState) {
    emitState(newState);
    debugPrint('Counter: ${state.count}');
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
            StateBuilderWidget<CounterViewModel, CounterModel>(
              viewModel: counterViewModel,
              builder: (context, counterModel) {
                return Text(
                  '${counterModel.count}',
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

////////////////////////////////////////////////////////////////////////////////

abstract class StateManagement<T> extends ChangeNotifier {
  late T _state;

  StateManagement() {
    _state = build();
  }

  @protected
  T build();

  T get state => _state;

  @protected
  void emitState(T newState) {
    if (identical(_state, newState)) return;
    _state = newState;
    notifyListeners();
  }

  @override
  String toString() => 'StateManagement<$T>(state: $_state)';
}

@protected
typedef StateBuilder<S> = Widget Function(BuildContext context, S state);

class StateBuilderWidget<V extends StateManagement<S>, S>
    extends StatelessWidget {
  final V viewModel;
  final StateBuilder<S> builder;
  final Widget? child;

  const StateBuilderWidget({
    super.key,
    required this.viewModel,
    required this.builder,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      child: child,
      builder: (context, child) {
        return builder(context, viewModel.state);
      },
    );
  }
}
