class File {
  final String path;
  File(this.path);
  Future<File> copy(String path) async => this;
}
