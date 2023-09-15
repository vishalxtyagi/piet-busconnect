import 'package:flutter/material.dart';

class SelectRouteScreen extends StatefulWidget {
  const SelectRouteScreen({super.key});

  final String title = 'Select Your Route';

  @override
  State<SelectRouteScreen> createState() => _SelectRouteScreenState();
}

class _SelectRouteScreenState extends State<SelectRouteScreen> {

  int _selectedRouteIndex = -1;

  final List<Map<String, dynamic>> _routes = [
    {
      'name': 'Route 1',
      'stops': [
        'Stop 1',
        'Stop 2',
        'Stop 3',
      ]
    },
    {
      'name': 'Route 2',
      'stops': [
        'Stop 5',
        'Stop 8',
        'Stop 3',
      ]
    },
  ];

  void _selectRoute(int index) {
    setState(() {
      _selectedRouteIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Select Your Route',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            Text(
              'By selecting your route, everyday you will be notified\nwhen your bus is arriving.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var route in _routes)
                  GestureDetector(
                    onTap: () => _selectRoute(_routes.indexOf(route)),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: _selectedRouteIndex == _routes.indexOf(route)
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outline ,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        route['name'],
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: _selectedRouteIndex == _routes.indexOf(route)
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.onSecondary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 30),
            Text(
              _selectedRouteIndex != -1
                ? _routes[_selectedRouteIndex]['stops'].join(' - ')
                : 'No route selected',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
