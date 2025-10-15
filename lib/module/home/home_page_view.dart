import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../edit/edit_page_view.dart';
import 'home_page_logic.dart';
import 'home_page_state.dart';

class HomePageView extends StatelessWidget {
  const HomePageView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HomePageLogic(HomePageState()),
      builder: (context, _) {
        return Builder(
          builder: (context) {
            final logic = context.watch<HomePageLogic>();
            final state = logic.curState;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SizedBox(height: 22),
                Text('全部', style: TextStyle(fontSize: 20)),
                SizedBox(height: 6),
                _buildFiles(state.filePaths),
                SizedBox(height: 22),
                Text('最近', style: TextStyle(fontSize: 20)),
                SizedBox(height: 6),
                _buildFiles(state.recentFilePaths),
                SizedBox(height: 22),
                Text('示例', style: TextStyle(fontSize: 20)),
                SizedBox(height: 6),
                _DocItem('assets/示例文档.json', () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return EditPageView('assets/示例文档.json');
                      },
                    ),
                  );
                }),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildFiles(List<String> filePaths) {
    if (filePaths.isEmpty) {
      return Card(
        child: SizedBox(
          height: 100,
          child: Center(child: Text('空', style: TextStyle(fontSize: 20))),
        ),
      );
    }
    return _buldItems(filePaths);
  }

  Column _buldItems(List<String> filePaths) {
    return Column(
      children: List.generate(filePaths.length, (index) {
        return Padding(
          padding: const EdgeInsets.only(top: 6),
          child: _DocItem(filePaths[index]),
        );
      }),
    );
  }
}

class _DocItem extends StatelessWidget {
  const _DocItem(this.filePath, [this.onTap]);

  final String filePath;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fileName = filePath.split('/').last.split('.').first;
    return Ink(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            blurRadius: 1,
            spreadRadius: 1,
            color: Colors.grey.shade300,
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap ?? () {},
        child: ListTile(
          title: Text(
            fileName,
            style: TextStyle(fontSize: 16),
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            filePath,
            style: TextStyle(fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
