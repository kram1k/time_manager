import 'dart:math' as math;

class ClockTicks {
  static const hourStep = 2 * math.pi / 24;

  static List<double> get large => [0, 6*hourStep, 12*hourStep, 18*hourStep];
  static List<double> get allHours => List.generate(24, (i) => i * hourStep);
  static List<double> get medium => allHours.where((a) => !large.contains(a)).toList();
  
  static List<double> small({int ticksBetweenHours = 3}) {
    final sorted = [...allHours].map((a) => (a % (2*math.pi) + 2*math.pi) % (2*math.pi)).toList()..sort();
    List<double> result = [];
    for(int i=0; i<sorted.length; i++){
      double curr = sorted[i], next = sorted[(i+1)%sorted.length];
      double diff = next - curr; if(diff <= 0) diff += 2*math.pi;
      double step = diff / (ticksBetweenHours + 1);
      for(int k=1; k<=ticksBetweenHours; k++) {
        result.add(curr + step * k);
      }
    }
    return result;
  }
}
