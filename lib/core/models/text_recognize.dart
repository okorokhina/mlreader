class TextRecognize {
  List<Response> responses;

  TextRecognize({this.responses});

  factory TextRecognize.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson["responses"] as List;
    List<Response> response = list.map((e) => Response.fromJson(e)).toList();

    return TextRecognize(responses: response);
  }
}

class Response {
  List<TextAnnotations> textAnnotations;

  Response({this.textAnnotations});

  factory Response.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson["textAnnotations"] as List;
    List<TextAnnotations> textAnnotation =
        list.map((e) => TextAnnotations.fromJson(e)).toList();

    return Response(textAnnotations: textAnnotation);
  }
}

class TextAnnotations {
  String locale;
  String description;
  BoundingPoly boundingPoly;

  TextAnnotations({this.locale, this.description, this.boundingPoly});

  factory TextAnnotations.fromJson(Map<String, dynamic> parsedJson) {
    return TextAnnotations(
        locale: parsedJson["locale"],
        description: parsedJson["description"],
        boundingPoly: BoundingPoly.fromJson(parsedJson["boundingPoly"]));
  }
}

class BoundingPoly {
  List<Vertices> vertices;

  BoundingPoly({this.vertices});

  factory BoundingPoly.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson["vertices"] as List;
    List<Vertices> vertice = list.map((i) => Vertices.fromJson(i)).toList();

    return BoundingPoly(vertices: vertice);
  }
}

class Vertices {
  int x;
  int y;

  Vertices({this.x, this.y});

  factory Vertices.fromJson(Map<String, dynamic> parseJson) {
    return Vertices(x: parseJson["x"], y: parseJson["y"]);
  }
}
