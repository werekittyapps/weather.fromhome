import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:weather/forecasts.dart';
import 'package:weather/utils/utils.dart';
import 'package:weather/widgets/cards.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:toast/toast.dart';
import 'package:data_connection_checker/data_connection_checker.dart';

class WeatherBody extends StatefulWidget {

  @override
  createState() => new WeatherBodyState();
}

class WeatherBodyState extends State<WeatherBody> {
  var _currentWeather; // for search
  var _currentWeatherForFavorites; // for life
  String citiesID = "";
  int cityPosition;

  // Geolocation
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  Position _currentPosition;
  var _currentGeoWeather;

  // For search bar
  Widget _appBarTitle = new Text( 'Weather' );
  Icon _searchIcon = new Icon(Icons.add);
  final TextEditingController _filter = new TextEditingController();

  // Flags
  bool noFavorites = true;
  bool searchFlag = false;
  bool inSearchFlag = false;
  bool isLoading = false;
  bool editFlag = false;
  bool curWeatherCallError = false;
  bool curWeatherCallErrorForFavorites = false;
  bool curGeoWeatherCallError = false;

  weatherCall(String cities, bool inSearchFlag, double lat, double lon, bool callingGeo) async {
    checkInternet();
    print("wheater call");
    setState(() {
      isLoading = true;
    });
    try {
      Response response;
      Response geoResponse;
      if(callingGeo) {
        geoResponse = await Dio().get("https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&units=metric&appid=7fe8b89a7579b408a6997d47eb97164c");
      }
      if(inSearchFlag){
        response = await Dio().get("https://api.openweathermap.org/data/2.5/weather?q=$cities&appid=7fe8b89a7579b408a6997d47eb97164c&units=metric");
      } else {
        response = await Dio().get("https://api.openweathermap.org/data/2.5/group?id=$cities&units=metric&appid=7fe8b89a7579b408a6997d47eb97164c");
      }
      debugPrint("response ${response.statusCode}");
      if(response.statusCode == 200) {
        if(callingGeo) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          var data = geoResponse.data;
          prefs.setString('geoWeatherCache', json.encode(data));
          setState(() {
            _currentGeoWeather = geoResponse.data;
            curGeoWeatherCallError = false;
            isLoading = false;
          });
        }
        if(inSearchFlag) {
          setState(() {
            _currentWeather = response.data;
            curWeatherCallError = false;
            searchFlag = true;
            isLoading = false;
          });
        } else {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          var data = response.data;
          prefs.setString('favoriteWeatherCache', json.encode(data));
          setState(() {
            _currentWeatherForFavorites = response.data;
            curWeatherCallErrorForFavorites = false;
            isLoading = false;
          });
        }
      }
      if(response.statusCode == 400 || response.statusCode == 404 ||
          response.statusCode == 429 || response.statusCode == 500 ||
          response.statusCode == 503) {
        // 400 - "Некорректный запрос"
        // 404 - "Такого города не найдено"
        // 429 - "Исчерпан лимит запросов"
        // 500 - "Internal Server Error: ошибка соединения с сервером"
        // 503 - "Сервер недоступен"
        setState(() {
          if(callingGeo) {
            getCachedGeoWeather();
          }
          if(inSearchFlag) {
            curWeatherCallError = true;
            searchFlag = true;
          } else {
            getCachedWeather();
          }
          isLoading = false;
        });
      }
    } catch (e) {
      print(e);
      setState(() {
        if(callingGeo){
          getCachedGeoWeather();
        }
        if(inSearchFlag) {
          curWeatherCallError = true;
          searchFlag = true;
        } else {
          getCachedWeather();
        }
        isLoading = false;
      });
    }
  }

  getCachedWeather() async{
    var noData = false;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var cache = (prefs.getString('favoriteWeatherCache') ?? {
      curWeatherCallErrorForFavorites = true,
      print("No cached favorite weather"),
      noData = true,
    });
    if(!noData){
      setState(() {
        _currentWeatherForFavorites = json.decode(cache);
      });
    }
    setState(() {
      curWeatherCallErrorForFavorites = curWeatherCallErrorForFavorites;
    });
  }

  getCachedGeoWeather() async{
    var noData = false;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var cache = (prefs.getString('geoWeatherCache') ?? {
      curWeatherCallError = true,
      print("No cached geo weather"),
      noData = true,
    });
    if(!noData){
      setState(() {
        _currentGeoWeather = json.decode(cache);
      });
    }
    setState(() {
      curWeatherCallError = curWeatherCallError;
    });
  }

  getCached() async{
    print("get cached");
    getLocation();
    var noData = false;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var favorsID = (prefs.getString('favorites') ?? {
      citiesID = null,
      print("No favorites"),
      noFavorites = true,
      noData = true,
    });
    if(!noData){
      noFavorites = false;
      citiesID = favorsID;
      citiesID = dealWithCommas(citiesID);
      citiesID = dealWithDuplicated(citiesID);
      prefs.setString('favorites', citiesID);
      print("citiesID: $citiesID");
      weatherCall(citiesID, inSearchFlag, 0.0, 0.0, false); //
    }
    print(noData);
    setState(() {
      noFavorites = noFavorites;
    });
  }

  searching(){
    setState(() {
      if (this._searchIcon.icon == Icons.add) {
        inSearchFlag = true;
        this._searchIcon = new Icon(Icons.close);
        this._appBarTitle = new TextField(
          controller: _filter,
          decoration: new InputDecoration(
            prefixIcon: new Icon(Icons.search),
            hintText: 'Search...',),
          onSubmitted: (value) {
            String city = value.trim().replaceAll(" ", "%20").replaceAll("\n", "");
            if(city.isNotEmpty) weatherCall(city, inSearchFlag, 0.0, 0.0, false);
          },
        );
      } else {
        if(!editFlag){
          this._searchIcon = new Icon(Icons.add);
          this._appBarTitle = new Text('Weather');
          inSearchFlag = false;
          searchFlag = false;
          _filter.clear();
          getCached();
        }
      }
    });
  }

  startEditing(){
    setState(() {
      editFlag = true;
      this._searchIcon = new Icon(Icons.close);
      this._appBarTitle = new Text( 'Editing...' );
    });
  }

  closeEditing(){
    if (editFlag) {
      setState(() {
        this._searchIcon = new Icon(Icons.add);
        this._appBarTitle = new Text('Weather');
        editFlag = false;
        getCached();
      });
    }
  }

  isInFavorites(String id){
    bool isIn = false;
    if(citiesID != null) {
      List list = [];
      list = citiesID.split(",").toList();
      for(int i = 0; i < list.length; i++){
        if (list[i] == id){
          cityPosition = i;
          isIn = true;
        }
      }
    }
    return isIn;
  }

  pressButtonSearch() {
    setState(() {
      if(isInFavorites(_currentWeather["id"].toString())) deleteFromFavoritesUtils(_currentWeather["id"].toString(), citiesID, getCached, cityPosition);
      else addToFavorites(_currentWeather["id"].toString());
      isInFavorites(_currentWeather["id"].toString());
    });
  }

  pressButton() {
    setState(() {
      if(isInFavorites(_currentGeoWeather["id"].toString())) {
        deleteFromFavoritesUtils(_currentGeoWeather["id"].toString(), citiesID, getCached, cityPosition);
        getCached();
      } else {
        addToFavorites(_currentGeoWeather["id"].toString());
        getCached();
      }
      isInFavorites(_currentGeoWeather["id"].toString());
    });
  }

  addToFavorites(String id) async {
    if(citiesID==null) citiesID = "";
    print("add to favorites");
    SharedPreferences getDataPrefs = await SharedPreferences.getInstance();
    if (citiesID != ""){
      citiesID += ",$id";
      getDataPrefs.setString('favorites', citiesID);
    } else {
      citiesID = "$id";
      getDataPrefs.setString('favorites', citiesID);
    }
  }

  deleteCache() async{
    SharedPreferences getDataPrefs = await SharedPreferences.getInstance();
    getDataPrefs.clear();
  }

  getLocation(){
    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      _currentPosition = position;
      weatherCall(citiesID, inSearchFlag, _currentPosition.latitude, _currentPosition.longitude, true);
    }).catchError((e) {
      print(e);
    });
  }

  checkInternet() async{
    bool result = await DataConnectionChecker().hasConnection;
    if(result == true) {
      print('We have connection');
    } else {
      Toast.show("Не удалось подключиться к сети", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
    }
  }

  @override
  void initState() {
    getCached();
    //deleteCache();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[300],
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(0.0), child: Container(),),
        body: Stack(
          children: <Widget>[
            Container(
                padding: EdgeInsets.fromLTRB(0, 60, 0, 0),
                child:
                searchFlag ? // Если сделали запрос и пришло [200]
                Column (
                    children: [
                      Expanded (
                        child: Container (
                          child: isLoading ?
                          Container(alignment: Alignment(0.0,-1.0), padding: EdgeInsets.fromLTRB(0, 55, 0, 0), child: CircularProgressIndicator(),)
                              :
                          ListView.builder(
                              itemCount: 1,
                              itemBuilder: (context, i){
                                return new ListTile(
                                  title: Container(child: curWeatherCallError? errorCard(context, curWeatherCallError) : currentWeatherSearchCard(context, _currentWeather, isInFavorites(_currentWeather["id"].toString()), pressButtonSearch),),
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ForecastsBody(id: _currentWeather["id"].toString(), city: _currentWeather["name"].toString(), caching: false,))),
                                );
                              }),
                        ),
                      ),
                    ]) :
                // If we not searching, we must show favorite cards
                Column (
                    children: [
                      Expanded (
                        child: Container (
                          padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                          child:
                          noFavorites && _currentGeoWeather == null ?
                          Container() // Если нет избранных карт показываем пустой контейнер
                              :
                          isLoading ?
                          Container(alignment: Alignment(0.0,-1.0), padding: EdgeInsets.fromLTRB(0, 55, 0, 0), child: CircularProgressIndicator(),)
                              :
                          ListView.builder(
                              itemCount: noFavorites && _currentGeoWeather != null ? 1 : _currentGeoWeather == null ? _currentWeatherForFavorites["cnt"] : _currentWeatherForFavorites["cnt"] + 1,
                              itemBuilder: (context, i){
                                return new ListTile(
                                  title: Container(
                                      child:
                                      _currentGeoWeather == null ?
                                      curWeatherCallErrorForFavorites? errorCard(context, curWeatherCallError): currentWeatherFavoriteCard(context,_currentWeatherForFavorites, i, citiesID, getCached,  editFlag, false, null, null)
                                          : curGeoWeatherCallError && i == 0 ? errorCard(context, curWeatherCallError)
                                          : curGeoWeatherCallError && i != 0 ? curWeatherCallErrorForFavorites? errorCard(context, curWeatherCallError): currentWeatherFavoriteCard(context,_currentWeatherForFavorites, i - 1, citiesID, getCached,  editFlag, false, null, null)
                                          : !curGeoWeatherCallError && i == 0 ? currentWeatherFavoriteCard(context,_currentGeoWeather, 0, citiesID, getCached,  false, true, isInFavorites(_currentGeoWeather["id"].toString()), pressButton)
                                          : !curGeoWeatherCallError && i != 0 ? curWeatherCallErrorForFavorites? errorCard(context, curWeatherCallError): currentWeatherFavoriteCard(context,_currentWeatherForFavorites, i - 1, citiesID, getCached,  editFlag, false, null, null)
                                          : Container()
                                  ),
                                  onTap: () => _currentGeoWeather != null && i == 0 ? Navigator.push(context, MaterialPageRoute(builder: (context) => ForecastsBody(id: _currentGeoWeather["id"].toString(), city: _currentGeoWeather["name"].toString(), caching: false,)))
                                      : curWeatherCallErrorForFavorites ? null
                                      : Navigator.push(context, MaterialPageRoute(builder: (context) => ForecastsBody(id: _currentWeatherForFavorites["list"][i -1]["id"].toString(), city: _currentWeatherForFavorites["list"][i-1]["name"].toString(), caching: true,))),
                                  onLongPress: () => startEditing(),
                                );
                              }),
                        ),
                      ),
                    ])
            ),
            new Positioned(
              top: 0.0, left: 0.0, right: 0.0,
              child: AppBar(
                title: _appBarTitle,
                backgroundColor: Colors.transparent,
                elevation: 0.0,
                actions: <Widget>[
                  IconButton(
                    icon: _searchIcon,
                    color: Colors.grey[800],
                    onPressed: () {
                      searching();
                      closeEditing();
                    },
                  ),],
              ),
            )
          ],
        )
    );
  }
}