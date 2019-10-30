import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:weather/tabs/dayforecast.dart';
import 'package:weather/tabs/fivedayforecast.dart';

class ForecastsBody extends StatefulWidget {
  final String id;
  final String city;
  final bool caching;
  ForecastsBody({this.id, this.city, this.caching});

  @override
  createState() => new ForecastsBodyState(id, city, caching);
}

class ForecastsBodyState extends State<ForecastsBody>
    with SingleTickerProviderStateMixin {
  final String id;
  final String city;
  final bool caching;
  ForecastsBodyState(this.id, this.city, this.caching);

  TabController _controller;

  @override
  void initState() {
    _controller = TabController(
      length: 2,
      vsync: this,
    );
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
                padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: Column(
                  children: [
                    TabBar(
                      controller: _controller,
                      tabs: [
                        Tab(
                          //text: "First",
                          //icon: Icon(Icons.cloud),
                          icon: Container(),
                        ),
                        Tab(
                          //text: "Second",
                          //icon: Icon(Icons.date_range),
                          icon: Container(),
                        )
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _controller,
                        children: [
                          DayForecast(id: id, city: city, caching: caching),
                          FiveDaysForecast(id: id, city: city, caching: caching),
                        ],
                      ),
                    )
                  ],
                )
            ),
            new Positioned(
              top: 0.0, left: 0.0, right: 0.0,
              child: AppBar(
                title: Text('$city'),
                backgroundColor: Colors.transparent,
                elevation: 0.0,
              ),
            )
          ],
        )
    );
  }
}