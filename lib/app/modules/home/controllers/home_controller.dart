import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:iot_bluetooth/app/themes/app_colors.dart';

class HomeController extends GetxController {
  // ignore: prefer_function_declarations_over_variables
  static final _box = () => GetStorage('IOT-Bluetooth');
  final FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  BluetoothConnection? connection;
  RxBool isConnected = false.obs;
  RxBool loading = false.obs;
  bool isDisconnecting = false;
  RxBool canStop = true.obs;

  var info = ''.obs;
  RxList<bool> selected = [false, false].obs;

  BluetoothDevice? device;
  RxList<BluetoothDevice> devicesList = <BluetoothDevice>[].obs;
  final deviceConnected = ReadWriteValue('device', '', _box);

  @override
  void onInit() {
    super.onInit();

    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });

    getStatusBluetooth();

    Future.doWhile(() async {
      // Wait if adapter not enabled
      if ((await _bluetooth.isEnabled) ?? false) {
        return false;
      }
      await Future.delayed(Duration(milliseconds: 0xDD));
      return true;
    }).then((_) async {
      // Update the address field
      _bluetooth.address.then((address) {
        log(address.toString());
      });

      _bluetooth.name.then((name) {
        log(name.toString());
      });

      log(deviceConnected.val);

      if (deviceConnected.val.isNotEmpty) {
        device = BluetoothDevice.fromMap(jsonDecode(deviceConnected.val));
        isConnected.value = true;
        canStop.value = false;
      }
    });

    // Listen for futher state changes
    _bluetooth.onStateChanged().listen((BluetoothState state) {
      log("listen $state");
      setSelected(state == BluetoothState.STATE_ON);
    });

    // Load data from storage
    // final _device = _box.read('device');
    // if (_device != null) {
    //   device = _device;
    // }
  }

  @override
  void onClose() {}

  void getStatusBluetooth() async {
    _bluetooth.state.then((state) {
      setSelected(state == BluetoothState.STATE_ON);
    });
  }

  void changeStatusBluetooth(int value) async {
    if (value == 0) {
      await _bluetooth.requestDisable();
    } else {
      await _bluetooth.requestEnable();
    }
  }

  void setSelected(bool value) {
    if (value) {
      selected.value = [false, true];
      info.value = 'Bluetooth Aktif';
      canStop.value = true;
      getPairedDevices();
    } else {
      selected.value = [true, false];
      info.value = 'Bluetooth Tidak Aktif';
      devicesList.value = [];
      device = null;
      isConnected.value = false;
      // ignore: unnecessary_null_comparison
      deviceConnected.val == null;
      GetStorage('IOT-Bluetooth').erase();
      log("clear");
    }
  }

  void setDevice(BluetoothDevice? _device) {
    device = _device;
    devicesList.refresh();
  }

  void submit() async {
    if (device == null) {
      notifikasi(teks: "Silahkan pilih bluetooth yang ingin dihubungkan");
      return;
    }

    if (!isConnected.value) {
      await connectingBluetooth();
    } else {
      await connection!.close();
      isConnected.value = false;
    }
  }

  Future<void> connectingBluetooth() async {
    try {
      loading.value = true;

      await BluetoothConnection.toAddress(device!.address).then((_connection) {
        notifikasi(
            teks: "Berhasil terhubung ke ${device!.name}", success: true);

        isConnected.value = true;
        connection = _connection;
        deviceConnected.val = jsonEncode(device!.toMap());

        connection!.input!.listen(null).onDone(() {
          if (isDisconnecting) {
            print('Disconnecting locally!');
          } else {
            print('Disconnected remotely!');
            AwesomeNotifications().createNotification(
              content: NotificationContent(
                  id: 10,
                  channelKey: 'iot_channel',
                  title: 'Peringatan',
                  body: 'Tas anda ketinggalan bosku....'),
            );
          }
          connection!.close();
          isConnected.value = true;
        });
      }).catchError((error) {
        notifikasi(teks: "Tidak dapat terhubung ke bluetooth");
        print('Cannot connect, exception occurred');
        print(error);
      });
    } catch (e) {
      log(e.toString());
      notifikasi(teks: "Tidak dapat terhubung ke bluetooth");
    }

    loading.value = false;
  }

  void getPairedDevices() async {
    List<BluetoothDevice> devices = [];
    try {
      devices = await _bluetooth.getBondedDevices();
    } on PlatformException {
      print("Error");
    }

    devicesList.value = devices;
  }

  void notifikasi({teks, success = false}) {
    Get.snackbar(
      "Informasi",
      teks,
      icon: Icon(Icons.info, color: Colors.white),
      backgroundColor: !success ? warningColor : Colors.green,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }
}
