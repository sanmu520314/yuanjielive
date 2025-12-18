class MusicInfo {
  int index;
  String name;
  String path;

  MusicInfo(this.index, this.name, this.path);

  MusicInfo clone() => MusicInfo(index, name, path);
}
