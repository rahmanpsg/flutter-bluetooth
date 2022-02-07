import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:iot_bluetooth/app/themes/app_theme.dart';

import 'app/routes/app_pages.dart';

void main() async {
  AwesomeNotifications().initialize(
    // set the icon to null if you want to use the default app icon
    null,
    [
      NotificationChannel(
        channelGroupKey: 'iot_channel_group',
        channelKey: 'iot_channel',
        channelName: 'IOT notifications',
        channelDescription: 'Notifikasi ketika bluetooth disconnect',
        defaultColor: Color(0xFF9D50DD),
        ledColor: Colors.white,
      )
    ],
    debug: true,
  );

  await GetStorage.init('IOT-Bluetooth');

  runApp(
    GetMaterialApp(
      title: "IOT Bluetooth",
      theme: AppTheme.basic,
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    ),
  );
}
