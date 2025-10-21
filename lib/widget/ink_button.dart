import 'package:flutter/material.dart';

class InkButton extends InkResponse {
  final EdgeInsetsGeometry padding;

  @override
  Widget get child {
    final hasEvent =
        onTap != null ||
        onDoubleTap != null ||
        onLongPress != null ||
        onTapDown != null ||
        onTapUp != null ||
        onTapCancel != null ||
        onSecondaryTap != null ||
        onSecondaryTapUp != null ||
        onSecondaryTapDown != null ||
        onSecondaryTapCancel != null ||
        onHighlightChanged != null ||
        onHover != null;
    return Padding(
      padding: padding,
      child: hasEvent
          ? super.child
          : IconTheme(
              data: IconThemeData(color: Colors.grey),
              child: super.child!,
            ),
    );
  }

  const InkButton({
    this.padding = const EdgeInsets.all(6),
    super.key,
    required super.child,
    super.onTap,
    super.onDoubleTap,
    super.onLongPress,
    super.onTapDown,
    super.onTapUp,
    super.onTapCancel,
    super.onSecondaryTap,
    super.onSecondaryTapUp,
    super.onSecondaryTapDown,
    super.onSecondaryTapCancel,
    super.onHighlightChanged,
    super.onHover,
    super.mouseCursor,
    super.focusColor,
    super.hoverColor,
    super.highlightColor,
    super.overlayColor,
    super.splashColor,
    super.splashFactory,
    super.radius,
    super.borderRadius = const BorderRadius.all(Radius.circular(6)),
    super.customBorder,
    super.enableFeedback,
    super.excludeFromSemantics,
    super.focusNode,
    super.canRequestFocus,
    super.onFocusChange,
    super.autofocus,
    super.statesController,
    super.hoverDuration,
    super.containedInkWell = true,
    super.highlightShape = BoxShape.rectangle,
  });
}
