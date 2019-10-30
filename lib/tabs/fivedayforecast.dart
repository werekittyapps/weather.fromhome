import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather/widgets/cards.dart';
import 'package:dio/dio.dart';
import 'package:toast/toast.dart';
import 'package:data_connection_checker/data_connection_checker.dart';

class FiveDaysForecast extends StatefulWidget {
  final String id;
  final String city;
  final bool caching;

  const FiveDaysForecast({
    Key key,
    this.id, this.city, this.caching
  }) : super(key: key);

  @override
  FiveDaysForecastState createState() => FiveDaysForecastState(id, city, caching);
}

class FiveDaysForecastState extends State<FiveDaysForecast> {
  final String id;
  final String city;
  final bool caching;
  FiveDaysForecastState(this.id, this.city, this.caching);

  var _forecast; // for forecast
  bool forecastError = false;
  bool isLoading = false;

  DateTime first;
  DateTime second;
  DateTime third;
  DateTime forth;
  DateTime fifth;

  List<dynamic> firstDayData = [];
  List<dynamic> secondDayData = [];
  List<dynamic> thirdDayData = [];
  List<dynamic> forthDayData = [];
  List<dynamic> fifthDayData = [];

  weatherForecastCall(String id) async {
    checkInternet();
    setState(() {
      isLoading = true;
    });
    try {
      Response response = await Dio().get("https://api.openweathermap.org/data/2.5/forecast?id=$id&units=metric&appid=7fe8b89a7579b408a6997d47eb97164c");
      debugPrint("forecast response ${response.statusCode}");
      if(response.statusCode == 200) {
        if (caching){
          SharedPreferences prefs = await SharedPreferences.getInstance();
          var data = response.data;
          prefs.setString('forecastFor$id', json.encode(data));
        }
        setState(() {
          _forecast = response.data;
          forecastError = false;
          forecastHandler();
        });
      }
      if(response.statusCode == 400 || response.statusCode == 404 ||
          response.statusCode == 429 || response.statusCode == 500 ||
          response.statusCode == 503) {
        // 400 - "Некорректный запрос"
        // 404 - "Такого города не найдено"
        // 429 - "Исчерпан лимит запросов"
        // 500 - "Internal Server Error: ошибка соединения с сервером"
        // 503 - "Сервер недоступен"
        getCachedForecast();
      }
    } catch (e) {
      getCachedForecast();
    }
  }

  getCachedForecast() async{
    var noData = false;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var cache = (prefs.getString('forecastFor$id') ?? {
      forecastError = true,
      print("No cached forecasts"),
      noData = true,
    });
    if(!noData){
      _forecast = json.decode(cache);
      setState(() {
        //forecastError = forecastError;
        forecastHandler();
      });
    }
    setState(() {
      forecastError = forecastError;
      isLoading = false;
    });
  }


  forecastHandler(){
    int beginOfSecondDay;
    int beginOfThirdDay;
    int beginOfForthDay;
    int beginOfFifthDay;
    List list = _forecast["list"];
    List firstList = [];
    List secondList = [];
    List thirdList = [];
    List forthList = [];
    List fifthList = [];

    // разбиваем прогноз по дням
    for (int i = 0; i < list.length; i++){
      var weeky = DateTime.parse(list[i]["dt_txt"]);
      if(i == 0){
        first = weeky;
      }
      if(first != null && second == null && third == null && forth == null && fifth == null){
        if (weeky.day != first.day){
          second = weeky;
          beginOfSecondDay = i;
        }
      }
      if(first != null && second != null && third == null && forth == null && fifth == null){
        if (weeky.day != second.day){
          third = weeky;
          beginOfThirdDay = i;
        }
      }
      if(first != null && second != null && third != null && forth == null && fifth == null){
        if (weeky.day != third.day){
          forth = weeky;
          beginOfForthDay = i;
        }
      }
      if(first != null && second != null && third != null && forth != null && fifth == null){
        if (weeky.day != forth.day){
          fifth = weeky;
          beginOfFifthDay = i;
        }
      }
    }

    // Выделяем листы данных каждому дню
    for(int i = 0; i < beginOfSecondDay; i++){
      firstList.add(list[i]);
    }
    for(int i = beginOfSecondDay; i < beginOfThirdDay; i++){
      secondList.add(list[i]);
    }
    for(int i = beginOfThirdDay; i < beginOfForthDay; i++){
      thirdList.add(list[i]);
    }
    for(int i = beginOfForthDay; i < beginOfFifthDay; i++){
      forthList.add(list[i]);
    }
    for(int i = beginOfFifthDay; i < beginOfFifthDay + 8; i++){
      fifthList.add(list[i]);
    }

    setState(() {
      print("Bыгружаем листы");
      isLoading = false;
      forecastHelper(first, firstList, firstDayData);
      forecastHelper(second, secondList, secondDayData);
      forecastHelper(third, thirdList, thirdDayData);
      forecastHelper(forth, forthList, forthDayData);
      forecastHelper(fifth, fifthList, fifthDayData);
    });
  }

