import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uretim_monitoru/models/product.dart';
import 'package:uretim_monitoru/models/product_material.dart';
import 'package:uretim_monitoru/providers/product_material_provider.dart';
import 'package:uretim_monitoru/providers/product_provider.dart';

class AddProductPage extends ConsumerStatefulWidget {
  const AddProductPage({super.key});

  @override
  ConsumerState<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends ConsumerState<AddProductPage> {
  late final TextEditingController _productNameController;
  late final TextEditingController _productDailyTargetController;
  late final TextEditingController _productTotalTargetController;

  List<ProductMaterial> materials = [];
  List<ProductMaterialForm> materialForms = [];

  int _nextFormId = 0;

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _productNameController = TextEditingController();
    _productDailyTargetController = TextEditingController();
    _productTotalTargetController = TextEditingController();
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _productDailyTargetController.dispose();
    _productTotalTargetController.dispose();
    super.dispose();
  }

  void addMaterialForm() {
    final id = _nextFormId++;
    final form = ProductMaterialForm(
      key: ValueKey(id),
      addMaterial: addMaterial,
      removeMaterialForm: () => removeMaterialForm(ValueKey(id)),
    );
    setState(() => materialForms.add(form));
  }

  void removeMaterialForm(Key key) {
    setState(() {
      materialForms = materialForms.where((mf) => mf.key != key).toList();
    });
  }

  void addMaterial(ProductMaterial material) {
    setState(() {
      materials.add(material);
    });
  }

