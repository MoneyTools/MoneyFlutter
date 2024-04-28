import 'package:money/helpers/list_helper.dart';
import 'package:money/helpers/misc_helpers.dart';
import 'package:money/storage/data/data.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:image/image.dart';
import 'dart:math';

Future<void> importOCR(
  final String filePath,
  final Data data,
) async {
  File imageFile = File(filePath);

  Uint8List imageBytes = imageFile.readAsBytesSync();
  Image? image = decodePng(imageBytes);
  if (image == null) {
    return; // Problem
  }

  Image grayscaleImage = grayscale(image);
  Image binaryImage = luminanceThreshold(grayscaleImage);
  final List<Blob> blobs = extractBlobs(binaryImage);

  // Initialize an empty string to store the recognized text.
  String recognizedText = "";

  // Iterate through each blob and try to recognize characters.
  for (var blob in blobs) {
    if (matchesTemplate(blob.pixels, templateA)) {
      recognizedText += 'A';
    } else if (matchesTemplate(blob.pixels, templateB)) {
      recognizedText += 'B';
    }
  }
  debugLog(recognizedText);
}

// A
List<List<int>> templateA = [
  [0, 0, 1, 1, 1, 0, 0],
  [0, 1, 1, 0, 1, 1, 0],
  [0, 1, 1, 0, 1, 1, 0],
  [1, 1, 0, 0, 0, 1, 1],
  [1, 1, 1, 1, 1, 1, 1],
  [1, 0, 0, 0, 0, 0, 1],
  [1, 0, 0, 0, 0, 0, 1],
];

// B
List<List<int>> templateB = [
  [1,1,1,1,1,1,1,1,1,1,1,0],
  [1,1,1,1,1,1,1,1,1,1,1,1],
  [1,1,1,0,0,0,0,0,1,1,1,1],
  [1,1,1,0,0,0,0,0,0,1,1,1],
  [1,1,1,0,0,0,0,1,1,1,1,0],
  [1,1,1,1,1,1,1,1,1,1,0,0],
  [1,1,1,1,1,1,1,1,1,1,1,1],
  [1,1,1,0,0,0,0,0,0,1,1,1],
  [1,1,1,0,0,0,0,0,0,1,1,1],
  [1,1,1,0,0,0,0,0,0,1,1,1],
  [1,1,1,1,1,1,1,1,1,1,1,1],
  [1,1,1,1,1,1,1,1,1,1,1,0],
];

// C
List<List<int>> templateC = [
  [0, 1, 1, 1, 0],
  [1, 0, 0, 0, 1],
  [1, 0, 0, 0, 0],
  [1, 0, 0, 0, 0],
  [1, 0, 0, 0, 0],
  [1, 0, 0, 0, 1],
  [0, 1, 1, 1, 0],
];

// Function to recognize characters 'A' and 'B' from blobs.
String recognizeCharacters(List<Blob> blobs) {
  String recognizedText = '';

  for (var blob in blobs) {
    if (matchesTemplate(blob.pixels, templateA)) {
      recognizedText += 'A';
    } else if (matchesTemplate(blob.pixels, templateB)) {
      recognizedText += 'B';
    } else if (matchesTemplate(blob.pixels, templateC)) {
      recognizedText += 'C';
    }
  }

  return recognizedText;
}

const res = 12;

// Function to normalize and compare a blob against a 3x3 template.
bool matchesTemplate(List<Point> blobPixels, List<List<int>> template) {
  // Get the bounding box of the blob.
  int minX = blobPixels.map((p) => p.x).reduce(min).toInt();
  int maxX = blobPixels.map((p) => p.x).reduce(max).toInt();
  int minY = blobPixels.map((p) => p.y).reduce(min).toInt();
  int maxY = blobPixels.map((p) => p.y).reduce(max).toInt();


  // Calculate the scale factors for x and y dimensions.
  double scaleX = res / (maxX - minX + 1);
  double scaleY = res / (maxY - minY + 1);

  // Create a 3x3 grid to represent the normalized blob's pixels.
  List<List<int>> normalizedBlobGrid = List.generate(res, (_) => List.filled(res, 0));

  // Map the blob's pixels to the normalized 3x3 grid.
  for (var pixel in blobPixels) {
    int normalizedX = ((pixel.x - minX) * scaleX).floor();
    int normalizedY = ((pixel.y - minY) * scaleY).floor();
    normalizedBlobGrid[normalizedY][normalizedX] = 1;
  }

  final resizedTemplate = resizeMatrix(template, res, res);

  for (int y = 0; y < res; y++) {
    debugLog('${zeroOneToLineBlock(normalizedBlobGrid[y])}');
  }
  debugLog('-------------------------------------');
  for (int y = 0; y < res; y++) {
    debugLog('${zeroOneToLineBlock(resizedTemplate[y])}');
  }
  debugLog('---------------');


  // Compare the normalized blob grid with the template.
  for (int y = 0; y < res; y++) {
    int reduceY = y; // ~/ 5;
    // debugLog('${normalizedBlobGrid[y]} ${template[reduceY]}');
    for (int x = 0; x < res; x++) {
      final v1 = normalizedBlobGrid[y][x];

      int reduceX = x; // ~/ 5;
      final v2 = template[reduceY][reduceX];
      // debugLog('$v1 $v2');
      if (v1 != v2) {
        debugLog('failed at row $y');
        return false; // The blob does not match the template.
      }
    }
  }

  return true; // The blob matches the template.
}

