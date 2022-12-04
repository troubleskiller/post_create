import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class AllowNegativePadding extends SingleChildRenderObjectWidget {
  const AllowNegativePadding({
    Key? key,
    required this.padding,
    Widget? child,
  }) : super(key: key, child: child);

  /// The amount of space by which to inset the child.
  final EdgeInsetsGeometry padding;

  @override
  RenderAllowNegativePadding createRenderObject(BuildContext context) {
    return RenderAllowNegativePadding(
      padding: padding,
      textDirection: Directionality.of(context),
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderAllowNegativePadding renderObject,
  ) {
    renderObject
      ..padding = padding
      ..textDirection = Directionality.of(context);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<EdgeInsetsGeometry>('padding', padding));
  }
}

class RenderAllowNegativePadding extends RenderShiftedBox {
  RenderAllowNegativePadding({
    required EdgeInsetsGeometry padding,
    TextDirection? textDirection,
    RenderBox? child,
  })  :
        // assert(padding.isNonNegative),
        _textDirection = textDirection,
        _padding = padding,
        super(child);

  EdgeInsets? _resolvedPadding;

  void _resolve() {
    if (_resolvedPadding != null) return;
    _resolvedPadding = padding.resolve(textDirection);
    // assert(_resolvedPadding.isNonNegative);
  }

  void _markNeedResolution() {
    _resolvedPadding = null;
    markNeedsLayout();
  }

  /// The amount to pad the child in each dimension.
  ///
  /// If this is set to an [EdgeInsetsDirectional] object, then [textDirection]
  /// must not be null.
  EdgeInsetsGeometry get padding => _padding;
  EdgeInsetsGeometry _padding;

  set padding(EdgeInsetsGeometry value) {
    // assert(value.isNonNegative);
    if (_padding == value) return;
    _padding = value;
    _markNeedResolution();
  }

  /// The text direction with which to resolve [padding].
  ///
  /// This may be changed to null, but only after the [padding] has been changed
  /// to a value that does not depend on the direction.
  TextDirection? get textDirection => _textDirection;
  TextDirection? _textDirection;

  set textDirection(TextDirection? value) {
    if (_textDirection == value) return;
    _textDirection = value;
    _markNeedResolution();
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    _resolve();
    final double totalHorizontalPadding =
        _resolvedPadding!.left + _resolvedPadding!.right;
    final double totalVerticalPadding =
        _resolvedPadding!.top + _resolvedPadding!.bottom;
    if (child != null) // next line relies on double.infinity absorption
    {
      return child!.getMinIntrinsicWidth(
            math.max(0.0, height - totalVerticalPadding),
          ) +
          totalHorizontalPadding;
    }

    return totalHorizontalPadding;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    _resolve();
    final double totalHorizontalPadding =
        _resolvedPadding!.left + _resolvedPadding!.right;
    final double totalVerticalPadding =
        _resolvedPadding!.top + _resolvedPadding!.bottom;
    if (child != null) // next line relies on double.infinity absorption
    {
      return child!.getMaxIntrinsicWidth(
            math.max(0.0, height - totalVerticalPadding),
          ) +
          totalHorizontalPadding;
    }

    return totalHorizontalPadding;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    _resolve();
    final double totalHorizontalPadding =
        _resolvedPadding!.left + _resolvedPadding!.right;
    final double totalVerticalPadding =
        _resolvedPadding!.top + _resolvedPadding!.bottom;
    if (child != null) // next line relies on double.infinity absorption
    {
      return child!.getMinIntrinsicHeight(
            math.max(0.0, width - totalHorizontalPadding),
          ) +
          totalVerticalPadding;
    }

    return totalVerticalPadding;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    _resolve();
    final double totalHorizontalPadding =
        _resolvedPadding!.left + _resolvedPadding!.right;
    final double totalVerticalPadding =
        _resolvedPadding!.top + _resolvedPadding!.bottom;
    if (child != null) // next line relies on double.infinity absorption
    {
      return child!.getMaxIntrinsicHeight(
            math.max(0.0, width - totalHorizontalPadding),
          ) +
          totalVerticalPadding;
    }

    return totalVerticalPadding;
  }

  @override
  void performLayout() {
    final BoxConstraints constraints = this.constraints;
    _resolve();
    assert(_resolvedPadding != null);
    if (child == null) {
      size = constraints.constrain(Size(
        _resolvedPadding!.left + _resolvedPadding!.right,
        _resolvedPadding!.top + _resolvedPadding!.bottom,
      ));

      return;
    }
    final BoxConstraints innerConstraints =
        constraints.deflate(_resolvedPadding!);
    child!.layout(innerConstraints, parentUsesSize: true);
    final BoxParentData childParentData = child!.parentData as BoxParentData;
    childParentData.offset =
        Offset(_resolvedPadding!.left, _resolvedPadding!.top);
    size = constraints.constrain(Size(
      _resolvedPadding!.left + child!.size.width + _resolvedPadding!.right,
      _resolvedPadding!.top + child!.size.height + _resolvedPadding!.bottom,
    ));
  }

  @override
  void debugPaintSize(PaintingContext context, Offset offset) {
    super.debugPaintSize(context, offset);
    assert(() {
      final Rect outerRect = offset & size;
      debugPaintPadding(
        context.canvas,
        outerRect,
        child != null ? _resolvedPadding!.deflateRect(outerRect) : null,
      );

      return true;
    }());
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<EdgeInsetsGeometry>('padding', padding));
    properties.add(EnumProperty<TextDirection>(
      'textDirection',
      textDirection,
      defaultValue: null,
    ));
  }
}
