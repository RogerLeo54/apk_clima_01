import 'package:apk_clima_01/consts.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:weather/weather.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Homepage(),
    );
  }
}

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomePageState();
}

class _HomePageState extends State<Homepage> {
  final WeatherFactory _wf = WeatherFactory(OPENWEATHER_API_KEY);
  Weather? _weather;
  List<Weather>? _forecast;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    setState(() {
      _isLoading = true;
    });

    try {
      Position position = await determinePosition();
      final weather = await _wf.currentWeatherByLocation(position.latitude, position.longitude);
      final forecast = await _wf.fiveDayForecastByLocation(position.latitude, position.longitude);

      setState(() {
        _weather = weather;
        _forecast = forecast.take(3).toList();
      });
    } catch (e) {
      print('Error al cargar el clima: $e');
      setState(() {
        _weather = null;
        _forecast = null;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<Position> determinePosition() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Los permisos están denegados permanentemente');
      }
    }
    if (permission == LocationPermission.denied) {
      throw Exception('Permiso de ubicación denegado');
    }
    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clima 360'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadWeather,
          ),
        ],
      ),
      body: _isLoading ? _loadingIndicator() : _buildUI(),
      backgroundColor: const Color(0xFF92ABFD),
    );
  }

  Widget _loadingIndicator() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildUI() {
    if (_weather == null || _forecast == null) {
      return const Center(child: Text("No se ha podido cargar el clima"));
    }

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _locationHeader(),
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.08),
            _dateTimeInfo(),
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.05),
            _weatherIcon(),
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.02),
            _currentTemp(),
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.02),
            _extraInfo(),
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.05),
            _navigateButton(),
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.05),
            _refreshButton(),
          ],
        ),
      ),
    );
  }

  Widget _locationHeader() {
    return Text(
      _weather?.areaName ?? "Ubicación no disponible",
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
    );
  }

  Widget _dateTimeInfo() {
    DateTime now = _weather!.date!;
    return Column(
      children: [
        Text(
          DateFormat("h:mm a").format(now),
          style: const TextStyle(fontSize: 35),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              DateFormat("EEEE").format(now),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            Text(
              " ${DateFormat("d.M.y").format(now)}",
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ],
    );
  }

  Widget _weatherIcon() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: MediaQuery.sizeOf(context).height * 0.20,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                  "https://openweathermap.org/img/wn/${_weather?.weatherIcon}@4x.png"),
            ),
          ),
        ),
        Text(
          _weather?.weatherDescription ?? "",
          style: const TextStyle(color: Colors.black, fontSize: 20),
        ),
      ],
    );
  }

  Widget _currentTemp() {
    return Text(
      "${_weather?.temperature?.celsius?.toStringAsFixed(0)}° C",
      style: const TextStyle(
        color: Colors.black,
        fontSize: 90,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _extraInfo() {
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.15,
      width: MediaQuery.sizeOf(context).width * 0.80,
      decoration: BoxDecoration(
        color: const Color(0x4FF0F0F0),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                "Max: ${_weather?.tempMax?.celsius?.toStringAsFixed(0)}° C",
                style: const TextStyle(color: Colors.black, fontSize: 15),
              ),
              Text(
                "Min: ${_weather?.tempMin?.celsius?.toStringAsFixed(0)}° C",
                style: const TextStyle(color: Colors.black, fontSize: 15),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                "Viento: ${_weather?.windSpeed?.toStringAsFixed(0)} m/s",
                style: const TextStyle(color: Colors.black, fontSize: 15),
              ),
              Text(
                "Humedad: ${_weather?.humidity?.toStringAsFixed(0)}%",
                style: const TextStyle(color: Colors.black, fontSize: 15),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _refreshButton() {
    return ElevatedButton.icon(
      onPressed: _isLoading ? null : _loadWeather,
      icon: const Icon(Icons.refresh),
      label: const Text("Actualizar clima"),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        textStyle: const TextStyle(fontSize: 18),
      ),
    );
  }

  Widget _navigateButton() {
    return ElevatedButton(
      onPressed: () {
        if (_forecast != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ForecastPage(forecast: _forecast),
            ),
          );
        }
      },
      child: const Text("Ver Pronóstico"),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        textStyle: const TextStyle(fontSize: 18),
        backgroundColor: Colors.blueAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

class ForecastPage extends StatelessWidget {
  final List<Weather>? forecast;

  const ForecastPage({super.key, required this.forecast});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pronóstico del Clima'),
      ),
      body: _buildForecastUI(),
      backgroundColor: const Color(0xFF92ABFD),
    );
  }

  Widget _buildForecastUI() {
    if (forecast == null || forecast!.isEmpty) {
      return const Center(child: Text("No hay pronóstico disponible"));
    }

    return ListView.builder(
      itemCount: forecast!.length,
      itemBuilder: (context, index) {
        final dayForecast = forecast![index];
        DateTime forecastDate = DateTime.now().add(Duration(days: index + 1));
        return ListTile(
          title: Text(
            DateFormat('EEEE').format(forecastDate),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            "${dayForecast.weatherDescription}, Max: ${dayForecast.tempMax?.celsius?.toStringAsFixed(0)}° C, Min: ${dayForecast.tempMin?.celsius?.toStringAsFixed(0)}° C",
          ),
          trailing: Image.network(
            "https://openweathermap.org/img/wn/${dayForecast.weatherIcon}@2x.png",
            height: 50,
            width: 50,
          ),
        );
      },
    );
  }
}
