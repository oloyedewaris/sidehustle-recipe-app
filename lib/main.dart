import 'package:flutter/material.dart';

import 'package:recipe-app/src/app.dart';
import 'package:recipe-app/src/state_widget.dart';

// - StateWidget incl. state data
//    - RecipesApp
//        - All other widgets which are able to access the data
void main() => runApp(new StateWidget(
      child: new RecipesApp(),
    ));
