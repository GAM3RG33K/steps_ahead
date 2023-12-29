import 'package:flutter/material.dart';

export 'di_utils.dart';
export 'logs_utils.dart';
export 'transformer_utils.dart';
export 'widget_utils.dart';

typedef JSON = Map<String, dynamic>;

// colors used inside app

Color get materialColorLight1 => Colors.red.shade100;

Color get materialColorLight2 => Colors.blue.shade100;

Color get materialColorLight3 => Colors.purple.shade100;

Color get materialColorLight4 => Colors.green.shade100;

Color get materialColorLight5 => Colors.orange.shade100;

Color get materialColorLight6 => Colors.teal.shade100;

List<Color> get materialLightColors => [
      materialColorLight1,
      materialColorLight2,
      materialColorLight3,
      materialColorLight4,
      materialColorLight5,
      materialColorLight6,
    ];

Color get materialColor1 => Colors.red.shade800;

Color get materialColor2 => Colors.blue.shade800;

Color get materialColor3 => Colors.purple.shade800;

Color get materialColor4 => Colors.green.shade800;

Color get materialColor5 => Colors.orange.shade800;

Color get materialColor6 => Colors.teal.shade800;

List<Color> get materialColors => [
      materialColor1,
      materialColor2,
      materialColor3,
      materialColor4,
      materialColor5,
      materialColor6,
    ];
