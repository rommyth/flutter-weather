import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future weather;

  Future getCurrentWeather() async {
    try {
      var city = 'Bandung';
      var appid = '8e228993b21988191176f7538c198d4a';
      final res = await http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?q=$city&appid=$appid'));

      final data = jsonDecode(res.body);

      if (data['cod'] != '200') {
        throw 'An unexpected response';
      }

      return data;
    } catch (err) {
      throw err.toString();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    weather = getCurrentWeather();
  }

  @override
  Widget build(BuildContext context) {
    var appBar = AppBar(
      title: const Text(
        'Weather App',
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: () {
            setState(() {
              weather = getCurrentWeather();
            });
          },
          icon: const Icon(Icons.refresh),
        ),
      ],
    );

    return Scaffold(
      appBar: appBar,
      body: FutureBuilder(
        future: weather,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator.adaptive(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }
          final data = snapshot.data;
          final currentWeatherData = data['list'][0];
          final currentTemp = currentWeatherData['main']['temp'];
          final currentSky = currentWeatherData['weather'][0]['main'];
          final currentPressure = currentWeatherData['main']['pressure'];
          final currentWindSpeed = currentWeatherData['wind']['speed'];
          final currentHumidity = currentWeatherData['main']['humidity'];

          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Weather Cartd
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    elevation: 20,
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16))),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(16)),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                '$currentTemp^C',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 32,
                                ),
                              ),
                              SizedBox(height: 8),
                              Icon(
                                Icons.cloud,
                                size: 64,
                              ),
                              SizedBox(height: 8),
                              Text('$currentSky',
                                  style: TextStyle(fontSize: 16))
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // weather forecast card
                const SizedBox(height: 20),
                const Text(
                  'Hourly Forecast',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      final hourlyItem = data['list'][index + 1];
                      final time = DateTime.parse(hourlyItem['dt_txt']);
                      return HourlyForecastItem(
                          time: DateFormat.Hm().format(time),
                          icon: hourlyItem['weather'][0]['main'] == 'Rain'
                              ? Icons.cloud
                              : Icons.sunny,
                          temperature: hourlyItem['main']['temp'].toString());
                    },
                  ),
                ),

                // addtional info
                const SizedBox(height: 20),
                const Text(
                  'Additional Info',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    AdditionalInfoItem(
                        icon: Icons.water_drop,
                        label: 'Humidity',
                        value: currentHumidity.toString()),
                    AdditionalInfoItem(
                        icon: Icons.air,
                        label: 'Wind Speed',
                        value: currentWindSpeed.toString()),
                    AdditionalInfoItem(
                        icon: Icons.beach_access,
                        label: 'Preasure',
                        value: currentPressure.toString()),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class AdditionalInfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const AdditionalInfoItem(
      {super.key,
      required this.icon,
      required this.label,
      required this.value});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        children: [
          Icon(
            icon,
            size: 32,
          ),
          const SizedBox(
            height: 8,
          ),
          Text(label),
          const SizedBox(
            height: 8,
          ),
          Text(value,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))
        ],
      ),
    );
  }
}

class HourlyForecastItem extends StatelessWidget {
  final String time;
  final IconData icon;
  final String temperature;
  const HourlyForecastItem(
      {super.key,
      required this.time,
      required this.icon,
      required this.temperature});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
        child: Column(
          children: [
            Text(
              time,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Icon(icon),
            const SizedBox(height: 8),
            Text(
              '$temperature^C',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
