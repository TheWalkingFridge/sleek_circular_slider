library circular_slider;

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:sleek_circular_slider/src/slider_animations.dart';
import 'utils.dart';
import 'appearance.dart';
import 'slider_label.dart';
import 'dart:math' as math;

part 'curve_painter.dart';
part 'custom_gesture_recognizer.dart';

typedef void OnChange(double value);
typedef Widget InnerWidget(double percentage);

class SleekCircularSlider extends StatefulWidget {
  final double initialValue;
  final double min;
  final double max;
  final CircularSliderAppearance appearance;
  final OnChange onChange;
  final OnChange onChangeStart;
  final OnChange onChangeEnd;
  final InnerWidget innerWidget;
  static const defaultAppearance = CircularSliderAppearance();

  double get angle {
    return valueToAngle(initialValue, min, max, appearance.angleRange);
  }

  const SleekCircularSlider(
      {Key key,
      this.initialValue = 50,
      this.min = 0,
      this.max = 100,
      this.appearance = defaultAppearance,
      this.onChange,
      this.onChangeStart,
      this.onChangeEnd,
      this.innerWidget})
      : assert(initialValue != null),
        assert(min != null),
        assert(max != null),
        assert(min <= max),
        assert(initialValue >= min && initialValue <= max),
        assert(appearance != null),
        super(key: key);
  @override
  _SleekCircularSliderState createState() => _SleekCircularSliderState();
}

