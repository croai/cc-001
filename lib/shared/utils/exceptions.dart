class CapacityExceededException implements Exception {
  final String message;
  const CapacityExceededException([
    this.message = 'Capacity exceeded. Tickets are sold out.',
  ]);

  @override
  String toString() => 'CapacityExceededException: $message';
}
