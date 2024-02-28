import 'package:flutter/material.dart';
import 'NotCompletedTasks.dart';
import 'CompletedTasks.dart';



class AllTasks extends StatefulWidget {
  @override
  _AllTasksState createState() => _AllTasksState();
}

class _AllTasksState extends State<AllTasks> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Todo App'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Completed'),
            Tab(text: 'Not Completed'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          CompletedTasksPage(),
          NotCompletedTasksPage(),
        ],
      ),
    );
  }
}