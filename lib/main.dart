import 'package:flutter/material.dart';
import 'dart:math' as math;

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
                'Проріз: ${door['width']}x${door['height']} мм | Стіна: ${door['wallThick']} мм\nВідкривання: ${door['openSide']}, ${door['openType']}\nМонтаж: ${doorTotal.toStringAsFixed(0)} грн',
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

  // Розрахунок матеріалів
  Map<String, dynamic> calculateMaterials() {
    double w = double.tryParse(_widthController.text) ?? 800;
    double h = double.tryParse(_heightController.text) ?? 2000;
    double wall = double.tryParse(_wallController.text) ?? 100;

    // Стандартна ширина коробки зазвичай 70-80 мм
    double standardBoxWidth = 80.0;
    
    // Кількість лиштви: 2 сторони по (2 вертикальні палиці висотою біля 2.1м + 1 горизонтальна біля 1м) -> в комплекті зазвичай 2.5 шт на бік, разом 5 шт на двері (або в пачках по 2.5м)
    int architravesPieces = 5; // 5 палок лиштви на дві сторони

    // Коробка: 2.5 палки на стандартний блок (2 стійки + поріг/притолока)
    int boxPieces = 3;

    // Добори: якщо стіна товща за коробку (наприклад, > 90-100мм), потрібен добір
    double needDoborWidth = wall - 90;
    if (needDoborWidth < 0) needDoborWidth = 0;
    
    // Кількість добірної дошки (погонні метри: 2 стійки + 1 поперечина = приблизно 5 м.п.)
    double doborMeters = needDoborWidth > 0 ? 5.0 : 0.0;

    return {
      'boxPieces': boxPieces,
      'architravesPieces': architravesPieces,
      'doborWidth': needDoborWidth > 0 ? needDoborWidth : 0.0,
      'doborMeters': doborMeters,
    };
  }

  @override
  Widget build(BuildContext context) {
    final mats = calculateMaterials();

    return Scaffold(
      appBar: AppBar(
        title: Text('Редагування прорізу'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              widget.doorData['name'] = _nameController.text;
              widget.doorData['width'] = double.tryParse(_widthController.text) ?? 800;
              widget.doorData['height'] = double.tryParse(_heightController.text) ?? 2000;
              widget.doorData['wallThick'] = double.tryParse(_wallController.text) ?? 100;
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
              Expanded(child: TextField(controller: _widthController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Ширина'))),
              SizedBox(width: 10),
              Expanded(child: TextField(controller: _heightController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Висота'))),
              SizedBox(width: 10),
              Expanded(child: TextField(controller: _wallController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Товщ. стіни'))),
            ],
          ),
          SizedBox(height: 16),
          
          // Вибір відкривання
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
          
          // 2D Креслення та Візуалізація
          Text('Візуальне 2D креслення прорізу', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(height: 8),
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.blueGrey, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomPaint(
              painter: Door2DPainter(
                openSide: _openSide,
                openType: _openType,
              ),
              child: Center(
                child: Text(
                  '${_widthController.text} x ${_heightController.text} мм\n(Стіна: ${_wallController.text} мм)',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, backgroundColor: Colors.white70),
                ),
              ),
            ),
          ),
          SizedBox(height: 20),

          // Калькуляція матеріалів
          Card(
            color: Colors.blue[50],
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('📦 Розрахунок необхідних матеріалів:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.blue[900])),
                  SizedBox(height: 6),
                  Text('• Коробка: ${mats['boxPieces']} шт. (стандартна ширина ~80 мм)'),
                  Text('• Лиштва: ${mats['architravesPieces']} пал. (на обидві сторони)'),
                  Text('• Добори: ${mats['doborMeters']} м.п. (ширина добору: ${mats['doborWidth']} мм)'),
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
            onChanged: (val) => _extraPrice = double.tryScale ?? double.tryParse(val) ?? 0,
          ),
        ],
      ),
    );
  }
}

// Допоміжний клас для малювання 2D креслення прорізу та відкривання
class Door2DPainter extends CustomPainter {
  final String openSide;
  final String openType;

  Door2DPainter({required this.openSide, required this.openType});

  @override
  void paint(Canvas canvas, Size size) {
    final paintWall = Paint()
      ..color = Colors.blueGrey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    final paintDoor = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final rect = Rect.fromLTWH(size.width * 0.25, size.height * 0.15, size.width * 0.5, size.height * 0.7);
    
    // Малюємо стіни / проріз
    canvas.drawRect(rect, paintWall);

    // Малюємо схему відкривання полотна
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
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
