import 'dart:math';

import 'package:flutter/material.dart';
import 'package:one_context/one_context.dart';

bool debugShowCheckedModeBanner = false;
const localeEnglish = [Locale('en', '')];

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  OnePlatform.app = () => MyApp();
}

class MyApp extends StatelessWidget {
  MyApp() {
    print('MyApp loaded!');

    debugShowCheckedModeBanner = true;
  }

  @override
  Widget build(BuildContext context) {
    /// important: Use [OneContext().builder] in MaterialApp builder, in order to show dialogs, overlays and change the app theme.
    /// important: Use [OneContext().key] in MaterialApp navigatorKey, in order to navigate.

    return OneNotification<List<Locale>>(
      onVisited: (_, __) {
        print('Root widget visited!');
      },
      // This widget rebuild the Material app to update theme, supportedLocales, etc...
      stopBubbling: true, // avoid the data bubbling to ancestors widgets
      initialData:
          localeEnglish, // [data] is null during boot of the application, but you can set initialData ;)
      rebuildOnNull:
          true, // Allow other entities reload this widget without messing up currenty data (Data is cached on first event)

      builder: (context, dataLocale) {
        if (dataLocale != null && dataLocale != localeEnglish)
          print('Set Locale: $dataLocale');

        return OneNotification<OneThemeChangerEvent>(
            onVisited: (_, __) {
              print('Theme Changer widget visited!');
            },
            stopBubbling: true,
            builder: (context, data) {
              return MaterialApp(
                debugShowCheckedModeBanner: debugShowCheckedModeBanner,

                // Configure reactive theme mode and theme data (needs OneNotification above in the widget tree)
                themeMode: OneThemeController.initThemeMode(ThemeMode.light),
                theme: OneThemeController.initThemeData(ThemeData(
                  colorSchemeSeed: Colors.green,
                  brightness: Brightness.light,
                  useMaterial3: true,
                )),
                darkTheme: OneThemeController.initDarkThemeData(ThemeData(
                    colorSchemeSeed: Colors.blue, brightness: Brightness.dark)),

                // Configure Navigator key
                navigatorKey: OneContext().key,

                // Configure navigator observers for proper back gesture handling
                navigatorObservers: [OneContext().navAppObserver],

                // Configure [OneContext] to dialogs, overlays, snackbars, and ThemeMode
                builder: OneContext().builder,

                // [data] it comes through events
                supportedLocales: dataLocale ?? [const Locale('en', '')],

                title: 'OneContext Demo',
                home: MyHomePage(
                  title: 'OneContext Demo',
                ),
                // routes: {'/second': (context) => SecondPage()},
                onGenerateRoute: (settings) {
                  if (settings.name == SecondPage.routeName) {
                    return MaterialPageRoute<String>(
                      builder: (context) {
                        return SecondPage();
                      },
                      settings: settings,
                    );
                  } else
                    return null;
                },
              );
            });
      },
    );
  }
}

class MyApp2 extends StatelessWidget {
  MyApp2() {
    print('MyApp2 loaded!');
    OneContext().key = GlobalKey<NavigatorState>();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(primarySwatch: Colors.pink),
        title: 'OneContext Demo',
        home: MyHomePage2(title: 'A NEW APPLICATION'),
        routes: {'/second': (context) => SecondPage()},
        builder: OneContext().builder,
        navigatorKey: OneContext().key,
        navigatorObservers: [OneContext().navAppObserver]);
  }
}

class MyHomePage2 extends StatefulWidget {
  MyHomePage2({this.title, Key? key}) : super(key: key);
  final String? title;
  @override
  _MyHomePage2State createState() => _MyHomePage2State();
}

class _MyHomePage2State extends State<MyHomePage2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? ""),
      ),
      body: Container(
        color: Colors.pink,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
                child: Text('COME BACK TO THE OLD APP'),
                onPressed: () {
                  OnePlatform.reboot(
                    setUp: () {
                      OneContext().key = GlobalKey<NavigatorState>();
                    },
                    builder: () => MyApp(),
                  );
                }),
            ElevatedButton(
                child: Text('Navigate to Second Page'),
                onPressed: () {
                  OneContext().pushNamed('/second');
                })
          ],
        ),
      ),
    );
  }
}

class DemoSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final IconData icon;

  const DemoSection({
    required this.title,
    required this.children,
    required this.icon,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      elevation: 0,
      color: Theme.of(context)
          .colorScheme
          .surfaceContainerHighest
          .withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context)
              .colorScheme
              .outlineVariant
              .withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
            const Divider(height: 32),
            ...children,
          ],
        ),
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  const ActionButton({
    required this.label,
    required this.onPressed,
    this.icon,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: FilledButton.tonalIcon(
        onPressed: onPressed,
        icon: icon != null ? Icon(icon, size: 18) : null,
        label: Text(label),
        style: FilledButton.styleFrom(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String? reloadAppButtonLabel;
  MyHomePage({Key? key, this.title = "", this.reloadAppButtonLabel})
      : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  Map<String, Offset> randomOffset = Map<String, Offset>();
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: Offset(0, -1),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final bool? shouldPop = await OneContext().showDialog<bool>(
          builder: (context) => AlertDialog(
            title: const Text('Confirmation'),
            content: const Text('Do you really want to exit?'),
            actions: [
              TextButton(
                onPressed: () => OneContext().popDialog(false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => OneContext().popDialog(true),
                child: const Text('Yes'),
              ),
            ],
          ),
        );

        if (shouldPop == true) {
          OneContext().pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          centerTitle: true,
          surfaceTintColor: Colors.transparent,
          elevation: 2,
          actions: <Widget>[
            IconButton(
              onPressed: () {
                debugShowCheckedModeBanner = !debugShowCheckedModeBanner;
                OneNotification.hardReloadRoot(context);
              },
              icon: Icon(debugShowCheckedModeBanner
                  ? Icons.visibility
                  : Icons.visibility_off),
              tooltip: 'Toggle Debug Banner',
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Introduction
              Text(
                'A single context for the entire application, without the need for dependencies.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // --- App Management Section ---
              DemoSection(
                title: 'App Management',
                icon: Icons.settings_power,
                children: [
                  ActionButton(
                    label: 'Hard Reload (App Root)',
                    icon: Icons.refresh,
                    onPressed: () {
                      OneNotification.hardReloadRoot(context);
                    },
                  ),
                  ActionButton(
                    label: 'Soft Reboot the application',
                    icon: Icons.restart_alt,
                    onPressed: () {
                      OnePlatform.reboot(
                          setUp: () => print('Reboot requested!'));
                    },
                  ),
                  ActionButton(
                    label: 'Hard Reboot with banner enabled',
                    icon: Icons.power_settings_new,
                    onPressed: () {
                      OnePlatform.reboot(
                          builder: () => MyApp(),
                          setUp: () {
                            debugShowCheckedModeBanner = true;
                          });
                    },
                  ),
                  ActionButton(
                    label: 'Load instance of MyApp2',
                    icon: Icons.apps,
                    onPressed: () {
                      OnePlatform.reboot(
                          setUp: () {
                            OneContext().key = GlobalKey<NavigatorState>();
                          },
                          builder: () => MyApp2());
                    },
                  ),
                ],
              ),

              // --- Theme & Layout Section ---
              DemoSection(
                title: 'Theme & Styling',
                icon: Icons.color_lens,
                children: [
                  ActionButton(
                    label: 'Toggle Dark/Light Mode',
                    icon: Icons.brightness_6,
                    onPressed: () {
                      OneContext().oneTheme.toggleMode();
                    },
                  ),
                  ActionButton(
                    label: 'Change Light Seed (Purple)',
                    icon: Icons.palette,
                    onPressed: () {
                      OneContext().oneTheme.changeThemeData(ThemeData(
                            colorSchemeSeed: Colors.purple,
                            brightness: Brightness.light,
                            useMaterial3: true,
                          ));
                    },
                  ),
                  ActionButton(
                    label: 'Change Dark Seed (Amber)',
                    icon: Icons.palette_outlined,
                    onPressed: () {
                      OneContext().oneTheme.changeDarkThemeData(ThemeData(
                            colorSchemeSeed: Colors.amber,
                            brightness: Brightness.dark,
                            useMaterial3: true,
                          ));
                    },
                  ),
                  ActionButton(
                    label: 'Support English Locale',
                    icon: Icons.language,
                    onPressed: () {
                      OneNotification.notify<List<Locale>>(context,
                          payload: NotificationPayload(data: [
                            const Locale('en', ''),
                          ]));
                    },
                  ),
                ],
              ),

              // --- Feedback Section ---
              DemoSection(
                title: 'Feedback (SnackBars)',
                icon: Icons.notifications,
                children: [
                  ActionButton(
                    label: 'Show SnackBar',
                    icon: Icons.info,
                    onPressed: () {
                      showTipsOnScreen('OneContext().showSnackBar()');
                      OneContext().hideCurrentSnackBar();
                      OneContext().showSnackBar(
                        builder: (context) => SnackBar(
                          content: Text(
                            'My awesome snackBar!',
                            textAlign: TextAlign.center,
                            style: Theme.of(context!)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(color: Colors.white),
                          ),
                          action: SnackBarAction(
                              label: 'DISMISS', onPressed: () {}),
                        ),
                      );
                    },
                  ),
                  ActionButton(
                    label: 'Close Current SnackBar',
                    icon: Icons.close,
                    onPressed: () => OneContext().hideCurrentSnackBar(),
                  ),
                ],
              ),

              // --- Overlays Section ---
              DemoSection(
                title: 'Dialogs & Bottom Sheets',
                icon: Icons.layers,
                children: [
                  ActionButton(
                    label: 'Show Default Dialog',
                    icon: Icons.chat_bubble_outline,
                    onPressed: () async {
                      showTipsOnScreen('OneContext().showDialog<String>()');

                      var result = await OneContext().showDialog<String>(
                          barrierColor:
                              Colors.deepPurple.withValues(alpha: 0.3),
                          builder: (context) => AlertDialog(
                                title: const Text("App Dialog"),
                                content: const Text(
                                    "Dialogs work anywhere without context!"),
                                actions: <Widget>[
                                  TextButton(
                                      child: const Text("Push to Second"),
                                      onPressed: () async {
                                        String? result = await OneContext()
                                            .push<String>(MaterialPageRoute(
                                                builder: (_) => SecondPage()));
                                        print(
                                            '$result from OneContext().push()');
                                      }),
                                  TextButton(
                                      child: const Text("Show Bottom Sheet"),
                                      onPressed: () {
                                        showModalBottomSheet(
                                          context: context,
                                          builder: (context) => Container(
                                            padding: const EdgeInsets.all(24),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Text(
                                                    "I'm a bottom sheet shown from a dialog!"),
                                                const SizedBox(height: 16),
                                                FilledButton(
                                                  onPressed: () =>
                                                      OneContext().popDialog(),
                                                  child: const Text("Close"),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }),
                                  TextButton(
                                      child: const Text("OK"),
                                      onPressed: () =>
                                          OneContext().popDialog('ok')),
                                ],
                              ));
                      print(result);
                    },
                  ),
                  ActionButton(
                    label: 'Show Modal Bottom Sheet',
                    icon: Icons.keyboard_arrow_up,
                    onPressed: () async {
                      showTipsOnScreen(
                          'OneContext().showModalBottomSheet<String>()');
                      var result =
                          await OneContext().showModalBottomSheet<String>(
                        barrierColor: Colors.amber.withValues(alpha: 0.3),
                        builder: (context) => SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              ListTile(
                                  leading: const Icon(Icons.music_note),
                                  title: const Text('Music'),
                                  onTap: () => OneContext().popDialog('Music')),
                              ListTile(
                                  leading: const Icon(Icons.videocam),
                                  title: const Text('Video'),
                                  onTap: () => OneContext().popDialog('Video')),
                              ListTile(
                                  leading: const Icon(Icons.chat_bubble),
                                  title: const Text('Show Dialog'),
                                  onTap: () {
                                    OneContext().showDialog(
                                      builder: (context) => AlertDialog(
                                        title:
                                            const Text("Bottom Sheet Dialog"),
                                        content: const Text(
                                            "A dialog triggered from a bottom sheet!"),
                                        actions: [
                                          TextButton(
                                              onPressed: () =>
                                                  OneContext().popDialog(),
                                              child: const Text("OK")),
                                        ],
                                      ),
                                    );
                                  }),
                            ],
                          ),
                        ),
                        showDragHandle: true,
                      );
                      print(result);
                    },
                  ),
                  ActionButton(
                    label: 'Show Persistent Bottom Sheet',
                    icon: Icons.expand_less,
                    onPressed: () {
                      showTipsOnScreen('OneContext().showBottomSheet()');
                      OneContext().showBottomSheet(
                        builder: (context) => Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(20)),
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
                          ),
                          padding: const EdgeInsets.all(20),
                          height: 150,
                          child: Column(
                            children: [
                              Text(
                                "Persistent bottom sheet",
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const Spacer(),
                              FilledButton(
                                onPressed: () => OneContext().popDialog(),
                                child: const Text("Dismiss"),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  ActionButton(
                    label: 'Blocking Simple Dialog',
                    icon: Icons.warning_amber,
                    onPressed: () async {
                      showTipsOnScreen('OneContext().showDialog<int>()');
                      int? selected = await OneContext().showDialog<int>(
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return SimpleDialog(
                              title: const Text('Select assignment'),
                              children: <Widget>[
                                SimpleDialogOption(
                                  onPressed: () => OneContext().popDialog(1),
                                  child: const Text('Option 1'),
                                ),
                                SimpleDialogOption(
                                  onPressed: () => OneContext().popDialog(2),
                                  child: const Text('Option 2'),
                                ),
                                SimpleDialogOption(
                                  onPressed: () async {
                                    await OneContext().popDialog();
                                    OneContext().push(MaterialPageRoute(
                                        builder: (_) => SecondPage()));
                                  },
                                  child: const Text('Open Second Page'),
                                ),
                              ],
                            );
                          });
                      print('User selected: $selected');
                    },
                  ),
                ],
              ),

              // --- Loading & Overlays Section ---
              DemoSection(
                title: 'Loading Indicators',
                icon: Icons.hourglass_top,
                children: [
                  ActionButton(
                    label: 'Default Progress Indicator',
                    icon: Icons.refresh,
                    onPressed: () {
                      showTipsOnScreen('OneContext().showProgressIndicator()');
                      OneContext().showProgressIndicator();
                      Future.delayed(const Duration(seconds: 2),
                          () => OneContext().hideProgressIndicator());
                    },
                  ),
                  ActionButton(
                    label: 'Custom Animated Indicator',
                    icon: Icons.animation,
                    onPressed: () {
                      showTipsOnScreen(
                          'OneContext().showProgressIndicator(builder)');
                      OneContext().showProgressIndicator(
                          builder: (_) => SlideTransition(
                                position: _offsetAnimation,
                                child: Center(
                                  child: Container(
                                      alignment: Alignment.center,
                                      height: 70,
                                      width: 70,
                                      decoration: BoxDecoration(
                                        color: Colors.yellow,
                                        borderRadius: BorderRadius.circular(35),
                                        boxShadow: [
                                          BoxShadow(
                                              blurRadius: 10,
                                              color: Colors.black26)
                                        ],
                                      ),
                                      child: const CircularProgressIndicator()),
                                ),
                              ),
                          backgroundColor: Colors.transparent);
                      _controller.reset();
                      _controller.forward();
                      Future.delayed(const Duration(seconds: 3), () {
                        _controller.reverse().whenComplete(
                            () => OneContext().hideProgressIndicator());
                      });
                    },
                  ),
                  ActionButton(
                    label: 'Generic Floating Overlay',
                    icon: Icons.control_point_duplicate,
                    onPressed: () {
                      showTipsOnScreen('OneContext().addOverlay(builder)');
                      String overId = UniqueKey().toString();
                      double getY() => Random()
                          .nextInt((MediaQuery.of(context).size.height - 100)
                              .toInt())
                          .toDouble();
                      double getX() => Random()
                          .nextInt(
                              (MediaQuery.of(context).size.width - 100).toInt())
                          .toDouble();

                      randomOffset[overId] = Offset(getX(), getY());

                      Widget w = Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.blue,
                        child: InkWell(
                          onTap: () => OneContext().removeOverlay(overId),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: const Text(
                              'DRAG OR TAP TO CLOSE',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      );

                      OneContext().addOverlay(
                        overlayId: overId,
                        builder: (_) => Positioned(
                          top: randomOffset[overId]?.dy,
                          left: randomOffset[overId]?.dx,
                          child: Draggable(
                            onDragEnd: (DraggableDetails detail) =>
                                randomOffset[overId] = detail.offset,
                            childWhenDragging: Container(),
                            feedback: w,
                            child: w,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),

              // --- Comparison Section ---
              DemoSection(
                title: 'Native Flutter vs OneContext',
                icon: Icons.compare_arrows,
                children: [
                  RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodySmall,
                      children: [
                        const TextSpan(text: 'Flutter Native: '),
                        TextSpan(
                          text: 'Requires BuildContext\n',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(text: 'OneContext: '),
                        TextSpan(
                          text: 'NO Context Needed',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Compare Dialog Methods:',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Row(
                    children: [
                      Expanded(
                        child: ActionButton(
                          label: 'Native',
                          onPressed: () => showDialog(
                            context: context,
                            builder: (dlgCtx) => AlertDialog(
                              title: const Text('Flutter Native Dialog'),
                              content: const Text('showDialog(context, ...)'),
                              actions: [
                                TextButton(
                                  onPressed: () => showDialog(
                                    context: dlgCtx,
                                    builder: (_) => AlertDialog(
                                      title: const Text('Native Dialog'),
                                      content: const Text('From Native Dialog'),
                                    ),
                                  ),
                                  child: const Text('Native D'),
                                ),
                                TextButton(
                                  onPressed: () => OneContext().showDialog(
                                    builder: (_) => AlertDialog(
                                      title: const Text('OC Dialog'),
                                      content: const Text('From Native Dialog'),
                                    ),
                                  ),
                                  child: const Text('OC D'),
                                ),
                                TextButton(
                                  onPressed: () => showModalBottomSheet(
                                    context: dlgCtx,
                                    builder: (_) => Container(
                                      height: 100,
                                      alignment: Alignment.center,
                                      child: const Text(
                                          'Native BS from Native Dialog'),
                                    ),
                                  ),
                                  child: const Text('Native BS'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      OneContext().showModalBottomSheet(
                                    builder: (_) => Container(
                                      height: 100,
                                      alignment: Alignment.center,
                                      child: const Text(
                                          'OC BS from Native Dialog'),
                                    ),
                                  ),
                                  child: const Text('OC BS'),
                                ),
                                TextButton(
                                  onPressed: () => OneContext().push(
                                    MaterialPageRoute(
                                        builder: (_) => SecondPage()),
                                  ),
                                  child: const Text('Push'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(dlgCtx),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ActionButton(
                          label: 'OneContext',
                          onPressed: () => OneContext().showDialog(
                            builder: (dlgCtx) => AlertDialog(
                              title: const Text('OneContext Dialog'),
                              content:
                                  const Text('OneContext().showDialog(...)'),
                              actions: [
                                TextButton(
                                  onPressed: () => showDialog(
                                    context: dlgCtx!,
                                    builder: (_) => AlertDialog(
                                      title: const Text('Native Dialog'),
                                      content: const Text('From OC Dialog'),
                                    ),
                                  ),
                                  child: const Text('Native D'),
                                ),
                                TextButton(
                                  onPressed: () => OneContext().showDialog(
                                    builder: (_) => AlertDialog(
                                      title: const Text('OC Dialog'),
                                      content: const Text('From OC Dialog'),
                                    ),
                                  ),
                                  child: const Text('OC D'),
                                ),
                                TextButton(
                                  onPressed: () => showModalBottomSheet(
                                    context: dlgCtx!,
                                    builder: (_) => Container(
                                      height: 100,
                                      alignment: Alignment.center,
                                      child: const Text(
                                          'Native BS from OC Dialog'),
                                    ),
                                  ),
                                  child: const Text('Native BS'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      OneContext().showModalBottomSheet(
                                    builder: (_) => Container(
                                      height: 100,
                                      alignment: Alignment.center,
                                      child: const Text('OC BS from OC Dialog'),
                                    ),
                                  ),
                                  child: const Text('OC BS'),
                                ),
                                TextButton(
                                  onPressed: () => OneContext().push(
                                    MaterialPageRoute(
                                        builder: (_) => SecondPage()),
                                  ),
                                  child: const Text('Push'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SecondPage()),
                                  ),
                                  child: const Text('Native Push'),
                                ),
                                TextButton(
                                  onPressed: () => OneContext().popDialog(),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('Compare Bottom Sheet Methods:',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Row(
                    children: [
                      Expanded(
                        child: ActionButton(
                          label: 'Native',
                          onPressed: () => showModalBottomSheet(
                            context: context,
                            builder: (bsCtx) => Container(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('Native Bottom Sheet',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 6,
                                    children: [
                                      FilledButton(
                                        onPressed: () => showDialog(
                                          context: bsCtx,
                                          builder: (_) => AlertDialog(
                                            title: const Text('Native Dialog'),
                                            content:
                                                const Text('From Native BS'),
                                          ),
                                        ),
                                        child: const Text('Native D'),
                                      ),
                                      FilledButton(
                                        onPressed: () =>
                                            OneContext().showDialog(
                                          builder: (_) => AlertDialog(
                                            title: const Text('OC Dialog'),
                                            content:
                                                const Text('From Native BS'),
                                          ),
                                        ),
                                        child: const Text('OC D'),
                                      ),
                                      FilledButton(
                                        onPressed: () => showModalBottomSheet(
                                          context: bsCtx,
                                          builder: (_) => Container(
                                            height: 100,
                                            alignment: Alignment.center,
                                            child: const Text(
                                                'Native BS from Native BS'),
                                          ),
                                        ),
                                        child: const Text('Native BS'),
                                      ),
                                      FilledButton(
                                        onPressed: () =>
                                            OneContext().showModalBottomSheet(
                                          builder: (_) => Container(
                                            height: 100,
                                            alignment: Alignment.center,
                                            child: const Text(
                                                'OC BS from Native BS'),
                                          ),
                                        ),
                                        child: const Text('OC BS'),
                                      ),
                                      FilledButton(
                                        onPressed: () => OneContext().push(
                                          MaterialPageRoute(
                                              builder: (_) => SecondPage()),
                                        ),
                                        child: const Text('Push'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ActionButton(
                          label: 'OneContext',
                          onPressed: () => OneContext().showModalBottomSheet(
                            builder: (bsCtx) => Container(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('OneContext Bottom Sheet',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 6,
                                    children: [
                                      FilledButton(
                                        onPressed: () => showDialog(
                                          context: bsCtx!,
                                          builder: (_) => AlertDialog(
                                            title: const Text('Native Dialog'),
                                            content: const Text('From OC BS'),
                                          ),
                                        ),
                                        child: const Text('Native D'),
                                      ),
                                      FilledButton(
                                        onPressed: () =>
                                            OneContext().showDialog(
                                          builder: (_) => AlertDialog(
                                            title: const Text('OC Dialog'),
                                            content: const Text('From OC BS'),
                                          ),
                                        ),
                                        child: const Text('OC D'),
                                      ),
                                      FilledButton(
                                        onPressed: () => showModalBottomSheet(
                                          context: bsCtx!,
                                          builder: (_) => Container(
                                            height: 100,
                                            alignment: Alignment.center,
                                            child: const Text(
                                                'Native BS from OC BS'),
                                          ),
                                        ),
                                        child: const Text('Native BS'),
                                      ),
                                      FilledButton(
                                        onPressed: () =>
                                            OneContext().showModalBottomSheet(
                                          builder: (_) => Container(
                                            height: 100,
                                            alignment: Alignment.center,
                                            child:
                                                const Text('OC BS from OC BS'),
                                          ),
                                        ),
                                        child: const Text('OC BS'),
                                      ),
                                      FilledButton(
                                        onPressed: () => OneContext().push(
                                          MaterialPageRoute(
                                              builder: (_) => SecondPage()),
                                        ),
                                        child: const Text('Push'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // --- Navigation Section ---
              DemoSection(
                title: 'Global Navigation',
                icon: Icons.navigation_outlined,
                children: [
                  ActionButton(
                    label: 'Push Second Page',
                    icon: Icons.arrow_forward_ios,
                    onPressed: () async {
                      showTipsOnScreen('OneContext().push(...)');
                      String? result = await OneContext().push<String>(
                          MaterialPageRoute(builder: (_) => SecondPage()));
                      print('Page returned: $result');
                    },
                  ),
                  ActionButton(
                    label: 'Push Named Route',
                    icon: Icons.route,
                    onPressed: () async {
                      showTipsOnScreen('OneContext().pushNamed("/second")');
                      String? result =
                          (await OneContext().pushNamed('/second')) as String?;
                      print('Page returned: $result');
                    },
                  ),
                  ActionButton(
                    label: 'Push Page with Dialog Demo',
                    icon: Icons.library_add,
                    onPressed: () async {
                      String? result = await OneContext().push<String>(
                          MaterialPageRoute(builder: (_) => DialogPage()));
                      print('Page returned: $result');
                    },
                  ),
                ],
              ),

              // --- Utilities Section ---
              DemoSection(
                title: 'Data & Tools',
                icon: Icons.info_outline,
                children: [
                  ActionButton(
                    label: 'MediaQuery Inspector',
                    icon: Icons.phonelink_setup,
                    onPressed: () {
                      MediaQueryData mq = OneContext().mediaQuery;
                      String info = 'Orientation: ${mq.orientation}\n'
                          'Size: ${mq.size.width.toInt()}x${mq.size.height.toInt()}\n'
                          'Pixel Density: ${mq.devicePixelRatio}';
                      showTipsOnScreen(info, size: 150, seconds: 5);
                    },
                  ),
                  ActionButton(
                    label: 'Pick a Date (DatePicker)',
                    icon: Icons.calendar_month,
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        OneContext().showSnackBar(
                            builder: (_) =>
                                SnackBar(content: Text('Selected: $picked')));
                      }
                    },
                  ),
                  ActionButton(
                    label: 'Theme Inspector',
                    icon: Icons.color_lens_outlined,
                    onPressed: () {
                      ThemeData theme = OneContext().theme;
                      String info = 'Platform: ${theme.platform}\n'
                          'Primary: ${theme.primaryColor}\n'
                          'Material 3: ${theme.useMaterial3}';
                      showTipsOnScreen(info, size: 150, seconds: 5);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}

class SecondPage extends StatelessWidget {
  static String routeName = "/second";

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('Second Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Icon(Icons.rocket_launch, size: 64, color: Colors.blue),
            const SizedBox(height: 24),
            Text(
              'This page was pushed without context!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text(
              'OneContext handles navigation globally.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 48),
            ActionButton(
              label: 'Go Back with "success"',
              icon: Icons.arrow_back,
              onPressed: () {
                showTipsOnScreen('OneContext().pop("success")');
                OneContext().pop('success');
              },
            ),
          ],
        ),
      ));
}

// Features can be used anywhere without context!
void showTipsOnScreen(String text, {double? size, int? seconds}) {
  String id = UniqueKey().toString();
  OneContext().addOverlay(
    overlayId: id,
    builder: (_) => Align(
      alignment: Alignment.topCenter,
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.9),
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(16)),
            boxShadow: [
              BoxShadow(
                blurRadius: 10,
                color: Colors.black26,
                offset: Offset(0, 4),
              )
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          width: double.infinity,
          child: SafeArea(
            bottom: false,
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    ),
  );
  Future.delayed(
      Duration(seconds: seconds ?? 2), () => OneContext().removeOverlay(id));
}

class DialogPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Dialog Integration')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Icon(Icons.library_books, size: 60, color: Colors.orange),
              const SizedBox(height: 16),
              Text(
                'Demonstrating deep context-less calls',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 32),
              ActionButton(
                label: 'Show Modal Dialog from here',
                icon: Icons.chat,
                onPressed: () {
                  OneContext().showDialog(
                    builder: (context) => AlertDialog(
                      title: const Text('Local Page Context'),
                      content: const Text('Still works perfectly!'),
                      actions: [
                        TextButton(
                          onPressed: () => OneContext().popDialog(),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                },
              ),
              ActionButton(
                label: 'Show DatePicker',
                icon: Icons.date_range,
                onPressed: () async {
                  showTipsOnScreen('OneContext() helps navigation too!');
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    OneContext().showSnackBar(
                      builder: (_) => SnackBar(
                        content: Text('Selected: $picked'),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 12),
              ActionButton(
                label: 'Return to Homepage',
                icon: Icons.home,
                onPressed: () {
                  OneContext().pop('Returned from DialogPage');
                },
              ),
            ],
          ),
        ),
      ));
}
