import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stocky/widgets/custom_text_field.dart';
import 'package:stocky/widgets/date_piecker_field.dart';
import 'package:stocky/widgets/error_message.dart';
import 'package:stocky/widgets/form_action_buttons.dart';
import 'package:stocky/widgets/label_widget.dart';
import 'package:stocky/widgets/page_header_icon.dart';
import 'package:stocky/widgets/quantity_selector.dart';
import '../../viewmodels/add_product_viewmodel.dart';
import '../../services/hive_service.dart';

class AddProductView extends StatelessWidget {
  final HiveService hiveService;

  const AddProductView({super.key, required this.hiveService});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddProductViewModel(hiveService),
      child: const AddProductContent(),
    );
  }
}

class AddProductContent extends StatefulWidget {
  const AddProductContent({super.key});

  @override
  State<AddProductContent> createState() => _AddProductContentState();
}

class _AddProductContentState extends State<AddProductContent> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AddProductViewModel>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Añadir Producto',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: vm.isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.green))
          : SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PageHeaderIcon(
                      icon: Icons.add_shopping_cart,
                      color: Colors.green,
                    ),
                    SizedBox(height: 24),

                    LabelWidget(text: 'NOMBRE DEL PRODUCTO'),
                    SizedBox(height: 8),
                    CustomTextField(
                      hint: 'Ej. Manzanas rojas',
                      onChanged: vm.updateName,
                      prefixIcon: Icons.shopping_bag_outlined,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Este campo es obligatorio';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),

                    LabelWidget(text: 'CANTIDAD'),
                    SizedBox(height: 8),
                    QuantitySelector(
                      quantity: vm.quantity,
                      onIncrement: vm.incrementQuantity,
                      onDecrement: vm.decrementQuantity,
                    ),
                    SizedBox(height: 20),

                    LabelWidget(text: 'FECHA DE VENCIMIENTO'),
                    SizedBox(height: 8),
                    DatePickerField(
                      selectedDate: vm.expiryDate,
                      onDateSelected: vm.updateExpiryDate,
                    ),
                    SizedBox(height: 20),

                    LabelWidget(text: 'DESCRIPCIÓN (OPCIONAL)'),
                    SizedBox(height: 8),
                    CustomTextField(
                      hint: 'Notas adicionales...',
                      onChanged: vm.updateDescription,
                      maxLines: 4,
                      isOptional: true,
                    ),
                    SizedBox(height: 20),

                    if (vm.errorMessage != null) ...[
                      ErrorMessage(message: vm.errorMessage!),
                      SizedBox(height: 20),
                    ],

                    FormActionButtons(
                      onCancel: () {
                        vm.resetForm();
                        Navigator.pop(context);
                      },
                      onSave: () async {
                        if (_formKey.currentState!.validate()) {
                          final success = await vm.saveProduct();
                          if (success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 8),
                                    Text('Producto guardado'),
                                  ],
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                            Navigator.pop(context, true);
                          }
                        }
                      },
                      isLoading: vm.isLoading,
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }
}
