import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config.dart';
import '../oss_licenses.dart';

class About extends StatelessWidget {
  const About({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("About"),
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          tooltip: "Back",
          icon: Icon(Icons.adaptive.arrow_back),
          color: Theme.of(context).appBarTheme.foregroundColor,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: [
          if (appConfig.appDesc != null)
            Text(appConfig.appDesc!,
                style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 16.0),
          Text(
            "Open Source Libraries",
            style: Theme.of(context)
                .textTheme
                .headlineMedium!
                .copyWith(color: Theme.of(context).colorScheme.onBackground),
          ),
          for (final package in ossLicenses)
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Material(
                type: MaterialType.card,
                surfaceTintColor: Colors.white,
                borderRadius: const BorderRadius.all(Radius.circular(16.0)),
                child: InkWell(
                  onTap: () => showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => Dialog(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    const SizedBox(height: 16.0),
                                    Text(
                                      package.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                    Text(
                                      package.license ??
                                          "This package has no license",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (package.homepage != null)
                                  TextButton(
                                    onPressed: () {
                                      launchUrl(Uri.parse(package.homepage!),
                                          mode: LaunchMode.externalApplication);
                                    },
                                    child: const Text('Go to project homepage'),
                                  ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Done'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(16.0)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      package.name,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
