import 'package:flutter/material.dart';

/// 갤럭시 폴드7(펼치면 넓은 화면) / 플립5(좁은 화면) 대응.
/// 화면 너비가 600dp 이상이면 NavigationRail을, 이하면 하단 네비게이션 바를 쓴다.
class ResponsiveScaffold extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final List<Widget> pages;
  final List<NavigationDestination> destinations;
  final Widget titleWidget;

  const ResponsiveScaffold({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
    required this.pages,
    required this.destinations,
    required this.titleWidget,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 600;
    final body = IndexedStack(index: selectedIndex, children: pages);

    if (isWide) {
      return Scaffold(
        appBar: AppBar(title: titleWidget),
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: onSelect,
              labelType: NavigationRailLabelType.all,
              destinations: destinations
                  .map((d) => NavigationRailDestination(
                        icon: d.icon,
                        selectedIcon: d.selectedIcon,
                        label: Text(d.label),
                      ))
                  .toList(),
            ),
            const VerticalDivider(width: 1),
            Expanded(child: body),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: titleWidget),
      body: body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onSelect,
        destinations: destinations,
      ),
    );
  }
}
