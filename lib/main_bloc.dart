import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

typedef _ViewModel = StateManagement<CounterModel>;

abstract interface class CounterViewModel extends _ViewModel {
  CounterViewModel(super.initialState);

  void increment();
  void decrement();
}

class CounterViewModelImpl extends _ViewModel implements CounterViewModel {
  CounterViewModelImpl() : super(CounterModel());

  @override
  void increment() {
    emit(state.copyWith(counter: state.counter + 1));
    _debug();
  }

  @override
  void decrement() {
    emit(state.copyWith(counter: state.counter - 1));
    _debug();
  }

  void _debug() {
    debugPrint('Counter: ${state.counter}');
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
    counterViewModel.close();
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
              builder: (context, child) {
                return Text(
                  '${counterViewModel.state.counter}',
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

abstract class StateManagement<T> extends Cubit<T> {
  StateManagement(super.initialState);

  @protected
  void emitState(T newState) {
    if (state != newState) {
      emit(newState);
    }
  }
}

@protected
typedef StateBuilder<S> = Widget Function(BuildContext context, S state);

class StateBuilderWidget<V extends Cubit<S>, S> extends StatelessWidget {
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
    return BlocProvider<V>.value(
      value: viewModel,
      child: BlocBuilder<V, S>(
        bloc: viewModel,
        builder: (context, state) {
          return builder(context, state);
        },
      ),
    );
  }
}
