import 'dart:convert';

import 'package:ble_temperature/src/bluetooth/data/constants/constants.dart';
import 'package:ble_temperature/src/bluetooth/data/utils/extensions.dart';
import 'package:ble_temperature/src/bluetooth/domain/enums/enums.dart';
import 'package:ble_temperature/src/bluetooth/domain/value_objects/device_connection_state_update.dart';
import 'package:ble_temperature/src/bluetooth/domain/value_objects/discovered_device.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart' as ble;

abstract class BleRemoteDataSource {
  Stream<double> subscribeToCharacteristic(String deviceId);

  Stream<DiscoveredDevice> scanForDevices();

  Stream<BLEState> bleStateStream();

  BLEState bleState();

  Stream<DeviceConnectionStateUpdate> connectToDevice({
    required String deviceId,
    Map<String, List<String>>? servicesWithCharacteristicsToDiscover,
    Duration? connectionTimeout,
  });
}

class BleRemoteDataSourceImpl implements BleRemoteDataSource {
  BleRemoteDataSourceImpl(this._ble);
  final ble.FlutterReactiveBle _ble;

  @override
  Stream<double> subscribeToCharacteristic(String deviceId) {
    return _ble
        .subscribeToCharacteristic(
          ble.QualifiedCharacteristic(
            characteristicId: kChrUuid.toUuid(),
            serviceId: kSrvUuid.toUuid(),
            deviceId: deviceId,
          ),
        )
        .map((event) => double.parse(const Utf8Decoder().convert(event)));
  }

  @override
  Stream<DiscoveredDevice> scanForDevices() {
    return _ble
        .scanForDevices(
          withServices: [],
        )
        .map(
          (event) => DiscoveredDevice(
            id: event.id,
            name: event.name,
            serviceData: {
              for (final item in event.serviceData.entries)
                item.key.toString(): item.value,
            },
            manufacturerData: event.manufacturerData,
            rssi: event.rssi,
            serviceUuids: event.serviceUuids.map((e) => e.toString()).toList(),
          ),
        )
        .where((event) => event.name == kAdvName);
  }

  @override
  Stream<BLEState> bleStateStream() {
    return _ble.statusStream.map((event) => event.toBleStatus());
  }

  @override
  BLEState bleState() {
    return _ble.status.toBleStatus();
  }

  @override
  Stream<DeviceConnectionStateUpdate> connectToDevice({
    required String deviceId,
    Map<String, List<String>>? servicesWithCharacteristicsToDiscover,
    Duration? connectionTimeout,
  }) {
    return _ble
        .connectToDevice(
          id: deviceId,
          servicesWithCharacteristicsToDiscover:
              servicesWithCharacteristicsToDiscover != null
                  ? {
                      for (final e
                          in servicesWithCharacteristicsToDiscover.entries)
                        e.key.toUuid(): e.value.map((e) => e.toUuid()).toList(),
                    }
                  : null,
          connectionTimeout: connectionTimeout,
        )
        .map(
          (event) => DeviceConnectionStateUpdate(
            deviceId: event.deviceId,
            deviceConnectionState:
                event.connectionState.toDeviceConnectionState(),
            error: event.failure,
          ),
        );
  }
}
