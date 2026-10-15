import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:vector_math/vector_math_64.dart' as vmath;

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
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFFC8A278),
          primary: Color(0xFF8D6E63),
          secondary: Color(0xFFD7CCC8),
          surface: Color(0xFFFAF7F2),
        ),
        scaffoldBackgroundColor: Color(0xFFF7F4EF),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF8D6E63),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        cardTheme: CardThemeData(
          color: Color(0xFFFFFFFF),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFFFFFDF9),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFFD7CCC8)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFFD7CCC8)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFF8D6E63), width: 2),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF8D6E63),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
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
          'openingWidthTop': 805.0,
          'openingWidthMid': 800.0,
          'openingWidthBottom': 802.0,
          'openingHeightLeft': 2010.0,
          'openingHeightRight': 2005.0,
          'wallThickTop': 160.0,
          'wallThickBottom': 165.0,
          'canvasWidth': 700.0,
          'canvasHeight': 1960.0,
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
        title: Text('Каталог Замовлень', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(12),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          List doorsList = order['doors'];
          double orderTotal = doorsList.fold(0, (sum, d) => sum + (d['basePrice'] + d['extraPrice']));

          return Container(
            margin: EdgeInsets.symmetric(vertical: 6),
            child: Card(
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: Color(0xFFD7CCC8),
                  child: Icon(Icons.folder_open, color: Color(0xFF5D4037)),
                ),
                title: Text('${order['orderNumber']} — ${order['clientName']}', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
                subtitle: Text('Адреса: ${order['address']}\nДверей: ${doorsList.length} | Сума: ${orderTotal.toStringAsFixed(0)} грн', style: TextStyle(color: Color(0xFF6D4C41))),
                isThreeLine: true,
                trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF8D6E63)),
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
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF8D6E63),
        foregroundColor: Colors.white,
        onPressed: _addNewOrder,
        child: Icon(Icons.add),
        tooltip: 'Створити нове замовлення',
      ),
    );
  }
}

// 2. Екран списку дверей у замовленні
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
        'openingWidthTop': 800.0,
        'openingWidthMid': 800.0,
        'openingWidthBottom': 800.0,
        'openingHeightLeft': 2000.0,
        'openingHeightRight': 2000.0,
        'wallThickTop': 100.0,
        'wallThickBottom': 100.0,
        'canvasWidth': 700.0,
        'canvasHeight': 1960.0,
        'boxWidth': 80.0,
        'boxDepth': 40.0,
        'doborWidth': 70.0,
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

  void _exportToWordDialog() {
    String htmlContent = "Замовлення: ${widget.orderData['orderNumber']}\nКлієнт: ${widget.orderData['clientName']}\nАдреса: ${widget.orderData['address']}\n\n";
    List doorsList = widget.orderData['doors'];
    for (var d in doorsList) {
      htmlContent += "--- Приміщення: ${d['name']} ---\n";
      htmlContent += "Полотно: ${d['canvasWidth']}x${d['canvasHeight']} мм\n";
      htmlContent += "Проріз верх/серед/низ: ${d['openingWidthTop']}/${d['openingWidthMid']}/${d['openingWidthBottom']} мм\n";
      htmlContent += "Висота ліво/право: ${d['openingHeightLeft']}/${d['openingHeightRight']} мм\n";
      htmlContent += "Стіна верх/низ: ${d['wallThickTop']}/${d['wallThickBottom']} мм\n";
      htmlContent += "Лиштва крило: ${d['architraveSize']}, Відкривання: ${d['openSide']}, ${d['openType']}\n";
      htmlContent += "Монтаж: ${d['basePrice'] + d['extraPrice']} грн\n\n";
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Експорт замовлення'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Text(
              'Скопіюйте замовлення та вставте його в Microsoft Word (або надішліть клієнту):\n\n$htmlContent',
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: htmlContent));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Скопійовано в буфер обміну!')));
            },
            child: Text('Копіювати текст', style: TextStyle(color: Color(0xFF8D6E63))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Закрити', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List doorsList = widget.orderData['doors'];
    double totalProjectPrice = doorsList.fold(0, (sum, item) => sum + (item['basePrice'] + item['extraPrice']));

    return Scaffold(
      appBar: AppBar(
        title: Text('Проєкт: ${widget.orderData['orderNumber']}'),
        actions: [
          IconButton(
            icon: Icon(Icons.download_rounded),
            tooltip: 'Експорт у Word',
            onPressed: _exportToWordDialog,
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                '${totalProjectPrice.toStringAsFixed(0)} грн',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFD7CCC8)),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12.0),
            color: Color(0xFFEFEBE9),
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
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(12),
              itemCount: doorsList.length,
              itemBuilder: (context, index) {
                final door = doorsList[index];
                double doorTotal = (door['basePrice'] as double) + (door['extraPrice'] as double);
                
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: Color(0xFFD7CCC8),
                      child: Icon(Icons.door_sliding_rounded, color: Color(0xFF5D4037)),
                    ),
                    title: Text(door['name'], style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
                    subtitle: Text(
                      'Полотно: ${door['canvasWidth']}x${door['canvasHeight']} мм | Лиштва: ${door['architraveSize']}\nМонтаж: ${doorTotal.toStringAsFixed(0)} грн',
                      style: TextStyle(color: Color(0xFF6D4C41)),
                    ),
                    isThreeLine: true,
                    trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF8D6E63)),
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
        backgroundColor: Color(0xFF8D6E63),
        foregroundColor: Colors.white,
        onPressed: _addNewDoor,
        child: Icon(Icons.add),
        tooltip: 'Додати двері в замовлення',
      ),
    );
  }
}

