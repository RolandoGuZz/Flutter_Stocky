import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stocky/viewmodels/update_product_viewmodel.dart';
import 'package:stocky/widgets/confirmation_dialog.dart';
import 'package:stocky/widgets/custom_text_field.dart';
import 'package:stocky/widgets/date_piecker_field.dart';
import 'package:stocky/widgets/error_message.dart';
import 'package:stocky/widgets/form_action_buttons.dart';
import 'package:stocky/widgets/label_widget.dart';
import 'package:stocky/widgets/page_header_icon.dart';
import 'package:stocky/widgets/quantity_selector.dart';
import '../../services/hive_service.dart';
import '../../models/product.dart';

class UpdateProductView extends StatelessWidget {
  final HiveService hiveService;
  final Product product;

  const UpdateProductView({
    super.key,
    required this.hiveService,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UpdateProductViewModel(hiveService, product),
      child: const UpdateProductContent(),
    );
  }
}

class UpdateProductContent extends StatefulWidget {
  const UpdateProductContent({super.key});

  @override
  State<UpdateProductContent> createState() => _UpdateProductContentState();
}

class _UpdateProductContentState extends State<UpdateProductContent> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<UpdateProductViewModel>();
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Editar Producto',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.white),
            onPressed: () => _confirmDelete(context, vm),
          ),
        ],
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
                    PageHeaderIcon(icon: Icons.edit, color: Colors.green),
                    SizedBox(height: 24),

                    LabelWidget(text: 'NOMBRE DEL PRODUCTO'),
                    SizedBox(height: 8),
                    CustomTextField(
                      hint: 'Ej. Manzanas rojas',
                      onChanged: vm.updateName,
                      prefixIcon: Icons.shopping_bag_outlined,
                      initialValue: vm.name,
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
                      initialValue: vm.description,
                    ),
                    SizedBox(height: 20),

                    if (vm.errorMessage != null) ...[
                      ErrorMessage(message: vm.errorMessage!),
                      SizedBox(height: 20),
                    ],

                    FormActionButtons(
                      onCancel: () => Navigator.pop(context),
                      onSave: () async {
                        if (_formKey.currentState!.validate()) {
                          final success = await vm.updateProduct();
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
                                    Text('Producto actualizado'),
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
                      saveText: 'Actualizar',
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          vm.markAsUsed();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 8),
                                    Text('Producto usado'),
                                  ],
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                          Navigator.pop(context, true);
                        },
                        icon: Icon(
                          Icons.check,
                          fontWeight: FontWeight.bold,
                          size: 20,
                        ),
                        label: Text(
                          "Marcar como usado",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade100,
                          foregroundColor: Colors.green,
                          padding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    UpdateProductViewModel vm,
  ) async {
    final confirm = await showConfirmationDialog(
      context: context,
      title: 'Eliminar Producto',
      content: '¿Estás seguro de eliminar "${vm.name}" de tu despensa?',
    );

    if (confirm == true && context.mounted) {
      final success = await vm.deleteProduct();
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${vm.name} eliminado'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context, true);
      }
    }
  }
}
