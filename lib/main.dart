import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/user/user_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await UserState.loadFromStorage();
  runApp(const DoomscrollDaycareApp());
}
