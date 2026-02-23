import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:one_context/src/controllers/dialog_controller.mixin.dart';
import 'package:one_context/src/controllers/navigator_controller.mixin.dart';
import 'package:one_context/src/controllers/one_notification_controller.dart';
import 'package:one_context/src/controllers/overlay_controller.mixin.dart';

import '../../one_context.dart';

/// A [PopEntry] that blocks the Nav-App route from being popped
/// when a dialog/picker is visible on Nav-Inner.
class _DialogBlockingPopEntry extends PopEntry<Object?> {
  final ValueNotifier<bool> _canPop = ValueNotifier<bool>(true);

  @override
  ValueListenable<bool> get canPopNotifier => _canPop;

  @override
  void onPopInvokedWithResult(bool didPop, Object? result) {}

  void block() {
    if (_canPop.value) _canPop.value = false;
  }

  void unblock() {
    if (!_canPop.value) _canPop.value = true;
  }
}

/// Observes Nav-App (the MaterialApp navigator) to track the current route.
/// When Nav-Inner has dialogs, registers a [PopEntry] on the current route
/// to prevent the predictive back gesture from popping the page instead of
/// the dialog.
class OneContextNavAppObserver extends NavigatorObserver {
  ModalRoute<dynamic>? _currentRoute;
  ModalRoute<dynamic>? _blockedRoute;
  final _DialogBlockingPopEntry _popEntry = _DialogBlockingPopEntry();
  bool _shouldBlock = false;

  void setBlocking(bool block) {
    _shouldBlock = block;
    if (block) {
      _block();
    } else {
      _unblock();
    }
  }

  void _block() {
    if (_currentRoute == null) return;
    if (_blockedRoute == _currentRoute) return;
    _unblock();
    _popEntry.block();
    _currentRoute!.registerPopEntry(_popEntry);
    _blockedRoute = _currentRoute;
  }

  void _unblock() {
    if (_blockedRoute != null) {
      _popEntry.unblock();
      _blockedRoute!.unregisterPopEntry(_popEntry);
      _blockedRoute = null;
    }
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route is ModalRoute) {
      _currentRoute = route;
      if (_shouldBlock) _block();
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute is ModalRoute) {
      _currentRoute = previousRoute;
      if (_shouldBlock) _block();
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute is ModalRoute) {
      _currentRoute = newRoute;
      if (_shouldBlock) _block();
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (_currentRoute == route) {
      _currentRoute = previousRoute is ModalRoute ? previousRoute : null;
      if (_shouldBlock) _block();
    }
  }
}

/// Observes Nav-Inner to detect when routes are pushed above the base route
/// (i.e. dialogs, date pickers, bottom sheets). Signals [OneContextNavAppObserver]
/// to block the page route on Nav-App so the predictive back gesture
/// closes the dialog instead of the page.
class _OneContextNavInnerObserver extends NavigatorObserver {
  int _routeCount = 0;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _routeCount++;
    _syncBlock();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _routeCount--;
    _syncBlock();
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _routeCount--;
    _syncBlock();
  }

  void _syncBlock() {
    // routeCount > 1 means a dialog/picker/sheet is on top of the base route
    OneContext._navAppObserver?.setBlocking(_routeCount > 1);
  }
}

class _OneContextBackObserver extends WidgetsBindingObserver {
  /// Handles the predictive back gesture (Android gesture navigation).
  /// Returns true if Nav-Inner has a dialog/route to pop, claiming the gesture.
  @override
  bool handleStartBackGesture(PredictiveBackEvent backEvent) {
    if (backEvent.isButtonEvent) return false;

    final scaffoldContext = OneContext().scaffoldKey.currentContext;
    if (scaffoldContext != null && scaffoldContext.mounted) {
      final innerNav = Navigator.of(scaffoldContext);
      if (innerNav.canPop()) {
        return true;
      }
    }
    return false;
  }

  @override
  void handleCommitBackGesture() {
    final scaffoldContext = OneContext().scaffoldKey.currentContext;
    if (scaffoldContext != null && scaffoldContext.mounted) {
      final innerNav = Navigator.of(scaffoldContext);
      if (innerNav.canPop()) {
        innerNav.pop();
      }
    }
  }

  @override
  void handleCancelBackGesture() {
    // Gesture was cancelled — nothing to do.
  }

  /// Handles the 3-button back navigation and fallback from predictive back
  /// when no observer handled the gesture start.
  @override
  Future<bool> didPopRoute() async {
    // 1. If any OneContext-tracked dialog is visible, pop it from Nav-Inner
    if (OneContext().hasDialogVisible) {
      final scaffoldContext = OneContext().scaffoldKey.currentContext;
      if (scaffoldContext != null && scaffoldContext.mounted) {
        final innerNav = Navigator.of(scaffoldContext);
        if (innerNav.canPop()) {
          innerNav.pop();
        } else {
          Navigator.of(scaffoldContext, rootNavigator: true).pop();
        }
        return true;
      }
    }

    // 2. Check if Nav-Inner has any untracked routes to pop
    //    (e.g. standard Flutter showDatePicker, showDialog called directly)
    final scaffoldContext = OneContext().scaffoldKey.currentContext;
    if (scaffoldContext != null && scaffoldContext.mounted) {
      final innerNav = Navigator.of(scaffoldContext);
      if (innerNav.canPop()) {
        return await innerNav.maybePop();
      }
    }

    // 3. No dialog on Nav-Inner - forward to Nav-App (Root Navigator)
    //    This triggers PopScope.onPopInvokedWithResult if present on the current route.
    final rootNav = OneContext().key.currentState;
    if (rootNav != null) {
      return await rootNav.maybePop();
    }

    return false;
  }
}