class Blob {
  List<Point> pixels = [];

  void addPixel(int row, int col) {
    pixels.add(Point(col, row));
  }

// You can add more properties like bounding box, centroid, etc.
}

// Example function to extract blobs from a binary image.
List<Blob> extractBlobs(Image binaryImage) {
  final int width = binaryImage.width;
  final int height = binaryImage.height;
  final List<Blob> blobs = [];

  // Initialize a 2D array to track visited pixels.
  final List<List<bool>> visited = List.generate(
    height,
    (_) => List.filled(width, false),
  );

  // Define 4-connectivity neighbors (up, down, left, right).
  final List<List<int>> neighbors = [
    [-1, 0], // Up
    [1, 0], // Down
    [0, -1], // Left
    [0, 1], // Right
  ];

  void dfs(int row, int col, Blob currentBlob) {
    if (row < 0 || row >= height || col < 0 || col >= width) {
      return;
    }

    if (visited[row][col] || binaryImage.getPixel(col, row).toString() != '(0, 0, 0, 255)') {
      return;
    }

    visited[row][col] = true;
    currentBlob.addPixel(row, col);

    for (final neighbor in neighbors) {
      final newRow = row + neighbor[0];
      final newCol = col + neighbor[1];
      dfs(newRow, newCol, currentBlob);
    }
  }

  for (int row = 0; row < height; row++) {
    for (int col = 0; col < width; col++) {
      // debugLog(binaryImage.getPixel(col, row).toString());
      if (!visited[row][col] && binaryImage.getPixel(col, row).toString() != '(255, 255, 255, 255)') {
        final Blob blob = Blob();
        dfs(row, col, blob);
        blobs.add(blob);
      }
    }
  }

  return blobs;
}

String zeroOneToLineBlock(final List<int> input){
  return input.join('').replaceAll('0','◾️').replaceAll('1', '🟦');
}

