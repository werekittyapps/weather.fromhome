import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:weather/utils/utils.dart';
import 'package:weather/widgets/images.dart';
import 'package:weather/widgets/texts.dart';
import 'package:flutter_sparkline/flutter_sparkline.dart';

errorCard(BuildContext context, bool curWeatherCallError) {
  return Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.grey[400]),),
      child: Container (
        // Белая карточка
        color: Colors.white,
        child:
        Row (
          children: [
            Expanded(
              child: Column(
                children:[
                  SizedBox(height: 48),
                  Container(
                    padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Container(
                          alignment: Alignment(-1.0, -1.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              curWeatherCallError ? greyTextView(context, "Error", 22) : greyTextViewForForecast("Error", 22),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Divider(
                      thickness: 1,
                    ),
                  ),
                  curWeatherCallError ?
                  Container(padding: EdgeInsets.fromLTRB(5, 0, 5, 10), child: greyTextView(context, 'город не найден', 14),)
                      : Container(padding: EdgeInsets.fromLTRB(5, 0, 5, 10), child: greyTextViewForForecast('Что-то пошло не так', 14),),
                ],
              ),
            )
          ],
        ),
      )
  );
}

currentWeatherSearchCard(BuildContext context, Map<String, dynamic> map, bool isInFavorites, Function pressButton) {
  return Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.grey[400]),),
      child:
      Container (
        // Белая карточка
          color: Colors.white,
          child: Row (
            children: [
              Expanded(
                child: Column(
                  children:[
                    Container(
                      alignment: Alignment(-1.0, -1.0),
                      child: IconButton(
                        icon: Icon(isInFavorites ? Icons.star : Icons.star_border),
                        onPressed: (){pressButton();},),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Город и страна
                          // Иконка
                          // Градусы
                          Container(
                            alignment: Alignment(-1.0, -1.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(width: 160, child: greyAutoSizedTextView(context, map["name"], 22)),
                                greyTextView(context, map["sys"]["country"], 12),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Container(
                                    alignment: Alignment(1.0, -1.0),
                                    padding: EdgeInsets.fromLTRB(0, 5, 5, 5),
                                    child: cachedImageLoader(map["weather"][0]["icon"], 60.0),
                                  ),
                                  Container(
                                    alignment: Alignment(1.0, -1.0),
                                    padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                                    child: greyTextView(context, '${map["main"]["temp"].round()}°C', 24),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: Divider(
                        thickness: 1,
                      ),
                    ),
                    Container(
                        padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            greyTextView(context, 'Влажность ${map["main"]["humidity"].round()}% | '
                                '${map["wind"]["deg"] == null ? "?"
                                : map["wind"]["deg"] > 337.5 || map["wind"]["deg"] < 22.5 ? "С"
                                : map["wind"]["deg"] > 22.5 && map["wind"]["deg"] < 67.5 ? "СВ"
                                : map["wind"]["deg"] > 67.5 && map["wind"]["deg"] < 112.5 ? "В"
                                : map["wind"]["deg"] > 112.5 && map["wind"]["deg"] < 157.5 ? "ЮВ"
                                : map["wind"]["deg"] > 157.5 && map["wind"]["deg"] < 202.5 ? "Ю"
                                : map["wind"]["deg"] > 202.5 && map["wind"]["deg"] < 247.5 ? "ЮЗ"
                                : map["wind"]["deg"] > 247.5 && map["wind"]["deg"] < 292.5 ? "З"
                                : "СЗ"} | ${map["wind"]["speed"].round() * 3.6} км/ч', 14),
                            greyTextView(context, '${map["main"]["temp_max"].round()}/${map["main"]["temp_min"].round()}°C', 14),
                          ],
                        )
                    ),
                  ],
                ),
              )
            ],
          )
      )
  );
}

