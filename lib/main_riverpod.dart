import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
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

final counterViewModelProvider =
    NotifierProvider.autoDispose<CounterViewModel, CounterModel>(
      CounterViewModelImpl.new,
    );

class CounterModel {
  final int counter;

  CounterModel({this.counter = 0});

  CounterModel copyWith({int? counter}) =>
      CounterModel(counter: counter ?? this.counter);
}

typedef _ViewModel = Notifier<CounterModel>;

abstract interface class CounterViewModel extends _ViewModel {
  CounterModel get model;

  void increment();
  void decrement();
}

class CounterViewModelImpl extends _ViewModel implements CounterViewModel {
  @override
  CounterModel build() {
    return CounterModel();
  }

  @override
  CounterModel get model => state;

  @override
  void increment() {
    state = state.copyWith(counter: state.counter + 1);
    _debug();
  }

  @override
  void decrement() {
    state = state.copyWith(counter: state.counter - 1);
    _debug();
  }

  void _debug() {
    debugPrint('Counter: ${state.counter}');
  }
}

class CounterView extends ConsumerStatefulWidget {
  const CounterView({super.key});

  @override
  ConsumerState<CounterView> createState() => _CounterViewState();
}

class _CounterViewState extends ConsumerState<CounterView> {
  @override
  void initState() {
    super.initState();
    debugPrint(
      'COUNTER HASHCODE: ${ref.read(counterViewModelProvider.notifier).hashCode}',
    );
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
            StateBuilderWidget<CounterModel>(
              provider: counterViewModelProvider,
              builder: (context, state) {
                return Text(
                  '${state.counter}',
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
              ref.read(counterViewModelProvider.notifier).increment();
            },
          ),
          const SizedBox(height: 8.0),
          FloatingActionButton(
            key: const Key('decrement'),
            child: const Icon(Icons.remove_outlined),
            onPressed: () {
              ref.read(counterViewModelProvider.notifier).decrement();
            },
          ),
        ],
      ),
    );
  }
}

@protected
typedef StateBuilder<T> = Widget Function(BuildContext context, T state);

class StateBuilderWidget<T> extends StatelessWidget {
  final ProviderListenable<T> provider;
  final StateBuilder<T> builder;

  const StateBuilderWidget({
    super.key,
    required this.provider,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final state = ref.watch(provider);
        return builder(context, state);
      },
    );
  }
}
