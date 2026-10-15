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
      home: OrdersListScreen(),
    );
  }
}

// 1. Екран списку замовлень (проєктів)
class OrdersListScreen extends StatefulWidget {
  @override
  _OrdersListScreenState createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends State<OrdersListScreen> {
  final List<Map<String, dynamic>> orders = [
    {
      'orderNumber': '№ 2026-001',
      'clientName': 'Іван Петренко',
      'address': 'вул. Шевченка, 10',
      'doors': [
        {
          'name': 'Спальня',
          'openingWidth': 800.0,
          'openingHeight': 2000.0,
          'canvasWidth': 700.0,
          'canvasHeight': 1960.0,
          'wallThick': 160.0,
          'boxWidth': 80.0,
          'boxDepth': 40.0,
          'doborWidth': 70.0,
          'architraveSize': '70 мм',
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
      ]
    }
  ];

  void _addNewOrder() {
    String newOrderNum = '№ 2026-00${orders.length + 1}';
    setState(() {
      orders.add({
        'orderNumber': newOrderNum,
        'clientName': 'Новий клієнт',
        'address': 'Адреса об\'єкта',
        'doors': []
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Список замовлень (проєктів)'),
      ),
      body: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          List doorsList = order['doors'];
          double orderTotal = doorsList.fold(0, (sum, d) => sum + (d['basePrice'] + d['extraPrice']));

          return Card(
            margin: EdgeInsets.all(8.0),
            elevation: 3,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.indigo,
                child: Icon(Icons.folder, color: Colors.white),
              ),
              title: Text('${order['orderNumber']} — ${order['clientName']}', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Адреса: ${order['address']}\nКількість дверей: ${doorsList.length} | Сума: ${orderTotal.toStringAsFixed(0)} грн'),
              isThreeLine: true,
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProjectDoorsScreen(orderData: order),
                  ),
                );
                setState(() {});
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewOrder,
        child: Icon(Icons.add),
        tooltip: 'Створити нове замовлення',
      ),
    );
  }
}

// 2. Екран списку дверей у конкретному замовленні
class ProjectDoorsScreen extends StatefulWidget {
  final Map<String, dynamic> orderData;
  ProjectDoorsScreen({required this.orderData});

  @override
  _ProjectDoorsScreenState createState() => _ProjectDoorsScreenState();
}

class _ProjectDoorsScreenState extends State<ProjectDoorsScreen> {
  late TextEditingController _clientController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _clientController = TextEditingController(text: widget.orderData['clientName']);
    _addressController = TextEditingController(text: widget.orderData['address']);
  }

  void _addNewDoor() {
    setState(() {
      widget.orderData['doors'].add({
        'name': 'Двері ${widget.orderData['doors'].length + 1}',
        'openingWidth': 800.0,
        'openingHeight': 2000.0,
        'canvasWidth': 700.0,
        'canvasHeight': 1960.0,
        'wallThick': 100.0,
        'boxWidth': 80.0,
        'boxDepth': 40.0,
        'doborWidth': 0.0,
        'architraveSize': '70 мм',
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
    List doorsList = widget.orderData['doors'];
    double totalProjectPrice = doorsList.fold(0, (sum, item) => sum + (item['basePrice'] + item['extraPrice']));

    return Scaffold(
      appBar: AppBar(
        title: Text('Замовлення: ${widget.orderData['orderNumber']}'),
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
      body: Column(
        children: [
          // Інформація про клієнта
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _clientController,
                    decoration: InputDecoration(labelText: 'Ім\'я клієнта'),
                    onChanged: (val) => widget.orderData['clientName'] = val,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _addressController,
                    decoration: InputDecoration(labelText: 'Адреса об\'єкта'),
                    onChanged: (val) => widget.orderData['address'] = val,
                  ),
                ),
              ],
            ),
          ),
          Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: doorsList.length,
              itemBuilder: (context, index) {
                final door = doorsList[index];
                double doorTotal = (door['basePrice'] as double) + (door['extraPrice'] as double);
                
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blueAccent,
                      child: Icon(Icons.door_sliding, color: Colors.white),
                    ),
                    title: Text(door['name'], style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      'Полотно: ${door['canvasWidth']}x${door['canvasHeight']} мм | Лиштва: ${door['architraveSize']}\nМонтаж: ${doorTotal.toStringAsFixed(0)} грн',
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
                          doorsList[index] = updatedDoor;
                        });
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewDoor,
        child: Icon(Icons.add),
        tooltip: 'Додати двері в замовлення',
      ),
    );
  }
}

// 3. Екран редагування дверей, розмірів полотна та лиштви
class EditDoorScreen extends StatefulWidget {
  final Map<String, dynamic> doorData;
  EditDoorScreen({required this.doorData});

  @override
  _EditDoorScreenState createState() => _EditDoorScreenState();
}

class _EditDoorScreenState extends State<EditDoorScreen> {
  late TextEditingController _nameController;
  late TextEditingController _openWidthController;
  late TextEditingController _openHeightController;
  late TextEditingController _canvasWidthController;
  late TextEditingController _canvasHeightController;
  late TextEditingController _wallController;
  late TextEditingController _boxWidthController;
  late TextEditingController _boxDepthController;
  late TextEditingController _doborWidthController;
  
  String _architraveSize = '70 мм';
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
    _openWidthController = TextEditingController(text: widget.doorData['openingWidth'].toString());
    _openHeightController = TextEditingController(text: widget.doorData['openingHeight'].toString());
    _canvasWidthController = TextEditingController(text: widget.doorData['canvasWidth'].toString());
    _canvasHeightController = TextEditingController(text: widget.doorData['canvasHeight'].toString());
    _wallController = TextEditingController(text: widget.doorData['wallThick'].toString());
    _boxWidthController = TextEditingController(text: widget.doorData['boxWidth'].toString());
    _boxDepthController = TextEditingController(text: widget.doorData['boxDepth'].toString());
    _doborWidthController = TextEditingController(text: widget.doorData['doborWidth'].toString());
    
