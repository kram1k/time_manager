# CustomSlider Documentation

This document contains all extracted comments and documentation from `slider.dart`.
Create by agent.

---

## Overview

The `CustomSlider` widget implements a circular arc slider with draggable start/end handles and a movable body. It's designed for time range selection (e.g., 12-hour clock face).

---

## Enums

### DragMode
```dart
enum DragMode { none, startEdge, endEdge, body }
```
**Possible states of what we're currently dragging:**
- `none` - Not dragging
- `startEdge` - Dragging the start handle (green circle)
- `endEdge` - Dragging the end handle (red circle)
- `body` - Dragging the entire arc body

---

## _CustomSliderState

### State Variables

```dart
double _startAngle = -math.pi / 2;
double _sweepAngle = 3 * math.pi / 4;
```
**Arc state:** Both the start point AND the length of the arc can change.

```dart
DragMode _dragMode = DragMode.none;
double _lastAngle = 0.0;
```
**Drag tracking:** Current drag mode and last recorded touch angle.

---

### Helper Methods

#### `_angleDelta(double from, double to)`
**Function to find the shortest distance between two angles.**
- Normalizes the delta to range `[-π, π]`
- Handles angle wrapping correctly

#### `_isAngleInArc(double checkAngle, double start, double sweep)`
**Check if a touch angle falls within the arc body.**
- Normalizes angles to `[0, 2π]`
- Handles arcs that cross the 0/2π boundary

---

### Gesture Handlers

#### `_onPanDown(DragDownDetails details, Size widgetSize)`
**Triggers on FIRST touch.**

1. Calculates touch position relative to center
2. Computes `touchAngle` using `atan2`
3. Calculates `touchRadius` to verify touch is on the ring (not center)
4. Gets expected ring radius from `Sizes` (arcRadius / 2)
5. **Ignores touches** more than 40 pixels away from the ring
6. Computes angles of both edges (start and end)
7. Measures distance from touch to each edge (`deltaStart`, `deltaEnd`)
8. **Hit tolerance:** 0.3 radians (~17 degrees) for edge grabbing
9. Sets `_dragMode` based on proximity:
   - Close to start → `DragMode.startEdge`
   - Close to end → `DragMode.endEdge`
   - Inside arc body → `DragMode.body`
   - Elsewhere → `DragMode.none`
10. Stores `_lastAngle` for delta calculation

#### `_onPanUpdate(DragUpdateDetails details, Size widgetSize)`
**Triggers on finger movement.**

- Early return if `_dragMode == DragMode.none`
- Calculates new `touchAngle`
- Computes `delta = _angleDelta(_lastAngle, touchAngle)`

**Behavior by mode:**

| Mode | Action |
|------|--------|
| `body` | Move entire arc: `_startAngle += delta` |
| `startEdge` | Adjust length: `newSweep = _sweepAngle - delta`, clamp to `[0.15, π]`, shift start by actual clamped delta |
| `endEdge` | Adjust length: `newSweep = _sweepAngle + delta`, clamp to `[0.15, π]` |

**Clamp limits:**
- `0.15` - Prevents inverting the arc (minimum ~8.6°)
- `math.pi` - Maximum half circle (12 hours)

- Updates `_lastAngle`

#### `_onPanEnd(DragEndDetails details)`
**Triggers when finger is released.**
- Resets `_dragMode = DragMode.none`

---

## SliderPainter

### Constructor
```dart
SliderPainter({
  required this.startAngle,
  required this.sweepAngle,
  required this.mapPicture,
});
```
- `startAngle` - Arc start angle (radians)
- `sweepAngle` - Arc length (radians)
- `mapPicture` - Preloaded SVG pictures (e.g., 'lock', 'lock_open')

---

### Paint Method

#### 1. Draw Slider Arc
```dart
canvas.drawArc(
  Rect.fromCenter(center: sizes.center, width: sizes.arcRadius, height: sizes.arcRadius),
  startAngle,
  sweepAngle,
  false,
  paints.sliderArc,
);
```

#### 2. Draw Tick Marks OVER the Arc
- **Step:** `math.pi / 40` (every 4.5°)
- **Logic:** Loop from `tickStep` to `sweepAngle` (skip first tick under start handle)
- **Tick length:** 10 pixels
- **Positioning:** Centered on radius (inner/outer points calculated via cos/sin)
- **Paint:** `paints.sliderLine`

#### 3. Calculate Edge Coordinates
**Start point (green circle):**
```dart
Offset startPoint = Offset(
  center.dx + radius * cos(startAngle),
  center.dy + radius * sin(startAngle),
);
```

**End point (red circle):**
```dart
Offset endPoint = Offset(
  center.dx + radius * cos(startAngle + sweepAngle),
  center.dy + radius * sin(startAngle + sweepAngle),
);
```

#### 4. Draw Handle Circles
- **Radius:** 12 pixels
- **Start:** `paints.offIcon` (green)
- **End:** `paints.onIcon` (red)

#### 5. Draw Semi-transparent SVG Icons
**Function `drawSvgIcon(String key, Offset position)`:**
1. Returns early if key not in `mapPicture`
2. Creates layer with `paints.lockIcon` for transparency
3. Translates to position
4. Scales to 60% (0.60)
5. Centers 24x24 SVG
6. Draws picture
7. Restores canvas

**Icons drawn:**
- `'lock'` at start point
- `'lock_open'` at end point

---

### shouldRepaint
Repaints when:
- `startAngle` changes
- `sweepAngle` changes
- `mapPicture.length` changes (not content, just count)

---

## Constants & Magic Numbers

| Value | Meaning |
|-------|---------|
| `-math.pi / 2` | Default start angle (12 o'clock position) |
| `3 * math.pi / 4` | Default sweep (135° = 9 hours) |
| `40` | Touch radius tolerance (pixels) |
| `0.3` | Edge hit tolerance (radians ≈ 17°) |
| `0.15` | Minimum sweep angle (radians ≈ 8.6°) |
| `math.pi` | Maximum sweep (radians = 180° = 12 hours) |
| `math.pi / 40` | Tick step (4.5°) |
| `10.0` | Tick mark length (pixels) |
| `12` | Handle circle radius (pixels) |
| `0.60` | SVG scale factor |
| `24.0` | SVG source dimensions |

---

## Dependencies

- `dart:math` as `math`
- `dart:ui` as `ui`
- `package:flutter/material.dart`
- `package:time_manager/widgets/custom_slider/paints.dart`
- `package:time_manager/widgets/custom_slider/sizes.dart`

---

## Usage Example

```dart
CustomSlider(
  preloadedSVGs: {
    'lock': lockedSvgPicture,
    'lock_open': unlockedSvgPicture,
  },
)
```

The widget is square (width = height = screen width) and uses `GestureDetector` with `HitTestBehavior.translucent` to capture touches across the entire area.