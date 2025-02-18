class VideoFilter {
  final String name;
  final String command;

  VideoFilter(this.name, this.command);
}

List<VideoFilter> filters = [
  VideoFilter('Sepia', 'colorchannelmixer=0.393:0.769:0.189:0.349:0.686:0.168:0.272:0.534:0.131'),
  VideoFilter('Grayscale', 'hue=s=0'),
  VideoFilter('Invert', 'negate'),
  // Add more filters as needed
];
