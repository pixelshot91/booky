import 'package:flutter/material.dart';

class CenteredTrackShape extends RoundedRectSliderTrackShape {
  const CenteredTrackShape();

  @override
  void paint(PaintingContext context,
      Offset offset, {
        required RenderBox parentBox,
        required SliderThemeData sliderTheme,
        required Animation<double> enableAnimation,
        required TextDirection textDirection,
        required Offset thumbCenter,
        Offset? secondaryOffset,
        bool isDiscrete = false,
        bool isEnabled = false,
        double additionalActiveTrackHeight = 2,
      }) {
    assert(sliderTheme.disabledActiveTrackColor != null);
    assert(sliderTheme.disabledInactiveTrackColor != null);
    assert(sliderTheme.activeTrackColor != null);
    assert(sliderTheme.inactiveTrackColor != null);
    assert(sliderTheme.thumbShape != null);
    // If the slider [SliderThemeData.trackHeight] is less than or equal to 0,
    // then it makes no difference whether the track is painted or not,
    // therefore the painting can be a no-op.
    if (sliderTheme.trackHeight == null || sliderTheme.trackHeight! <= 0) {
      return;
    }

    // Assign the track segment paints, which are leading: active and
    // trailing: inactive.
    final ColorTween activeTrackColorTween =
    ColorTween(begin: sliderTheme.disabledActiveTrackColor, end: sliderTheme.activeTrackColor);
    final ColorTween inactiveTrackColorTween =
    ColorTween(begin: sliderTheme.disabledInactiveTrackColor, end: sliderTheme.inactiveTrackColor);
    final Paint activePaint = Paint()
      ..color = activeTrackColorTween.evaluate(enableAnimation)!;
    final Paint inactivePaint = Paint()
      ..color = inactiveTrackColorTween.evaluate(enableAnimation)!;

    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );
    final Radius trackRadius = Radius.circular(trackRect.height / 2);
    final Radius activeTrackRadius = Radius.circular((trackRect.height + additionalActiveTrackHeight) / 2);

    context.canvas.drawRRect(
      RRect.fromRectAndRadius(trackRect, activeTrackRadius),
      inactivePaint,
    );
    context.canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        trackRect.center.dx,
        trackRect.top,
        thumbCenter.dx,
        trackRect.bottom,
        topRight: trackRadius,
        bottomRight: trackRadius,
      ),
      activePaint,
    );
  }
}