class OneContext with NavigatorController, OverlayController, DialogController {
  static BuildContext? _context;
  static _OneContextBackObserver? _backObserver;
  static OneContextNavAppObserver? _navAppObserver;
  static _OneContextNavInnerObserver? _navInnerObserver;

  /// The almost top root context of the app,
  /// use it carefully or don't use it directly!
  BuildContext? get context {
    _context = key.currentContext;
    assert(_context != null, NO_CONTEXT_ERROR);
    return _context;
  }

  static bool get hasContext => OneContext().context != null;

  set context(BuildContext? newContext) => _context = newContext;

  /// Observer to add to [MaterialApp.navigatorObservers] for proper
  /// back gesture handling on Android gesture navigation.
  ///
  /// Without this observer, swiping back on a pushed page while a dialog
  /// is visible will close the page instead of the dialog.
  ///
  /// ```dart
  /// MaterialApp(
  ///   navigatorKey: OneContext().key,
  ///   navigatorObservers: [OneContext().navAppObserver],
  ///   builder: OneContext().builder,
  /// )
  /// ```
  NavigatorObserver get navAppObserver {
    _navAppObserver ??= OneContextNavAppObserver();
    return _navAppObserver!;
  }

  /// Navigator observer for Nav-Inner, used internally.
  NavigatorObserver get innerObserver {
    _navInnerObserver ??= _OneContextNavInnerObserver();
    return _navInnerObserver!;
  }

  /// If you need reactive changes, do not use OneContext().mediaQuery
  /// Use `MediaQuery.of(context)` instead.
  MediaQueryData get mediaQuery => MediaQuery.of(context!);

  /// If you need reactive changes, do not use OneContext().theme
  /// Use `Theme.of(context)` instead.
  ThemeData get theme => Theme.of(context!);

  /// If you need reactive changes, do not use OneContext().textTheme
  /// Use `Theme.of(context).textTheme` instead.
  TextTheme get textTheme => theme.textTheme;
  FocusScopeNode get focusScope => FocusScope.of(context!);

  /// Locale
  Locale get locale => Localizations.localeOf(context!);

  // ThemeMode and ThemeData
  ThemeMode get themeMode => oneTheme.themeMode;
  ThemeData? get themeData => oneTheme.themeData;
  ThemeData? get darkThemeData => oneTheme.darkThemeData;

  // Notifiers
  late OneNotificationController oneNotifier;
  late OneThemeController oneTheme;

  HeroController heroController = HeroController(
      createRectTween: (begin, end) =>
          MaterialRectCenterArcTween(begin: begin, end: end));

  OneContext._private() {
    oneNotifier = OneNotificationController();
    oneTheme = OneThemeController();
    _ensureBackObserver();
  }

  static void _ensureBackObserver() {
    if (_backObserver == null) {
      WidgetsFlutterBinding.ensureInitialized();
      _backObserver = _OneContextBackObserver();
      WidgetsBinding.instance.addObserver(_backObserver!);
    }
  }

  static OneContext instance = OneContext._private();
  factory OneContext() => instance;

  /// Use [OneContext().builder] in MaterialApp builder,
  /// in order to show dialogs and overlays.
  ///
  /// e.g.
  ///
  /// ```dart
  /// return MaterialApp(
  ///       builder: OneContext().builder,
  ///      ...
  /// ```
  Widget builder(
    BuildContext context,
    Widget? widget, {
    Key? key,
    MediaQueryData? mediaQueryData,
    String? initialRoute,
    List<NavigatorObserver> observers = const <NavigatorObserver>[],
  }) =>
      OneContextWidget(
        child: widget,
        mediaQueryData: mediaQueryData,
        initialRoute: initialRoute,
        observers: observers,
      );
}

const String NO_CONTEXT_ERROR = """
  OneContext not initiated! please use builder method.
  You need to use the OneContext().builder function to be able to show dialogs and overlays! e.g. ->

  MaterialApp(
    builder: OneContext().builder,
    ...
  )

  If you already set the OneContext().builder early, maybe you are probably trying to use some methods that will only be available after the first MaterialApp build.
  OneContext needs to be initialized by MaterialApp before it can be used in the application. This error exception occurs when OneContext context has not yet loaded and you try to use some method that needs the context, such as the showDialog, dismissSnackBar, showSnackBar, showModalBottomSheet, showBottomSheet or popDialog methods.

  If you need to use any of these OneContext methods before defining the MaterialApp, a safe way is to check if the OneContext context has already been initialized.
  e.g. 

  ```dart
    if (OneContext.hasContext) {OneContext().showDialog (...);}
  ```
""";