class _SleekCircularSliderState extends State<SleekCircularSlider>
    with SingleTickerProviderStateMixin {
  bool _isHandlerSelected;
  _CurvePainter _painter;
  double _oldWidgetAngle;
  double _oldWidgetValue;
  double _currentAngle;
  double _startAngle;
  double _angleRange;
  double _selectedAngle;
  double _rotation;
  SpinAnimationManager _spinManager;
  // bool _animationCompleted = false;

  bool get _interactionEnabled => (widget.onChangeEnd != null ||
      widget.onChange != null && !widget.appearance.spinnerMode);
  // Animation<double> _animation;
  // Animation<double> _animation1;
  // Animation<double> _animation2;
  // Animation<double> _animation3;
  // AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _startAngle = widget.appearance.startAngle;
    _angleRange = widget.appearance.angleRange;

    // _animController = AnimationController(vsync: this);
    // _animController.duration = Duration(milliseconds: 3500);
    // _animController
    //   ..addListener(() {
    // setState(() {
    //   _currentAngle = _animation3 != null ? _animation3.value : 0;
    //   _startAngle = _animation2 != null ? math.pi * _animation2.value : 0;
    //   _rotation = _animation1.value;
    //       // _angleRange = 360 - _animation.value;
    //       // update painter and the on change closure
    // _setupPainter();
    // _updateOnChange();
    //     });
    //   })
    //   ..repeat();
    // _animation1 = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
    //     parent: _animController,
    //     curve: const Interval(0.5, 1.0, curve: Curves.linear)));
    // _animation2 = Tween<double>(begin: -240.0, end: 180.0).animate(
    //     CurvedAnimation(
    //         parent: _animController,
    //         curve: const Interval(0, 1.0, curve: Curves.linear)));
    // _animation3 = Tween(begin: 0.0, end: 360.0).animate(CurvedAnimation(
    //     parent: _animController,
    //     curve: const Interval(0.0, 1.0, curve: SpinnerCurve())));

    if (!widget.appearance.animationEnabled) {
      return;
    }

    // widget.appearance.spinnerMode ? _spin() : _animate();
  }

  @override
  void didUpdateWidget(SleekCircularSlider oldWidget) {
    if (oldWidget.angle != widget.angle) {
      // _animate();
    }
    super.didUpdateWidget(oldWidget);
  }

  // void _animate() {
  //   if (!widget.appearance.animationEnabled || _animController == null) {
  //     // if there is no animation we need to update painter and onChange value
  //     _setupPainter();
  //     _updateOnChange();
  //     return;
  //   }

  //   _animationCompleted = false;

  //   final duration = valueToDuration(widget.initialValue,
  //       _oldWidgetValue ?? widget.min, widget.min, widget.max);

  //   _animController.duration = Duration(milliseconds: duration);

  //   final curvedAnimation = CurvedAnimation(
  //     parent: _animController,
  //     curve: Curves.easeOut,
  //   );

  //   _animation = Tween<double>(begin: _oldWidgetAngle ?? 0, end: widget.angle)
  //       .animate(curvedAnimation)
  //         ..addListener(() {
  //           setState(() {
  //             if (!_animationCompleted) {
  //               _currentAngle = _animation.value;
  //               // update painter and the on change closure
  //               _setupPainter();
  //               _updateOnChange();
  //             }
  //           });
  //         })
  //         ..addStatusListener((status) {
  //           if (status == AnimationStatus.completed) {
  //             _animationCompleted = true;

  //             _animController.reset();
  //           }
  //         });
  //   _animController.forward();
  // }

  void _spin() {
    _spinManager = SpinAnimationManager(
        tickerProvider: this,
        duration: Duration(milliseconds: 3500),
        animate: ((double anim1, anim2, anim3) {
          setState(() {
            _rotation = anim1 != null ? anim1 : 0;
            _startAngle = anim2 != null ? math.pi * anim2 : 0;
            _currentAngle = anim3 != null ? anim3 : 0;
            _setupPainter();
            _updateOnChange();
          });
        }));
    _spinManager.spin();
  }

  // void _spin() {
  // if (_animController == null) {
  //   // if there is no animation we need to update painter and onChange value
  //   _setupPainter();
  //   _updateOnChange();
  //   return;
  // }

  // final curvedAnimation =
  //     CurvedAnimation(parent: _animController, curve: Curves.decelerate);

  // _animation = Tween<double>(begin: 0, end: 350).animate(curvedAnimation)
  //   ..addListener(() {
  //     setState(() {
  //       if (!_animationCompleted) {
  //         _currentAngle = _animation.value;
  //         _startAngle = _animation.value * 0.2;
  //         // _angleRange = 360 - _animation.value;
  //         // update painter and the on change closure
  //         _setupPainter();
  //         _updateOnChange();
  //       }
  //     });
  //   })
  // ..addStatusListener((status) {
  //   if (status == AnimationStatus.completed) {
  //     _animController.repeat(min: 0, max: 50);
  //   }
  //   });
  // _animController.forward();
  // }

  @override
  Widget build(BuildContext context) {
    /// If painter is null there is a need to setup it to prevent exceptions.
    if (_painter == null) {
      _setupPainter();
    }
    return RawGestureDetector(
        gestures: <Type, GestureRecognizerFactory>{
          _CustomPanGestureRecognizer:
              GestureRecognizerFactoryWithHandlers<_CustomPanGestureRecognizer>(
            () => _CustomPanGestureRecognizer(
              onPanDown: _onPanDown,
              onPanUpdate: _onPanUpdate,
              onPanEnd: _onPanEnd,
            ),
            (_CustomPanGestureRecognizer instance) {},
          ),
        },
        child: _buildRotatingPainter(
            rotation: _rotation,
            size: Size(widget.appearance.size, widget.appearance.size)));
  }

  @override
  void dispose() {
    // if (_animController != null) _animController.dispose();
    super.dispose();
  }

  void _setupPainter() {
    var defaultAngle = _currentAngle ?? widget.angle;
    if (_oldWidgetAngle != null) {
      if (_oldWidgetAngle != widget.angle) {
        _selectedAngle = null;
        defaultAngle = widget.angle;
      }
    }

    _currentAngle = calculateAngle(
        startAngle: _startAngle,
        angleRange: _angleRange,
        selectedAngle: _selectedAngle,
        previousAngle: _currentAngle,
        defaultAngle: defaultAngle);

    _painter = _CurvePainter(
        startAngle: _startAngle,
        angleRange: _angleRange,
        angle: _currentAngle < 0.5 ? 0.5 : _currentAngle,
        appearance: widget.appearance);
    _oldWidgetAngle = widget.angle;
    _oldWidgetValue = widget.initialValue;
  }

  void _updateOnChange() {
    if (widget.onChange != null) {
      final value =
          angleToValue(_currentAngle, widget.min, widget.max, _angleRange);
      widget.onChange(value);
    }
  }

  Widget _buildRotatingPainter({double rotation, Size size}) {
    if (rotation != null) {
      return Transform(
          transform: Matrix4.identity()..rotateZ((rotation) * 5 * math.pi / 6),
          alignment: FractionalOffset.center,
          child: _buildPainter(size: size));
    } else {
      return _buildPainter(size: size);
    }
  }

  Widget _buildPainter({Size size}) {
    return CustomPaint(
        painter: _painter,
        child: Container(
            width: size.width,
            height: size.height,
            child: _buildChildWidget()));
  }

  Widget _buildChildWidget() {
    // if (widget.appearance.spinnerMode) {
    //   return null;
    // }
    final value =
        angleToValue(_currentAngle, widget.min, widget.max, _angleRange);
    final childWidget = widget.innerWidget != null
        ? widget.innerWidget(value)
        : SliderLabel(
            value: value,
            appearance: widget.appearance,
          );
    return childWidget;
  }

  void _onPanUpdate(Offset details) {
    if (!_isHandlerSelected) {
      return;
    }
    if (_painter.center == null) {
      return;
    }
    _handlePan(details, false);
  }

  void _onPanEnd(Offset details) {
    _handlePan(details, true);
    if (widget.onChangeEnd != null) {
      widget.onChangeEnd(
          angleToValue(_currentAngle, widget.min, widget.max, _angleRange));
    }

    _isHandlerSelected = false;
  }

  void _handlePan(Offset details, bool isPanEnd) {
    if (_painter.center == null) {
      return;
    }
    RenderBox renderBox = context.findRenderObject();
    var position = renderBox.globalToLocal(details);
    _selectedAngle = coordinatesToRadians(_painter.center, position);
    // setup painter with new angle values and update onChange
    _setupPainter();
    _updateOnChange();
    setState(() {});
  }

  bool _onPanDown(Offset details) {
    if (_painter == null || _interactionEnabled == false) {
      return false;
    }
    RenderBox renderBox = context.findRenderObject();
    var position = renderBox.globalToLocal(details);

    if (position == null) {
      return false;
    }

    final double touchWidth = widget.appearance.progressBarWidth >= 25.0
        ? widget.appearance.progressBarWidth
        : 25.0;

    if (isPointAlongCircle(
        position, _painter.center, _painter.radius, touchWidth)) {
      _isHandlerSelected = true;
      if (widget.onChangeStart != null) {
        widget.onChangeStart(
            angleToValue(_currentAngle, widget.min, widget.max, _angleRange));
      }
      _onPanUpdate(details);
    } else {
      _isHandlerSelected = false;
    }

    return _isHandlerSelected;
  }
}
