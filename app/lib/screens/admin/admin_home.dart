import 'package:flutter/material.dart';
import '../../state/app_state.dart';
import '../../widgets/app_drawer.dart';

class AdminHome extends StatelessWidget {
  const AdminHome({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final users = AppState.instance.users.values.toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Panel')),
      drawer: const AppDrawer(),
      body: ListView.builder(
          itemCount: users.length,
          itemBuilder: (c, i) {
            final u = users[i];
            return Card(
                child: ListTile(
                    title: Text(u['name']),
                    subtitle: Text('${u['role']} • ${u['email']}')));
          }),
    );
  }
}
