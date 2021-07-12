import 'package:duration/duration.dart';

enum RecipeType {
  food,
  drink,
}

class Recipe {
  String id;
  RecipeType type;
  String name;
  Duration duration;
  List<String> ingredients;
  List<String> preparation;
  String imageURL;

  Recipe({
    this.id,
    this.type,
    this.name,
    this.duration,
    this.ingredients,
    this.preparation,
    this.imageURL,
  });

  String get getDurationString => prettyDuration(this.duration);

  Recipe.fromMap(Map<String, dynamic> data, String id)
      : this(
          id: id,
          type: RecipeType.values[data['type']],
          name: data['name'],
          duration: Duration(minutes: data['duration']),
          ingredients: new List<String>.from(data['ingredients']),
          preparation: new List<String>.from(data['preparation']),
          imageURL: data['imageURL'],
        );
}