    _architraveSize = widget.doorData['architraveSize'] ?? '70 мм';
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

  @override
  Widget build(BuildContext context) {
    double cWidth = double.tryParse(_canvasWidthController.text) ?? 700;
    double cHeight = double.tryParse(_canvasHeightController.text) ?? 1960;
    double oWidth = double.tryParse(_openWidthController.text) ?? 800;
    double oHeight = double.tryParse(_openHeightController.text) ?? 2000;
    double wall = double.tryParse(_wallController.text) ?? 100;
    double boxW = double.tryParse(_boxWidthController.text) ?? 80;
    double doborW = double.tryParse(_doborWidthController.text) ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text('Параметри дверей та прорізу'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              widget.doorData['name'] = _nameController.text;
              widget.doorData['openingWidth'] = oWidth;
              widget.doorData['openingHeight'] = oHeight;
              widget.doorData['canvasWidth'] = cWidth;
              widget.doorData['canvasHeight'] = cHeight;
              widget.doorData['wallThick'] = wall;
              widget.doorData['boxWidth'] = boxW;
              widget.doorData['boxDepth'] = double.tryParse(_boxDepthController.text) ?? 40;
              widget.doorData['doborWidth'] = doborW;
              widget.doorData['architraveSize'] = _architraveSize;
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
          
          Text('Розміри дверного полотна (мм)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Row(
            children: [
              Expanded(child: TextField(controller: _canvasWidthController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Ширина полотна'), onChanged: (v) => setState(() {}))),
              SizedBox(width: 10),
              Expanded(child: TextField(controller: _canvasHeightController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Висота полотна'), onChanged: (v) => setState(() {}))),
            ],
          ),
          SizedBox(height: 16),

          Text('Розміри прорізу (мм)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Row(
            children: [
              Expanded(child: TextField(controller: _openWidthController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Ширина прорізу'), onChanged: (v) => setState(() {}))),
              SizedBox(width: 10),
              Expanded(child: TextField(controller: _openHeightController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Висота прорізу'), onChanged: (v) => setState(() {}))),
              SizedBox(width: 10),
              Expanded(child: TextField(controller: _wallController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Товщ. стіни'), onChanged: (v) => setState(() {}))),
            ],
          ),
          SizedBox(height: 16),
          
          Text('Коробка, добір та лиштва', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Row(
            children: [
              Expanded(child: TextField(controller: _boxWidthController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Ширина коробки'), onChanged: (v) => setState(() {}))),
              SizedBox(width: 10),
              Expanded(child: TextField(controller: _boxDepthController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Товщина коробки'), onChanged: (v) => setState(() {}))),
              SizedBox(width: 10),
              Expanded(child: TextField(controller: _doborWidthController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Ширина добору'), onChanged: (v) => setState(() {}))),
            ],
          ),
          SizedBox(height: 12),
          
          // Вибір розміру лиштви (крило)
          DropdownButtonFormField<String>(
            value: _architraveSize,
            decoration: InputDecoration(labelText: 'Розмір лиштви (крило)'),
            items: ['30 мм', '50 мм', '70 мм'].map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
            onChanged: (val) => setState(() => _architraveSize = val!),
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
          
          // Візуальне 2D креслення з розмірами полотна та отвору
          Text('Візуальне 2D креслення', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                canvasWidth: cWidth,
                canvasHeight: cHeight,
                wallThick: wall,
                boxWidth: boxW,
                doborWidth: doborW,
                architraveSize: _architraveSize,
                openSide: _openSide,
                openType: _openType,
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

// 2D Креслення з параметрами полотна та лиштви
class DetailedDoorPainter extends CustomPainter {
  final double canvasWidth;
  final double canvasHeight;
  final double wallThick;
  final double boxWidth;
  final double doborWidth;
  final String architraveSize;
  final String openSide;
  final String openType;

  DetailedDoorPainter({
    required this.canvasWidth,
    required this.canvasHeight,
    required this.wallThick,
    required this.boxWidth,
    required this.doborWidth,
    required this.architraveSize,
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

    final double rectLeft = size.width * 0.25;
    final double rectTop = size.height * 0.2;
    final double rectWidth = size.width * 0.5;
    final double rectHeight = size.height * 0.6;

    final rect = Rect.fromLTWH(rectLeft, rectTop, rectWidth, rectHeight);
    canvas.drawRect(rect, paintWall);

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

    void drawDimension(String text, double x, double y, {bool vertical = false}) {
      paintText.text = TextSpan(
        text: text,
        style: TextStyle(color: Colors.black87, fontSize: 10, fontWeight: FontWeight.bold),
      );
      paintText.layout();
      canvas.save();
      canvas.translate(x, y);
      if (vertical) {
        canvas.rotate(-3.1415926535897932 / 2);
      }
      paintText.paint(canvas, Offset(-paintText.width / 2, -paintText.height / 2));
      canvas.restore();
    }

    drawDimension('Полотно: ${canvasWidth.toStringAsFixed(0)} мм', rect.center.dx, rect.bottom + 15);
    drawDimension('Лиштва: $architraveSize | Добір: ${doborWidth.toStringAsFixed(0)}мм', rect.center.dx, rect.top - 15);
    drawDimension('Висота: ${canvasHeight.toStringAsFixed(0)} мм', rect.left - 22, rect.center.dy, vertical: true);
    drawDimension('Стіна: ${wallThick.toStringAsFixed(0)} мм', rect.right + 22, rect.center.dy, vertical: true);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