List<List<List<int>>> getPatterns() {
  return [
    // A
    [
      [0, 1, 0],
      [1, 1, 1],
      [1, 0, 1],
      [1, 1, 1],
      [1, 0, 1]
    ],
    // B
    [
      [1, 1, 0],
      [1, 0, 1],
      [1, 1, 0],
      [1, 0, 1],
      [1, 1, 0]
    ],
    // C
    [
      [0, 1, 1],
      [1, 0, 0],
      [1, 0, 0],
      [1, 0, 0],
      [0, 1, 1]
    ],
    // D
    [
      [1, 1, 0],
      [1, 0, 1],
      [1, 0, 1],
      [1, 0, 1],
      [1, 1, 0]
    ],
    // E
    [
      [1, 1, 1],
      [1, 0, 0],
      [1, 1, 0],
      [1, 0, 0],
      [1, 1, 1]
    ],
    // F
    [
      [1, 1, 1],
      [1, 0, 0],
      [1, 1, 0],
      [1, 0, 0],
      [1, 0, 0]
    ],
    // G
    [
      [0, 1, 1],
      [1, 0, 0],
      [1, 0, 1],
      [1, 0, 1],
      [0, 1, 1]
    ],
    // H
    [
      [1, 0, 1],
      [1, 0, 1],
      [1, 1, 1],
      [1, 0, 1],
      [1, 0, 1]
    ],
    // I
    [
      [1, 1, 1],
      [0, 1, 0],
      [0, 1, 0],
      [0, 1, 0],
      [1, 1, 1]
    ],
    // J
    [
      [1, 1, 1],
      [0, 0, 1],
      [0, 0, 1],
      [1, 0, 1],
      [0, 1, 0]
    ],
    // K
    [
      [1, 0, 1],
      [1, 0, 1],
      [1, 1, 0],
      [1, 0, 1],
      [1, 0, 1]
    ],
    // L
    [
      [1, 0, 0],
      [1, 0, 0],
      [1, 0, 0],
      [1, 0, 0],
      [1, 1, 1]
    ],
    // M
    [
      [1, 0, 1],
      [1, 1, 1],
      [1, 1, 1],
      [1, 0, 1],
      [1, 0, 1]
    ],
    // N
    [
      [1, 0, 1],
      [1, 0, 1],
      [1, 1, 1],
      [1, 1, 1],
      [1, 0, 1]
    ],
    // O
    [
      [0, 1, 0],
      [1, 0, 1],
      [1, 0, 1],
      [1, 0, 1],
      [0, 1, 0]
    ],
    // P
    [
      [1, 1, 0],
      [1, 0, 1],
      [1, 1, 0],
      [1, 0, 0],
      [1, 0, 0]
    ],
    // Q
    [
      [0, 1, 0],
      [1, 0, 1],
      [1, 0, 1],
      [1, 1, 0],
      [0, 0, 1]
    ],
    // R
    [
      [1, 1, 0],
      [1, 0, 1],
      [1, 1, 0],
      [1, 0, 1],
      [1, 0, 1]
    ],
    // S
    [
      [0, 1, 1],
      [1, 0, 0],
      [0, 1, 0],
      [0, 0, 1],
      [1, 1, 0]
    ],
    // T
    [
      [1, 1, 1],
      [0, 1, 0],
      [0, 1, 0],
      [0, 1, 0],
      [0, 1, 0]
    ],
    // U
    [
      [1, 0, 1],
      [1, 0, 1],
      [1, 0, 1],
      [1, 0, 1],
      [0, 1, 0]
    ],
    // V
    [
      [1, 0, 1],
      [1, 0, 1],
      [1, 0, 1],
      [1, 0, 1],
      [0, 1, 0]
    ],
    // W
    [
      [1, 0, 1],
      [1, 0, 1],
      [1, 1, 1],
      [1, 1, 1],
      [1, 0, 1]
    ],
    // X
    [
      [1, 0, 1],
      [1, 0, 1],
      [0, 1, 0],
      [1, 0, 1],
      [1, 0, 1]
    ],
    // Y
    [
      [1, 0, 1],
      [1, 0, 1],
      [0, 1, 0],
      [0, 1, 0],
      [0, 1, 0]
    ],
    // Z
    [
      [1, 1, 1],
      [0, 0, 1],
      [0, 1, 0],
      [1, 0, 0],
      [1, 1, 1]
    ],
    // 0
    [
      [0, 1, 0],
      [1, 0, 1],
      [1, 0, 1],
      [1, 0, 1],
      [0, 1, 0]
    ],
    // 1
    [
      [0, 1, 0],
      [1, 1, 0],
      [0, 1, 0],
      [0, 1, 0],
      [1, 1, 1]
    ],
    // 2
    [
      [1, 1, 1],
      [0, 0, 1],
      [0, 1, 0],
      [1, 0, 0],
      [1, 1, 1]
    ],
    // 3
    [
      [1, 1, 1],
      [0, 0, 1],
      [0, 1, 0],
      [0, 0, 1],
      [1, 1, 1]
    ],
    // 4
    [
      [1, 0, 1],
      [1, 0, 1],
      [1, 1, 1],
      [0, 0, 1],
      [0, 0, 1]
    ],
    // 5
    [
      [1, 1, 1],
      [1, 0, 0],
      [1, 1, 1],
      [0, 0, 1],
      [1, 1, 1]
    ],
    // 6
    [
      [0, 1, 1],
      [1, 0, 0],
      [1, 1, 1],
      [1, 0, 1],
      [0, 1, 0]
    ],
    // 7
    [
      [1, 1, 1],
      [0, 0, 1],
      [0, 1, 0],
      [1, 0, 0],
      [1, 0, 0]
    ],
    // 8
    [
      [0, 1, 0],
      [1, 0, 1],
      [0, 1, 0],
      [1, 0, 1],
      [0, 1, 0]
    ],
    // 9
    [
      [0, 1, 0],
      [1, 0, 1],
      [0, 1, 1],
      [0, 0, 1],
      [0, 1, 0]
    ],
  ];
}
