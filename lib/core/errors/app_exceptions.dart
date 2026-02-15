class ImageFailure implements Exception {
  final String message;
  ImageFailure(this.message);
  @override
  String toString() => message;
}