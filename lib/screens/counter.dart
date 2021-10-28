import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

//Gerenciador de estado e o estado atual
//Exemplo de contador utilizando bloc em duas variações
class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  void increment() => emit(state + 1);

  void decrement() => emit(state - 1);
}

class CounterContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => CounterCubit(), child: CounterView());
  }
}

class CounterView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text("Counter"),
      ),
      body: Center(
        child: BlocBuilder<CounterCubit, int>(builder: (context, state) {
          return Text("$state", style: textTheme.headline2);
        }),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            child: const Icon(Icons.add),
            //abordagem 1 de como acessar o bloc
            onPressed: () => context.read<CounterCubit>().increment(),
          ),
          const SizedBox(
            height: 8,
          ),
          FloatingActionButton(
            backgroundColor: Colors.red,
            child: const Icon(Icons.remove),
            onPressed: () => context.read<CounterCubit>().decrement(),
          ),
        ],
      ),
    );
  }
}
