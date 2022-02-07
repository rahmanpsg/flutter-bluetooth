import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import 'package:get/get.dart';
import 'package:iot_bluetooth/app/themes/app_colors.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  final String judul =
      'Rancang Bangun Sistem Keamanan Pada Tas Menggunakan Bluetooth';
  final String nama = 'Herwin Basri';
  final String nim = '215280121';
  final String pembimbing1 = "Muh. Basri, ST., MT";
  final String pembimbing2 = "Ir. Untung Suwardoyo, S.Kom, MT";
  final String penguji1 = "Masnur, ST., M.Kom";
  final String penguji2 = "HJ. A. Irmayani P, ST., MT";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('IOT Bluetooth'),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: dangerColor,
              // shape: BoxShape.rectangle,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 1,
                  offset: Offset(-5, 5), // changes position of shadow
                ),
              ],
            ),
            child: Column(
              children: <Widget>[
                const SizedBox(height: 5),
                Center(
                  child: Text(
                    'Informasi',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Divider(
                  thickness: 2,
                  color: warningColor,
                ),
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    judul,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Center(
                  child: Text(
                    '$nama \n$nim',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                // const Divider(thickness: 1),
                const SizedBox(height: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    ..._dosenInfo("Pembimbing", 1, pembimbing1),
                    ..._dosenInfo("Pembimbing", 2, pembimbing2),
                    ..._dosenInfo("Penguji", 1, penguji1),
                    ..._dosenInfo("Penguji", 2, penguji2),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: dangerColor,
              // shape: BoxShape.rectangle,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 1,
                  offset: Offset(-5, 5), // changes position of shadow
                ),
              ],
            ),
            child: Obx(
              () => Column(
                children: <Widget>[
                  const SizedBox(height: 5),
                  Center(
                    child: Text(
                      'Pengaturan',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Divider(
                    thickness: 2,
                    color: warningColor,
                  ),
                  ListTile(
                    leading: Icon(Icons.info),
                    title: Text(controller.info.value),
                    trailing: ToggleButtons(
                      selectedColor: bgColor,
                      color: warningColor,
                      children: <Widget>[
                        Icon(Icons.bluetooth_disabled),
                        Icon(Icons.bluetooth_connected),
                      ],
                      // onPressed: (int index) {
                      //   log(index.toString());
                      //   controller.changeStatusBluetooth(index == 1);
                      // },
                      onPressed: controller.changeStatusBluetooth,
                      isSelected: controller.selected,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        width: 200,
                        child: DropdownButton(
                          hint: Text('Pilih Bluetooth'),
                          isExpanded: true,
                          items: controller.devicesList.map((device) {
                            log(device.name.toString());
                            return DropdownMenuItem(
                              child: Text(device.name.toString()),
                              value: device,
                            );
                          }).toList(),
                          onChanged: controller.isConnected.value
                              ? null
                              : controller.setDevice,
                          value: controller.device,
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: bgColor,
                        ),
                        // ignore: invalid_use_of_protected_member
                        onPressed: controller.selected.value.first ||
                                !controller.canStop.value ||
                                controller.loading.value
                            ? null
                            : controller.submit,
                        child: controller.loading.value
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(),
                              )
                            : Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.bluetooth_searching,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    controller.isConnected.value
                                        ? "Berhenti"
                                        : "Hubungkan",
                                  ),
                                ],
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

List<Widget> _dosenInfo(String jenis, int angka, String nama) {
  return [
    ListTile(
      contentPadding: const EdgeInsets.all(0),
      leading: Text("$jenis $angka"),
      title: Transform.translate(
        offset: Offset(0, -5),
        child: Text(": $nama"),
      ),
      horizontalTitleGap: (jenis == 'Pembimbing' ? 29.0 : 56.0) - angka,
    ),
    Transform.translate(
      offset: Offset(0, -15),
      child: const Divider(
        height: 0,
        thickness: 0,
        color: warningColor,
      ),
    )
  ];
}