  forecastHelper(DateTime day, List listInput, List listOutput){
    var highest;
    var highState;
    var highIcon;
    var lowest;
    var lowState;
    var lowIcon;
    var pressure = 0;
    for(int i = 0; i < listInput.length; i++){
      pressure += listInput[i]["main"]["pressure"];
      if (highest == null){
        highest = lowest = listInput[i]["main"]["temp"];
        highState = lowState = listInput[i]["weather"][0]["main"];
        highIcon = lowIcon = listInput[i]["weather"][0]["icon"];
      }
      if (highest != null && listInput[i]["main"]["temp"] > highest){
        highest = listInput[i]["main"]["temp"];
        highState = listInput[i]["weather"][0]["main"];
        highIcon = listInput[i]["weather"][0]["icon"];
      }
      if (highest != null && listInput[i]["main"]["temp"] < lowest){
        lowest = listInput[i]["main"]["temp"];
        lowState = listInput[i]["weather"][0]["main"];
        lowIcon = listInput[i]["weather"][0]["icon"];
      }
    }
    pressure = (pressure/listInput.length).round();
    highest = (highest).round();
    lowest = (lowest).round();

    if(day == first) listOutput.add("Сегодня");
    if(day == second) listOutput.add("Завтра");
    if(day != first && day != second) listOutput.add("${weekDay(day.weekday)}");
    listOutput.add("${day.day}.${day.month}");
    listOutput.add(highIcon.replaceAll("n", "d"));
    listOutput.add(highState);
    listOutput.add(highest);
    listOutput.add(lowest);
    listOutput.add(lowIcon.replaceAll("d", "n"));
    listOutput.add(lowState);
    listOutput.add(pressure);
  }

  String weekDay(int index){
    if (index == 1) return "Пн";
    if (index == 2) return "Вт";
    if (index == 3) return "Ср";
    if (index == 4) return "Чт";
    if (index == 5) return "Пт";
    if (index == 6) return "Сб";
    return "Вс";
  }

  checkInternet() async{
    bool result = await DataConnectionChecker().hasConnection;
    if(result == true) {
      print('We have connection');
    } else {
      Toast.show("Не удалось подключиться к сети", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
    }
  }

  void initState() {
    weatherForecastCall(id);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return  Container(
      child: isLoading ?
      Container(alignment: Alignment(0.0,-1.0), padding: EdgeInsets.fromLTRB(0, 55, 0, 0), child: CircularProgressIndicator())
          : forecastError?
      ListView.builder(
          itemCount: 1,
          itemBuilder: (context, i){
            return new ListTile(
                title: Container(height: 170, padding: EdgeInsets.fromLTRB(20, 10, 20, 0), child: errorCard(context, false))
            );
          })
          : Container(alignment: Alignment(0.0, -1.0), child: weatherForecast(firstDayData, secondDayData, thirdDayData, forthDayData, fifthDayData),),
    );
  }

}