  void removeMaterial(int index) {
    setState(() {
      materials.removeAt(index);
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> addProduct() async {
    final product = Product(
      name: _productNameController.text,
      dailyTarget: int.parse(_productDailyTargetController.text),
      totalTarget: int.parse(_productTotalTargetController.text),
      image: _selectedImage,
    );

    int productId = await ref
        .read(productsProvider.notifier)
        .addProduct(product);
    print(productId);
    for (var m in materials) {
      await ref.read(productMaterialsProvider(productId).notifier).addMaterial(m);
    }
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Yeni Ürün', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Yeni Ürün Oluştur', style: TextStyle(fontSize: 20)),
            Text(
              'Üretim hedeflerini ve gerekli öğeleri yapılandırın.',
              style: TextStyle(color: Colors.grey),
            ),
            Container(
              margin: EdgeInsets.only(top: 16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: Colors.blue.shade600,
                        ),
                        child: Center(
                          child: Text(
                            '1',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Text(
                        'Ürün Bilgileri',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Ürün Adı',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        TextFormField(
                          controller: _productNameController,
                          keyboardType: TextInputType.name,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 16,
                            ),
                            hintText: 'Ürün Adı',
                            hintStyle: TextStyle(color: Colors.grey),
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.blue.shade600,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ürün adı boş olamaz';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Toplam Hedef Miktarı',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        TextFormField(
                          controller: _productTotalTargetController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 16,
                            ),
                            hintText: 'Örnek: 1000',
                            hintStyle: TextStyle(color: Colors.grey),
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.blue.shade600,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Toplam Hedef Miktarı boş olamaz';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Günlük Hedef Miktarı',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        TextFormField(
                          controller: _productDailyTargetController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 16,
                            ),
                            hintText: 'Örnek: 50',
                            hintStyle: TextStyle(color: Colors.grey),
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.blue.shade600,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Günlük Hedef Miktarı boş olamaz';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  GestureDetector(
                    onTap: _showImageSourceSheet,
                    child: DottedBorder(
                      options: RoundedRectDottedBorderOptions(
                        color: Colors.grey.shade400,
                        strokeWidth: 1.5,
                        dashPattern: [6, 3],
                        radius: Radius.circular(8),
                      ),
                      child: Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _selectedImage == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image_outlined,
                                    color: Colors.grey,
                                    size: 32,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Fotoğraf eklemek için dokun',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  _selectedImage!,
                                  fit: BoxFit.contain,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 35,
                            height: 35,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              color: Colors.blue.shade600,
                            ),
                            child: Center(
                              child: Text(
                                '2',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Text(
                            'Gerekli Malzemeler',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade500,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        onPressed: addMaterialForm,
                        icon: Icon(Icons.add),
                        label: Text('Ekle'),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  materials.isEmpty && materialForms.isEmpty
                      ? Container(
                          margin: EdgeInsets.only(
                            left: 16,
                            right: 16,
                            bottom: 16,
                          ),
                          padding: EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Container(
                                padding: EdgeInsets.all(16),
                                margin: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.blue.shade100,
                                  ),
                                ),
                                child: Icon(
                                  Icons.construction,
                                  color: Colors.blue.shade600,
                                  size: 40,
                                ),
                              ),
                              Text(
                                'Malzeme Henüz Eklenmedi',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Ürünün takibini sağlamak için gerekli malzemeleri ekleyin.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : Column(
                          children: [
                            ...materials.map((m) => _buildMaterialContainer(m)),
                            SizedBox(height: 16),
                            ...materialForms,
                          ],
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.blue.shade600,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              addProduct();
              Navigator.pop(context);
            }
          },
          child: Text('Ürün Oluştur'),
        ),
      ),
    );
  }

  Widget _buildMaterialContainer(ProductMaterial material) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 2,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            leading: SizedBox(
              width: 20,
              height: 20,
              child: material.image != null
                  ? Image.file(
                      material.image!,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.image_not_supported);
                      },
                    )
                  : const Icon(Icons.image_not_supported),
            ),
            title: Row(
              children: [
                Text(
                  material.name,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(color: Colors.grey.shade300),
                  child: Text(material.code, style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            trailing: IconButton(
              onPressed: () => removeMaterial(materials.indexOf(material)),
              icon: Icon(Icons.delete_outline, color: Colors.grey),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Divider(color: Colors.grey.shade300, height: 1),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Toplam', style: TextStyle(color: Colors.grey)),
                    SizedBox(height: 2),
                    Text(
                      '${material.totalPcs} birim',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Birim / Ürün', style: TextStyle(color: Colors.grey)),
                    SizedBox(height: 2),
                    Text(
                      '${material.pcsPerProduct} birim',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.photo_camera),
              title: Text('Kameradan çek'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Galeriden seç'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ProductMaterialForm extends StatefulWidget {
  const ProductMaterialForm({
    super.key,
    required this.addMaterial,
    required this.removeMaterialForm,
  });

  final void Function(ProductMaterial) addMaterial;
  final VoidCallback removeMaterialForm;

  @override
  State<ProductMaterialForm> createState() => _ProductMaterialFormState();
}

class _ProductMaterialFormState extends State<ProductMaterialForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _materialNameController;
  late final TextEditingController _materialCodeController;
  late final TextEditingController _materialPcsPerProductController;
  late final TextEditingController _materialTotalPcsController;

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _materialNameController = TextEditingController();
    _materialCodeController = TextEditingController();
    _materialPcsPerProductController = TextEditingController();
    _materialTotalPcsController = TextEditingController();
  }

  @override
  void dispose() {
    _materialNameController.dispose();
    _materialCodeController.dispose();
    _materialPcsPerProductController.dispose();
    _materialTotalPcsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.add_circle_outline_sharp, color: Colors.blue.shade600),
              SizedBox(width: 8),
              Text(
                'Malzeme Ekleyin',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue.shade600,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Malzeme Adı',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: _materialNameController,
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    hintText: 'Malzeme Adı',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue.shade600),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Malzeme adı boş olamaz';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                Text(
                  'Malzeme Kodu',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: _materialCodeController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    hintText: 'örnek: HL-123',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue.shade600),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Malzeme kodu boş olamaz';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                Text(
                  'Toplam Malzeme Sayısı',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: _materialTotalPcsController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    hintText: 'Örnek: 5000',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue.shade600),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Toplam malzeme sayısı boş olamaz';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                Text(
                  'Birim / Ürün',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: _materialPcsPerProductController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    hintText: 'Örnek: 2',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue.shade600),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Birim / Ürün boş olamaz';
                    }

                    if (int.parse(value) <= 0) {
                      return '0 veya negatif olamaz';
                    }

                    if (int.parse(value) >
                        int.parse(_materialTotalPcsController.text)) {
                      return 'Toplam malzeme sayısından büyük olamaz';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          GestureDetector(
            onTap: _showImageSourceSheet,
            child: DottedBorder(
              options: RoundedRectDottedBorderOptions(
                color: Colors.grey.shade400,
                strokeWidth: 1.5,
                dashPattern: [6, 3],
                radius: Radius.circular(8),
              ),
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _selectedImage == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_outlined,
                            color: Colors.grey,
                            size: 32,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Fotoğraf eklemek için dokun',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(_selectedImage!, fit: BoxFit.contain),
                      ),
              ),
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: widget.removeMaterialForm,
                child: Text('İptal Et', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue.shade600,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                onPressed: () => {
                  if (_formKey.currentState!.validate())
                    {
                      widget.addMaterial(
                        ProductMaterial(
                          name: _materialNameController.text,
                          code: _materialCodeController.text,
                          totalPcs: int.parse(
                            _materialTotalPcsController.text,
                          ),
                          pcsPerProduct: int.parse(
                            _materialPcsPerProductController.text,
                          ),
                          image: _selectedImage,
                        ),
                      ),
                      widget.removeMaterialForm(),
                    },
                },
                child: Text('Stoka Ekle'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.photo_camera),
              title: Text('Kameradan çek'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Galeriden seç'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }
}
