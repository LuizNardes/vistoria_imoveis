class ImageException implements Exception {
  final String message;
  final bool isPermissionError;

  ImageException(this.message, {this.isPermissionError = false});

  @override
  String toString() => message;
}