

// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:async';
import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:test1/model/CurrentCityDataModel.dart';
import 'package:intl/intl.dart';
import 'package:test1/model/ForecastDaysModel.dart';

void main() {
  runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyApp()
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<CurrentCityDataModel> currentWeatherFuture;
  late StreamController<List<ForecastDaysModel>> StreamForcastDays;
  var cityName = 'tehran';
  var lat;
  var lon;

  TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentWeatherFuture = SendRequestCurrentWeather(cityName);
    StreamForcastDays = StreamController<List<ForecastDaysModel>>();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Weather App"),
        elevation: 15,
        actions: <Widget> [
          PopupMenuButton <String> (
              itemBuilder: (BuildContext context) {
                return {'settings', 'profile', 'logout'}.map((String Choice){
                  return PopupMenuItem(
                    value: Choice,
                    child: Text(Choice),
                  );
                }).toList();
              }
          )
        ],
      ),
      body: FutureBuilder<CurrentCityDataModel>(
        future: currentWeatherFuture,
        builder: (context, snapshot){
          if (snapshot.hasData) {
            CurrentCityDataModel? cityDataModel = snapshot.data;
            SendRequest7DaysForcast(lat, lon);

            final formatter = DateFormat.jm();
            var sunrise = formatter.format(
                DateTime.fromMicrosecondsSinceEpoch(
                    cityDataModel!.surise * 1000,
                    isUtc: true));
            var sunset = formatter.format(
                DateTime.fromMicrosecondsSinceEpoch(
                    cityDataModel.sunset * 1000,
                    isUtc: true));

            return Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      fit: BoxFit.cover,
                      image: AssetImage('images/pic_bg.jpg')
                  )
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Center(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: ElevatedButton(
                                  onPressed:(){
                                    setState(() {
                                      currentWeatherFuture = SendRequestCurrentWeather(textEditingController.text);
                                    });
                                  }, child: Text("find")),
                            ),
                            Expanded(child: TextField(
                              controller: textEditingController,
                              decoration: InputDecoration(
                                  hintStyle: TextStyle(color: Colors.blueGrey[300]),
                                  hintText: "enter a city name",
                                  border: UnderlineInputBorder()
                              ),
                              style: TextStyle(color: Colors.blueGrey[300]),
                            ))
                          ],
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Text(cityDataModel.cityName, style: TextStyle(color: Colors.white, fontSize: 50),)
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Text(cityDataModel.description, style: TextStyle(color: Colors.grey, fontSize:20 )),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top:25),
                        child: setIconForMain(cityDataModel),
                        ),
                      Padding(
                        padding: const EdgeInsets.only(top:15),
                        child: Text(cityDataModel.temp.round().toString() + "\u00B0", style: TextStyle(color: Colors.white, fontSize: 55),),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              Text("max", style: TextStyle(color: Colors.grey, fontSize: 20),),
                              Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: Text(cityDataModel.tempMax.round().toString()+"\u00B0", style: TextStyle(color: Colors.white, fontSize: 20),),
                              )
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Container(
                              width: 1,
                              height: 40,
                              color: Colors.white,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Column(
                              children: [
                                Text("min", style: TextStyle(color: Colors.grey, fontSize: 20),),
                                Padding(
                                  padding: const EdgeInsets.only(top: 5),
                                  child: Text(cityDataModel.tempMin.round().toString()+"\u00B0", style: TextStyle(color: Colors.white, fontSize: 20),),
                                ),

                              ],
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Container(
                          color: Colors.grey[600],
                          height: 1,
                          width: double.infinity,
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        height: 80,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Center(
                            child: StreamBuilder<List<ForecastDaysModel>>(
                              stream: StreamForcastDays.stream,
                              builder: (context, snapshot) {

                                if (snapshot.hasData) {
                                  List<ForecastDaysModel>? forcastDays = snapshot.data;
                                  return ListView.builder(
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    itemCount: 6,
                                    itemBuilder: (BuildContext context, int position){
                                      return listViewItems(forcastDays![position + 1]);
                                    });
                                } else {
                                    return Center(
                                      child: JumpingDotsProgressIndicator(
                                      color: Colors.black,
                                      fontSize: 70,
                                      dotSpacing: 2,
                                      )
                                    );
                                  };
                              },
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Container(
                          color: Colors.grey[600],
                          height: 1,
                          width: double.infinity,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              children: [
                                Text("wind speed", style: TextStyle(color: Colors.grey, fontSize: 15),),
                                Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Text(cityDataModel.windSpeed.toString() + "m/s", style: TextStyle(color: Colors.white, fontSize: 15),),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Container(
                                width: 1,
                                height: 30,
                                color: Colors.white,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Column(
                                children: [
                                  Text("sunrise", style: TextStyle(color: Colors.grey, fontSize: 15),),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Text(sunrise, style: TextStyle(color: Colors.white, fontSize: 15),),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Container(
                                width: 1,
                                height: 30,
                                color: Colors.white,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Column(
                                children: [
                                  Text("sunset", style: TextStyle(color: Colors.grey, fontSize: 15),),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Text(sunset, style: TextStyle(color: Colors.white, fontSize: 15),),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Container(
                                width: 1,
                                height: 30,
                                color: Colors.white,
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Column(
                                children: [
                                  Text("humidity", style: TextStyle(color: Colors.grey, fontSize: 15),),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Text(cityDataModel.humidity.toString() + "%", style: TextStyle(color: Colors.white, fontSize: 15),),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );

        } else {
            return Center(
              child: JumpingDotsProgressIndicator(
                color: Colors.black,
                fontSize: 70,
                dotSpacing: 2,
              )
            );
          }
        },



        ),
    );
  }

  Container listViewItems(ForecastDaysModel forcastDays){
    return Container(
        height: 50,
        width: 70,
        child: Card(
            elevation: 0,
            color: Colors.transparent,
            child: Column(
              children: [
                //Text("fri, 8pm", style: TextStyle(color: Colors.grey, fontSize: 15),),
                Text(forcastDays.dateTime, style: TextStyle(color: Colors.grey, fontSize: 15),),
                //Icon(Icons.cloud, color: Colors.white,),
                Expanded(child: setIconForMain(forcastDays)),
                //Text("14"+"\u00B0", style: TextStyle(color: Colors.grey, fontSize: 15),),
                Text(forcastDays.temp.round().toString()+"\u00B0", style: TextStyle(color: Colors.grey, fontSize: 15),),
              ],
            )
        )
    );
  }

  Image setIconForMain(model) {
    String description = model.description;
    if (description == "clear sky") {
      return Image(
        image: AssetImage(
          'images/icons8-sun-96.png',
        ));
    } else if (description == "few clouds") {
      return Image(image: AssetImage('images/icons8-partly-cloudy-day-80.png'));
    } else if (description.contains("clouds")) {
      return Image(image: AssetImage('images/icons8-clouds-80.png'));
    } else if (description.contains("thunderstorm")) {
      return Image(image: AssetImage('images/icons8-storm-80.png'));
    } else if (description.contains("drizzle")) {
      return Image(image: AssetImage('images/icons8-rain-cloud-80.png'));
    } else if (description.contains("rain")) {
      return Image(image: AssetImage('images/icons8-heavy-rain-80.png'));
    } else if (description.contains("snow")) {
      return Image(image: AssetImage('images/icons8-snow-80.png'));
    } else {
      return Image(image: AssetImage('images/icons8-windy-weather-80.png'));
    }
  }

  Future<CurrentCityDataModel> SendRequestCurrentWeather(String cityName) async {
    var apikey = '7073333cafd4ed731f86c0107e90616f';

    var response = await Dio().get(
        "https://api.openweathermap.org/data/2.5/weather",
        queryParameters: {'q': cityName, 'appid': apikey, 'units': 'metric'}
    );

    lat = response.data["coord"]["lat"];
    lon = response.data["coord"]["lon"];

    print(response.data);
    print(response.statusCode);

    var datamodel = CurrentCityDataModel(
      response.data["name"],
      response.data["coord"]["lon"],
      response.data["coord"]["lat"],
      response.data["weather"][0]["main"],
      response.data["weather"][0]["description"],
      response.data["main"]["temp"],
      response.data["main"]["temp_min"],
      response.data["main"]["temp_max"],
      response.data["main"]["pressure"],
      response.data["main"]["humidity"],
      response.data["wind"]["speed"],
      response.data["dt"],
      response.data["sys"]["country"],
      response.data["sys"]["sunrise"],
      response.data["sys"]["sunset"],
    );
    return datamodel;
  }

  void SendRequest7DaysForcast(lat, lon) async {
    List<ForecastDaysModel> list = [];
    var appkey = '';
    var response = await Dio().get(
        "http://api.openweathermap.org/data/2.5/onecall",
        queryParameters: {
          'lat': lat,
          'lon': lon,
          'exclude': 'minutly, hourly',
          'appid': appkey,
          'units': 'metric'
        }
    );
    final formatter = DateFormat.MMMd();

    for (int i = 0; i < 8; i++) {
      var model = response.data['daily'][i];

      var dt = formatter.format(DateTime.fromMicrosecondsSinceEpoch(
          model['dt'] * 1000,
          isUtc: true
      ));

      ForecastDaysModel forecastDaysModel = ForecastDaysModel(
          dt, model['temp']['day'], model['weather'][0]['main'],
          model['weather'][0]['description']);

      list.add(forecastDaysModel);
    }
    StreamForcastDays.add(list);

  }



}