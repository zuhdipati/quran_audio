import 'package:flutter_compass/flutter_compass.dart';

abstract class CompassDataSource {
  /// Heading in degrees clockwise from north, or null when the device has
  /// no usable magnetometer. The stream itself is null without a sensor.
  Stream<double?>? headingStream();
}

class CompassDataSourceImpl implements CompassDataSource {
  @override
  Stream<double?>? headingStream() {
    return FlutterCompass.events?.map((event) => event.heading);
  }
}
