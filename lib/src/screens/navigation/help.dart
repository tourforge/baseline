import 'package:flutter/material.dart';

import '../help_slides.dart';

class NavigationHelpScreen extends StatefulWidget {
  const NavigationHelpScreen({super.key});

  @override
  State<StatefulWidget> createState() => _NavigationHelpScreenState();
}

class _NavigationHelpScreenState extends State<NavigationHelpScreen> {
  final HelpSlidesController _controller = HelpSlidesController();

  @override
  Widget build(BuildContext context) {
    return HelpSlidesScreen(
      dismissible: true,
      title: "Help",
      controller: _controller,
      onDone: () {
        Navigator.of(context).pop();
      },
      slides: [
        HelpSlide(
          children: [
            Text(
              "Navigation Mode",
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16.0),
            Text(
              "In navigation mode, you can view a map of a tour and its surrounding areas. "
              "While the map is open, audio narrations about the stops you visit will automatically play.",
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32.0),
            Text(
              "Using the Map",
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16.0),
            Text(
              "Use your fingers to move and zoom the map.",
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16.0),
            Text(
              "Tap on markers to open an info page including a helpful Directions button "
              "that links to your phone's navigation app with directions to the stop.",
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32.0),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 12.0,
                horizontal: 48.0,
              ),
              child: ElevatedButton(
                onPressed: _controller.finish,
                child: Text(
                  "Got it",
                  style: Theme.of(context).textTheme.labelLarge!.copyWith(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
