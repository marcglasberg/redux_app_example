import 'package:async_redux_project_template/_EXPORT.dart';
import 'package:flutter/material.dart';

////////////////////////////////////////////////////////////////////////////////////////////////////

class TriviaControls extends StatefulWidget {
  //
  final VoidCallback onGetRandomTrivia;
  final ValueSetter<String> onSearchTrivia;

  const TriviaControls({
    Key? key,
    required this.onGetRandomTrivia,
    required this.onSearchTrivia,
  }) : super(key: key);

  @override
  _TriviaControlsState createState() => _TriviaControlsState();
}

////////////////////////////////////////////////////////////////////////////////////////////////////

class _TriviaControlsState extends State<TriviaControls> {
  //
  static const inputDecoration = const InputDecoration(
    border: OutlineInputBorder(),
    hintText: 'Input a number...',
  );

  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _textField(),
        const Box(height: 10),
        Row(
          children: [
            Expanded(child: _searchButton()),
            const Box(width: 10),
            Expanded(child: _randomButton()),
          ],
        )
      ],
    );
  }

  TextField _textField() => TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: inputDecoration,
        onSubmitted: (_) => _onSearch(),
      );

  Widget _randomButton() => ElevatedButton(
        child: const Text('Get random trivia'),
        onPressed: () {
          widget.onGetRandomTrivia();
          controller.clear();
        },
      );

  Widget _searchButton() => ElevatedButton(
        child: const Text('Search'),
        onPressed: _onSearch,
      );

  void _onSearch() {
    widget.onSearchTrivia(controller.text);
    controller.clear();
  }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
