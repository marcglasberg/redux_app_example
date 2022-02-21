import 'package:async_redux_project_template/_EXPORT.dart';
import 'package:flutter/material.dart';

////////////////////////////////////////////////////////////////////////////////////////////////////

class Trivia_Widget extends StatelessWidget {
  //
  final Wait wait;
  final int number;
  final String description;
  final VoidCallback onSeeCache;

  Trivia_Widget({
    required this.wait,
    required this.number,
    required this.description,
    required this.onSeeCache,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Number Trivia with AsyncRedux')),
      body: Box(
        padding: const Pad(all: 15),
        child: Column(
          children: [
            const Box(height: 10),
            Expanded(flex: 3, child: _top()),
            const Box(height: 10),
            const Expanded(flex: 2, child: TriviaControls_Connector()),
            _seeCache(),
          ],
        ),
      ),
    );
  }

  Widget _top() {
    //
    if (number == -1)
      return const _MessageDisplay(message: 'Start searching!');
    //
    else if (wait.isWaiting)
      return const _LoadingWidget();
    //
    else
      return _TriviaDisplay(number: number, description: description);
  }

  Widget _seeCache() => Align(
        alignment: Alignment.centerRight,
        child: TextButton(
          child: const Text('See cache'),
          onPressed: onSeeCache,
        ),
      );
}

////////////////////////////////////////////////////////////////////////////////////////////////////

class _TriviaDisplay extends StatelessWidget {
  //
  final int number;
  final String description;

  const _TriviaDisplay({
    Key? key,
    required this.number,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          number.toString(),
          style: const TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              child: Text(
                description,
                style: const TextStyle(fontSize: 25),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

////////////////////////////////////////////////////////////////////////////////////////////////////

class _MessageDisplay extends StatelessWidget {
  final String message;

  const _MessageDisplay({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Text(
          message,
          style: const TextStyle(fontSize: 25),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////////////////////////////////////////////

class _LoadingWidget extends StatelessWidget {
  const _LoadingWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
////////////////////////////////////////////////////////////////////////////////////////////////////
