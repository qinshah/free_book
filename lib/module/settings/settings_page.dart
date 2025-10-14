import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  int _count = 0;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(
      alignment: Alignment.center,
      children: [
        ListView.builder(
          itemBuilder: (context, index) {
            return ListTile(title: Text('Item $index'));
          },
        ),
        TextButton(
          onPressed: () => setState(() => _count++),
          child: Text('$_count'),
        ),
      ],
    );
  }
}
