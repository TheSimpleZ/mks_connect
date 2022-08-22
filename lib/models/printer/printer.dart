class Printer {
  List<Extruder> extruders = [];
  List<Nozzle> nozzles = [];

  Bed bed = Bed();

  List<String> sdCardFiles = [];
}

class Bed with Heatable {}

mixin Heatable {
  int currentTemperature = 0;
  int targetTemperature = 0;
}

class Nozzle with Heatable {}

class Extruder with Heatable {}
