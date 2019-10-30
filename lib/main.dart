import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:weather/weather.dart';

void main() {
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(
        new MaterialApp(
            debugShowCheckedModeBanner: false,// скрываем надпись debug
            theme: ThemeData(
              primarySwatch: Colors.grey,
              secondaryHeaderColor: Colors.grey[800],
              indicatorColor: Colors.grey[800],
              hintColor: Colors.grey[800],
              accentColor: Colors.grey[800],
            ),
            home: WeatherBody()
        )
    );
  });
}