import 'package:flutter/material.dart';
import 'dart:async';
import 'package:easy_geofencing/easy_geofencing.dart';
import 'package:easy_geofencing/enums/geofence_status.dart';
import 'package:geolocator/geolocator.dart';




void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Easy Geofencing',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Easy Geofencing'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, this.title});

  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  StreamSubscription<GeofenceStatus>? geofenceStatusStream;
  Geolocator geolocator = Geolocator();
  String geofenceStatus = '';
  String status = '';
  bool isReady = false;
  Position? position;

  // Definir a localização e o raio diretamente no código
  final double definedLatitude = -22.355431;  // Latitude de exemplo (São Francisco)
  final double definedLongitude =  -47.334057;  // Longitude de exemplo (São Francisco)
  final double definedRadius = 50;  // Raio em metros

  @override
  void initState() {
    super.initState();
    getCurrentPosition();  // Obter a posição atual ao iniciar o aplicativo.
    EasyGeofencing.startGeofenceService(
      pointedLatitude: definedLatitude.toString(),
      pointedLongitude: definedLongitude.toString(),
      radiusMeter: definedRadius.toString(),
      eventPeriodInSeconds: 5,
    );

    // Iniciar o stream para escutar os status de geofencing
    geofenceStatusStream = EasyGeofencing.getGeofenceStream()!
        .listen((GeofenceStatus status) {
      setState(() {
        geofenceStatus = status.name;
      });
    });
  }

  // Função para obter a posição atual
  getCurrentPosition() async {
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    print("LOCATION => ${position!.toJson()}");
    isReady = (position != null) ? true : false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title!),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              if (isReady) {
                setState(() {
                  getCurrentPosition();
                });
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: <Widget>[
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text("Verificar Localização"),
              onPressed: () {
                if (isReady) {
                  // Verificar se o usuário está dentro da área definida usando o status do geofencing
                  if (geofenceStatus == "enter") {
                    setState(() {
                      status = "Você está dentro da área definida!";
                    });
                  } else {
                    setState(() {
                      status = "Você está fora da área definida!";
                    });
                  }
                }
              },
            ),
            const SizedBox(height: 20),
            Text(
              "Status da Localização: \n\n\n${status}",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    if (geofenceStatusStream != null) {
      geofenceStatusStream!.cancel(); // Cancelar o stream ao sai
    }
  }
}