currentWeatherFavoriteCard(BuildContext context, Map<String, dynamic> map, int i, String citiesID, Function function, bool editFlag, bool isItGeoCard, bool isInFavorites, Function pressButton) {

  press(String id){
    deleteFromFavoritesUtils(id, citiesID, function, i);
  }

  return Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.grey[400]),),
      child:
      Container (
        // Белая карточка
          color: Colors.white,
          child: Row (
            children: [
              Expanded(
                child: Column(
                  children:[
                    editFlag ? Container(
                      alignment: Alignment(1.0, -1.0),
                      child: IconButton(
                        icon: Icon(Icons.remove_circle_outline),
                        onPressed: (){press(map["list"][i]["id"].toString());},),
                    ) : isItGeoCard ? Container(
                        alignment: Alignment(-1.0, -1.0),
                        child: Row(
                          children: <Widget>[
                            IconButton(
                              icon: Icon(isInFavorites ? Icons.star : Icons.star_border),
                              onPressed: (){pressButton();},),
                            greyTextView(context, "Текущее местоположение", 14)
                          ],
                        )
                    )
                        : SizedBox(height: 48),
                    Container(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Город и страна
                          // Иконка
                          // Градусы
                          Container(
                            alignment: Alignment(-1.0, -1.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                isItGeoCard ? Row(children: <Widget>[Container(width: 160, child: greyAutoSizedTextView(context, map["name"], 22),), Icon(Icons.place, color: Colors.grey[800],)],)
                                    : Container(width: 160, child: greyAutoSizedTextView(context, map["list"][i]["name"], 22)),
                                isItGeoCard ? map["sys"] == null ? greyTextView(context, "empty", 12) : greyTextView(context, map["sys"]["country"], 12) : greyTextView(context, map["list"][i]["sys"]["country"], 12),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Container(
                                    alignment: Alignment(1.0, -1.0),
                                    padding: EdgeInsets.fromLTRB(0, 5, 5, 5),
                                    child: isItGeoCard ? cachedImageLoader(map["weather"][0]["icon"], 60.0) : cachedImageLoader(map["list"][i]["weather"][0]["icon"], 60.0),
                                  ),
                                  Container(
                                    alignment: Alignment(1.0, -1.0),
                                    padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                                    child: isItGeoCard ? greyTextView(context, '${map["main"]["temp"].round()}°C', 24) : greyTextView(context, '${map["list"][i]["main"]["temp"].round()}°C', 24),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: Divider(
                        thickness: 1,
                      ),
                    ),
                    Container(
                        padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
                        child: isItGeoCard ?
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            greyTextView(context, 'Влажность ${map["main"]["humidity"].round()}% | '
                                '${map["wind"]["deg"] == null ? "?"
                                : map["wind"]["deg"] > 337.5 || map["wind"]["deg"] < 22.5 ? "С"
                                : map["wind"]["deg"] > 22.5 && map["wind"]["deg"] < 67.5 ? "СВ"
                                : map["wind"]["deg"] > 67.5 && map["wind"]["deg"] < 112.5 ? "В"
                                : map["wind"]["deg"] > 112.5 && map["wind"]["deg"] < 157.5 ? "ЮВ"
                                : map["wind"]["deg"] > 157.5 && map["wind"]["deg"] < 202.5 ? "Ю"
                                : map["wind"]["deg"] > 202.5 && map["wind"]["deg"] < 247.5 ? "ЮЗ"
                                : map["wind"]["deg"] > 247.5 && map["wind"]["deg"] < 292.5 ? "З"
                                : "СЗ"} | ${map["wind"]["speed"].round() * 3.6} км/ч', 14),
                            greyTextView(context, '${map["main"]["temp_max"].round()}/${map["main"]["temp_min"].round()}°C', 14),
                          ],
                        )
                            :
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            greyTextView(context, 'Влажность ${map["list"][i]["main"]["humidity"].round()}% | '
                                '${map["list"][i]["wind"]["deg"] == null ? "?"
                                : map["list"][i]["wind"]["deg"] > 337.5 || map["list"][i]["wind"]["deg"] < 22.5 ? "С"
                                : map["list"][i]["wind"]["deg"] > 22.5 && map["list"][i]["wind"]["deg"] < 67.5 ? "СВ"
                                : map["list"][i]["wind"]["deg"] > 67.5 && map["list"][i]["wind"]["deg"] < 112.5 ? "В"
                                : map["list"][i]["wind"]["deg"] > 112.5 && map["list"][i]["wind"]["deg"] < 157.5 ? "ЮВ"
                                : map["list"][i]["wind"]["deg"] > 157.5 && map["list"][i]["wind"]["deg"] < 202.5 ? "Ю"
                                : map["list"][i]["wind"]["deg"] > 202.5 && map["list"][i]["wind"]["deg"] < 247.5 ? "ЮЗ"
                                : map["list"][i]["wind"]["deg"] > 247.5 && map["list"][i]["wind"]["deg"] < 292.5 ? "З"
                                : "СЗ"} | ${map["list"][i]["wind"]["speed"].round() * 3.6} км/ч', 14),
                            greyTextView(context, '${map["list"][i]["main"]["temp_max"].round()}/${map["list"][i]["main"]["temp_min"].round()}°C', 14),
                          ],
                        )
                    ),
                  ],
                ),
              )
            ],
          )
      )
  );
}

