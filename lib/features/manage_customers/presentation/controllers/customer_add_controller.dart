import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

import 'package:pos/core/enums.dart';
import 'package:pos/features/manage_customers/domain/usecases/create_customer_use_case.dart';
import 'package:pos/core/models/country_model.dart';
import 'package:pos/features/manage_customers/domain/entities/customer.dart';
import 'package:pos/core/utils/scaffold_message_utils.dart';
import 'package:flutter/services.dart' show rootBundle;

class CustomerAddController extends GetxController {
  /// Convenient static getter for the controller.
  static CustomerAddController get to => Get.find();

  // 1. Dependencies and final services
  final CreateCustomerUseCase _createCustomerUseCase;
  final ImagePicker _picker = ImagePicker();

  CustomerAddController({
    required this._createCustomerUseCase,
  });

  // 2. Observable states
  /// Observable file for the customer's profile photo.
  final Rx<File?> profilePhoto = Rx<File?>(null);

  /// Observable file for the customer's document.
  final Rx<File?> documentFile = Rx<File?>(null);

  /// Currently selected country ID.
  final RxInt selectedCountryId = 0.obs;

  /// Currently selected customer type (local / foreigner).
  final RxString selectedCustomerType = CustomerType.local.value.obs;

  /// Currently selected customer gender.
  final RxString selectedGender = GenderType.male.value.obs;

  /// Currently selected membership level.
  final RxString selectedMembershipLevel = MembershipLevel.bronze.value.obs;

  /// List of available countries fetched from JSON.
  final RxList<CountryModel> countries = <CountryModel>[].obs;

  /// Indicates if a saving/adding network operation is in progress.
  final RxBool isLoading = false.obs;

  /// Indicates if the customer was successfully added.
  final RxBool isAdded = false.obs;

  // 3. Form and Text Controllers
  /// Form key to validate input fields.
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// Text controller for the customer's name.
  final TextEditingController nameController = TextEditingController();

  /// Text controller for the customer's phone number.
  final TextEditingController phoneController = TextEditingController();

  /// Text controller for the customer's email.
  final TextEditingController emailController = TextEditingController();

  /// Text controller for the customer's NIC.
  final TextEditingController nicController = TextEditingController();

  /// Text controller for the customer's passport ID.
  final TextEditingController passportController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchCountries();

    ever(selectedCustomerType, (type) {
      if (type == CustomerType.local.value) {
        final sriLanka = countries
            .firstWhereOrNull((c) => c.name.toLowerCase() == 'sri lanka');
        if (sriLanka != null) {
          selectedCountryId.value = sriLanka.id;
        }
      }
    });
  }

  /// Picks an image from the specified [source] (camera or gallery) and updates [profilePhoto].
  Future<void> pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(
      source: source,
      imageQuality: 50,
      maxWidth: 800,
      maxHeight: 800,
    );
    if (image != null) {
      profilePhoto.value = File(image.path);
    }
  }

  /// Picks a document file (PDF or Image) and updates [documentFile].
  Future<void> pickDocument() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      );
      if (result.single.path != null) {
        documentFile.value = File(result.single.path!);
      }
    } catch (e) {
      ScaffoldMessageUtils.showError('Error picking document: $e');
    }
  }

  /// Fetches a list of countries from local assets.
  Future<void> fetchCountries() async {
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/json/countries.json',
      );
      final List<dynamic> jsonList = json.decode(jsonString);

      countries.value = jsonList
          .map((json) => CountryModel(
                // id: countries.length + 1, // Generate sequential IDs
                id: json['id'],
                name: json['name'],
                isoCode: json['iso_code'],
              ))
          .toList();

      // Set default country
      if (countries.isNotEmpty) {
        if (selectedCustomerType.value == CustomerType.local.value) {
          final sriLanka = countries
              .firstWhereOrNull((c) => c.name.toLowerCase() == 'sri lanka');
          if (sriLanka != null) {
            selectedCountryId.value = sriLanka.id;
          } else {
            selectedCountryId.value = countries.first.id;
          }
        } else {
          selectedCountryId.value = countries.first.id;
        }
      }
    } catch (e) {
      ScaffoldMessageUtils.showError(
          'Failed to load countries: ${e.toString()}');
    }
  }

  /// Submits the customer form data to create a new customer.
  Future<void> addCustomer() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isLoading.value = true;
      final customer = Customer(
        countryId: selectedCountryId.value,
        name: nameController.text,
        phone: phoneController.text,
        email: emailController.text,
        profilePhoto: profilePhoto.value?.path,
        customerType: selectedCustomerType.value,
        gender: selectedGender.value,
        nic: nicController.text,
        passportId: passportController.text,
        documentPhotoUrl: documentFile.value?.path,
        membershipLevel: selectedMembershipLevel.value,
      );

      final result = await _createCustomerUseCase.execute(customer);
      isAdded.value = true;
      log(result);
      Get.back(result: true);
      ScaffoldMessageUtils.showSuccess(result);
    } catch (e) {
      ScaffoldMessageUtils.showError(e.toString());
      log(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    nicController.dispose();
    passportController.dispose();

    super.onClose();
  }
}
