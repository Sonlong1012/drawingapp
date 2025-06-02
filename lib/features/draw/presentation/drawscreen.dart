import 'dart:nativewrappers/_internal/vm/lib/developer.dart';

import 'package:drawingapp/features/draw/models/stroke.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class DrawScreen extends StatefulWidget {
  const DrawScreen({super.key});

  @override
 State<DrawScreen> createState() => _DrawScreenState();
  
}



class _DrawScreenState extends State<DrawScreen> {
  
    List<Stroke> _strokes = [];
    List<Stroke> _redoStokes = [];
    List<Offset> _currentPoints = [];
    Color _selectedColor = Colors.black;
    double _brushSize = 4.0;
    late Box<List<Stroke>> _drawingBox;


    @override
void initState() {
  _initializeHive();
    super.initState();
  }

  _initializeHive() {
    _drawingBox = Hive.box<List<Stroke>>('drawings');
  }

   Future<void> _saveDrawing(String name) async {
      await _drawingBox.put(name, _strokes);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content:Text('Drawing $name saved!'),)
        );
   }

  void _showSaveDialog() {
    final TextEditingController _controller = TextEditingController();
    showDialog(
      context: context, 
      builder: (context) {
        return AlertDialog(
          title: const Text('Save Drawing'),
          content: TextField(
            controller: _controller,
            decoration: const InputDecoration(hintText: 'Enter drawing name'),
          ),
          actions: [
            TextButton(
              onPressed:(){
                Navigator.of(context).pop();
              } , 
              child: Text('Cancel')
              ),
              TextButton(
              onPressed:(){
                final name = _controller.text.trim();
                if(name.isNotEmpty){
                  _saveDrawing(name);
                  Navigator.of(context).pop();
                }
              } , 
              child: Text('Save')
              ),
          ],
        );
      }
      );
  }

  @override
  void dispone() {
    Hive.close(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(
        title: const Text("Draw Your Dream"),
      ),
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onPanStart:(details) {
                setState(() {
                  _currentPoints.add(details.localPosition);
                });
              },
              onPanUpdate: (details){
                setState(() {
                  _currentPoints.add(details.localPosition);
                });
              },
              onPanEnd: (details) {
                setState(() {
                  _strokes.add(
                    Stroke.fromOffsets(
                      points: List.from(_currentPoints), 
                      
                      color: _selectedColor, 
                      brushSize: _brushSize
                    ),
                  );
                  _currentPoints = [];
                  _redoStokes = [];
                });
              },
              child: CustomPaint(
                painter: DrawPainter(
                  strokes: _strokes, 
                  currentPoints: _currentPoints, 
                  currentColor: _selectedColor, 
                  currentBrushSize: _brushSize
                ),
              ),
            ),
          ),
          _buildToolBar(),

        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showSaveDialog,
        child: const Icon(Icons.save),
        ),
    );
  }
  Widget _buildToolBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey[200],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          /// _strokes = [A,B]
          IconButton(
            onPressed:  _redoStokes.isNotEmpty ? (){
              setState(() {
                _strokes.add(_redoStokes.removeLast());
              });
            } : null,
            icon: const Icon(Icons.redo)
            ),

            // Brush Size dropdown 
            DropdownButton(
              value: _brushSize,
              items: [
                DropdownMenuItem(
                  value: 2.0,
                  child: Text('Small')
                  ),
                DropdownMenuItem(
                  value: 4.0,
                  child: Text('Medium')
                  ),
                 DropdownMenuItem(
                  value: 8.0,
                  child: Text('Small')
                  ),
              ], 
              onChanged: (value) {
                setState(() {
                  _brushSize = value!;
                });
              }
              ),

              // Color Picker
              Row(
                children: [
                    _buildColorButton(Colors.black),
                    _buildColorButton(Colors.red),
                    _buildColorButton(Colors.blue),
                    _buildColorButton(Colors.green),
                ],
              ),
        ],
      ),
    );
  }

    Widget _buildColorButton(Color color) {
      return GestureDetector(
        onTap: (){
          setState(() {
            _selectedColor = color;
          });
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color, 
            shape: BoxShape.circle,
            border: Border.all(
              color: _selectedColor == color ? Colors.grey : Colors.transparent,
              width: 2
            )
          ),
        ),
      );
    }


}


class DrawPainter extends CustomPainter {
  final List<Stroke> strokes; 
  final List<Offset> currentPoints;
  final Color currentColor; 
  final double currentBrushSize;

  DrawPainter({super.repaint, required this.strokes, required this.currentPoints,required this.currentColor, required this.currentBrushSize});

  @override
  void paint(Canvas canvas, Size size) {
    for(final stroke in strokes) {
      final paint = Paint() 
          ..color = stroke.strokeColor
          ..strokeCap = StrokeCap.round
          ..strokeWidth = stroke.brushSize;
          
    final points = stroke.offsetPoints;
    for(int i=0; i < stroke.points.length-1; i++) {
      if(points[i] != Offset.zero && points[i+1] != Offset.zero){
        canvas.drawLine(points[i], points[i+1],paint);
      }
    }
    }

    final paint = Paint()
      ..color = currentColor
      ..strokeCap = StrokeCap.round
      ..strokeWidth = currentBrushSize;
      for(int i=0; i < currentPoints.length-1; i++) {
      if(currentPoints[i] != Offset.zero && currentPoints[i+1] != Offset.zero){
        canvas.drawLine(currentPoints[i], currentPoints[i+1],paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
  
}