// 3. Екран редагування з 3 вкладками
class EditDoorScreen extends StatefulWidget {
  final Map<String, dynamic> doorData;
  EditDoorScreen({required this.doorData});

  @override
  _EditDoorScreenState createState() => _EditDoorScreenState();
}

class _EditDoorScreenState extends State<EditDoorScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  late TextEditingController _nameController;
  late TextEditingController _opTopController;
  late TextEditingController _opMidController;
  late TextEditingController _opBotController;
  late TextEditingController _opHLeftController;
  late TextEditingController _opHRightController;
  late TextEditingController _wallTopController;
  late TextEditingController _wallBotController;
  late TextEditingController _canvasWidthController;
  late TextEditingController _canvasHeightController;
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

  double _rotateX = 0.0;
  double _rotateY = 0.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    _nameController = TextEditingController(text: widget.doorData['name']);
    _opTopController = TextEditingController(text: widget.doorData['openingWidthTop'].toString());
    _opMidController = TextEditingController(text: widget.doorData['openingWidthMid'].toString());
    _opBotController = TextEditingController(text: widget.doorData['openingWidthBottom'].toString());
    _opHLeftController = TextEditingController(text: widget.doorData['openingHeightLeft'].toString());
    _opHRightController = TextEditingController(text: widget.doorData['openingHeightRight'].toString());
    _wallTopController = TextEditingController(text: widget.doorData['wallThickTop'].toString());
    _wallBotController = TextEditingController(text: widget.doorData['wallThickBottom'].toString());
    
    _canvasWidthController = TextEditingController(text: widget.doorData['canvasWidth'].toString());
    _canvasHeightController = TextEditingController(text: widget.doorData['canvasHeight'].toString());
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
    double opTop = double.tryParse(_opTopController.text) ?? 800;
    double opMid = double.tryParse(_opMidController.text) ?? 800;
    double opBot = double.tryParse(_opBotController.text) ?? 800;
    double opHLeft = double.tryParse(_opHLeftController.text) ?? 2000;
    double opHRight = double.tryParse(_opHRightController.text) ?? 2000;
    double wallTop = double.tryParse(_wallTopController.text) ?? 100;
    double wallBot = double.tryParse(_wallBotController.text) ?? 100;
    double boxW = double.tryParse(_boxWidthController.text) ?? 80;
    double boxD = double.tryParse(_boxDepthController.text) ?? 40;
    double doborW = double.tryParse(_doborWidthController.text) ?? 70;
    int hCount = int.tryParse(_hingeCount) ?? 3;

    double avgHeight = (opHLeft + opHRight) / 2;
    double avgWidth = (opTop + opMid + opBot) / 3;
    double avgWall = (wallTop + wallBot) / 2;

    double boxMeters = (avgHeight * 2 + avgWidth) / 1000 * 1.1;
    double architravePieces = 6.0;
    bool needsDobor = avgWall > 90.0;
    double doborMeters = needsDobor ? (avgHeight * 2 + avgWidth) / 1000 * 1.1 : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text('Конфігурація Дверей'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Color(0xFFD7CCC8),
          labelColor: Colors.white,
          unselectedLabelColor: Color(0xFFD7CCC8),
          tabs: [
            Tab(text: '3D Полотно', icon: Icon(Icons.door_sliding_rounded)),
            Tab(text: '3D Проріз', icon: Icon(Icons.architecture_rounded)),
            Tab(text: 'Калькулятор', icon: Icon(Icons.calculate_rounded)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.save_rounded),
            onPressed: () {
              widget.doorData['name'] = _nameController.text;
              widget.doorData['openingWidthTop'] = opTop;
              widget.doorData['openingWidthMid'] = opMid;
              widget.doorData['openingWidthBottom'] = opBot;
              widget.doorData['openingHeightLeft'] = opHLeft;
              widget.doorData['openingHeightRight'] = opHRight;
              widget.doorData['wallThickTop'] = wallTop;
              widget.doorData['wallThickBottom'] = wallBot;
              widget.doorData['canvasWidth'] = cWidth;
              widget.doorData['canvasHeight'] = cHeight;
              widget.doorData['boxWidth'] = boxW;
              widget.doorData['boxDepth'] = boxD;
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
      body: TabBarView(
        controller: _tabController,
        children: [
          // Вкладка 1: 3D Полотно + Коробка, Лиштва, Добір
          ListView(
            padding: EdgeInsets.all(16.0),
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Назва приміщення'),
              ),
              SizedBox(height: 16),
              Text('Візуалізація полотна (вигляд з коридору)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF3E2723))),
              SizedBox(height: 8),
              Container(
                height: 280,
                decoration: BoxDecoration(
                  color: Color(0xFFFFFDF9),
                  border: Border.all(color: Color(0xFFD7CCC8), width: 1.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: CustomPaint(
                  painter: True3DCanvasPainter(
                    canvasWidth: cWidth,
                    canvasHeight: cHeight,
                    wallDepth: avgWall,
                    openAngle: 45.0,
                    openSide: _openSide,
                    openType: _openType,
                    hingeCount: hCount,
                    hasHandle: _hasHandle,
                    hasLatch: _hasLatch,
                    hasKey: _hasKey,
                  ),
                ),
              ),
              SizedBox(height: 20),
              
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
                      decoration: InputDecoration(labelText: 'Тип'),
                      items: ['Зовнішнє', 'Внутрішнє'].map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
                      onChanged: (val) => setState(() => _openType = val!),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              Text('Розміри полотна (мм)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF3E2723))),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: TextField(controller: _canvasWidthController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Ширина'), onChanged: (v) => setState(() {}))),
                  SizedBox(width: 10),
                  Expanded(child: TextField(controller: _canvasHeightController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Висота'), onChanged: (v) => setState(() {}))),
                ],
              ),
              SizedBox(height: 20),

              Text('Коробка, лиштва та добір', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF3E2723))),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: TextField(controller: _boxWidthController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Ширина коробки'), onChanged: (v) => setState(() {}))),
                  SizedBox(width: 10),
                  Expanded(child: TextField(controller: _boxDepthController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Глибина коробки'), onChanged: (v) => setState(() {}))),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _architraveSize,
                      decoration: InputDecoration(labelText: 'Розмір лиштви'),
                      items: ['30 мм', '50 мм', '70 мм'].map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
                      onChanged: (val) => setState(() => _architraveSize = val!),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _doborWidthController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: 'Ширина добору (мм)'),
                      onChanged: (v) => setState(() {}),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              Text('Фурнітура', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF3E2723))),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _hingeType,
                decoration: InputDecoration(labelText: 'Вид петель'),
                items: ['Приховані', 'Бабочки', 'Врізні карткові', 'Штирові'].map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
                onChanged: (val) => setState(() => _hingeType = val!),
              ),
              SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _hingeCount,
                decoration: InputDecoration(labelText: 'Кількість петель'),
                items: ['2', '3', '4'].map((val) => DropdownMenuItem(value: val, child: Text('$val шт.'))).toList(),
                onChanged: (val) => setState(() => _hingeCount = val!),
              ),
              SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _lockType,
                decoration: InputDecoration(labelText: 'Вид замка'),
                items: ['Магнітний', 'Механічний (язичок)', 'Під циліндр'].map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
                onChanged: (val) => setState(() => _lockType = val!),
              ),
              CheckboxListTile(
                title: Text('Отвори під ручку', style: TextStyle(color: Color(0xFF3E2723))),
                value: _hasHandle,
                activeColor: Color(0xFF8D6E63),
                onChanged: (val) => setState(() => _hasHandle = val!),
              ),
              CheckboxListTile(
                title: Text('Отвори під фіксатор (санвузол)', style: TextStyle(color: Color(0xFF3E2723))),
                value: _hasLatch,
                activeColor: Color(0xFF8D6E63),
                onChanged: (val) => setState(() => _hasLatch = val!),
              ),
              CheckboxListTile(
                title: Text('Отвори під ключ (циліндр)', style: TextStyle(color: Color(0xFF3E2723))),
                value: _hasKey,
                activeColor: Color(0xFF8D6E63),
                onChanged: (val) => setState(() => _hasKey = val!),
              ),
              SizedBox(height: 20),
              Text('Вартість робіт (грн)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF3E2723))),
              SizedBox(height: 8),
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Базова вартість монтажу'),
                controller: TextEditingController(text: _basePrice.toString()),
                onChanged: (val) => _basePrice = double.tryParse(val) ?? 0,
              ),
              SizedBox(height: 12),
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Додаткові роботи'),
                controller: TextEditingController(text: _extraPrice.toString()),
                onChanged: (val) => _extraPrice = double.tryParse(val) ?? 0,
              ),
            ],
          ),

          // Вкладка 2: 3D Проріз
          ListView(
            padding: EdgeInsets.all(16.0),
            children: [
              Text('Обертайте пальцем для огляду 3D-прорізу', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF3E2723))),
              SizedBox(height: 8),
              GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    _rotateY += details.delta.dx * 0.015;
                    _rotateX -= details.delta.dy * 0.015;
                  });
                },
                child: Container(
                  height: 300,
                  decoration: BoxDecoration(
                    color: Color(0xFFEFEBE9),
                    border: Border.all(color: Color(0xFFD7CCC8), width: 1.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Transform(
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateX(_rotateX)
                        ..rotateY(_rotateY),
                      alignment: Alignment.center,
                      child: CustomPaint(
                        size: Size(250, 250),
                        painter: True3DOpeningPainter(
                          opTop: opTop,
                          opMid: opMid,
                          opBot: opBot,
                          opHLeft: opHLeft,
                          opHRight: opHRight,
                          wallTop: wallTop,
                          wallBot: wallBot,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Center(
                child: TextButton.icon(
                  onPressed: () => setState(() { _rotateX = 0.0; _rotateY = 0.0; }),
                  icon: Icon(Icons.refresh_rounded, color: Color(0xFF8D6E63)),
                  label: Text('Скинути ракурс', style: TextStyle(color: Color(0xFF8D6E63))),
                ),
              ),
              SizedBox(height: 10),

              Text('Ширина прорізу (мм)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF3E2723))),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: TextField(controller: _opTopController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Зверху'), onChanged: (v) => setState(() {}))),
                  SizedBox(width: 8),
                  Expanded(child: TextField(controller: _opMidController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Посер'), onChanged: (v) => setState(() {}))),
                  SizedBox(width: 8),
                  Expanded(child: TextField(controller: _opBotController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Знизу'), onChanged: (v) => setState(() {}))),
                ],
              ),
              SizedBox(height: 16),

              Text('Висота прорізу (мм)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF3E2723))),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: TextField(controller: _opHLeftController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Зліва'), onChanged: (v) => setState(() {}))),
                  SizedBox(width: 10),
                  Expanded(child: TextField(controller: _opHRightController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Справа'), onChanged: (v) => setState(() {}))),
                ],
              ),
              SizedBox(height: 16),

              Text('Товщина стіни (мм)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF3E2723))),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: TextField(controller: _wallTopController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Зверху'), onChanged: (v) => setState(() {}))),
                  SizedBox(width: 10),
                  Expanded(child: TextField(controller: _wallBotController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Знизу'), onChanged: (v) => setState(() {}))),
                ],
              ),
            ],
          ),

          // Вкладка 3: Калькулятор матеріалів
          ListView(
            padding: EdgeInsets.all(16.0),
            children: [
              Text('Розрахунок матеріалів за розмірами отвору', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF3E2723))),
              SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Дверна коробка:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                          Text('${boxMeters.toStringAsFixed(2)} м.п.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF8D6E63))),
                        ],
                      ),
                      Text('Функція: тримає дверне полотно в отворі.', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      Divider(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Лиштва (на 2 боки):', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                          Text('${architravePieces.toStringAsFixed(0)} палок', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF8D6E63))),
                        ],
                      ),
                      Text('Функція: закриває монтажний шов навколо отвору ($_architraveSize).', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      Divider(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Добірна планка:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                          Text('${doborMeters.toStringAsFixed(2)} м.п. (${doborW.toStringAsFixed(0)} мм)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF8D6E63))),
                        ],
                      ),
                      Text('Функція: закриває стіну, якщо її товщина більша за коробку.', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      Divider(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Монтажна піна:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                          Text('~ 1.5 балона', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF8D6E63))),
                        ],
                      ),
                      Text('Функція: фіксація та герметизація коробки в отворі.', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFFEFEBE9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '💡 Розрахунок базується на введеній висоті (${avgHeight.toStringAsFixed(0)} мм), середній ширині (${avgWidth.toStringAsFixed(0)} мм) та товщині стіни (${avgWall.toStringAsFixed(0)} мм) із врахуванням технічного запасу 10%.',
                  style: TextStyle(color: Color(0xFF5D4037), fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// 3D Рендер полотна (вигляд з коридору з правильним позиціонуванням)
class True3DCanvasPainter extends CustomPainter {
  final double canvasWidth;
  final double canvasHeight;
  final double wallDepth;
  final double openAngle;
  final String openSide;
  final String openType;
  final int hingeCount;
  final bool hasHandle;
  final bool hasLatch;
  final bool hasKey;

  True3DCanvasPainter({
    required this.canvasWidth,
    required this.canvasHeight,
    required this.wallDepth,
    required this.openAngle,
    required this.openSide,
    required this.openType,
    required this.hingeCount,
    required this.hasHandle,
    required this.hasLatch,
    required this.hasKey,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paintBox = Paint()..color = Color(0xFF5D4037)..style = PaintingStyle.stroke..strokeWidth = 3.0;
    final paintCanvas = Paint()..color = Color(0xFF8D6E63)..style = PaintingStyle.stroke..strokeWidth = 2.0;
    final paintCanvasFill = Paint()..color = Color(0xFFD7CCC8).withOpacity(0.3);
    final paintHardware = Paint()..color = Color(0xFFD4AF37)..style = PaintingStyle.fill;
    final paintHole = Paint()..color = Color(0xFF3E2723)..style = PaintingStyle.fill;
    final paintText = TextPainter(textDirection: TextDirection.ltr);

    double cx = size.width / 2;
    double cy = size.height / 2;

    double maxDim = math.max(canvasWidth, canvasHeight);
    double scale = 150.0 / (maxDim > 0 ? maxDim : 1000.0);

    double w = canvasWidth * scale;
    double h = canvasHeight * scale;

    Rect boxRect = Rect.fromCenter(center: Offset(cx, cy), width: w + 10, height: h + 10);
    canvas.drawRect(boxRect, paintBox);

    canvas.save();
    bool isRight = (openSide == 'Праве');
    bool isExternal = (openType == 'Зовнішнє');

    // Вісь обертання та напрямок з коридору
    double pivotX = isRight ? boxRect.right : boxRect.left;
    double pivotY = boxRect.center.dy;

    canvas.translate(pivotX, pivotY);
    double rad = openAngle * math.pi / 180;
    
    // Коригування напрямку відкривання на себе з коридору
    double angleMultiplier = isRight ? 1.0 : -1.0;
    if (!isExternal) angleMultiplier *= -1.0;

    final vmath.Matrix4 matrix = vmath.Matrix4.identity()
      ..setEntry(3, 2, 0.002)
      ..rotateY(rad * angleMultiplier);
    canvas.transform(matrix.storage);

    // Геометрія полотна відносно осі
    double drawX = isRight ? -w : 0;
    Rect doorLeaf = Rect.fromLTWH(drawX, -h / 2 + 5, w, h - 10);
    canvas.drawRect(doorLeaf, paintCanvasFill);
    canvas.drawRect(doorLeaf, paintCanvas);

    // Петлі на правильній стороні
    for (int i = 0; i < hingeCount; i++) {
      double hY = (i - (hingeCount - 1) / 2) * (h / 3);
      double hingeXPos = isRight ? drawX + w - 5 : drawX + 5;
      canvas.drawCircle(Offset(hingeXPos, hY), 3.5, paintHardware);
    }

    // Ручка та отвори з протилежного від петель боку
    double handleX = isRight ? drawX + w * 0.25 : drawX + w * 0.75;
    if (hasHandle) {
      canvas.drawCircle(Offset(handleX, 0), 4.5, paintHardware);
    }
    if (hasLatch) {
      canvas.drawCircle(Offset(handleX, 25), 3.0, paintHole);
    }
    if (hasKey) {
      canvas.drawRect(Rect.fromCenter(center: Offset(handleX, 45), width: 3.5, height: 8), paintHole);
    }

    canvas.restore();

    void drawDim(String text, double x, double y) {
      paintText.text = TextSpan(text: text, style: TextStyle(color: Color(0xFF3E2723), fontSize: 10, fontWeight: FontWeight.bold));
      paintText.layout();
      paintText.paint(canvas, Offset(x - paintText.width / 2, y - paintText.height / 2));
    }

    drawDim('Полотно: ${canvasWidth.toStringAsFixed(0)} x ${canvasHeight.toStringAsFixed(0)} мм ($openSide, $openType)', cx, boxRect.bottom + 18);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// 3D Об'ємний проріз
class True3DOpeningPainter extends CustomPainter {
  final double opTop;
  final double opMid;
  final double opBot;
  final double opHLeft;
  final double opHRight;
  final double wallTop;
  final double wallBot;

  True3DOpeningPainter({
    required this.opTop,
    required this.opMid,
    required this.opBot,
    required this.opHLeft,
    required this.opHRight,
    required this.wallTop,
    required this.wallBot,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paintFront = Paint()..color = Color(0xFF6D4C41)..style = PaintingStyle.stroke..strokeWidth = 2.5;
    final paintBack = Paint()..color = Color(0xFFBCAAA4)..style = PaintingStyle.stroke..strokeWidth = 1.5;
    final paintDepthWall = Paint()..color = Color(0xFFD7CCC8).withOpacity(0.4)..style = PaintingStyle.fill;
    final paintDepthLine = Paint()..color = Color(0xFF8D6E63)..style = PaintingStyle.stroke..strokeWidth = 1.5;
    final paintText = TextPainter(textDirection: TextDirection.ltr);

    double cx = size.width / 2;
    double cy = size.height / 2;

    double maxW = math.max(math.max(opTop, opMid), opBot);
    double maxH = math.max(opHLeft, opHRight);
    double scaleW = 110.0 / (maxW > 0 ? maxW : 900.0);
    double scaleH = 130.0 / (maxH > 0 ? maxH : 2100.0);

    double wTop = opTop * scaleW;
    double wBot = opBot * scaleW;
    double hLeft = opHLeft * scaleH;
    double hRight = opHRight * scaleH;

    double avgWallThick = (wallTop + wallBot) / 2;
    double d = avgWallThick * scaleW * 0.45;

    Offset fTL = Offset(cx - wTop / 2, cy - hLeft / 2);
    Offset fTR = Offset(cx + wTop / 2, cy - hRight / 2);
    Offset fBR = Offset(cx + wBot / 2, cy + hRight / 2);
    Offset fBL = Offset(cx - wBot / 2, cy + hLeft / 2);

    Path frontPath = Path()
      ..moveTo(fTL.dx, fTL.dy)
      ..lineTo(fTR.dx, fTR.dy)
      ..lineTo(fBR.dx, fBR.dy)
      ..lineTo(fBL.dx, fBL.dy)
      ..close();

    Offset bTL = Offset(fTL.dx - d, fTL.dy - d * 0.5);
    Offset bTR = Offset(fTR.dx + d, fTR.dy - d * 0.5);
    Offset bBR = Offset(fBR.dx + d, fBR.dy - d * 0.5);
    Offset bBL = Offset(fBL.dx - d, fBL.dy - d * 0.5);

    Path backPath = Path()
      ..moveTo(bTL.dx, bTL.dy)
      ..lineTo(bTR.dx, bTR.dy)
      ..lineTo(bBR.dx, bBR.dy)
      ..lineTo(bBL.dx, bBL.dy)
      ..close();

    void drawWallSide(Offset f1, Offset f2, Offset b2, Offset b1) {
      Path sidePath = Path()
        ..moveTo(f1.dx, f1.dy)
        ..lineTo(f2.dx, f2.dy)
        ..lineTo(b2.dx, b2.dy)
        ..lineTo(b1.dx, b1.dy)
        ..close();
      canvas.drawPath(sidePath, paintDepthWall);
      canvas.drawPath(sidePath, paintDepthLine);
    }

    drawWallSide(fTL, fTR, bTR, bTL);
    drawWallSide(fTR, fBR, bBR, bTR);
    drawWallSide(fBR, fBL, bBL, bBR);
    drawWallSide(fBL, fTL, bTL, bBL);

    canvas.drawPath(backPath, paintBack);
    canvas.drawPath(frontPath, paintFront);

    void drawDim(String text, double x, double y) {
      paintText.text = TextSpan(text: text, style: TextStyle(color: Color(0xFF3E2723), fontSize: 9, fontWeight: FontWeight.bold));
      paintText.layout();
      paintText.paint(canvas, Offset(x - paintText.width / 2, y - paintText.height / 2));
    }

    drawDim('Зверху: ${opTop.toStringAsFixed(0)} мм', cx, cy - hLeft / 2 - 16);
    drawDim('Посер: ${opMid.toStringAsFixed(0)} мм', cx, cy);
    drawDim('Знизу: ${opBot.toStringAsFixed(0)} мм', cx, cy + hLeft / 2 + 18);
    
    drawDim('Стіна: ${avgWallThick.toStringAsFixed(0)} мм', bTR.dx + 25, bTR.dy);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
