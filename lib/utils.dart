int cmToInt(double cm) {
  return (cm * 100).round();
}

double intToCm(int x) {
  return x / 100;
}

double intToM(int x) {
  return x / 10000;
}

double intToEuro(int x) {
  return x / 100;
}

int euroToInt(double x) {
  return (x * 100).round();
}