weatherForecast(List<dynamic> first, List<dynamic> second, List<dynamic> third,
    List<dynamic> forth, List<dynamic> fifth){
  List<double> dataHigh = [];
  dataHigh.add(first[4].toDouble());
  dataHigh.add(second[4].toDouble());
  dataHigh.add(third[4].toDouble());
  dataHigh.add(forth[4].toDouble());
  dataHigh.add(fifth[4].toDouble());
  List<double> dataLow = [];
  dataLow.add(first[5].toDouble());
  dataLow.add(second[5].toDouble());
  dataLow.add(third[5].toDouble());
  dataLow.add(forth[5].toDouble());
  dataLow.add(fifth[5].toDouble());

  return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
            child: Container (
              // Белая карточка
                height: 480,
                color: Colors.white,
                child: Column(
                  children: <Widget>[
                    Row (
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        forecastHighColumn(first),
                        forecastHighColumn(second),
                        forecastHighColumn(third),
                        forecastHighColumn(forth),
                        forecastHighColumn(fifth),
                      ],
                    ),
                    Container(padding: EdgeInsets.fromLTRB(20, 0, 20, 0), height: 60, width: 360, child: Sparkline(data: dataHigh, lineColor: Colors.grey[400],
                      lineWidth: 1, pointsMode: PointsMode.all, pointSize: 3, pointColor: Colors.grey[800],)),
                    Container(padding: EdgeInsets.fromLTRB(20, 0, 20, 0), height: 60, width: 360,child: Sparkline(data: dataLow, lineColor: Colors.grey[400],
                      lineWidth: 1, pointsMode: PointsMode.all, pointSize: 3, pointColor: Colors.grey[800],)),
                    Row (
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        forecastLowColumn(first),
                        forecastLowColumn(second),
                        forecastLowColumn(third),
                        forecastLowColumn(forth),
                        forecastLowColumn(fifth),
                      ],
                    )
                  ],
                )
            )
        ),
      )
  );
}

forecastHighColumn(List<dynamic> list){
  return Container(
      height: 190,
      width: 80,
      child: Row(
        children: <Widget>[
          Expanded(
            child:
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(child: Divider(thickness: 1, height: 1, color: Colors.grey[400],)),
                Container(
                    child: Column(
                      children: <Widget>[
                        Container(padding: EdgeInsets.fromLTRB(0, 10, 0, 5), child: greyTextViewForForecast(list[0].toString(), 14)),
                        Container(padding: EdgeInsets.only(bottom: 10), child: greyTextViewForForecast(list[1].toString(), 14)),
                      ],
                    )
                ),
                Divider(thickness: 1, height: 0, color: Colors.grey[400]),
                Container(
                  child: Column(
                    children: <Widget>[
                      Container(padding: EdgeInsets.only(bottom: 10), child: cachedImageLoader(list[2].toString(), 50.0),),
                      Container(child: greyTextViewForForecast(list[3].toString().toString(), 14)),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
                  child: greyTextViewForForecast("${list[4]}°C", 28),
                ),
              ],
            ),
          )
        ],
      )
  );
}

forecastLowColumn(List<dynamic> list){
  return Container(
      height: 170,
      width: 80,
      child: Row(
        children: <Widget>[
          Expanded(
            child:
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                  child: greyTextViewForForecast("${list[5]}°C", 28),
                ),
                Container(
                  child: Column(
                    children: <Widget>[
                      Container(child: cachedImageLoader(list[6].toString(), 50.0),),
                      Container(padding: EdgeInsets.only(bottom: 10), child: greyTextViewForForecast(list[7].toString(), 14)),
                      Container(child: greyTextViewForForecast("давление", 14)),
                      Container(padding: EdgeInsets.only(bottom: 10), child: greyTextViewForForecast(list[8].toString(), 14)),
                    ],
                  ),
                ),
                Divider(thickness: 1, height: 0, color: Colors.grey[400])
              ],
            ),
          )
        ],
      )
  );
}

forecastDayHigh(String temp){
  return Container(
      height: 40,
      width: 80,
      child: Row(
        children: <Widget>[
          Expanded(
            child:
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Divider(thickness: 1, height: 0, color: Colors.grey[400]),
                Container(
                  child: greyTextViewForForecast("$temp°C", 18),
                ),

              ],
            ),
          )
        ],
      )
  );
}

forecastDayLow(String time){
  return Container(
      height: 40,
      width: 80,
      child: Row(
        children: <Widget>[
          Expanded(
            child:
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                  child: greyTextViewForForecast(time, 14),
                ),
                Divider(thickness: 1, height: 0, color: Colors.grey[400])
              ],
            ),
          )
        ],
      )
  );
}