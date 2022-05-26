import 'package:flutter/material.dart';
import 'package:komikku/utils/toast.dart';
import 'package:komikku/views/latest_update.dart';
import 'package:komikku/views/me.dart';
import 'package:komikku/views/signup.dart';
import 'package:komikku/views/subscribes.dart';
import 'package:komikku/views/login.dart';

/// 主界面Shell
class Shell extends StatefulWidget {
  const Shell({Key? key}) : super(key: key);

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  final _pages = [const LatestUpdate(), const Subscribes(), const Me()];
  int _currentIndex = 0;
  DateTime? lastPop;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              label: '最新更新',
              icon: Icon(
                Icons.home_rounded,
                color: Colors.green,
              ),
            ),
            BottomNavigationBarItem(
              label: '订阅',
              icon: Icon(
                Icons.favorite,
                color: Colors.pink,
              ),
            ),
            BottomNavigationBarItem(
              label: '我的',
              icon: Icon(
                Icons.person_pin,
                color: Colors.blue,
              ),
            ),
          ],
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            if (index != _currentIndex) setState(() => _currentIndex = index);
          },
        ),
      ),
      onWillPop: () async {
        if (lastPop == null || DateTime.now().difference(lastPop!) > const Duration(seconds: 2)) {
          lastPop = DateTime.now();
          showText(text: '再按一次退出');
          return false;
        }
        return true;
      },
    );
  }
}

/// 登录-注册的Shell
class TabShell extends StatefulWidget {
  const TabShell({Key? key}) : super(key: key);

  @override
  State<TabShell> createState() => _TabShellState();
}

class _TabShellState extends State<TabShell> {
  final _pages = [const Login(), const Signup()];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _pages.length,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_rounded,
                  color: Colors.black45,
                ),
                onPressed: () => Navigator.pop(context),
              );
            },
          ),
        ),
        body: TabBarView(children: _pages),
      ),
    );
  }
}
