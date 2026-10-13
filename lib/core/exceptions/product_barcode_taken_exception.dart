class ProductBarcodeTakenException implements Exception {
  const ProductBarcodeTakenException({required this.msg});
  final String msg;
}
