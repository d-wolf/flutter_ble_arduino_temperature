import 'package:ble_temperature/src/bluetooth/presentation/widgets/thermostat/thermostat_painter.dart';
import 'package:flutter/material.dart';

class Thermostat extends StatelessWidget {
  const Thermostat({
    required this.value,
    required this.scaleLow,
    required this.scaleHight,
    required this.scaleStep,
    this.glassColor,
    this.fillColor,
    this.scaleColor,
    this.textColor,
    this.fontSize,
    super.key,
  });
  final double value;
  final double scaleLow;
  final double scaleHight;
  final double scaleStep;

  final Color? glassColor;
  final Color? fillColor;
  final Color? scaleColor;
  final Color? textColor;

  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ThermostatPainter(
        value: value,
        scaleLow: scaleLow,
        scaleHigh: scaleHight,
        scaleStep: scaleStep,
        glassColor: glassColor ?? Colors.grey.shade200,
        fillColor: fillColor ?? Colors.red.shade400,
        scaleColor: scaleColor ?? Colors.grey.shade800,
        textColor: textColor ?? Colors.black,
        fontSize: fontSize ?? 14,
      ),
      child: Container(),
    );
  }
}
