import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:free_book/module/root/root_logic.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final _themeManager = AdaptiveTheme.of(context);

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: PageStorageKey('SettingsPageStorageKey'),
      controller: context.read<RootLogic>().curState.scrollCntlr,
      children: [
        ListTile(title: Text('外观')),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              ListTile(
                title: const Text('主题亮暗(深色模式)', style: TextStyle(fontSize: 16)),
                subtitle: CupertinoSlidingSegmentedControl(
                  groupValue: _themeManager.mode,
                  onValueChanged: (mode) => _themeManager.setThemeMode(mode!),
                  children: Map.fromIterables(
                    AdaptiveThemeMode.values,
                    AdaptiveThemeMode.values.map((mode) => Text(mode.name)),
                  ),
                ),
              ),
              ListTile(
                title: const Text('主色调'),
                subtitle: const Text('切换功能待开发'),
                trailing: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
