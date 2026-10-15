import 'package:flutter/material.dart';

void main() {
  runApp(DoorInstallerApp());
}

class DoorInstallerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Монтаж Дверей',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Color(0xFFF5F7FA),
      ),
      home: DoorProjectScreen(),
    );
  }
}

class DoorProjectScreen extends StatefulWidget {
  @override
  _DoorProjectScreenState createState() => _DoorProjectScreenState();
}

class _DoorProjectScreenState extends State<DoorProjectScreen> {
  String clientName = "Іван Петренко";
  String orderNumber = "№ 2026-001";

  final List<Map<String, dynamic>> doors = [
    {
      'name': 'Спальня',
      'width': 800.0,
      'height': 2000.0,
      'wallThick': 160.0,
      'boxWidth': 80.0,
      'boxDepth': 40.0,
      'doborWidth': 70.0,
      'openSide': 'Праве',
      'openType': 'Зовнішнє',
      'hingeType': 'Приховані',
      'hingeCount': '3',
      'lockType': 'Магнітний',
      'hasHandle': true,
      'hasLatch': false,
      'hasKey': false,
      'basePrice': 1200.0,
      'extraPrice': 400.0,
    }
  ];

  void _addNewDoor() {
    setState(() {
      doors.add({
        'name': 'Двері ${doors.length + 1}',
        'width': 700.0,
        'height': 2000.0,
        'wallThick': 100.0,
        'boxWidth': 80.0,
        'boxDepth': 40.0,
        'doborWidth': 0.0,
        'openSide': 'Ліві',
        'openType': 'Зовнішнє',
        'hingeType': 'Бабочки',
        'hingeCount': '2',
        'lockType': 'Механічний',
        'hasHandle': true,
        'hasLatch': true,
        'hasKey': false,
        'basePrice': 1000.0,
        'extraPrice': 300.0,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double totalProjectPrice = doors.fold(0, (sum, item) => sum + (item['basePrice'] + item['extraPrice']));

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Замовлення: $orderNumber', style: TextStyle(fontSize: 14)),
            Text('Клієнт: $clientName', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Разом: ${totalProjectPrice.toStringAsFixed(0)} грн',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: doors.length,
        itemBuilder: (context, index) {
          final door = doors[index];
          double doorTotal = (door['basePrice'] as double) + (door['extraPrice'] as double);
          
          return Card(
            margin: EdgeInsets.all(8.0),
            elevation: 2,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blueAccent,
                child: Icon(Icons.door_sliding, color: Colors.white),
              ),
              title: Text(door['name'], style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                'Проріз: ${door['width']}x${door['height']} мм | Стіна: ${door['wallThick']} мм\nКоробка: ${door['boxWidth']}x${door['boxDepth']} мм | Добір: ${door['doborWidth']} мм\nМонтаж: ${doorTotal.toStringAsFixed(0)} грн',
              ),
              isThreeLine: true,
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () async {
                final updatedDoor = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditDoorScreen(doorData: door),
                  ),
                );
                if (updatedDoor != null) {
                  setState(() {
                    doors[index] = updatedDoor;
                  });
                }
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewDoor,
        child: Icon(Icons.add),
        tooltip: 'Додати двері',
      ),
    );
  }
}

class EditDoorScreen extends StatefulWidget {
  final Map<String, dynamic> doorData;
  EditDoorScreen({required this.doorData});

  @override
  _EditDoorScreenState createState() => _EditDoorScreenState();
}

class _EditDoorScreenState extends State<EditDoorScreen> {
  late TextEditingController _nameController;
  late TextEditingController _widthController;
  late TextEditingController _heightController;
  late TextEditingController _wallController;
  late TextEditingController _boxWidthController;
  late TextEditingController _boxDepthController;
  late TextEditingController _doborWidthController;
  
  String _openSide = 'Праве';
  String _openType = 'Зовнішнє';
  String _hingeType = 'Приховані';
  String _hingeCount = '3';
  String _lockType = 'Магнітний';
  
  bool _hasHandle = true;
  bool _hasLatch = false;
  bool _hasKey = false;
  
  double _basePrice = 1200.0;
  double _extraPrice = 400.0;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.doorData['name']);
    _widthController = TextEditingController(text: widget.doorData['width'].toString());
    _heightController = TextEditingController(text: widget.doorData['height'].toString());
    _wallController = TextEditingController(text: widget.doorData['wallThick'].toString());
    _boxWidthController = TextEditingController(text: widget.doorData['boxWidth'].toString());
    _boxDepthController = TextEditingController(text: widget.doorData['boxDepth'].toString());
    _doborWidthController = TextEditingController(text: widget.doorData['doborWidth'].toString());
    
    _openSide = widget.doorData['openSide'];
    _openType = widget.doorData['openType'];
    _hingeType = widget.doorData['hingeType'];
    _hingeCount = widget.doorData['hingeCount'];
    _lockType = widget.doorData['lockType'];
    _hasHandle = widget.doorData['hasHandle'];
    _hasLatch = widget.doorData['hasLatch'];
    _hasKey = widget.doorData['hasKey'];
    _basePrice = widget.doorData['basePrice'];
    _extraPrice = widget.doorData['extraPrice'];
  }

  Map<String, dynamic> calculateMaterials() {
    int architravesPieces = 5; // На дві сторони
    int boxPieces = 3;
    double doborMeters = (double.tryParse(_doborWidthController.text) ?? 0) > 0 ? 5.0 : 0.0;

    return {
      'boxPieces': boxPieces,
      'architravesPieces': architravesPieces,
      'doborMeters': doborMeters,
    };
  }

  @override
  Widget build(BuildContext context) {
    final mats = calculateMaterials();
    double currentWidth = double.tryParse(_widthController.text) ?? 800;
    double currentHeight = double.tryParse(_heightController.text) ?? 2000;
    double currentWall = double.tryParse(_wallController.text) ?? 100;
    double currentBoxW = double.tryParse(_boxWidthController.text) ?? 80;
    double currentBoxD = double.tryParse(_boxDepthController.text) ?? 40;
    double currentDobor = double.tryParse(_doborWidthController.text) ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text('Редагування прорізу та креслення'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              widget.doorData['name'] = _nameController.text;
              widget.doorData['width'] = currentWidth;
              widget.doorData['height'] = currentHeight;
              widget.doorData['wallThick'] = currentWall;
              widget.doorData['boxWidth'] = currentBoxW;
              widget.doorData['boxDepth'] = currentBoxD;
              widget.doorData['doborWidth'] = currentDobor;
              widget.doorData['openSide'] = _openSide;
              widget.doorData['openType'] = _openType;
              widget.doorData['hingeType'] = _hingeType;
              widget.doorData['hingeCount'] = _hingeCount;
              widget.doorData['lockType'] = _lockType;
              widget.doorData['hasHandle'] = _hasHandle;
              widget.doorData['hasLatch'] = _hasLatch;
              widget.doorData['hasKey'] = _hasKey;
              widget.doorData['basePrice'] = _basePrice;
              widget.doorData['extraPrice'] = _extraPrice;
              
              Navigator.pop(context, widget.doorData);
            },
          )
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: 'Назва приміщення (напр. Спальня)'),
          ),
          SizedBox(height: 16),
          Text('Розміри прорізу (мм)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Row(
            children: [
              Expanded(child: TextField(controller: _widthController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Ширина'), onChanged: (v) => setState(() {}))),
              SizedBox(width: 10),
              Expanded(child: TextField(controller: _heightController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Висота'), onChanged: (v) => setState(() {}))),
              SizedBox(width: 10),
              Expanded(child: TextField(controller: _wallController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Товщ. стіни'), onChanged: (v) => setState(() {}))),
            ],
          ),
          SizedBox(height: 12),
          
          Text('Параметри коробки та добору (мм)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Row(
            children: [
              Expanded(child: TextField(controller: _boxWidthController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Ширина коробки'), onChanged: (v) => setState(() {}))),
              SizedBox(width: 10),
              Expanded(child: TextField(controller: _boxDepthController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Товщина коробки'), onChanged: (v) => setState(() {}))),
              SizedBox(width: 10),
              Expanded(child: TextField(controller: _doborWidthController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Ширина добору'), onChanged: (v) => setState(() {}))),
            ],
          ),
          SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _openSide,
                  decoration: InputDecoration(labelText: 'Сторона'),
                  items: ['Праве', 'Ліві'].map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
                  onChanged: (val) => setState(() => _openSide = val!),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _openType,
                  decoration: InputDecoration(labelText: 'Тип відкривання'),
                  items: ['Зовнішнє', 'Внутрішнє'].map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
                  onChanged: (val) => setState(() => _openType = val!),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          
          // Деталізоване 2D креслення з розмірами
          Text('Деталізоване 2D креслення з розмірами', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(height: 8),
          Container(
            height: 240,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.blueGrey, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomPaint(
              painter: DetailedDoorPainter(
                width: currentWidth,
                height: currentHeight,
                wallThick: currentWall,
                boxWidth: currentBoxW,
                doborWidth: currentDobor,
                openSide: _openSide,
                openType: _openType,
              ),
            ),
          ),
          SizedBox(height: 20),

          // Розрахунок матеріалів
          Card(
            color: Colors.blue[50],
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('📦 Розрахунок необхідних матеріалів:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.blue[900])),
                  SizedBox(height: 6),
                  Text('• Коробка: ${mats['boxPieces']} шт. (розмір: ${currentBoxW}x${currentBoxD} мм)'),
                  Text('• Лиштва: ${mats['architravesPieces']} пал. (на дві сторони)'),
                  Text('• Добір: ${mats['doborMeters']} м.п. (ширина: ${currentDobor} мм)'),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
          
          Text('Фурнітура та отвори', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          DropdownButtonFormField<String>(
            value: _hingeType,
            decoration: InputDecoration(labelText: 'Вид петель'),
            items: ['Приховані', 'Бабочки', 'Врізні карткові', 'Штирові'].map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
            onChanged: (val) => setState(() => _hingeType = val!),
          ),
          DropdownButtonFormField<String>(
            value: _hingeCount,
            decoration: InputDecoration(labelText: 'Кількість петель'),
            items: ['2', '3', '4'].map((val) => DropdownMenuItem(value: val, child: Text('$val шт.'))).toList(),
            onChanged: (val) => setState(() => _hingeCount = val!),
          ),
          DropdownButtonFormField<String>(
            value: _lockType,
            decoration: InputDecoration(labelText: 'Вид замка'),
            items: ['Магнітний', 'Механічний (язичок)', 'Під циліндр'].map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
            onChanged: (val) => setState(() => _lockType = val!),
          ),
          
          CheckboxListTile(
            title: Text('Отвори під ручку'),
            value: _hasHandle,
            onChanged: (val) => setState(() => _hasHandle = val!),
          ),
          CheckboxListTile(
            title: Text('Отвори під фіксатор (санвузол)'),
            value: _hasLatch,
            onChanged: (val) => setState(() => _hasLatch = val!),
          ),
          CheckboxListTile(
            title: Text('Отвори під ключ (циліндр)'),
            value: _hasKey,
            onChanged: (val) => setState(() => _hasKey = val!),
          ),
          
          SizedBox(height: 20),
          Text('Ціна за монтаж (грн)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Базова вартість монтажу'),
            controller: TextEditingController(text: _basePrice.toString()),
            onChanged: (val) => _basePrice = double.tryParse(val) ?? 0,
          ),
          TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Додаткові роботи (добори, лиштва тощо)'),
            controller: TextEditingController(text: _extraPrice.toString()),
            onChanged: (val) => _extraPrice = double.tryParse(val) ?? 0,
          ),
        ],
      ),
    );
  }
}

// Детальний відмальовник креслення з лінійками розмірів (знизу, зверху, зліва, справа)
class DetailedDoorPainter extends CustomPainter {
  final double width;
  final double height;
  final double wallThick;
  final double boxWidth;
  final double doborWidth;
  final String openSide;
  final String openType;

  DetailedDoorPainter({
    required this.width,
    required this.height,
    required this.wallThick,
    required this.boxWidth,
    required this.doborWidth,
    required this.openSide,
    required this.openType,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paintWall = Paint()
      ..color = Colors.blueGrey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final paintDoor = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final paintText = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // Центруємо схему прорізу всередині віджету
    final double rectLeft = size.width * 0.25;
    final double rectTop = size.height * 0.2;
    final double rectWidth = size.width * 0.5;
    final double rectHeight = size.height * 0.6;

    final rect = Rect.fromLTWH(rectLeft, rectTop, rectWidth, rectHeight);
    
    // Малюємо рамку прорізу
    canvas.drawRect(rect, paintWall);

    // Малюємо дугу відкривання дверей всередині
    Path path = Path();
    if (openSide == 'Праве') {
      if (openType == 'Зовнішнє') {
        path.moveTo(rect.right, rect.bottom);
        path.arcToPoint(Offset(rect.right, rect.top), radius: Radius.circular(rect.height), clockwise: false);
      } else {
        path.moveTo(rect.right, rect.top);
        path.arcToPoint(Offset(rect.right, rect.bottom), radius: Radius.circular(rect.height), clockwise: false);
      }
    } else {
      if (openType == 'Зовнішнє') {
        path.moveTo(rect.left, rect.bottom);
        path.arcToPoint(Offset(rect.left, rect.top), radius: Radius.circular(rect.height), clockwise: true);
      } else {
        path.moveTo(rect.left, rect.top);
        path.arcToPoint(Offset(rect.left, rect.bottom), radius: Radius.circular(rect.height), clockwise: true);
      }
    }
    canvas.drawPath(path, paintDoor);

    // Функція виведення тексту розмірів
    void drawDimension(String text, double x, double y, {bool vertical = false}) {
      paintText.text = TextSpan(
        text: text,
        style: TextStyle(color: Colors.black87, fontSize: 10, fontWeight: FontWeight.bold),
      );
      paintText.layout();
      canvas.save();
      canvas.translate(x, y);
      if (vertical) {
        canvas.rotate(-math.pi / 2);
      }
      paintText.paint(canvas, Offset(-paintText.width / 2, -paintText.height / 2));
      canvas.restore();
    }

    // Розмір ЗНИЗУ (Ширина прорізу)
    drawDimension('Шир: ${width.toStringAsFixed(0)} мм', rect.center.dx, rect.bottom + 15);
    // Розмір ЗВЕРХУ (Коробка та добір)
    drawDimension('Коробка: ${boxWidth.toStringAsFixed(0)}мм | Добір: ${doborWidth.toStringAsFixed(0)}мм', rect.center.dx, rect.top - 15);
    // Розмір ЗЛІВА (Висота прорізу)
    drawDimension('Висота: ${height.toStringAsFixed(0)} мм', rect.left - 22, rect.center.dy, vertical: true);
    // Розмір СПРАВА (Товщина стіни)
    drawDimension('Стіна: ${wallThick.toStringAsFixed(0)} мм', rect.right + 22, rect.center.dy, vertical: true);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Допоміжний клас для математичного обертання тексту на лінійках
class math {
  static const double pi = 3.1415926535897932;
}
