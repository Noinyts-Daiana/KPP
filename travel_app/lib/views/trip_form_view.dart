// lib/views/trip_form_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/manage_trip_bloc.dart';
import '../bloc/trip_list_bloc.dart';
import '../bloc/trip_list_event.dart';
import '../models/travel_models.dart';
import '../repositories/trips_repository.dart';

const Color primaryColor = Color(0xFF0D47A1); 
const Color accentColor = Color(0xFFF5F5F5); 

class TripFormView extends StatelessWidget {
  final Trip? initialTrip;

  TripFormView({super.key, this.initialTrip});

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _destinationController = TextEditingController();
  final _transportationController = TextEditingController();
  final _accommodationController = TextEditingController();
  final _budgetController = TextEditingController();

  final DateTime mockStartDate = DateTime.now().add(const Duration(days: 10));
  final DateTime mockEndDate = DateTime.now().add(const Duration(days: 20));

  void _initControllers() {
    if (initialTrip != null) {
      _nameController.text = initialTrip!.name;
      _destinationController.text = initialTrip!.destination;
      _transportationController.text = initialTrip!.transportation;
      _accommodationController.text = initialTrip!.accommodation;
      _budgetController.text = initialTrip!.budget.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    _initControllers();

    return BlocProvider(
      create: (ctx) => ManageTripBloc(ctx.read<TripsRepository>()),
      child: BlocListener<ManageTripBloc, ManageTripState>(
        listener: (listenerContext, state) {
          if (state is ManageTripSuccess) {
            ScaffoldMessenger.of(listenerContext).showSnackBar(
              SnackBar(
                  content: Text(initialTrip == null
                      ? 'Поїздку успішно створено!'
                      : 'Поїздку успішно оновлено!')),
            );
            // ❗ Ми використовуємо TripListBloc через BlocProvider.value
            listenerContext.read<TripListBloc>().add(const FetchTripsEvent());
            Navigator.of(listenerContext).pop();
          } else if (state is ManageTripFailure) {
            ScaffoldMessenger.of(listenerContext).showSnackBar(
              SnackBar(content: Text('Помилка: ${state.error}')),
            );
          }
        },
        child: Builder(
          builder: (builderContext) {
            return Container(
              height: MediaQuery.of(builderContext).size.height * 0.85,
              padding: EdgeInsets.fromLTRB(
                  20, 20, 20, MediaQuery.of(builderContext).viewInsets.bottom + 20),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      initialTrip == null ? 'НОВА ПОЇЗДКА' : 'РЕДАГУВАННЯ ПОЇЗДКИ',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold, color: primaryColor),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildTextField(_nameController, 'Назва поїздки', 'Обов\'язкове поле'),
                            _buildDateField(
                                'Дати',
                                '${mockStartDate.day} Apr, ${mockStartDate.year} - ${mockEndDate.day} Apr, ${mockEndDate.year}'),
                            _buildTextField(_destinationController, 'Місце призначення', 'Обов\'язкове поле'),
                            _buildTextField(_transportationController, 'Транспорт', 'Обов\'язкове поле'),
                            _buildTextField(_accommodationController, 'Проживання', 'Обов\'язкове поле'),
                            _buildNumericField(_budgetController, 'Бюджет', 'Введіть число'),
                          ],
                        ),
                      ),
                    ),
                    _buildActionButtons(builderContext),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String validationMessage) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: accentColor.withOpacity(0.5),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return validationMessage;
          }
          return null;
        },
      ),
    );
  }

  Widget _buildNumericField(TextEditingController controller, String label, String validationMessage) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: accentColor.withOpacity(0.5),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
        ),
        validator: (value) {
          if (value == null || double.tryParse(value) == null) {
            return 'Будь ласка, введіть дійсне число.';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDateField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: TextFormField(
        initialValue: value,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: accentColor.withOpacity(0.5),
          suffixIcon: const Icon(Icons.calendar_today, color: primaryColor),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final bloc = context.read<ManageTripBloc>();
    final isProcessing = context.select((ManageTripBloc b) => b.state is ManageTripProcessing);

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: isProcessing ? null : () => Navigator.pop(context),
          child: const Text('СКАСУВАТИ', style: TextStyle(color: primaryColor)),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: isProcessing
              ? null
              : () {
                  if (_formKey.currentState!.validate()) {
                    final tripToSave = Trip(
                      id: initialTrip?.id ?? '',
                      userId: '', // BLoC сам оновить UID
                      name: _nameController.text,
                      destination: _destinationController.text,
                      transportation: _transportationController.text,
                      accommodation: _accommodationController.text,
                      budget: double.tryParse(_budgetController.text) ?? 0.0,
                      startDate: mockStartDate,
                      endDate: mockEndDate,
                    );
                    bloc.add(SaveTripEvent(tripToSave, isNew: initialTrip == null));
                  }
                },
          style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
          child: isProcessing
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text(initialTrip == null ? 'ДОДАТИ' : 'ЗБЕРЕГТИ'),
        ),
      ],
    );
  }
}
