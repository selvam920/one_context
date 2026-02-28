import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as mat;
import 'package:one_context/src/controllers/one_context.dart';

typedef Widget DialogBuilder(BuildContext context);
mixin DialogController {
  /// Return dialog utility class `DialogController`
  DialogController get dialog => this;

  /// The current scaffold state
  /// It is used to show snackbars, dialogs, modalBottomsheets, etc.
  GlobalKey<ScaffoldState>? _scaffoldKey;
  GlobalKey<ScaffoldState> get scaffoldKey {
    _scaffoldKey ??= GlobalKey<ScaffoldState>();
    return _scaffoldKey!;
  }

  set scaffoldKey(scaffKey) => _scaffoldKey = scaffKey;
  BuildContext? get _scaffoldContext => _scaffoldKey?.currentContext;
  ScaffoldState? get _scaffoldState => _scaffoldKey?.currentState;

  ValueNotifier<List<Widget>> _dialogs = ValueNotifier([]);
  ValueNotifier<List<Widget>> get dialogNotifier => _dialogs;
  bool get hasDialogVisible => _dialogs.value.length > 0;

  void addDialogVisible(Widget widget) {
    _dialogs.value.add(widget);
  }

  /// Removes the last dialog
  void removeDialogVisible({Widget? widget}) {
    if (widget != null) {
      _dialogs.value.remove(widget);
    } else
      _dialogs.value.removeLast();
  }

  /// Pop all dialogs
  void popAllDialogs() {
    _dialogs.value.forEach((element) {
      OneContext().popDialog();
    });
    _resetDialogRegisters();
  }

  void _resetDialogRegisters() {
    _dialogs.value.clear();
  }

  /// Displays a Material dialog above the current contents of the app, with
  /// Material entrance and exit animations, modal barrier color, and modal
  /// barrier behavior (dialog is dismissible with a tap on the barrier).
  Future<T?> showDialog<T>({
    required Widget Function(BuildContext) builder,
    bool useRootNavigator = true,
    String? barrierLabel,
    RouteSettings? routeSettings,
    Offset? anchorPoint,
    bool? barrierDismissible = true,
    Color? barrierColor = Colors.black54,
    bool useSafeArea = true,
    TraversalEdgeBehavior? traversalEdgeBehavior,
  }) async {
    if (!(await _scaffoldContextLoaded())) return null;

    Widget dialogMarker = Container();
    addDialogVisible(dialogMarker);

    return mat
        .showDialog<T>(
          context: _scaffoldContext!,
          builder: builder,
          barrierDismissible: barrierDismissible ?? true,
          useRootNavigator: useRootNavigator,
          barrierColor: barrierColor,
          barrierLabel: barrierLabel,
          useSafeArea: useSafeArea,
          routeSettings: routeSettings,
          anchorPoint: anchorPoint,
          traversalEdgeBehavior: traversalEdgeBehavior,
        )
        .whenComplete(() => removeDialogVisible(widget: dialogMarker));
  }

  /// Removes the current [SnackBar] by running its normal exit animation.
  ///
  /// The closed completer is called after the animation is complete.
  void hideCurrentSnackBar(
      {SnackBarClosedReason reason = SnackBarClosedReason.hide}) async {
    if (!(await _scaffoldContextLoaded())) return;
    ScaffoldMessenger.of(_scaffoldContext!).hideCurrentSnackBar(reason: reason);
  }

  /// Removes the current [SnackBar] (if any) immediately.
  ///
  /// The removed snack bar does not run its normal exit animation. If there are
  /// any queued snack bars, they begin their entrance animation immediately.
  void removeCurrentSnackBar(
      {SnackBarClosedReason reason = SnackBarClosedReason.hide}) async {
    if (!(await _scaffoldContextLoaded())) return;
    ScaffoldMessenger.of(_scaffoldContext!)
        .removeCurrentSnackBar(reason: reason);
  }

  /// Shows a [SnackBar] at the bottom of the scaffold.
  Future<ScaffoldFeatureController<SnackBar, SnackBarClosedReason>?>
      showSnackBar({required SnackBar Function(BuildContext?) builder}) async {
    if (!(await _scaffoldContextLoaded())) return null;
    return ScaffoldMessenger.of(_scaffoldContext!)
        .showSnackBar(builder(_scaffoldContext));
  }

  /// Displays a Material date picker above the current contents of the app.
  Future<DateTime?> showDatePicker({
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
    DateTime? currentDate,
    DatePickerEntryMode initialEntryMode = DatePickerEntryMode.calendar,
    SelectableDayPredicate? selectableDayPredicate,
    String? helpText,
    String? cancelText,
    String? confirmText,
    Locale? locale,
    bool useRootNavigator = true,
    RouteSettings? routeSettings,
    TextDirection? textDirection,
    TransitionBuilder? builder,
    DatePickerMode initialDatePickerMode = DatePickerMode.day,
    String? errorFormatText,
    String? errorInvalidText,
    String? fieldHintText,
    String? fieldLabelText,
    TextInputType? keyboardType,
    Offset? anchorPoint,
    final Color? barrierColor,
    final String? barrierLabel,
    final bool barrierDismissible = true,
  }) async {
    if (!(await _scaffoldContextLoaded())) return null;

    Widget dialog = Container();
    addDialogVisible(dialog);

    return mat
        .showDatePicker(
          context: _scaffoldContext!,
          initialDate: initialDate,
          firstDate: firstDate,
          lastDate: lastDate,
          currentDate: currentDate,
          initialEntryMode: initialEntryMode,
          selectableDayPredicate: selectableDayPredicate,
          helpText: helpText,
          cancelText: cancelText,
          confirmText: confirmText,
          locale: locale,
          useRootNavigator: useRootNavigator,
          routeSettings: routeSettings,
          textDirection: textDirection,
          builder: builder,
          initialDatePickerMode: initialDatePickerMode,
          errorFormatText: errorFormatText,
          errorInvalidText: errorInvalidText,
          fieldHintText: fieldHintText,
          fieldLabelText: fieldLabelText,
          keyboardType: keyboardType,
          anchorPoint: anchorPoint,
          barrierColor: barrierColor,
          barrierLabel: barrierLabel,
          barrierDismissible: barrierDismissible,
        )
        .whenComplete(() => removeDialogVisible(widget: dialog));
  }

  /// Displays a Material time picker above the current contents of the app.
  Future<TimeOfDay?> showTimePicker({
    required TimeOfDay initialTime,
    TransitionBuilder? builder,
    bool useRootNavigator = true,
    RouteSettings? routeSettings,
    TimePickerEntryMode initialEntryMode = TimePickerEntryMode.dial,
    String? cancelText,
    String? confirmText,
    String? helpText,
    String? errorInvalidText,
    String? hourLabelText,
    String? minuteLabelText,
    Offset? anchorPoint,
    EntryModeChangeCallback? onEntryModeChanged,
    final Color? barrierColor,
    final String? barrierLabel,
    final bool barrierDismissible = true,
  }) async {
    if (!(await _scaffoldContextLoaded())) return null;

    Widget dialog = Container();
    addDialogVisible(dialog);

    return mat
        .showTimePicker(
          context: _scaffoldContext!,
          initialTime: initialTime,
          builder: builder,
          useRootNavigator: useRootNavigator,
          routeSettings: routeSettings,
          initialEntryMode: initialEntryMode,
          cancelText: cancelText,
          confirmText: confirmText,
          helpText: helpText,
          errorInvalidText: errorInvalidText,
          hourLabelText: hourLabelText,
          minuteLabelText: minuteLabelText,
          anchorPoint: anchorPoint,
          onEntryModeChanged: onEntryModeChanged,
          barrierColor: barrierColor,
          barrierLabel: barrierLabel,
          barrierDismissible: barrierDismissible,
        )
        .whenComplete(() => removeDialogVisible(widget: dialog));
  }

  /// Displays a Material date range picker above the current contents of the app.
  Future<DateTimeRange?> showDateRangePicker({
    DateTimeRange? initialDateRange,
    required DateTime firstDate,
    required DateTime lastDate,
    DateTime? currentDate,
    DatePickerEntryMode initialEntryMode = DatePickerEntryMode.calendar,
    String? helpText,
    String? cancelText,
    String? confirmText,
    String? saveText,
    String? errorInvalidRangeText,
    String? errorFormatText,
    String? errorInvalidText,
    String? fieldStartHintText,
    String? fieldEndHintText,
    String? fieldStartLabelText,
    String? fieldEndLabelText,
    Locale? locale,
    bool useRootNavigator = true,
    RouteSettings? routeSettings,
    TextDirection? textDirection,
    TransitionBuilder? builder,
    Offset? anchorPoint,
    final Color? barrierColor,
    final String? barrierLabel,
    final bool barrierDismissible = true,
  }) async {
    if (!(await _scaffoldContextLoaded())) return null;

    Widget dialog = Container();
    addDialogVisible(dialog);

    return mat
        .showDateRangePicker(
          context: _scaffoldContext!,
          initialDateRange: initialDateRange,
          firstDate: firstDate,
          lastDate: lastDate,
          currentDate: currentDate,
          initialEntryMode: initialEntryMode,
          helpText: helpText,
          cancelText: cancelText,
          confirmText: confirmText,
          saveText: saveText,
          errorInvalidRangeText: errorInvalidRangeText,
          errorFormatText: errorFormatText,
          errorInvalidText: errorInvalidText,
          fieldStartHintText: fieldStartHintText,
          fieldEndHintText: fieldEndHintText,
          fieldStartLabelText: fieldStartLabelText,
          fieldEndLabelText: fieldEndLabelText,
          locale: locale,
          useRootNavigator: useRootNavigator,
          routeSettings: routeSettings,
          textDirection: textDirection,
          builder: builder,
          anchorPoint: anchorPoint,
          barrierColor: barrierColor,
          barrierLabel: barrierLabel,
          barrierDismissible: barrierDismissible,
        )
        .whenComplete(() => removeDialogVisible(widget: dialog));
  }

  /// Shows a modal material design bottom sheet.
  ///
  /// A modal bottom sheet is an alternative to a menu or a dialog and prevents
  /// the user from interacting with the rest of the app.
  Future<T?> showModalBottomSheet<T>({
    required Widget Function(BuildContext) builder,
    Color? backgroundColor,
    double? elevation,
    ShapeBorder? shape,
    Clip? clipBehavior,
    bool isScrollControlled = false,
    bool useRootNavigator = false,
    bool isDismissible = true,
    BoxConstraints? constraints,
    Color? barrierColor,
    bool? enableDrag,
    RouteSettings? routeSettings,
    AnimationController? transitionAnimationController,
    Offset? anchorPoint,
    bool? showDragHandle,
    bool useSafeArea = false,
  }) async {
    if (!(await _scaffoldContextLoaded())) return null;

    Widget dialogMarker = Container();
    addDialogVisible(dialogMarker);

    return mat
        .showModalBottomSheet<T>(
          context: _scaffoldContext!,
          builder: builder,
          backgroundColor: backgroundColor,
          clipBehavior: clipBehavior,
          elevation: elevation,
          isDismissible: isDismissible,
          isScrollControlled: isScrollControlled,
          shape: shape,
          useRootNavigator: useRootNavigator,
          constraints: constraints,
          barrierColor: barrierColor,
          enableDrag: enableDrag = true,
          routeSettings: routeSettings,
          transitionAnimationController: transitionAnimationController,
          anchorPoint: anchorPoint,
          showDragHandle: showDragHandle,
          useSafeArea: useSafeArea,
        )
        .whenComplete(() => removeDialogVisible(widget: dialogMarker));
  }

  /// Shows a persistent bottom sheet
  Future<PersistentBottomSheetController?> showBottomSheet<T>({
    required Widget Function(BuildContext) builder,
    Color? backgroundColor,
    double? elevation,
    ShapeBorder? shape,
    Clip? clipBehavior,
    BoxConstraints? constraints,
    bool? enableDrag,
    AnimationController? transitionAnimationController,
  }) async {
    if (!(await _scaffoldContextLoaded())) return null;

    Widget dialogMarker = Container();
    addDialogVisible(dialogMarker);

    return _scaffoldState!.showBottomSheet(
      builder,
      backgroundColor: backgroundColor,
      elevation: elevation,
      shape: shape,
      clipBehavior: clipBehavior,
      constraints: constraints,
      enableDrag: enableDrag,
      transitionAnimationController: transitionAnimationController,
    )..closed.whenComplete(() => removeDialogVisible(widget: dialogMarker));
  }

  /// Pop the top-most dialog off the OneContext.dialog.
  ///
  /// Uses smart navigator selection: if the inner navigator can pop
  /// (e.g. a modal bottom sheet), it pops from there. Otherwise, it pops
  /// from the root navigator (e.g. a dialog shown with useRootNavigator: true).
  popDialog<T extends Object>([T? result]) async {
    if ((await _scaffoldContextLoaded())) {
      if (OneContext().hasDialogVisible) {
        final innerNav = Navigator.of(_scaffoldContext!);
        if (innerNav.canPop()) {
          return innerNav.pop<T>(result);
        } else {
          return Navigator.of(_scaffoldContext!, rootNavigator: true)
              .pop<T>(result);
        }
      }
    }
  }

  /// Context used by inner Navigator
  Future<bool> _scaffoldContextLoaded() async {
    await Future.delayed(Duration.zero);
    final isContextNull = _scaffoldContext == null;
    final isMounted = _scaffoldContext?.mounted ?? false;

    if ((isContextNull || !isMounted)) {
      throw NO_CONTEXT_ERROR;
    }

    return !isContextNull;
  }
}
